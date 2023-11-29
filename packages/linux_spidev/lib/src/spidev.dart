import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:ffi/ffi.dart' as ffi;
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:tuple/tuple.dart';
import 'package:_ardera_common_libc_bindings/_ardera_common_libc_bindings.dart';

import 'util.dart';

enum SpiMode { mode0, mode1, mode2, mode3 }

enum SpiFlag {
  csActiveHigh,
  lsbFirst,
  threeWire,
  loopBack,
  noCs,
  ready,
  txDual,
  txQuad,
  txOctal,
  rxDual,
  rxQuad,
  rxOctal,
  toggleCsAfterEachWord,
  threeWireHighImpedanceTurnaround
}

enum SpiTransferMode { single, dual, quad }

@immutable
class SpiTransfer<T extends SpiTransferData> {
  SpiTransfer({
    required this.data,
    SpiTransferProperties? properties,
  }) : this.properties = properties ?? SpiTransferProperties.defaultProperties;

  final T data;
  final SpiTransferProperties properties;
}

@immutable
abstract class SpiTransferData {
  SpiTransferData();

  factory SpiTransferData.fromNativeMem({ffi.Pointer? txPointer, ffi.Pointer? rxPointer, required int length}) {
    return NativeMemSpiTransferData._private(txPointer: txPointer ?? ffi.nullptr, rxPointer: rxPointer ?? ffi.nullptr, length: length);
  }

  factory SpiTransferData.fromTypedData({Uint8List? txBuf, Uint8List? rxBuf}) {
    return TypedDataSpiTransferData._private(txBuf: txBuf, rxBuf: rxBuf);
  }

  factory SpiTransferData.fromByteLists({List<int>? txBuf, List<int>? rxBuf}) {
    return ByteListSpiTransferData._private(txBuf: txBuf, rxBuf: rxBuf);
  }

  Tuple2<NativeMemSpiTransferData, void Function()> _toNativeMemTransferData();
}

@immutable
class NativeMemSpiTransferData extends SpiTransferData {
  final ffi.Pointer txPointer;
  final ffi.Pointer rxPointer;
  final int length;

  NativeMemSpiTransferData._private({required this.txPointer, required this.rxPointer, required this.length})
      : assert(txPointer != ffi.nullptr || rxPointer != ffi.nullptr);

  @override
  Tuple2<NativeMemSpiTransferData, void Function()> _toNativeMemTransferData() {
    return Tuple2(this, () {});
  }

  void _writeToStruct(spi_ioc_transfer struct) {
    struct.tx_buf = txPointer.address;
    struct.rx_buf = rxPointer.address;
    struct.len = length;
  }
}

@immutable
class TypedDataSpiTransferData extends SpiTransferData {
  /// data to be written. can be [null]
  final Uint8List? txBuf;

  /// data to be read. can be [null]
  final Uint8List? rxBuf;

  TypedDataSpiTransferData._private({this.txBuf, this.rxBuf})
      : assert(txBuf != null || rxBuf != null),
        assert((txBuf == null || rxBuf == null) || (txBuf.length == rxBuf.length));

  Tuple2<Map<Uint8List, ffi.Pointer>, Set<ffi.Pointer>> nativeMemFromOverlappingData(Set<Uint8List> data) {
    final start = data.map((v) => v.offsetInBytes).reduce(min);

    final end = data.map((v) => v.offsetInBytes + v.lengthInBytes).reduce(max);

    final length = end - start;

    final ptr = ffi.malloc.allocate<ffi.Uint8>(length);

    final ptrMap = <Uint8List, ffi.Pointer>{};
    final allocatedPtrs = <ffi.Pointer>{ptr};

    data.forEach((element) {
      ptrMap[element] = ptr.elementAt(element.offsetInBytes - start);
    });

    final result = Tuple2(ptrMap, allocatedPtrs);
    return result;
  }

  bool overlaps(Uint8List a, Uint8List b) {
    return (a.buffer == b.buffer) &&
        (((a.offsetInBytes >= b.offsetInBytes) && (a.offsetInBytes <= b.offsetInBytes + b.lengthInBytes)) ||
            ((b.offsetInBytes >= a.offsetInBytes) && (b.offsetInBytes <= a.offsetInBytes + a.lengthInBytes)));
  }

