import 'package:linux_spidev/src/libc.dart';

import 'dart:ffi' as ffi;

class FakeLibC extends LibC {
  FakeLibC({
    this.openFn,
    this.closeFn,
    this.ioctlPtrFn,
  }) : super();

  @override
  int open(ffi.Pointer<ffi.Char> path, int flags) {
    if (openFn != null) {
      return openFn!(path, flags);
    }

    throw UnimplementedError();
  }

  int Function(ffi.Pointer<ffi.Char>, int)? openFn;

  @override
  int close(int fd) {
    if (closeFn != null) {
      return closeFn!(fd);
    }

    throw UnimplementedError();
  }

  int Function(int)? closeFn;

  @override
  int ioctlPtr(int fd, int request, ffi.Pointer argp) {
    if (ioctlPtrFn != null) {
      return ioctlPtrFn!(fd, request, argp);
    }

    throw UnimplementedError();
  }

  int Function(int, int, ffi.Pointer)? ioctlPtrFn;

  @override
  int errno() {
    if (errnoFn != null) {
      return errnoFn!();
    }

    throw UnimplementedError();
  }

  int Function()? errnoFn;
}
