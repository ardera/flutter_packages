import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart' as ffi;

import 'package:test/test.dart';
import 'package:_ardera_common_libc_bindings/src/libc.dart';

void main() {
  test('epoll event binding', () {
    expect(ffi.sizeOf<epoll_event>(), 16);

    var ptr = ffi.Pointer<epoll_event>.fromAddress(0);
    expect(ptr.address, 0);
    expect(ptr.elementAt(1).address, 16);

    ptr = ffi.calloc.allocate<epoll_event>(ffi.sizeOf<epoll_event>());
    expect(ptr.address, isNot(0));
    expect(ptr.elementAt(0).address, ptr.address + 0);
    expect(ptr.elementAt(1).address, ptr.address + 16);
    ffi.calloc.free(ptr);
  });
}