  Tuple2<Map<Uint8List /*!*/, ffi.Pointer>, Set<ffi.Pointer>> nativeMemFromByteDataOfSameBuffer(Set<Uint8List> data) {
    final nodes = Set.of(data);
    final edges = <Tuple2<Uint8List, Uint8List>>{};

    final ptrMap = <Uint8List, ffi.Pointer>{};
    final allocatedPtrs = <ffi.Pointer>{};

    final reflexiveRemainder = Set.of(data);
    for (final a in data) {
      reflexiveRemainder.remove(a);
      for (final b in reflexiveRemainder) {
        if (overlaps(a, b)) {
          edges.add(Tuple2(a, b));
          edges.add(Tuple2(b, a));
        }
      }
    }

    while (nodes.isNotEmpty) {
      final node = nodes.first;
      nodes.remove(node);

      final group = <Uint8List>{node};

      while (true) {
        Uint8List? other = null;
        for (final edge in edges) {
          if (group.contains(edge.item1)) {
            other = edge.item2;
            break;
          } else if (group.contains(edge.item2)) {
            other = edge.item1;
            break;
          }
        }

        if (other == null) {
          break;
        } else {
          group.add(other);
          edges.removeWhere((element) => element.item1 == other || element.item2 == other);
        }
      }

      final partialResult = nativeMemFromOverlappingData(group);
      ptrMap.addAll(partialResult.item1);
      allocatedPtrs.addAll(partialResult.item2);
    }

    final result = Tuple2(ptrMap, allocatedPtrs);
    return result;
  }

  Tuple2<Map<Uint8List, ffi.Pointer>, Set<ffi.Pointer>> nativeMemFromByteData(Set<Uint8List> data) {
    final dataWithSameBuffer = <ByteBuffer, Set<Uint8List>>{};

    data.forEach((element) {
      dataWithSameBuffer.putIfAbsent(element.buffer, () => <Uint8List>{});
      dataWithSameBuffer[element.buffer]!.add(element);
    });

    final pointerMap = <Uint8List, ffi.Pointer>{};
    final allocatedPointers = <ffi.Pointer>{};

    dataWithSameBuffer.entries.forEach((element) {
      final partialResult = nativeMemFromByteDataOfSameBuffer(element.value);
      pointerMap.addAll(partialResult.item1);
      allocatedPointers.addAll(partialResult.item2);
    });

    final result = Tuple2(pointerMap, allocatedPointers);
    return result;
  }

  @override
  Tuple2<NativeMemSpiTransferData, void Function()> _toNativeMemTransferData() {
    if (rxBuf != null && txBuf != null) {
      assert(rxBuf!.length == txBuf!.length);
    }

    final nativeMem = nativeMemFromByteData({if (rxBuf != null) rxBuf!, if (txBuf != null) txBuf!});

    ffi.Pointer txPtr = ffi.nullptr;
    ffi.Pointer rxPtr = ffi.nullptr;

    if (txBuf != null) {
      txPtr = nativeMem.item1.entries.singleWhere((element) => element.key == txBuf).value;

      final txPtrAsBuf = txPtr.cast<ffi.Uint8>().asTypedList(txBuf!.lengthInBytes);

      for (var i = 0; i < txPtrAsBuf.length; i++) {
        txPtrAsBuf[i] = txBuf![i];
      }
    }

    if (rxBuf != null) {
      rxPtr = nativeMem.item1.entries.singleWhere((element) => element.key == rxBuf).value;
    }

    final postTransfer = () {
      if (rxBuf != null) {
        final rxPtrAsBuf = rxPtr.cast<ffi.Uint8>().asTypedList(rxBuf!.lengthInBytes);

        for (var i = 0; i < rxPtrAsBuf.length; i++) {
          rxBuf![i] = rxPtrAsBuf[i];
        }
      }

      nativeMem.item2.forEach((pointer) => ffi.malloc.free(pointer));
    };

    final raw = SpiTransferData.fromNativeMem(txPointer: txPtr, rxPointer: rxPtr, length: txBuf?.length ?? rxBuf!.length);

    return Tuple2(raw as NativeMemSpiTransferData, postTransfer);
  }
}

@immutable
class ByteListSpiTransferData extends SpiTransferData {
  /// data to be written. can be [null]
  final List<int>? txBuf;

