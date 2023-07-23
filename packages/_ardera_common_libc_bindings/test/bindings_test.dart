// ignore_for_file: non_constant_identifier_names

import 'dart:ffi' as ffi;
import 'package:_ardera_common_libc_bindings/_ardera_common_libc_bindings.dart';
import 'package:ffi/ffi.dart' as ffi;
import 'package:test/test.dart';

import 'package:_ardera_common_libc_bindings/src/libc.dart' as libc;

typedef MemberAbi = (int offset, int size);

typedef StatAbi = ({
  MemberAbi dev,
  MemberAbi ino,
  MemberAbi nlink,
  MemberAbi mode,
  MemberAbi uid,
  MemberAbi gid,
  MemberAbi size,
  MemberAbi atime,
  MemberAbi mtime,
  MemberAbi ctime
});

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

void testMember<T extends ffi.NativeType>({
  required ffi.Pointer<T> Function(ffi.Allocator allocator) allocate,
  required MemberAbi abi,
  required bool Function(ffi.Pointer<T> memory) check,
  required String fieldName,
  ffi.Allocator allocator = ffi.calloc,
}) {
  final (offset, size) = abi;

  final memory = allocate(allocator);

  memory.cast<ffi.Uint8>().elementAt(offset).value = 0xFF;
  expect(memory, predicate(check, 'has field $fieldName at offset $offset'));

  memory.cast<ffi.Uint8>().elementAt(offset).value = 0;
  memory.cast<ffi.Uint8>().elementAt(offset + size - 1).value = 0xFF;
  expect(memory, predicate(check, 'has field $fieldName with size $offset'));

  allocator.free(memory);
}

