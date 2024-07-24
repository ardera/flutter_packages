import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:_ardera_common_libc_bindings/_ardera_common_libc_bindings.dart';
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart' as ffi;
import 'package:linux_spidev/linux_spidev.dart';
import 'package:linux_spidev/src/data.dart';
import 'package:linux_spidev/src/executor/messages.dart';

import 'package:linux_spidev/src/spidev.dart';
import 'package:linux_spidev/src/util.dart';
import 'package:meta/meta.dart';

extension WritePropsToStruct on SpiTransferProperties {
  void writeToStruct(spi_ioc_transfer struct) {
    struct.speed_hz = speedHz ?? 0;
    struct.delay_usecs = delay.inMicroseconds;
    struct.bits_per_word = bitsPerWord ?? 0;
    struct.cs_change = doToggleCS ? 1 : 0;
    struct.tx_nbits = switch (txTransferMode) {
      null => 0,
      SpiTransferMode mode => mode.bits
    };
    struct.rx_nbits = switch (rxTransferMode) {
      null => 0,
      SpiTransferMode mode => mode.bits
    };
    struct.word_delay_usecs = wordDelay.inMicroseconds;
  }
}

void spiTransferExecutorEntry((int, SendPort) channel) async {
  final (fd, sendPort) = channel;

  final receivePort = ReceivePort();

  sendPort.send(SendPortMessage(receivePort.sendPort));

  final dylib = ffi.DynamicLibrary.open("libc.so.6");
  final libc = LibC(dylib);

  await for (final ToExecutorMessage message in receivePort) {
    switch (message) {
      case StartTransferMessage(:final id, :final nTransfers, :final pointer):
        try {
          Timeline.startSync('SPI transfer');

          SpidevPlatformInterface.staticIoctl(
            libc,
            fd,
            SPI_IOC_MESSAGE(nTransfers),
            pointer,
          );

          Timeline.finishSync();

          final reply = TransferCompleteMessage.success(id: id);

          sendPort.send(reply);
        } on OSError catch (e, st) {
          final reply = TransferCompleteMessage.error(
            id: id,
            exception: e,
            stackTrace: st,
          );

          sendPort.send(reply);
        }

      case StopExecutorMessage _:
        receivePort.close();
        return;
    }
  }
}

class SpiTransferExecutor {
  SpiTransferExecutor(
    this.fd, {
    ffi.Allocator allocator = ffi.malloc,
  }) : _allocator = allocator {
    _startIsolate();
  }

  late Completer<SendPort> _toExecutorCompleter;
  final _finished = Completer.sync();
  late Future<SendPort> _toExecutor;
  final _pending = <int, Completer<void>>{};

  final int fd;

  var _running = false;
  bool get running => _running;

  var _nextTransferId = 0;
  final ffi.Allocator _allocator;

  void _startIsolate() {
    _toExecutorCompleter = Completer<SendPort>();
    _toExecutor = _toExecutorCompleter.future;

    final fromExecutor = ReceivePort();
    final isolateCompleter = Completer<Isolate>();

    final errorPort = ReceivePort()..listen(_onIsolateRuntimeError);
    final exitPort = ReceivePort()..listen(_onIsolateFinished);

    Isolate.spawn(
      spiTransferExecutorEntry,
      (
        fd,
        fromExecutor.sendPort,
      ),
      onError: errorPort.sendPort,
      onExit: exitPort.sendPort,
    ).then(
      (value) => isolateCompleter.complete(value),
      onError: _onIsolateSpawnError,
    );

    fromExecutor.listen(_onIsolateData);
  }

  @visibleForTesting
  Future<void> sendMessage(ToExecutorMessage message) async {
    final sendPort = await _toExecutor;
    sendPort.send(message);
  }

  void _onIsolateData(dynamic data) {
    final msg = data as FromExecutorMessage;

    switch (msg) {
      case TransferCompleteMessage(:final id):
        final transfer = _pending.remove(id)!;

        if (msg.errorMessage == null) {
          transfer.complete();
        } else {
          final error = RemoteError(msg.errorMessage!, msg.stackTrace ?? '');
          transfer.completeError(error, error.stackTrace);
        }

      case SendPortMessage(:final sendPort):
        if (!_toExecutorCompleter.isCompleted) {
          _toExecutorCompleter.complete(sendPort);
        }
    }
  }

  void _onIsolateRuntimeError(dynamic error) {
    assert(error is List);
    assert(error[0] is String);
    assert(error[1] is String);

    final constructedError = RemoteError(
      error[0] as String,
      error[1] as String,
    );

    _pending.values.forEach((value) => value.completeError(constructedError));
    _pending.clear();

    if (!_toExecutorCompleter.isCompleted) {
      _toExecutorCompleter.completeError(constructedError);
    }

    _running = false;
    _finished.complete();
  }

  void _onIsolateSpawnError(dynamic error) {
    assert(!_toExecutorCompleter.isCompleted);

    _toExecutorCompleter.completeError(error as Object);

    _running = false;
    _finished.complete();
  }

  void _onIsolateFinished(dynamic result) {
    final error = StateError(
      'SPI Transfer Executor Isolate exited prematurely. '
      'Transfer may or may not have been completed.',
    );

    _pending.values.forEach((transfer) {
      transfer.completeError(error);
    });

    if (!_toExecutorCompleter.isCompleted) {
      _toExecutorCompleter.completeError(error);
    }

    _running = false;
    _finished.complete();
  }

  Future<void> transfer(Iterable<SpiTransfer> transfers) async {
    if (!running) {
      throw StateError(
        'The SPI transfer executor is not running. '
        'It has either been stopped or exited unexpectedly due to errors.',
      );
    }

    final id = _nextTransferId++;

    // we can use a synchronous completer here because it's called as the last
    // step in _onIsolateData.
    final completer = Completer<void>.sync();

    // write all our transfers to a native spi_ioc_transfer array
    final pointer = _allocator<spi_ioc_transfer>(transfers.length);

    try {
      for (final (index, transfer) in transfers.indexed) {
        final struct = (pointer + index).ref;

        final (tx, rx, len) = transfer.startTransfer();
        final props = transfer.properties;

        struct.tx_buf = tx.address;
        struct.rx_buf = rx.address;
        struct.len = len;

        props.writeToStruct(struct);
      }

      _pending[id] = completer;

      final message = StartTransferMessage(
        id: id,
        nTransfers: transfers.length,
        pointer: pointer,
      );

      await sendMessage(message);

      return completer.future;
    } finally {
      _allocator.free(pointer);
    }
  }

  @visibleForTesting
  Future<void> sendStopMessage() async {
    sendMessage(StopExecutorMessage());
  }

  Future<void> close() async {
    if (!running) {
      throw StateError('The SPI transfer executor is not running.');
    }

    await sendStopMessage();

    await _finished.future;
    _running = false;
  }
}