  /// data to be read. can be [null]
  final List<int>? rxBuf;

  ByteListSpiTransferData._private({required this.txBuf, required this.rxBuf})
      : assert(txBuf != null || rxBuf != null),
        assert((txBuf == null || rxBuf == null) || (txBuf.length == rxBuf.length));

  @override
  Tuple2<NativeMemSpiTransferData, void Function()> _toNativeMemTransferData() {
    ffi.Pointer txPointer = ffi.nullptr;
    ffi.Pointer rxPointer = ffi.nullptr;

    if (txBuf != null) {
      txPointer = ffi.malloc.allocate<ffi.Uint8>(txBuf!.length);
      final txPointerAsBuf = txPointer.cast<ffi.Uint8>().asTypedList(txBuf!.length);

      txBuf!.asMap().forEach((key, value) {
        txPointerAsBuf[key] = value;
      });
    }

    if (rxBuf != null) {
      rxPointer = ffi.malloc.allocate<ffi.Uint8>(rxBuf!.length);
    }

    final postTransfer = () {
      if (rxBuf != null) {
        final rxPtrAsBuf = rxPointer.cast<ffi.Uint8>().asTypedList(rxBuf!.length);
        rxPtrAsBuf.asMap().forEach((key, value) {
          rxBuf![key] = value;
        });
      }

      if (txPointer != ffi.nullptr) {
        ffi.malloc.free(txPointer);
      }
      if (rxPointer != ffi.nullptr) {
        ffi.malloc.free(rxPointer);
      }
    };

    return Tuple2(SpiTransferData.fromNativeMem(txPointer: txPointer, rxPointer: rxPointer, length: txBuf?.length ?? rxBuf!.length) as NativeMemSpiTransferData,
        postTransfer);
  }
}

@immutable
class SpiTransferProperties {
  /// Select a speed other than the device default for this transfer.
  /// If 0, the default of the SPI device is used.
  final int? speedHz;

  /// Delay after this transfer before
  /// (optionally) changing the chipselect status,
  /// then starting the next transfer or completing this [RawSpiTransfer].
  /// Measured in microseconds.
  final Duration delay;

  /// Select a bits_per_word other than the device default for this transfer.
  /// If 0 the default of the SPI device is used.
  final int? bitsPerWord;

  /// Affects chipselect after this transfer completes.
  final bool doToggleCS;

  /// Number of bits used for writing. If 0 the default (SPI_NBITS_SINGLE) is used.
  final SpiTransferMode? txTransferMode;

  /// number of bits used for reading. If 0 the default (SPI_NBITS_SINGLE) is used.
  final SpiTransferMode? rxTransferMode;

  /// Delay to be inserted between consecutive words of a transfer
  final Duration wordDelay;

  static final defaultProperties = SpiTransferProperties();

  SpiTransferProperties(
      {this.speedHz,
      this.delay = const Duration(microseconds: 0),
      this.bitsPerWord,
      this.doToggleCS = false,
      this.txTransferMode,
      this.rxTransferMode,
      this.wordDelay = const Duration(microseconds: 0)})
      : assert(speedHz == null || (speedHz >= 0 && speedHz <= 0xFFFFFFFF)),
        assert(delay.inMicroseconds >= 0 && delay.inMicroseconds <= 0xFFFF),
        assert(bitsPerWord == null || (bitsPerWord >= 0 && bitsPerWord <= 32)),
        assert(wordDelay.inMicroseconds >= 0 && wordDelay.inMicroseconds <= 0xFF);

  int nbitsFromTransferMode(SpiTransferMode? mode) {
    switch (mode) {
      case SpiTransferMode.single:
        return 1;
      case SpiTransferMode.dual:
        return 2;
      case SpiTransferMode.quad:
        return 4;
      default:
        throw ArgumentError.notNull("mode");
    }
  }

  void _writeToStruct(spi_ioc_transfer struct) {
    struct.speed_hz = speedHz ?? 0;
    struct.delay_usecs = delay.inMicroseconds;
    struct.bits_per_word = bitsPerWord ?? 0;
    struct.cs_change = doToggleCS ? 1 : 0;
    struct.tx_nbits = txTransferMode == null ? 0 : nbitsFromTransferMode(txTransferMode);
    struct.rx_nbits = rxTransferMode == null ? 0 : nbitsFromTransferMode(rxTransferMode);
    struct.word_delay_usecs = wordDelay.inMicroseconds;
  }
}

