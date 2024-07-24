import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart' as ffi;
import 'package:linux_spidev/src/data.dart';
import 'package:linux_spidev/src/executor/executor.dart';
import 'package:linux_spidev/src/transfer.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:_ardera_common_libc_bindings/_ardera_common_libc_bindings.dart';

/// Singleton for accessing the platform-side SPI
/// methods.
class SpidevPlatformInterface {
  @visibleForTesting
  factory SpidevPlatformInterface.open() {
    if (!Platform.isLinux) {
      throw StateError("The spidev package only supports Linux as a Platform.");
    }

    final libc = LibC(ffi.DynamicLibrary.open("libc.so.6"));

    return SpidevPlatformInterface.testing(libc);
  }

  @visibleForTesting
  SpidevPlatformInterface.testing(this.libc, {ffi.Allocator? allocator})
      : _allocator = allocator ?? ffi.malloc;

  final LibC libc;
  final ffi.Allocator _allocator;

  static late final SpidevPlatformInterface instance =
      SpidevPlatformInterface.open();

  static int staticIoctl(LibC libc, int fd, int request, ffi.Pointer argp) {
    final result = libc.ioctlPtr(fd, request, argp.cast<ffi.Void>());
    if (result < 0) {
      throw OSError('Spidev ioctl failed.');
    }

    return result;
  }

  int ioctl(int fd, int request, ffi.Pointer argp) =>
      staticIoctl(libc, fd, request, argp);

  int open(String path) {
    final nativePath = path.toNativeUtf8(allocator: _allocator);

    try {
      final result = libc.open(nativePath.cast<ffi.Char>(), O_RDWR | O_CLOEXEC);
      if (result < 0) {
        throw OSError('Could not open spidev device at "$path".');
      }

      return result;
    } finally {
      _allocator.free(nativePath);
    }
  }

  void setModeAndFlags(
    int fd,
    SpiMode mode,
    Set<SpiFlag> flags, {
    ffi.Allocator? allocator,
  }) {
    allocator ??= _allocator;

    var arg = 0;

    arg |= mode.value;
    for (final flag in flags) {
      arg |= flag.value;
    }

    final ptr = allocator<ffi.Uint8>(1);
    ptr.value = arg;

    try {
      ioctl(fd, SPI_IOC_WR_MODE, ptr);
    } finally {
      allocator.free(ptr);
    }
  }

  (SpiMode, Set<SpiFlag>) getModeAndFlags(
    int fd, {
    ffi.Allocator? allocator,
  }) {
    allocator ??= _allocator;

    final ptr = allocator<ffi.Uint8>(1);

    try {
      ioctl(fd, SPI_IOC_RD_MODE, ptr);

      final result = ptr.value;

      final mode = SpiMode.fromValue(result & 3);

      final flags = <SpiFlag>{};
      for (final flag in SpiFlag.values) {
        if (result & flag.value != 0) {
          flags.add(flag);
        }
      }

      return (mode, flags);
    } finally {
      allocator.free(ptr);
    }
  }

  void setMaxSpeed(
    int fd,
    int speedHz, {
    ffi.Allocator? allocator,
  }) {
    allocator ??= _allocator;

    final pointer = allocator<ffi.Uint32>(1);
    pointer.value = speedHz;

    try {
      ioctl(fd, SPI_IOC_WR_MAX_SPEED_HZ, pointer);
    } finally {
      allocator.free(pointer);
    }
  }

  int getMaxSpeed(int fd, {ffi.Allocator? allocator}) {
    allocator ??= _allocator;

    final pointer = allocator.allocate<ffi.Uint32>(1);
    try {
      ioctl(fd, SPI_IOC_RD_MAX_SPEED_HZ, pointer);
      return pointer.value;
    } finally {
      allocator.free(pointer);
    }
  }

  void setWordSize(
    int fd,
    int bitsPerWord, {
    ffi.Allocator? allocator,
  }) {
    allocator ??= _allocator;

    final pointer = allocator<ffi.Uint8>(1);

    try {
      pointer.value = bitsPerWord;

      ioctl(fd, SPI_IOC_WR_BITS_PER_WORD, pointer);
    } finally {
      allocator.free(pointer);
    }
  }

