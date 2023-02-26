// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'dart:ffi' as ffi;

import 'libc_arm.g.dart' as arm;
export 'libc_arm.g.dart' hide LibCPlatformBackend;

class LibC extends arm.LibCPlatformBackend {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName) _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  LibC(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup,
        super(dynamicLibrary);

  /// The symbols are looked up with [lookup].
  LibC.fromLookup(ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName) lookup)
      : _lookup = lookup,
        super.fromLookup(lookup);

  late final ffi.Pointer<ffi.NativeFunction<ffi.Pointer<ffi.Int32> Function()>> errno_location_symbol_address = (() {
    ffi.Pointer<ffi.NativeFunction<ffi.Pointer<ffi.Int32> Function()>>? tryLookup(String name) {
      try {
        return _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Int32> Function()>>(name);
      } on ArgumentError {
        return null;
      }
    }

    ffi.Pointer<ffi.NativeFunction<ffi.Pointer<ffi.Int32> Function()>> throwStateError() {
      throw StateError('Couldn\'t resolve the errno location function.');
    }

    return tryLookup('__errno_location') ??
        tryLookup('__errno') ??
        tryLookup('errno') ??
        tryLookup('_dl_errno') ??
        tryLookup('__libc_errno') ??
        throwStateError();
  })();

  int ioctlPtr(
    int fd,
    int request,
    ffi.Pointer ptr,
  ) {
    return _ioctl_ptr(fd, request, ptr.cast<ffi.Void>());
  }

  late final _ioctl_ptrPtr =
      addresses.ioctl.cast<ffi.NativeFunction<ffi.Int Function(ffi.Int, ffi.Size, ffi.Pointer<ffi.Void>)>>();
  late final _ioctl_ptr = _ioctl_ptrPtr.asFunction<int Function(int, int, ffi.Pointer<ffi.Void>)>(isLeaf: true);

  ffi.Pointer<ffi.Int32> get errno_location =>
      errno_location_symbol_address.asFunction<ffi.Pointer<ffi.Int32> Function()>()();

  int get errno => errno_location.value;
}