void spiTransferExecutorEntry(Tuple2<int, SendPort> channel) async {
  final fd = channel.item1;
  final sendPort = channel.item2;
  final receivePort = ReceivePort();

  sendPort.send(receivePort.sendPort);

  final dylib = ffi.DynamicLibrary.open("libc.so.6");
  final libc = LibC(dylib);

  await for (dynamic untypedTransfer in receivePort) {
    if (untypedTransfer == SpiTransferExecutor._CLOSE) {
      receivePort.close();
      return;
    } else if (untypedTransfer is Tuple3<int, int, int>) {
      final transferId = untypedTransfer.item1;
      final nTransfers = untypedTransfer.item2;
      final address = untypedTransfer.item3;

      final pointer = ffi.Pointer<spi_ioc_transfer>.fromAddress(address);

      try {
        final watch = Stopwatch()..start();

        SpidevPlatformInterface._staticIoctl(libc, fd, SPI_IOC_MESSAGE(nTransfers), pointer);

        watch.stop();

        sendPort.send(Tuple3<int, dynamic, StackTrace?>(transferId, null, null));
      } on OSError catch (e) {
        sendPort.send(Tuple3<int, dynamic, StackTrace>(transferId, e, StackTrace.current));
      }
    } else {
      throw StateError("Invalid packet received from receivePort in SpiTransferExecutor isolate: $untypedTransfer");
    }
  }
}

class SpiTransferExecutor {
  factory SpiTransferExecutor(int fd) {
    final fromExecutor = ReceivePort();
    final toExecutorCompleter = Completer<SendPort>();
    final isolateCompleter = Completer<Isolate>();

    final executor = SpiTransferExecutor._construct(fd, toExecutorCompleter);

    late StreamSubscription<dynamic> subscription;
    subscription = fromExecutor.listen((dynamic data) {
      assert(data is SendPort);

      executor._toExecutor = data;
      toExecutorCompleter.complete(data);

      subscription.onData(executor._onIsolateData);
    });

    final errorPort = ReceivePort()..listen(executor._onIsolateRuntimeError);
    final exitPort = ReceivePort()..listen(executor._onIsolateFinished);

    Isolate.spawn(
      spiTransferExecutorEntry,
      Tuple2(
        fd,
        fromExecutor.sendPort,
      ),
      onError: errorPort.sendPort,
      onExit: exitPort.sendPort,
    ).then(
      (value) => isolateCompleter.complete(value),
      onError: executor._onIsolateSpawnError,
    );

    return executor;
  }

  SpiTransferExecutor._construct(this._fd, this._toExecutorCompleter);

  static const dynamic _CLOSE = null;

  final int _fd;
  final Completer<SendPort> _toExecutorCompleter;
  final _pendingTransfers = <int, Completer<void>>{};

  SendPort? _toExecutor;

  int get fd => _fd;

  bool _canTransfer = true;
  bool get canTransfer => _canTransfer;

  bool _hasError = false;
  bool get hasError => _hasError;

  Object? _error;
  Object? get error => _error;

  int _nextTransferId = 0;

  void _onIsolateData(dynamic untypedData) {
    final data = untypedData as Tuple3<int, dynamic, StackTrace?>;

    final transferId = data.item1;
    final error = data.item2;
    final stackTrace = data.item3;
    final success = error == null;

    final transfer = _pendingTransfers.remove(transferId)!;

    if (success) {
      transfer.complete();
    } else {
      transfer.completeError(error, stackTrace);
    }
  }

  void _onIsolateRuntimeError(dynamic error) {
    assert(error is List);
    assert(error[0] is String);
    assert(error[1] is String);

    final constructedError = RemoteError(error[0] as String, error[1] as String);

    _pendingTransfers.values.forEach((value) => value.completeError(constructedError));
    _pendingTransfers.clear();
    _toExecutorCompleter.completeError(constructedError);
    _error = constructedError;
    _hasError = true;
    _canTransfer = false;
  }

  void _onIsolateSpawnError(dynamic error) {
    _error = error as Object;
    _toExecutorCompleter.completeError(_error!);
    _hasError = true;
    _canTransfer = false;
  }

