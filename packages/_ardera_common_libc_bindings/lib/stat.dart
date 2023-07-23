import 'dart:ffi' as ffi;
import 'package:_ardera_common_libc_bindings/linux_error.dart';
import 'package:ffi/ffi.dart' as ffi;

import 'package:_ardera_common_libc_bindings/_ardera_common_libc_bindings.dart';

class FileStat {
  FileStat({
    required this.dev,
    required this.inode,
    required this.mode,
    required this.nlink,
    required this.uid,
    required this.gid,
    required this.rdev,
    required this.size,
    required this.blockSize,
    required this.blocks,
    required this.accessTime,
    required this.modificationTime,
    required this.creationTime,
  });

  final int dev;
  final int inode;
  final int mode;
  final int nlink;
  final int uid;
  final int gid;
  final int rdev;
  final int size;
  final int blockSize;
  final int blocks;
  final DateTime accessTime;
  final DateTime modificationTime;
  final DateTime creationTime;
}

DateTime parseTimespec(int sec, int nsec) {
  return DateTime.fromMicrosecondsSinceEpoch(0).add(Duration(seconds: sec, microseconds: nsec ~/ 1000));
}

extension Stat on LibC {
  FileStat stat(ffi.Pointer<ffi.Char> file, {ffi.Allocator allocator = ffi.malloc}) {
    allocator = ffi.Arena(allocator);

    try {
      late final FileStat stat;

      switch (this) {
        case LibCArm arm:
          final buf = allocator<stat_buf_arm>();

          final ok = arm.stat(file, buf);
          if (ok != 0) {
            throw LinuxError(null, 'stat', errno);
          }

          stat = FileStat(
            dev: buf.ref.st_dev,
            inode: buf.ref.st_ino,
            mode: buf.ref.st_mode,
            nlink: buf.ref.st_nlink,
            uid: buf.ref.st_uid,
            gid: buf.ref.st_gid,
            rdev: buf.ref.st_rdev,
            size: buf.ref.st_size,
            blockSize: buf.ref.st_blksize,
            blocks: buf.ref.st_blocks,
            accessTime: parseTimespec(buf.ref.st_atim.tv_sec, buf.ref.st_atim.tv_nsec),
            modificationTime: parseTimespec(buf.ref.st_mtim.tv_sec, buf.ref.st_mtim.tv_nsec),
            creationTime: parseTimespec(buf.ref.st_ctim.tv_sec, buf.ref.st_ctim.tv_nsec),
          );
          break;

        case LibCArm64 arm64:
          final buf = allocator<stat_buf_arm64>();

          final ok = arm64.stat(file, buf);
          if (ok != 0) {
            throw LinuxError(null, 'stat', errno);
          }

          stat = FileStat(
            dev: buf.ref.st_dev,
            inode: buf.ref.st_ino,
            mode: buf.ref.st_mode,
            nlink: buf.ref.st_nlink,
            uid: buf.ref.st_uid,
            gid: buf.ref.st_gid,
            rdev: buf.ref.st_rdev,
            size: buf.ref.st_size,
            blockSize: buf.ref.st_blksize,
            blocks: buf.ref.st_blocks,
            accessTime: parseTimespec(buf.ref.st_atim.tv_sec, buf.ref.st_atim.tv_nsec),
            modificationTime: parseTimespec(buf.ref.st_mtim.tv_sec, buf.ref.st_mtim.tv_nsec),
            creationTime: parseTimespec(buf.ref.st_ctim.tv_sec, buf.ref.st_ctim.tv_nsec),
          );
          break;

        case LibCI386 i386:
          final buf = allocator<stat_buf_i386>();

          final ok = i386.stat(file, buf);
          if (ok != 0) {
            throw LinuxError(null, 'stat', errno);
          }

          stat = FileStat(
            dev: buf.ref.st_dev,
            inode: buf.ref.st_ino,
            mode: buf.ref.st_mode,
            nlink: buf.ref.st_nlink,
            uid: buf.ref.st_uid,
            gid: buf.ref.st_gid,
            rdev: buf.ref.st_rdev,
            size: buf.ref.st_size,
            blockSize: buf.ref.st_blksize,
            blocks: buf.ref.st_blocks,
            accessTime: parseTimespec(buf.ref.st_atim.tv_sec, buf.ref.st_atim.tv_nsec),
            modificationTime: parseTimespec(buf.ref.st_mtim.tv_sec, buf.ref.st_mtim.tv_nsec),
            creationTime: parseTimespec(buf.ref.st_ctim.tv_sec, buf.ref.st_ctim.tv_nsec),
          );
          break;

        case LibCAmd64 amd64:
          final buf = allocator<stat_buf_amd64>();

          final ok = amd64.stat(file, buf);
          if (ok != 0) {
            throw LinuxError(null, 'stat', errno);
          }

          stat = FileStat(
            dev: buf.ref.st_dev,
            inode: buf.ref.st_ino,
            mode: buf.ref.st_mode,
            nlink: buf.ref.st_nlink,
            uid: buf.ref.st_uid,
            gid: buf.ref.st_gid,
            rdev: buf.ref.st_rdev,
            size: buf.ref.st_size,
            blockSize: buf.ref.st_blksize,
            blocks: buf.ref.st_blocks,
            accessTime: parseTimespec(buf.ref.st_atim.tv_sec, buf.ref.st_atim.tv_nsec),
            modificationTime: parseTimespec(buf.ref.st_mtim.tv_sec, buf.ref.st_mtim.tv_nsec),
            creationTime: parseTimespec(buf.ref.st_ctim.tv_sec, buf.ref.st_ctim.tv_nsec),
          );
          break;
        default:
          throw UnsupportedError('Unsupported ABI: $this');
      }

      return stat;
    } finally {
      (allocator as ffi.Arena).releaseAll();
    }
  }
}
