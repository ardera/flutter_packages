import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart';

import 'package:linux_spidev/src/data.dart';
import 'package:linux_spidev/src/transfer.dart';
import 'package:linux_spidev/src/native.dart';

/// Maintains a Set of SPI-devices connected to this machine.
class Spidevs {
  Spidevs._();

  static final _regex = RegExp("^spidev\\d*\\.\\d*\$");

  static List<Spidev> list() {
    return Directory("/dev/")
        .listSync()
        .map((e) => e.path)
        .where((e) => _regex.hasMatch(basename(e)))
        .map((e) => Spidev.fromPath(e))
        .toList();
  }

  static List<Spidev> get spidevs {
    return list();
  }
}

abstract class Spidev {
  factory Spidev.fromBusDevNrs(int bus, int dev) = NativeSpidev.fromBusDevNrs;

  factory Spidev.fromPath(String path) = NativeSpidev.fromPath;

  int? get busNr;
  int? get devNr;
  String get name;
  String get path;
  bool get exists;

  /// Opens a spidev from it's device path.
  ///
  /// Example:
  /// ```dart
  /// final spidev = await Spidev.fromPath("/dev/spidev0.0");
  /// ```
  SpidevHandle open({bool caching = true});
}

abstract class SpidevHandle {
  Spidev get spidev;

  /// The default number of bits per word for this [SpidevHandle].
  set bitsPerWord(int bits);
  int get bitsPerWord;

  set mode(SpiMode mode);
  SpiMode get mode;

  set flags(Set<SpiFlag> flags);
  Set<SpiFlag> get flags;

  set maxSpeed(int hz);
  int get maxSpeed;

  Future<void> transfer(Iterable<SpiTransfer> transfers);

  Future<void> transferSingleNative({
    ffi.Pointer? tx,
    ffi.Pointer? rx,
    required int length,
    SpiTransferProperties? transferProperties,
  }) {
    return transfer([
      NativeSpiTransfer(
        tx: tx ?? ffi.nullptr,
        rx: rx ?? ffi.nullptr,
        length: length,
        properties: transferProperties,
      )
    ]);
  }

  Future<void> transferSingle({
    Iterable<int>? tx,
    List<int>? rx,
    SpiTransferProperties? transferProperties,
  }) {
    if (rx is Uint8List? && tx is Uint8List?) {
      return transfer([
        TypedDataSpiTransfer(
          tx: tx,
          rx: rx,
          properties: transferProperties,
        )
      ]);
    } else {
      return transfer([
        ByteListSpiTransfer(
          tx: tx,
          rx: rx,
          properties: transferProperties,
        )
      ]);
    }
  }

  void close();
}

class CachingSpidevHandle extends SpidevHandle {
  CachingSpidevHandle(this._handle);

  final SpidevHandle _handle;

  Spidev get spidev => _handle.spidev;

  int? _bitsPerWord;

  @override
  int get bitsPerWord => _bitsPerWord ??= _handle.bitsPerWord;

  @override
  set bitsPerWord(int bits) {
    _handle.bitsPerWord = bits;
    _bitsPerWord = bits;
  }

  Set<SpiFlag>? _flags;

  @override
  Set<SpiFlag> get flags {
    return Set.of(_flags ??= _handle.flags);
  }

  @override
  set flags(Set<SpiFlag> flags) {
    _handle.flags = flags;
    _flags = Set.of(flags);
  }

  int? _maxSpeed;

  @override
  int get maxSpeed => _maxSpeed ??= _handle.maxSpeed;

  @override
  set maxSpeed(int hz) => _handle.maxSpeed = hz;

  SpiMode? _mode;

  @override
  SpiMode get mode => _mode ??= _handle.mode;

  @override
  set mode(SpiMode mode) {
    _handle.mode = mode;
    _mode = mode;
  }

  @override
  void close() {
    _handle.close();
  }

  @override
  Future<void> transfer(
    Iterable<SpiTransfer> transfers,
  ) async {
    return await _handle.transfer(transfers);
  }
}
