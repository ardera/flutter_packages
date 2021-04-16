import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:ffi/ffi.dart' as ffi;
import 'bindings/libc.dart';

/// ioctl request code for synchronously performing [count] SPI transfers.
/// Usage like this:
/// ```
/// final libc = LibC(DynamicLibrary.open("libc.so.6"));
///
/// final mesg = ffi.allocate<spi_ioc_message>(4);
///
/// libc.ioctlPointer(spidevFd, SPI_IOC_MESSAGE(4), mesg);
///
/// ffi.free(mesg);
/// ```
int SPI_IOC_MESSAGE(int count) {
  final dir = 1;
  final type = SPI_IOC_MAGIC;
  final nr = 0;
  final size = ffi.sizeOf<spi_ioc_transfer>() * count;
  return (dir << 30) | (size << 16) | (type << 8) | (nr);
}

/// for whatever reason, importing ffi's StringUtf8Pointer does not work.
extension StringUtf8Pointer on String {
  ffi.Pointer<ffi.Utf8> toNativeUtf8({ffi.Allocator allocator = ffi.malloc}) {
    final units = utf8.encode(this);
    final ffi.Pointer<ffi.Uint8> result = allocator<ffi.Uint8>(units.length + 1);
    final Uint8List nativeString = result.asTypedList(units.length + 1);
    nativeString.setAll(0, units);
    nativeString[units.length] = 0;
    return result.cast();
  }
}
