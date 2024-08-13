import 'dart:ffi' as ffi;

import 'package:_ardera_common_libc_bindings/_ardera_common_libc_bindings.dart'
    as libc;

abstract class LibC {
  LibC();

  factory LibC.open(String path) {
    return NativeLibC(libc.LibC(ffi.DynamicLibrary.open(path)));
  }

  int open(ffi.Pointer<ffi.Char> path, int flags);

  int close(int fd);

  int ioctlPtr(int fd, int request, ffi.Pointer argp);

  int errno();
}

class NativeLibC extends LibC {
  NativeLibC(this._libc);

  final libc.LibC _libc;

  int open(ffi.Pointer<ffi.Char> path, int flags) {
    return _libc.open(path, flags);
  }

  int close(int fd) {
    return _libc.close(fd);
  }

  int ioctlPtr(int fd, int request, ffi.Pointer argp) {
    return _libc.ioctlPtr(fd, request, argp);
  }

  int errno() {
    return _libc.errno;
  }
}