  void _onIsolateFinished(dynamic result) {
    final error = StateError("SPI Transfer Executor Isolate finished prematurely. Transfer may or may not have been completed.");

    _pendingTransfers.values.forEach((transfer) {
      transfer.completeError(error);
    });
    _toExecutorCompleter.completeError(error);
    _canTransfer = false;
  }

  Future<void> transfer(List<SpiTransfer<NativeMemSpiTransferData>> transfers) {
    if (canTransfer == false) {
      throw StateError("Can't execute any transfers, `canTransfer` is false. "
          "The reason may be that an unexpected error ocurred in the executor isolate or "
          "that the isolate exited prematurely.");
    }

    final transferId = _nextTransferId++;
    final transferCompleter = Completer<void>();

    final pointer = ffi.malloc.allocate<spi_ioc_transfer>(ffi.sizeOf<spi_ioc_transfer>() * transfers.length);

    transfers.asMap().forEach((key, value) {
      final struct = pointer.elementAt(key).ref;
      value.data._writeToStruct(struct);
      value.properties._writeToStruct(struct);
    });

    _pendingTransfers[transferId] = transferCompleter;

    final packet = Tuple3<int, int, int>(transferId, transfers.length, pointer.address);
    if (_toExecutor != null) {
      _toExecutor!.send(packet);
    } else {
      _toExecutorCompleter.future.then((value) => value.send(packet));
    }

    return transferCompleter.future;
  }

  void close() {
    if (_toExecutor != null) {
      _toExecutor!.send([]);
    } else {
      _toExecutorCompleter.future.then((value) => value.send(_CLOSE));
    }
  }
}

/// Singleton for accessing the platform-side SPI
/// methods.
class SpidevPlatformInterface {
  factory SpidevPlatformInterface._internal() {
    if (!Platform.isLinux) {
      throw StateError("The spidev package only supports Linux as a Platform.");
    }

    final libc = LibC(ffi.DynamicLibrary.open("libc.so.6"));

    return SpidevPlatformInterface._construct(libc);
  }

  SpidevPlatformInterface._construct(this.libc);

  final LibC libc;
  final _executorForFd = <int, SpiTransferExecutor>{};

  static SpidevPlatformInterface? _instance;

  static SpidevPlatformInterface get instance {
    if (_instance == null) {
      _instance = SpidevPlatformInterface._internal();
    }

    return _instance!;
  }

  static int _staticIoctl(LibC libc, int fd, int request, ffi.Pointer argp) {
    final result = libc.ioctlPtr(fd, request, argp.cast<ffi.Void>());
    if (result < 0) {
      throw OSError("Spidev ioctl failed");
    }

    return result;
  }

  int _ioctl(int fd, int request, ffi.Pointer argp) => _staticIoctl(libc, fd, request, argp);

  int open(String path) {
    final nativePath = path.toNativeUtf8();

    final result = libc.open(nativePath.cast<ffi.Char>(), O_RDWR | O_CLOEXEC);

    ffi.malloc.free(nativePath);

    if (result < 0) {
      throw OSError("Could not open spidev file at \"$path\"");
    }

    final fd = result;

    final executor = SpiTransferExecutor(fd);

    _executorForFd[fd] = executor;

    return fd;
  }

