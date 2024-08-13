import 'dart:ffi';

import 'package:linux_spidev/src/data.dart';
import 'package:linux_spidev/src/native.dart';

class FakePlatformInterface implements SpidevPlatformInterface {
  FakePlatformInterface({
    this.existsFn,
    this.openFn,
    this.closeFn,
    this.ioctlFn,
    this.getMaxSpeedFn,
    this.setMaxSpeedFn,
    this.getModeAndFlagsFn,
    this.setModeAndFlagsFn,
    this.getWordSizeFn,
    this.setWordSizeFn,
  });

  @override
  void close(int fd) {
    if (closeFn != null) {
      closeFn!(fd);
    } else {
      throw UnimplementedError();
    }
  }

  late void Function(int fd)? closeFn;

  @override
  int getMaxSpeed(int fd, {Allocator? allocator}) {
    if (getMaxSpeedFn != null) {
      return getMaxSpeedFn!(fd, allocator: allocator);
    } else {
      throw UnimplementedError();
    }
  }

  late int Function(int fd, {Allocator? allocator})? getMaxSpeedFn;

  @override
  (SpiMode, Set<SpiFlag>) getModeAndFlags(int fd, {Allocator? allocator}) {
    if (getModeAndFlagsFn != null) {
      return getModeAndFlagsFn!(fd, allocator: allocator);
    } else {
      throw UnimplementedError();
    }
  }

  late (SpiMode, Set<SpiFlag>) Function(int fd, {Allocator? allocator})?
      getModeAndFlagsFn;

  @override
  int getWordSize(int fd, {Allocator? allocator}) {
    if (getWordSizeFn != null) {
      return getWordSizeFn!(fd, allocator: allocator);
    } else {
      throw UnimplementedError();
    }
  }

  late int Function(int fd, {Allocator? allocator})? getWordSizeFn;

  @override
  int ioctl(int fd, int request, Pointer<NativeType> argp) {
    if (ioctlFn != null) {
      return ioctlFn!(fd, request, argp);
    } else {
      throw UnimplementedError();
    }
  }

  late int Function(int fd, int request, Pointer<NativeType> argp)? ioctlFn;

  @override
  int open(String path) {
    if (openFn != null) {
      return openFn!(path);
    } else {
      throw UnimplementedError();
    }
  }

  late int Function(String path)? openFn;

  @override
  bool exists(String path) {
    if (existsFn != null) {
      return existsFn!(path);
    } else {
      throw UnimplementedError();
    }
  }

  late bool Function(String path)? existsFn;

  @override
  void setMaxSpeed(int fd, int speedHz, {Allocator? allocator}) {
    if (setMaxSpeedFn != null) {
      setMaxSpeedFn!(fd, speedHz, allocator: allocator);
    } else {
      throw UnimplementedError();
    }
  }

  late void Function(int fd, int speedHz, {Allocator? allocator})?
      setMaxSpeedFn;

  @override
  void setModeAndFlags(
    int fd,
    SpiMode mode,
    Set<SpiFlag> flags, {
    Allocator? allocator,
  }) {
    if (setModeAndFlagsFn != null) {
      setModeAndFlagsFn!(fd, mode, flags, allocator: allocator);
    } else {
      throw UnimplementedError();
    }
  }

  late void Function(
    int fd,
    SpiMode mode,
    Set<SpiFlag> flags, {
    Allocator? allocator,
  })? setModeAndFlagsFn;

  @override
  void setWordSize(int fd, int bitsPerWord, {Allocator? allocator}) {
    if (setWordSizeFn != null) {
      setWordSizeFn!(fd, bitsPerWord, allocator: allocator);
    } else {
      throw UnimplementedError();
    }
  }

  late void Function(int fd, int bitsPerWord, {Allocator? allocator})?
      setWordSizeFn;
}