  int getWordSize(int fd, {ffi.Allocator? allocator}) {
    allocator ??= _allocator;

    final pointer = allocator<ffi.Uint8>(1);

    try {
      ioctl(fd, SPI_IOC_RD_BITS_PER_WORD, pointer);
      return pointer.value;
    } finally {
      allocator.free(pointer);
    }
  }

  void close(int fd) {
    libc.close(fd);
  }
}

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

class NativeSpidev implements Spidev {
  @visibleForTesting
  NativeSpidev.test(
    this._platformInterface,
    this.name,
    this.path,
    this.busNr,
    this.devNr,
  );

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
  NativeSpidev.fromBusDevNrs(this.busNr, this.devNr)
      : _platformInterface = SpidevPlatformInterface.instance,
        name = 'spidev$busNr.$devNr',
        path = '/dev/spidev$busNr.$devNr';

  factory NativeSpidev.fromPath(String path) {
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

    return Spidev.test(
      SpidevPlatformInterface.instance,
      name,
      path,
      busNr,
      devNr,
    );
  }

  static final _regex = RegExp("^spidev(\\d*)\\.(\\d*)\$");

  final SpidevPlatformInterface _platformInterface;

  final int? busNr;
  final int? devNr;
  final String name;
  final String path;

  bool get exists => File(path).existsSync();

  /// Opens a spidev from it's device path.
  ///
  /// Example:
  /// ```dart
  /// final spidev = await Spidev.fromPath("/dev/spidev0.0");
  /// ```
  SpidevHandle open({bool caching = true}) {
    assert(exists);

    final fd = _platformInterface.open(path);

    SpidevHandle handle = NativeSpidevHandle.test(_platformInterface, this, fd);
    if (caching) {
      handle = CachingSpidevHandle(handle);
    }

    return handle;
  }
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
    ffi.Pointer? txBuf,
    ffi.Pointer? rxBuf,
    required int length,
    SpiTransferProperties? transferProperties,
  }) {
    return transfer([
      NativeSpiTransfer(
        tx: txBuf ?? ffi.nullptr,
        rx: rxBuf ?? ffi.nullptr,
        length: length,
        properties: transferProperties,
      )
    ]);
  }

  Future<void> transferSingle({
    List<int>? tx,
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

class NativeSpidevHandle extends SpidevHandle {
  @visibleForTesting
  NativeSpidevHandle.test(
    this._platformInterface,
    this.spidev,
    this._fd, {
    SpiTransferExecutor? executor,
  })  : assert(spidev.exists),
        _executor = SpiTransferExecutor(_fd);

  final SpidevPlatformInterface _platformInterface;
  final SpiTransferExecutor _executor;
  final int _fd;

  final Spidev spidev;

  @override
  int get bitsPerWord {
    return _platformInterface.getWordSize(_fd);
  }

  @override
  set bitsPerWord(int bits) {
    return _platformInterface.setWordSize(_fd, bits);
  }

  @override
  Set<SpiFlag> get flags {
    /// TODO: Possibly make this an unmodifiable set so people don't make the
    ///  mistake of trying to do `handle.flags.add(SpiFlag...);` to add flags.
    return _platformInterface.getModeAndFlags(_fd).$2;
  }

  @override
  set flags(Set<SpiFlag> flags) {
    return _platformInterface.setModeAndFlags(_fd, mode, flags);
  }

  @override
  int get maxSpeed {
    return _platformInterface.getMaxSpeed(_fd);
  }

  @override
  set maxSpeed(int hz) {
    return _platformInterface.setMaxSpeed(_fd, hz);
  }

  @override
  SpiMode get mode {
    return _platformInterface.getModeAndFlags(_fd).$1;
  }

  set mode(SpiMode mode) {
    return _platformInterface.setModeAndFlags(_fd, mode, flags);
  }

  @override
  void close() {
    _executor.close();
    _platformInterface.close(_fd);
  }

  @override
  Future<void> transfer(Iterable<SpiTransfer> transfers) async {
    await _executor.transfer(transfers);
  }
}

class CachingSpidevHandle extends SpidevHandle {
  CachingSpidevHandle(
    this._handle,
  );

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