  void setModeAndFlags(int fd, SpiMode mode, Set<SpiFlag> flags) {
    int arg = 0;
    switch (mode) {
      case SpiMode.mode0:
        arg |= SPI_MODE_0;
        break;
      case SpiMode.mode1:
        arg |= SPI_MODE_1;
        break;
      case SpiMode.mode2:
        arg |= SPI_MODE_2;
        break;
      case SpiMode.mode3:
        arg |= SPI_MODE_3;
        break;
      default:
        throw ArgumentError.value(mode, "mode");
    }
    for (final flag in flags) {
      switch (flag) {
        case SpiFlag.csActiveHigh:
          arg |= SPI_CS_HIGH;
          break;
        case SpiFlag.lsbFirst:
          arg |= SPI_LSB_FIRST;
          break;
        case SpiFlag.threeWire:
          arg |= SPI_3WIRE;
          break;
        case SpiFlag.loopBack:
          arg |= SPI_LOOP;
          break;
        case SpiFlag.noCs:
          arg |= SPI_NO_CS;
          break;
        case SpiFlag.ready:
          arg |= SPI_READY;
          break;
        case SpiFlag.txDual:
          arg |= SPI_TX_DUAL;
          break;
        case SpiFlag.txQuad:
          arg |= SPI_TX_QUAD;
          break;
        case SpiFlag.rxDual:
          arg |= SPI_RX_DUAL;
          break;
        case SpiFlag.rxQuad:
          arg |= SPI_RX_QUAD;
          break;
        case SpiFlag.toggleCsAfterEachWord:
          arg |= SPI_CS_WORD;
          break;
        case SpiFlag.txOctal:
          arg |= SPI_TX_OCTAL;
          break;
        case SpiFlag.rxOctal:
          arg |= SPI_RX_OCTAL;
          break;
        case SpiFlag.threeWireHighImpedanceTurnaround:
          arg |= SPI_3WIRE_HIZ;
          break;
        default:
          throw ArgumentError.value(flags, "flags", "Invalid SpiFlag: $flag");
      }
    }

    final modePointer = ffi.malloc.allocate<ffi.Uint8>(1);
    modePointer.value = arg;

    try {
      _ioctl(fd, SPI_IOC_WR_MODE, modePointer);
    } finally {
      ffi.malloc.free(modePointer);
    }
  }

  Tuple2<SpiMode, Set<SpiFlag>> getModeAndFlags(int fd) {
    final nativeResultPtr = ffi.malloc.allocate<ffi.Uint8>(1);

    SpiMode mode;
    final flags = <SpiFlag>{};
    try {
      _ioctl(fd, SPI_IOC_RD_MODE, nativeResultPtr);

      final nativeResult = nativeResultPtr.value;

      switch (nativeResult & 0x03) {
        case 0:
          mode = SpiMode.mode0;
          break;
        case 1:
          mode = SpiMode.mode1;
          break;
        case 2:
          mode = SpiMode.mode2;
          break;
        case 3:
          mode = SpiMode.mode3;
          break;
        default:
          throw StateError("kernel returned invalid SPI mode $nativeResult");
      }

      if (nativeResult & SPI_CS_HIGH > 0) {
        flags.add(SpiFlag.csActiveHigh);
      }
      if (nativeResult & SPI_LSB_FIRST > 0) {
        flags.add(SpiFlag.lsbFirst);
      }
      if (nativeResult & SPI_3WIRE > 0) {
        flags.add(SpiFlag.threeWire);
      }
      if (nativeResult & SPI_LOOP > 0) {
        flags.add(SpiFlag.loopBack);
      }
      if (nativeResult & SPI_NO_CS > 0) {
        flags.add(SpiFlag.noCs);
      }
      if (nativeResult & SPI_READY > 0) {
        flags.add(SpiFlag.ready);
      }
      if (nativeResult & SPI_TX_DUAL > 0) {
        flags.add(SpiFlag.txDual);
      }
      if (nativeResult & SPI_TX_QUAD > 0) {
        flags.add(SpiFlag.txQuad);
      }
      if (nativeResult & SPI_RX_DUAL > 0) {
        flags.add(SpiFlag.rxDual);
      }
      if (nativeResult & SPI_CS_WORD > 0) {
        flags.add(SpiFlag.toggleCsAfterEachWord);
      }
      if (nativeResult & SPI_TX_OCTAL > 0) {
        flags.add(SpiFlag.txOctal);
      }
      if (nativeResult & SPI_RX_OCTAL > 0) {
        flags.add(SpiFlag.rxOctal);
      }
      if (nativeResult & SPI_3WIRE_HIZ > 0) {
        flags.add(SpiFlag.threeWireHighImpedanceTurnaround);
      }
    } finally {
      ffi.malloc.free(nativeResultPtr);
    }

    return Tuple2(mode, flags);
  }

  void setMaxSpeed(int fd, int speedHz) {
    final pointer = ffi.malloc.allocate<ffi.Uint32>(1);
    pointer.value = speedHz;

    try {
      _ioctl(fd, SPI_IOC_WR_MAX_SPEED_HZ, pointer);
    } finally {
      ffi.malloc.free(pointer);
    }
  }

