import 'dart:io';
import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart' as ffi;

import 'package:_ardera_common_libc_bindings/_ardera_common_libc_bindings.dart'
    as libc;
import 'package:_ardera_common_libc_bindings/_ardera_common_libc_bindings.dart'
    as bindings show EINTR;
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:linux_spidev/linux_spidev.dart';
import 'package:linux_spidev/src/executor/executor.dart';
import 'package:linux_spidev/src/libc.dart';
import 'package:linux_spidev/src/spidev.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' show basename;

/// Singleton for accessing the platform-side SPI
/// methods.
class SpidevPlatformInterface {
  @visibleForTesting
  factory SpidevPlatformInterface() {
    if (!Platform.isLinux) {
      throw StateError('The spidev package only supports Linux as a Platform.');
    }

    final libc = LibC.open('libc.so.6');

    return SpidevPlatformInterface.test(libc);
  }

  @visibleForTesting
  SpidevPlatformInterface.test(this._libc,
      {ffi.Allocator? allocator, FileSystem? fs})
      : _allocator = allocator ?? ffi.malloc,
        _fs = fs ?? LocalFileSystem();

  final LibC _libc;
  final ffi.Allocator _allocator;
  final FileSystem _fs;

  static SpidevPlatformInterface? _instance;

  static SpidevPlatformInterface get instance =>
      _instance ??= SpidevPlatformInterface();

  static set debugOverrideInstance(SpidevPlatformInterface? instance) {
    assert(() {
      _instance = instance;
      return true;
    }());
  }

  static int staticIoctl(LibC libc, int fd, int request, ffi.Pointer argp) {
    while (true) {
      final result = libc.ioctlPtr(fd, request, argp.cast<ffi.Void>());
      if (result < 0) {
        final errno = libc.errno();
        if (errno != bindings.EINTR) {
          throw OSError('Spidev ioctl failed.', errno);
        }
      } else {
        return result;
      }
    }
  }

  int ioctl(int fd, int request, ffi.Pointer argp) =>
      staticIoctl(_libc, fd, request, argp);

  int open(String path) {
    final nativePath = path.toNativeUtf8(allocator: _allocator);

    try {
      final result =
          _libc.open(nativePath.cast<ffi.Char>(), libc.O_RDWR | libc.O_CLOEXEC);
      if (result < 0) {
        throw OSError('Could not open spidev device at "$path".');
      }

      return result;
    } finally {
      _allocator.free(nativePath);
    }
  }

  bool exists(String path) {
    return _fs.file(path).existsSync();
  }

  void setModeAndFlags(int fd, SpiMode mode, Set<SpiFlag> flags) {
    var arg = 0;

    arg |= mode.value;
    for (final flag in flags) {
      arg |= flag.value;
    }

    final ptr = _allocator<ffi.Uint32>(1);
    ptr.value = arg;

    try {
      ioctl(fd, libc.SPI_IOC_WR_MODE32, ptr);
    } finally {
      _allocator.free(ptr);
    }
  }

  (SpiMode, Set<SpiFlag>) getModeAndFlags(int fd) {
    final ptr = _allocator<ffi.Uint32>(1);

    try {
      ioctl(fd, libc.SPI_IOC_RD_MODE32, ptr);

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
      _allocator.free(ptr);
    }
  }

  void setMaxSpeed(int fd, int speedHz) {
    final pointer = _allocator<ffi.Uint32>(1);
    pointer.value = speedHz;

    try {
      ioctl(fd, libc.SPI_IOC_WR_MAX_SPEED_HZ, pointer);
    } finally {
      _allocator.free(pointer);
    }
  }

  int getMaxSpeed(int fd) {
    final pointer = _allocator.allocate<ffi.Uint32>(1);
    try {
      ioctl(fd, libc.SPI_IOC_RD_MAX_SPEED_HZ, pointer);
      return pointer.value;
    } finally {
      _allocator.free(pointer);
    }
  }

  void setWordSize(int fd, int bitsPerWord) {
    final pointer = _allocator<ffi.Uint8>(1);

    try {
      pointer.value = bitsPerWord;

      ioctl(fd, libc.SPI_IOC_WR_BITS_PER_WORD, pointer);
    } finally {
      _allocator.free(pointer);
    }
  }

  int getWordSize(int fd) {
    _allocator;

    final pointer = _allocator<ffi.Uint8>(1);

    try {
      ioctl(fd, libc.SPI_IOC_RD_BITS_PER_WORD, pointer);
      return pointer.value;
    } finally {
      _allocator.free(pointer);
    }
  }

  void close(int fd) {
    final result = _libc.close(fd);
    if (result < 0) {
      throw OSError('Could not close spidev device with file descriptor $fd.');
    }
  }
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

  @visibleForTesting
  static (String, int?, int?) parsePath(String path) {
    final name = basename(path);

    if (_regex.firstMatch(name) case RegExpMatch match) {
      final bus = switch (match.group(1)) {
        null => null,
        String bus => int.tryParse(bus),
      };

      final dev = switch (match.group(2)) {
        null => null,
        String dev => int.tryParse(dev),
      };

      return (name, bus, dev);
    } else {
      return (name, null, null);
    }
  }

  factory NativeSpidev.fromPath(String path) {
    final (name, bus, dev) = parsePath(path);

    return NativeSpidev.test(
      SpidevPlatformInterface.instance,
      name,
      path,
      bus,
      dev,
    );
  }

  static final _regex = RegExp("^spidev(\\d*)\\.(\\d*)\$");

  final SpidevPlatformInterface _platformInterface;

  final int? busNr;
  final int? devNr;
  final String name;
  final String path;

  bool get exists => _platformInterface.exists(path);

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

class NativeSpidevHandle extends SpidevHandle {
  @visibleForTesting
  NativeSpidevHandle.test(
    this._platformInterface,
    this.spidev,
    this._fd, {
    SpiTransferExecutor? executor,
  }) : _executor = executor ?? SpiTransferExecutor(_fd);

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