void main() {
  final abi = ffi.Abi.current();

  const arm = ffi.Abi.linuxArm;
  const arm64 = ffi.Abi.linuxArm64;
  const ia32 = ffi.Abi.linuxIA32;
  const x64 = ffi.Abi.linuxX64;

  final isLinuxArm = abi == arm;
  final isLinuxArm64 = abi == arm64;
  final isLinuxIA32 = abi == ia32;
  final isLinuxX64 = abi == x64;

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

  test('stat binding', () {
    switch (abi) {
      case arm:
        expect(ffi.sizeOf<stat_buf_arm>(), 144);
        break;
      case arm64:
        expect(ffi.sizeOf<stat_buf_arm>(), 144);
        break;
      case ia32:
        expect(ffi.sizeOf<stat_buf_i386>(), 144);
        break;
      case x64:
        expect(ffi.sizeOf<stat_buf_amd64>(), 144);
        break;
    }

    final Map<ffi.Abi, StatAbi> statAbis = {
      arm: (
        dev: (0, 0),
        ino: (0, 0),
        nlink: (0, 0),
        mode: (0, 0),
        uid: (0, 0),
        gid: (0, 0),
        size: (0, 0),
        atime: (0, 0),
        mtime: (0, 0),
        ctime: (0, 0),
      ),
      arm64: (
        dev: (0, 0),
        ino: (0, 0),
        nlink: (0, 0),
        mode: (0, 0),
        uid: (0, 0),
        gid: (0, 0),
        size: (0, 0),
        atime: (0, 0),
        mtime: (0, 0),
        ctime: (0, 0),
      ),
      ia32: (
        dev: (0, 0),
        ino: (0, 0),
        nlink: (0, 0),
        mode: (0, 0),
        uid: (0, 0),
        gid: (0, 0),
        size: (0, 0),
        atime: (0, 0),
        mtime: (0, 0),
        ctime: (0, 0),
      ),
      x64: (
        dev: (0, 8),
        ino: (8, 8),
        nlink: (16, 8),
        mode: (24, 4),
        uid: (28, 4),
        gid: (32, 4),
        size: (48, 8),
        atime: (72, 8),
        mtime: (88, 8),
        ctime: (104, 8),
      ),
    };

    void testStat<T extends ffi.NativeType>({
      required ffi.Pointer<T> Function(ffi.Allocator) allocate,
      required StatAbi abi,
      required bool Function(ffi.Pointer<T> memory) check_dev,
      required bool Function(ffi.Pointer<T> memory) check_ino,
      required bool Function(ffi.Pointer<T> memory) check_nlink,
      required bool Function(ffi.Pointer<T> memory) check_mode,
      required bool Function(ffi.Pointer<T> memory) check_uid,
      required bool Function(ffi.Pointer<T> memory) check_gid,
      required bool Function(ffi.Pointer<T> memory) check_size,
      required bool Function(ffi.Pointer<T> memory) check_atime,
      required bool Function(ffi.Pointer<T> memory) check_mtime,
      required bool Function(ffi.Pointer<T> memory) check_ctime,
    }) {
      testMember<T>(
        allocate: allocate,
        abi: abi.dev,
        check: check_dev,
        fieldName: 'st_dev',
      );
      testMember<T>(
        allocate: allocate,
        abi: abi.ino,
        check: check_ino,
        fieldName: 'st_ino',
      );
      testMember<T>(
        allocate: allocate,
        abi: abi.nlink,
        check: check_nlink,
        fieldName: 'st_nlink',
      );
      testMember<T>(
        allocate: allocate,
        abi: abi.mode,
        check: check_mode,
        fieldName: 'st_mode',
      );
      testMember<T>(
        allocate: allocate,
        abi: abi.uid,
        check: check_uid,
        fieldName: 'st_uid',
      );
      testMember<T>(
        allocate: allocate,
        abi: abi.gid,
        check: check_gid,
        fieldName: 'st_gid',
      );
      testMember<T>(
        allocate: allocate,
        abi: abi.size,
        check: check_size,
        fieldName: 'st_size',
      );
      testMember<T>(
        allocate: allocate,
        abi: abi.atime,
        check: check_atime,
        fieldName: 'st_atime',
      );
      testMember<T>(
        allocate: allocate,
        abi: abi.mtime,
        check: check_mtime,
        fieldName: 'st_mtime',
      );
      testMember<T>(
        allocate: allocate,
        abi: abi.ctime,
        check: check_ctime,
        fieldName: 'st_ctime',
      );
    }

    if (abi == arm) {
      testStat<stat_buf_arm>(
        allocate: (allocate) => allocate(),
        abi: statAbis[arm]!,
        check_dev: (memory) => memory.ref.st_dev != 0,
        check_ino: (memory) => memory.ref.st_ino != 0,
        check_nlink: (memory) => memory.ref.st_nlink != 0,
        check_mode: (memory) => memory.ref.st_mode != 0,
        check_uid: (memory) => memory.ref.st_uid != 0,
        check_gid: (memory) => memory.ref.st_gid != 0,
        check_size: (memory) => memory.ref.st_size != 0,
        check_atime: (memory) => memory.ref.st_atim.tv_sec != 0 || memory.ref.st_atim.tv_nsec != 0,
        check_mtime: (memory) => memory.ref.st_mtim.tv_sec != 0 || memory.ref.st_mtim.tv_nsec != 0,
        check_ctime: (memory) => memory.ref.st_ctim.tv_sec != 0 || memory.ref.st_ctim.tv_nsec != 0,
      );
    } else if (abi == arm64) {
      testStat<stat_buf_arm64>(
        allocate: (allocate) => allocate(),
        abi: statAbis[arm64]!,
        check_dev: (memory) => memory.ref.st_dev != 0,
        check_ino: (memory) => memory.ref.st_ino != 0,
        check_nlink: (memory) => memory.ref.st_nlink != 0,
        check_mode: (memory) => memory.ref.st_mode != 0,
        check_uid: (memory) => memory.ref.st_uid != 0,
        check_gid: (memory) => memory.ref.st_gid != 0,
        check_size: (memory) => memory.ref.st_size != 0,
        check_atime: (memory) => memory.ref.st_atim.tv_sec != 0 || memory.ref.st_atim.tv_nsec != 0,
        check_mtime: (memory) => memory.ref.st_mtim.tv_sec != 0 || memory.ref.st_mtim.tv_nsec != 0,
        check_ctime: (memory) => memory.ref.st_ctim.tv_sec != 0 || memory.ref.st_ctim.tv_nsec != 0,
      );
    } else if (abi == ia32) {
      testStat<stat_buf_i386>(
        allocate: (allocate) => allocate(),
        abi: statAbis[ia32]!,
        check_dev: (memory) => memory.ref.st_dev != 0,
        check_ino: (memory) => memory.ref.st_ino != 0,
        check_nlink: (memory) => memory.ref.st_nlink != 0,
        check_mode: (memory) => memory.ref.st_mode != 0,
        check_uid: (memory) => memory.ref.st_uid != 0,
        check_gid: (memory) => memory.ref.st_gid != 0,
        check_size: (memory) => memory.ref.st_size != 0,
        check_atime: (memory) => memory.ref.st_atim.tv_sec != 0 || memory.ref.st_atim.tv_nsec != 0,
        check_mtime: (memory) => memory.ref.st_mtim.tv_sec != 0 || memory.ref.st_mtim.tv_nsec != 0,
        check_ctime: (memory) => memory.ref.st_ctim.tv_sec != 0 || memory.ref.st_ctim.tv_nsec != 0,
      );
    } else if (abi == x64) {
      testStat<stat_buf_amd64>(
        allocate: (allocate) => allocate(),
        abi: statAbis[x64]!,
        check_dev: (memory) => memory.ref.st_dev != 0,
        check_ino: (memory) => memory.ref.st_ino != 0,
        check_nlink: (memory) => memory.ref.st_nlink != 0,
        check_mode: (memory) => memory.ref.st_mode != 0,
        check_uid: (memory) => memory.ref.st_uid != 0,
        check_gid: (memory) => memory.ref.st_gid != 0,
        check_size: (memory) => memory.ref.st_size != 0,
        check_atime: (memory) => memory.ref.st_atim.tv_sec != 0 || memory.ref.st_atim.tv_nsec != 0,
        check_mtime: (memory) => memory.ref.st_mtim.tv_sec != 0 || memory.ref.st_mtim.tv_nsec != 0,
        check_ctime: (memory) => memory.ref.st_ctim.tv_sec != 0 || memory.ref.st_ctim.tv_nsec != 0,
      );
    }
  }, skip: !isLinux ? 'Only applies to linux platforms.' : null);
}
