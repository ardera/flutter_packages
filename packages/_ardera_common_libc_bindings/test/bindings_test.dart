import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart' as ffi;
import 'package:test/test.dart';

import 'package:_ardera_common_libc_bindings/src/libc.dart' as libc;

void testOffset<T extends ffi.NativeType>({
  required ffi.Pointer<T> Function(ffi.Allocator allocator) allocate,
  required int offset,
  required bool Function(ffi.Pointer<T> memory) check,
  required String fieldName,
  ffi.Allocator allocator = ffi.calloc,
}) {
  final memory = allocate(allocator);

  memory.cast<ffi.Uint8>().elementAt(offset).value = 0xFF;
  expect(memory, predicate(check, 'has field $fieldName at offset $offset'));

  allocator.free(memory);
}

void main() {
  final abi = ffi.Abi.current();
  final isLinuxArm = abi == ffi.Abi.linuxArm;
  final isLinuxArm64 = abi == ffi.Abi.linuxArm64;
  final isLinuxIA32 = abi == ffi.Abi.linuxIA32;
  final isLinuxX64 = abi == ffi.Abi.linuxX64;
  final isLinux = isLinuxArm || isLinuxArm64 || isLinuxIA32 || isLinuxX64;

  test('epoll event binding', () {
    if (isLinuxArm) {
      expect(ffi.sizeOf<libc.epoll_event>(), 16);

      var ptr = ffi.Pointer<libc.epoll_event>.fromAddress(0);
      expect(ptr.address, 0);
      expect(ptr.elementAt(1).address, 16);
    } else if (isLinuxArm64) {
      expect(ffi.sizeOf<libc.epoll_event>(), 16);

      var ptr = ffi.Pointer<libc.epoll_event>.fromAddress(0);
      expect(ptr.address, 0);
      expect(ptr.elementAt(1).address, 16);
    } else if (isLinuxIA32) {
      expect(ffi.sizeOf<libc.epoll_event>(), 12);

      var ptr = ffi.Pointer<libc.epoll_event>.fromAddress(0);
      expect(ptr.address, 0);
      expect(ptr.elementAt(1).address, 12);
    } else if (isLinuxX64) {
      expect(ffi.sizeOf<libc.epoll_event>(), 12);

      var ptr = ffi.Pointer<libc.epoll_event>.fromAddress(0);
      expect(ptr.address, 0);
      expect(ptr.elementAt(1).address, 12);
    }
  }, skip: !isLinux ? 'Only applies to linux platforms.' : null);

  test('CAN binding', () {
    expect(ffi.sizeOf<libc.can_frame>(), libc.CAN_MTU);
    expect(ffi.sizeOf<libc.canfd_frame>(), libc.CANFD_MTU);

    testOffset<libc.can_frame>(
      allocate: (alloc) => alloc(),
      offset: 7,
      check: (memory) {
        return memory.ref.len8_dlc != 0;
      },
      fieldName: 'data',
    );

    testOffset<libc.can_frame>(
      allocate: (alloc) => alloc(),
      offset: 8,
      check: (memory) {
        return memory.ref.data[0] != 0;
      },
      fieldName: 'data',
    );

    testOffset<libc.canfd_frame>(
      allocate: (alloc) => alloc(),
      offset: 8,
      check: (memory) {
        return memory.ref.data[0] != 0;
      },
      fieldName: 'data',
    );
  }, skip: !isLinux ? 'Only applies to linux platforms.' : null);
}
