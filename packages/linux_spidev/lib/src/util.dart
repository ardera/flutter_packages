import 'dart:ffi' as ffi;

import 'package:_ardera_common_libc_bindings/_ardera_common_libc_bindings.dart';

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
