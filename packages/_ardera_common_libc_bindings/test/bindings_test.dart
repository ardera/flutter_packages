import 'dart:ffi' as ffi;

import 'package:test/test.dart';
import 'package:_ardera_common_libc_bindings/src/libc_arm.g.dart' as arm;
import 'package:_ardera_common_libc_bindings/src/libc_arm64.g.dart' as arm64;
import 'package:_ardera_common_libc_bindings/src/libc_i386.g.dart' as i386;
import 'package:_ardera_common_libc_bindings/src/libc_amd64.g.dart' as amd64;

void main() {
  final abi = ffi.Abi.current();
  final isLinuxArm = abi == ffi.Abi.linuxArm;
  final isLinuxArm64 = abi == ffi.Abi.linuxArm64;
  final isLinuxIA32 = abi == ffi.Abi.linuxIA32;
  final isLinuxX64 = abi == ffi.Abi.linuxX64;
  final isLinux = isLinuxArm || isLinuxArm64 || isLinuxIA32 || isLinuxX64;

  test('epoll event binding', () {
    if (isLinuxArm) {
      expect(ffi.sizeOf<arm.epoll_event>(), 16);

      var ptr = ffi.Pointer<arm.epoll_event>.fromAddress(0);
      expect(ptr.address, 0);
      expect(ptr.elementAt(1).address, 16);
    } else if (isLinuxArm64) {
      expect(ffi.sizeOf<arm64.epoll_event>(), 16);

      var ptr = ffi.Pointer<arm64.epoll_event>.fromAddress(0);
      expect(ptr.address, 0);
      expect(ptr.elementAt(1).address, 16);
    } else if (isLinuxIA32) {
      expect(ffi.sizeOf<i386.epoll_event>(), 12);

      var ptr = ffi.Pointer<i386.epoll_event>.fromAddress(0);
      expect(ptr.address, 0);
      expect(ptr.elementAt(1).address, 12);
    } else if (isLinuxX64) {
      expect(ffi.sizeOf<amd64.epoll_event>(), 12);

      var ptr = ffi.Pointer<amd64.epoll_event>.fromAddress(0);
      expect(ptr.address, 0);
      expect(ptr.elementAt(1).address, 12);
    }

    // var ptr = ffi.Pointer<epoll_event>.fromAddress(0);
    // expect(ptr.address, 0);
    // expect(ptr.elementAt(1).address, 16);

    // ptr = ffi.calloc.allocate<epoll_event>(ffi.sizeOf<epoll_event>());
    // expect(ptr.address, isNot(0));
    // expect(ptr.elementAt(0).address, ptr.address + 0);
    // expect(ptr.elementAt(1).address, ptr.address + 16);
    // ffi.calloc.free(ptr);
  }, skip: !isLinux ? 'Only applies to linux platforms.' : null);
}