  int getMaxSpeed(int fd) {
    final pointer = ffi.malloc.allocate<ffi.Uint32>(1);

    int result;
    try {
      _ioctl(fd, SPI_IOC_RD_MAX_SPEED_HZ, pointer);
      result = pointer.value;
    } finally {
      ffi.malloc.free(pointer);
    }

    return result;
  }

  void setWordSize(int fd, int bitsPerWord) {
    final pointer = ffi.malloc.allocate<ffi.Uint8>(1);
    pointer.value = bitsPerWord;

    try {
      _ioctl(fd, SPI_IOC_WR_BITS_PER_WORD, pointer);
    } finally {
      ffi.malloc.free(pointer);
    }
  }

  int getWordSize(int fd) {
    final pointer = ffi.malloc.allocate<ffi.Uint8>(1);

    int result;
    try {
      _ioctl(fd, SPI_IOC_RD_BITS_PER_WORD, pointer);
      result = pointer.value;
    } finally {
      ffi.malloc.free(pointer);
    }

    return result;
  }

  Future<void> transfer(int fd, List<SpiTransfer<NativeMemSpiTransferData>> transfers) {
    assert(_executorForFd.containsKey(fd));

    SpiTransferExecutor? executor;

    if (_executorForFd[fd]!.canTransfer) {
      executor = _executorForFd[fd];
    } else {
      executor = SpiTransferExecutor(fd);
      _executorForFd[fd] = executor;
    }

    return executor!.transfer(transfers);
  }

  void close(int fd) {
    libc.close(fd);
  }
}

/// Maintains a Set of SPI-devices connected to this machine.
class Spidevs {
  Spidevs._();

  static final _regex = RegExp("^spidev\\d*\\.\\d*\$");

  static Set<Spidev>? _spidevs;

  static Set<Spidev>? get spidevs {
    _spidevs ??= Directory("/dev/").listSync().map((e) => e.path).where((e) => _regex.hasMatch(basename(e))).map((e) => Spidev.fromPath(e)).toSet();

    return _spidevs;
  }
}

@immutable
class Spidev {
  static final _regex = RegExp("^spidev(\\d*)\\.(\\d*)\$");

  bool get exists => File(path).existsSync();

  Spidev._construct(this.name, this.path, this.busNr, this.devNr);

  /// Constructs a spidev from it's bus nr and device nr.
  ///
  /// Basically a wrapper around `fromPath`. Device
  /// paths of spidevs typically have the form
  /// `/dev/spidevBUSNUMBER.DEVICENUMBER`.
  /// The busnumber selects the SCLK, MOSI and MISO pins.
  /// The device number selects the CS pin that will
  /// be set active at transimission.
  ///
  /// Example:
  /// ```dart
  /// final spidev = Spidev.fromBusDevNrs(0, 0);
  /// ```
  Spidev.fromBusDevNrs(this.busNr, this.devNr)
      : name = "spidev$busNr.$devNr",
        path = "/dev/spidev$busNr.$devNr";

  factory Spidev.fromPath(String path) {
    final name = basename(path);

    int? busNr;
    int? devNr;

    final match = _regex.firstMatch(name)!;

    if (match.groupCount == 2) {
      busNr = int.tryParse(match.group(1)!);
      devNr = int.tryParse(match.group(2)!);

      if (busNr == null || devNr == null) {
        busNr = null;
        devNr = null;
      }
    }

    return Spidev._construct(name, path, busNr!, devNr!);
  }

  final int busNr;
  final int devNr;
  final String name;
  final String path;

  /// Opens a spidev from it's device path.
  ///
  /// Example:
  /// ```dart
  /// final spidev = await Spidev.fromPath("/dev/spidev0.0");
  /// ```
  SpidevHandle open() {
    assert(exists);

    final fd = SpidevPlatformInterface.instance.open(path);

    return SpidevHandle._(this, fd);
  }
}

/// A wrapper around a linux spidev.
///
/// Communicates with one single SPI slave.
class SpidevHandle {
  SpidevHandle._(this.spidev, this._fd);

  final Spidev spidev;
  final int _fd;
  bool _isOpen = true;
  bool get isOpen => _isOpen;
  Tuple2<SpiMode, Set<SpiFlag>>? __modeAndFlags;
  int? _bitsPerWord;
  int? _maxSpeedHz;

