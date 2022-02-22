import 'dart:ffi' as ffi;

import 'package:test/test.dart';
import 'package:_ardera_common_libc_bindings/src/libc_arm.dart' as arm;
import 'package:_ardera_common_libc_bindings/src/libc_arm64.dart' as arm64;
import 'package:_ardera_common_libc_bindings/src/libc_i386.dart' as i386;
import 'package:_ardera_common_libc_bindings/src/libc_amd64.dart' as amd64;
import 'package:_ardera_common_libc_bindings/src/libc.dart';

void main() {
  test('epoll event binding', () {
    expect(ffi.sizeOf<arm.epoll_event_real>(), 16);
    expect(ffi.sizeOf<arm64.epoll_event_real>(), 16);
    expect(ffi.sizeOf<i386.epoll_event_real>(), 16);
    expect(ffi.sizeOf<amd64.epoll_event_real>(), 16);

    Arch.current = Arch.arm;
    expect(epoll_event_ptr.sizeOf(), 16);
    expect(epoll_event_ptr.nullptr.elementAt(0).backing.address, 0);
    expect(epoll_event_ptr.nullptr.elementAt(1).backing.address, 16);

    final ptr = epoll_event_ptr.allocate();
    expect(ptr.backing.address, isNot(0));
    expect(ptr.elementAt(0).backing.address, ptr.backing.address + 0);
    expect(ptr.elementAt(1).backing.address, ptr.backing.address + 16);
    ptr.free();
  });
}