  void set _modeAndFlags(Tuple2<SpiMode, Set<SpiFlag>> value) {
    ArgumentError.checkNotNull(bitsPerWord, "bitsPerWord");
    assert(isOpen);

    if (value != __modeAndFlags) {
      SpidevPlatformInterface.instance.setModeAndFlags(_fd, value.item1, value.item2);
      __modeAndFlags = value;
    }
  }

  Tuple2<SpiMode, Set<SpiFlag>> get _modeAndFlags {
    assert(isOpen);

    __modeAndFlags ??= SpidevPlatformInterface.instance.getModeAndFlags(_fd);
    return __modeAndFlags!;
  }

  /// Sets the default number of bits per word for this [SpidevHandle].
  void set bitsPerWord(int bitsPerWord) {
    ArgumentError.checkNotNull(bitsPerWord, "bitsPerWord");
    assert(isOpen);

    if (bitsPerWord != _bitsPerWord) {
      SpidevPlatformInterface.instance.setWordSize(_fd, bitsPerWord);
      _bitsPerWord = bitsPerWord;
    }
  }

  /// Gets the default number of bits per word for this [SpidevHandle].
  int get bitsPerWord {
    assert(isOpen);

    _bitsPerWord ??= SpidevPlatformInterface.instance.getWordSize(_fd);
    return _bitsPerWord!;
  }

  void set mode(SpiMode mode) {
    _modeAndFlags = _modeAndFlags.withItem1(mode);
  }

  SpiMode get mode => _modeAndFlags.item1;

  void set flags(Set<SpiFlag> flags) {
    _modeAndFlags = _modeAndFlags.withItem2(flags);
  }

  Set<SpiFlag> get flags => Set.of(_modeAndFlags.item2);

  void set maxSpeed(int hz) {
    ArgumentError.checkNotNull(hz, "hz");
    assert(isOpen);

    if (_maxSpeedHz != hz) {
      SpidevPlatformInterface.instance.setMaxSpeed(_fd, hz);
      _maxSpeedHz = hz;
    }
  }

  int get maxSpeed {
    assert(isOpen);

    _maxSpeedHz ??= SpidevPlatformInterface.instance.getMaxSpeed(_fd);
    return _maxSpeedHz!;
  }

  Future<void> transferNativeMem(List<SpiTransfer<NativeMemSpiTransferData>> transfers) {
    assert(isOpen);
    return SpidevPlatformInterface.instance.transfer(_fd, transfers);
  }

  Future<void> transfer(List<SpiTransfer> transfers) {
    final tuples = transfers.map((e) {
      final t = e.data._toNativeMemTransferData();
      return Tuple3(t.item1, e.properties, t.item2);
    }).toList();

    final rawTransfers = tuples.map((e) => SpiTransfer(data: e.item1, properties: e.item2)).toList();

    return transferNativeMem(rawTransfers).whenComplete(() {
      // call the postTransform callbacks for all spi transfers
      tuples.forEach((e) => e.item3());
    });
  }

  Future<void> transferSingleNativeMem({ffi.Pointer? txBuf, ffi.Pointer? rxBuf, required int length, SpiTransferProperties? transferProperties}) {
    return transferNativeMem([
      SpiTransfer(
          data: SpiTransferData.fromNativeMem(txPointer: txBuf, rxPointer: rxBuf, length: length) as NativeMemSpiTransferData,
          properties: transferProperties ?? SpiTransferProperties.defaultProperties)
    ]);
  }

  Future<void> transferSingleTypedData({Uint8List? txBuf, Uint8List? rxBuf, SpiTransferProperties? transferProperties}) {
    return transfer([
      SpiTransfer(
          data: SpiTransferData.fromTypedData(
            txBuf: txBuf,
            rxBuf: rxBuf,
          ),
          properties: transferProperties ?? SpiTransferProperties.defaultProperties)
    ]);
  }

  Future<void> transferSingleByteLists({List<int>? txBuf, List<int>? rxBuf, SpiTransferProperties? transferProperties}) {
    return transfer([
      SpiTransfer(data: SpiTransferData.fromByteLists(txBuf: txBuf, rxBuf: rxBuf), properties: transferProperties ?? SpiTransferProperties.defaultProperties)
    ]);
  }

  void close() {
    assert(isOpen);

    SpidevPlatformInterface.instance.close(_fd);
    _isOpen = false;
  }
}
