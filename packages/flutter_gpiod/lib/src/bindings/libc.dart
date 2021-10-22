import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:ffi/ffi.dart' as ffi;
import 'libc_arm.dart' as arm;
import 'libc_arm64.dart' as arm64;
import 'libc_i386.dart' as i386;
import 'libc_amd64.dart' as amd64;

// ignore_for_file: unnecessary_brace_in_string_interps

typedef _dart_ioctl = int Function(
  int __fd,
  int __request,
);

typedef _dart_ioctl_ptr = int Function(
  int __fd,
  int __request,
  ffi.Pointer<ffi.Void> __pointer,
);

typedef Native_ioctl_ptr_32 = ffi.Int32 Function(
  ffi.Int32 __fd,
  ffi.Uint32 __request,
  ffi.Pointer<ffi.Void> __pointer,
);

typedef Native_ioctl_ptr_64 = ffi.Int32 Function(
  ffi.Int32 __fd,
  ffi.Uint64 __request,
  ffi.Pointer<ffi.Void> __pointer,
);

typedef _dart_epoll_create = int Function(
  int __size,
);

typedef _dart_epoll_create1 = int Function(
  int __flags,
);

typedef _dart_epoll_ctl = int Function(
  int __epfd,
  int __op,
  int __fd,
  ffi.Pointer<epoll_event> __event,
);

typedef _dart_epoll_wait = int Function(
  int __epfd,
  ffi.Pointer<epoll_event> __events,
  int __maxevents,
  int __timeout,
);

typedef _dart_errno_location = ffi.Pointer<ffi.Int32> Function();

typedef _dart_open = int Function(
  ffi.Pointer<ffi.Void> __file,
  int __oflag,
);

typedef _dart_close = int Function(
  int __fd,
);

typedef _dart_read = int Function(
  int __fd,
  ffi.Pointer<ffi.Void> __buf,
  int __nbytes,
);

typedef _dart_tcgetpgrp = int Function(
  int __fd,
);

typedef _dart_tcsetpgrp = int Function(
  int __fd,
  int __pgrp_id,
);

typedef _dart_cfgetospeed = int Function(
  ffi.Pointer<termios> __termios_p,
);

typedef _dart_cfgetispeed = int Function(
  ffi.Pointer<termios> __termios_p,
);

typedef _dart_cfsetospeed = int Function(
  ffi.Pointer<termios> __termios_p,
  int __speed,
);

typedef _dart_cfsetispeed = int Function(
  ffi.Pointer<termios> __termios_p,
  int __speed,
);

typedef _dart_cfsetspeed = int Function(
  ffi.Pointer<termios> __termios_p,
  int __speed,
);

typedef _dart_tcgetattr = int Function(
  int __fd,
  ffi.Pointer<termios> __termios_p,
);

typedef _dart_tcsetattr = int Function(
  int __fd,
  int __optional_actions,
  ffi.Pointer<termios> __termios_p,
);

typedef _dart_cfmakeraw = void Function(
  ffi.Pointer<termios> __termios_p,
);

typedef _dart_tcsendbreak = int Function(
  int __fd,
  int __duration,
);

typedef _dart_tcdrain = int Function(
  int __fd,
);

typedef _dart_tcflush = int Function(
  int __fd,
  int __queue_selector,
);

typedef _dart_tcflow = int Function(
  int __fd,
  int __action,
);

typedef _dart_tcgetsid = int Function(
  int __fd,
);

class Arch {
  const Arch();

  static const arm = Arch();
  static const arm64 = Arch();
  static const i386 = Arch();
  static const amd64 = Arch();

  static Arch? _current;
  static Arch get current {
    if (_current == null) {
      final result = Process.runSync('uname', ['-m']);
      if (result.exitCode != 0) {
        throw ProcessException('uname', ['-m']);
      }
      final output = result.stdout.toString().trim();
      switch (output) {
        case 'armv6l':
        case 'armv7l':
          _current = arm;
          break;
        case 'arm64':
        case 'aarch64':
          _current = arm64;
          break;
        case 'i386':
        case 'i86pc':
        case 'x86':
        case 'x86pc':
        case 'i686-AT386':
        case 'i686':
          _current = i386;
          break;
        case 'amd64':
        case 'x86_64':
          _current = amd64;
          break;
      }
    }

    return _current!;
  }

  static bool get isArm => current == arm;
  static bool get isArm64 => current == arm64;
  static bool get isI386 => current == i386;
  static bool get isAmd64 => current == amd64;
}

class epoll_event extends ffi.Struct {
  @ffi.Uint32()
  external int events;

  @ffi.Uint64()
  external int u64;

  static ffi.Pointer<epoll_event> allocate({
    ffi.Allocator allocator = ffi.malloc,
    int count = 1,
  }) {
    return allocator.allocate(ffi.sizeOf<epoll_event>() * count);
  }
}

class termios extends ffi.Struct {
  @ffi.Uint32()
  external int c_iflag;

  @ffi.Uint32()
  external int c_oflag;

  @ffi.Uint32()
  external int c_cflag;

  @ffi.Uint32()
  external int c_lflag;

  @ffi.Uint8()
  external int c_line;

  @ffi.Uint8()
  external int _unique_c_cc_item_0;
  @ffi.Uint8()
  external int _unique_c_cc_item_1;
  @ffi.Uint8()
  external int _unique_c_cc_item_2;
  @ffi.Uint8()
  external int _unique_c_cc_item_3;
  @ffi.Uint8()
  external int _unique_c_cc_item_4;
  @ffi.Uint8()
  external int _unique_c_cc_item_5;
  @ffi.Uint8()
  external int _unique_c_cc_item_6;
  @ffi.Uint8()
  external int _unique_c_cc_item_7;
  @ffi.Uint8()
  external int _unique_c_cc_item_8;
  @ffi.Uint8()
  external int _unique_c_cc_item_9;
  @ffi.Uint8()
  external int _unique_c_cc_item_10;
  @ffi.Uint8()
  external int _unique_c_cc_item_11;
  @ffi.Uint8()
  external int _unique_c_cc_item_12;
  @ffi.Uint8()
  external int _unique_c_cc_item_13;
  @ffi.Uint8()
  external int _unique_c_cc_item_14;
  @ffi.Uint8()
  external int _unique_c_cc_item_15;
  @ffi.Uint8()
  external int _unique_c_cc_item_16;
  @ffi.Uint8()
  external int _unique_c_cc_item_17;
  @ffi.Uint8()
  external int _unique_c_cc_item_18;
  @ffi.Uint8()
  external int _unique_c_cc_item_19;
  @ffi.Uint8()
  external int _unique_c_cc_item_20;
  @ffi.Uint8()
  external int _unique_c_cc_item_21;
  @ffi.Uint8()
  external int _unique_c_cc_item_22;
  @ffi.Uint8()
  external int _unique_c_cc_item_23;
  @ffi.Uint8()
  external int _unique_c_cc_item_24;
  @ffi.Uint8()
  external int _unique_c_cc_item_25;
  @ffi.Uint8()
  external int _unique_c_cc_item_26;
  @ffi.Uint8()
  external int _unique_c_cc_item_27;
  @ffi.Uint8()
  external int _unique_c_cc_item_28;
  @ffi.Uint8()
  external int _unique_c_cc_item_29;
  @ffi.Uint8()
  external int _unique_c_cc_item_30;
  @ffi.Uint8()
  external int _unique_c_cc_item_31;

  /// Helper for array `c_cc`.
  ArrayHelper_termios_c_cc_level0 get c_cc => ArrayHelper_termios_c_cc_level0(this, [32], 0, 0);
  @ffi.Uint32()
  external int c_ispeed;

  @ffi.Uint32()
  external int c_ospeed;

  static ffi.Pointer<termios> allocate({
    ffi.Allocator allocator = ffi.malloc,
    int count = 1,
  }) {
    return allocator.allocate(ffi.sizeOf<termios>() * count);
  }
}

/// Helper for array `c_cc` in struct `termios`.
class ArrayHelper_termios_c_cc_level0 {
  final termios _struct;
  final List<int> dimensions;
  final int level;
  final int _absoluteIndex;
  int get length => dimensions[level];
  ArrayHelper_termios_c_cc_level0(this._struct, this.dimensions, this.level, this._absoluteIndex);
  void _checkBounds(int index) {
    if (index >= length || index < 0) {
      throw RangeError('Dimension $level: index not in range 0..$length exclusive.');
    }
  }

  int operator [](int index) {
    _checkBounds(index);
    switch (_absoluteIndex + index) {
      case 0:
        return _struct._unique_c_cc_item_0;
      case 1:
        return _struct._unique_c_cc_item_1;
      case 2:
        return _struct._unique_c_cc_item_2;
      case 3:
        return _struct._unique_c_cc_item_3;
      case 4:
        return _struct._unique_c_cc_item_4;
      case 5:
        return _struct._unique_c_cc_item_5;
      case 6:
        return _struct._unique_c_cc_item_6;
      case 7:
        return _struct._unique_c_cc_item_7;
      case 8:
        return _struct._unique_c_cc_item_8;
      case 9:
        return _struct._unique_c_cc_item_9;
      case 10:
        return _struct._unique_c_cc_item_10;
      case 11:
        return _struct._unique_c_cc_item_11;
      case 12:
        return _struct._unique_c_cc_item_12;
      case 13:
        return _struct._unique_c_cc_item_13;
      case 14:
        return _struct._unique_c_cc_item_14;
      case 15:
        return _struct._unique_c_cc_item_15;
      case 16:
        return _struct._unique_c_cc_item_16;
      case 17:
        return _struct._unique_c_cc_item_17;
      case 18:
        return _struct._unique_c_cc_item_18;
      case 19:
        return _struct._unique_c_cc_item_19;
      case 20:
        return _struct._unique_c_cc_item_20;
      case 21:
        return _struct._unique_c_cc_item_21;
      case 22:
        return _struct._unique_c_cc_item_22;
      case 23:
        return _struct._unique_c_cc_item_23;
      case 24:
        return _struct._unique_c_cc_item_24;
      case 25:
        return _struct._unique_c_cc_item_25;
      case 26:
        return _struct._unique_c_cc_item_26;
      case 27:
        return _struct._unique_c_cc_item_27;
      case 28:
        return _struct._unique_c_cc_item_28;
      case 29:
        return _struct._unique_c_cc_item_29;
      case 30:
        return _struct._unique_c_cc_item_30;
      case 31:
        return _struct._unique_c_cc_item_31;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }

  void operator []=(int index, int value) {
    _checkBounds(index);
    switch (_absoluteIndex + index) {
      case 0:
        _struct._unique_c_cc_item_0 = value;
        break;
      case 1:
        _struct._unique_c_cc_item_1 = value;
        break;
      case 2:
        _struct._unique_c_cc_item_2 = value;
        break;
      case 3:
        _struct._unique_c_cc_item_3 = value;
        break;
      case 4:
        _struct._unique_c_cc_item_4 = value;
        break;
      case 5:
        _struct._unique_c_cc_item_5 = value;
        break;
      case 6:
        _struct._unique_c_cc_item_6 = value;
        break;
      case 7:
        _struct._unique_c_cc_item_7 = value;
        break;
      case 8:
        _struct._unique_c_cc_item_8 = value;
        break;
      case 9:
        _struct._unique_c_cc_item_9 = value;
        break;
      case 10:
        _struct._unique_c_cc_item_10 = value;
        break;
      case 11:
        _struct._unique_c_cc_item_11 = value;
        break;
      case 12:
        _struct._unique_c_cc_item_12 = value;
        break;
      case 13:
        _struct._unique_c_cc_item_13 = value;
        break;
      case 14:
        _struct._unique_c_cc_item_14 = value;
        break;
      case 15:
        _struct._unique_c_cc_item_15 = value;
        break;
      case 16:
        _struct._unique_c_cc_item_16 = value;
        break;
      case 17:
        _struct._unique_c_cc_item_17 = value;
        break;
      case 18:
        _struct._unique_c_cc_item_18 = value;
        break;
      case 19:
        _struct._unique_c_cc_item_19 = value;
        break;
      case 20:
        _struct._unique_c_cc_item_20 = value;
        break;
      case 21:
        _struct._unique_c_cc_item_21 = value;
        break;
      case 22:
        _struct._unique_c_cc_item_22 = value;
        break;
      case 23:
        _struct._unique_c_cc_item_23 = value;
        break;
      case 24:
        _struct._unique_c_cc_item_24 = value;
        break;
      case 25:
        _struct._unique_c_cc_item_25 = value;
        break;
      case 26:
        _struct._unique_c_cc_item_26 = value;
        break;
      case 27:
        _struct._unique_c_cc_item_27 = value;
        break;
      case 28:
        _struct._unique_c_cc_item_28 = value;
        break;
      case 29:
        _struct._unique_c_cc_item_29 = value;
        break;
      case 30:
        _struct._unique_c_cc_item_30 = value;
        break;
      case 31:
        _struct._unique_c_cc_item_31 = value;
        break;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }
}

/// struct gpiochip_info - Information about a certain GPIO chip
/// @name: the Linux kernel name of this GPIO chip
/// @label: a functional name for this GPIO chip, such as a product
/// number, may be empty (i.e. label[0] == '\0')
/// @lines: number of GPIO lines on this chip
class gpiochip_info extends ffi.Struct {
  @ffi.Uint8()
  external int _unique_name_item_0;
  @ffi.Uint8()
  external int _unique_name_item_1;
  @ffi.Uint8()
  external int _unique_name_item_2;
  @ffi.Uint8()
  external int _unique_name_item_3;
  @ffi.Uint8()
  external int _unique_name_item_4;
  @ffi.Uint8()
  external int _unique_name_item_5;
  @ffi.Uint8()
  external int _unique_name_item_6;
  @ffi.Uint8()
  external int _unique_name_item_7;
  @ffi.Uint8()
  external int _unique_name_item_8;
  @ffi.Uint8()
  external int _unique_name_item_9;
  @ffi.Uint8()
  external int _unique_name_item_10;
  @ffi.Uint8()
  external int _unique_name_item_11;
  @ffi.Uint8()
  external int _unique_name_item_12;
  @ffi.Uint8()
  external int _unique_name_item_13;
  @ffi.Uint8()
  external int _unique_name_item_14;
  @ffi.Uint8()
  external int _unique_name_item_15;
  @ffi.Uint8()
  external int _unique_name_item_16;
  @ffi.Uint8()
  external int _unique_name_item_17;
  @ffi.Uint8()
  external int _unique_name_item_18;
  @ffi.Uint8()
  external int _unique_name_item_19;
  @ffi.Uint8()
  external int _unique_name_item_20;
  @ffi.Uint8()
  external int _unique_name_item_21;
  @ffi.Uint8()
  external int _unique_name_item_22;
  @ffi.Uint8()
  external int _unique_name_item_23;
  @ffi.Uint8()
  external int _unique_name_item_24;
  @ffi.Uint8()
  external int _unique_name_item_25;
  @ffi.Uint8()
  external int _unique_name_item_26;
  @ffi.Uint8()
  external int _unique_name_item_27;
  @ffi.Uint8()
  external int _unique_name_item_28;
  @ffi.Uint8()
  external int _unique_name_item_29;
  @ffi.Uint8()
  external int _unique_name_item_30;
  @ffi.Uint8()
  external int _unique_name_item_31;

  /// Helper for array `name`.
  ArrayHelper_gpiochip_info_name_level0 get name => ArrayHelper_gpiochip_info_name_level0(this, [32], 0, 0);
  @ffi.Uint8()
  external int _unique_label_item_0;
  @ffi.Uint8()
  external int _unique_label_item_1;
  @ffi.Uint8()
  external int _unique_label_item_2;
  @ffi.Uint8()
  external int _unique_label_item_3;
  @ffi.Uint8()
  external int _unique_label_item_4;
  @ffi.Uint8()
  external int _unique_label_item_5;
  @ffi.Uint8()
  external int _unique_label_item_6;
  @ffi.Uint8()
  external int _unique_label_item_7;
  @ffi.Uint8()
  external int _unique_label_item_8;
  @ffi.Uint8()
  external int _unique_label_item_9;
  @ffi.Uint8()
  external int _unique_label_item_10;
  @ffi.Uint8()
  external int _unique_label_item_11;
  @ffi.Uint8()
  external int _unique_label_item_12;
  @ffi.Uint8()
  external int _unique_label_item_13;
  @ffi.Uint8()
  external int _unique_label_item_14;
  @ffi.Uint8()
  external int _unique_label_item_15;
  @ffi.Uint8()
  external int _unique_label_item_16;
  @ffi.Uint8()
  external int _unique_label_item_17;
  @ffi.Uint8()
  external int _unique_label_item_18;
  @ffi.Uint8()
  external int _unique_label_item_19;
  @ffi.Uint8()
  external int _unique_label_item_20;
  @ffi.Uint8()
  external int _unique_label_item_21;
  @ffi.Uint8()
  external int _unique_label_item_22;
  @ffi.Uint8()
  external int _unique_label_item_23;
  @ffi.Uint8()
  external int _unique_label_item_24;
  @ffi.Uint8()
  external int _unique_label_item_25;
  @ffi.Uint8()
  external int _unique_label_item_26;
  @ffi.Uint8()
  external int _unique_label_item_27;
  @ffi.Uint8()
  external int _unique_label_item_28;
  @ffi.Uint8()
  external int _unique_label_item_29;
  @ffi.Uint8()
  external int _unique_label_item_30;
  @ffi.Uint8()
  external int _unique_label_item_31;

  /// Helper for array `label`.
  ArrayHelper_gpiochip_info_label_level0 get label => ArrayHelper_gpiochip_info_label_level0(this, [32], 0, 0);
  @ffi.Uint32()
  external int lines;
}

/// Helper for array `name` in struct `gpiochip_info`.
class ArrayHelper_gpiochip_info_name_level0 {
  final gpiochip_info _struct;
  final List<int> dimensions;
  final int level;
  final int _absoluteIndex;
  int get length => dimensions[level];
  ArrayHelper_gpiochip_info_name_level0(this._struct, this.dimensions, this.level, this._absoluteIndex);
  void _checkBounds(int index) {
    if (index >= length || index < 0) {
      throw RangeError('Dimension $level: index not in range 0..$length exclusive.');
    }
  }

  int operator [](int index) {
    _checkBounds(index);
    switch (_absoluteIndex + index) {
      case 0:
        return _struct._unique_name_item_0;
      case 1:
        return _struct._unique_name_item_1;
      case 2:
        return _struct._unique_name_item_2;
      case 3:
        return _struct._unique_name_item_3;
      case 4:
        return _struct._unique_name_item_4;
      case 5:
        return _struct._unique_name_item_5;
      case 6:
        return _struct._unique_name_item_6;
      case 7:
        return _struct._unique_name_item_7;
      case 8:
        return _struct._unique_name_item_8;
      case 9:
        return _struct._unique_name_item_9;
      case 10:
        return _struct._unique_name_item_10;
      case 11:
        return _struct._unique_name_item_11;
      case 12:
        return _struct._unique_name_item_12;
      case 13:
        return _struct._unique_name_item_13;
      case 14:
        return _struct._unique_name_item_14;
      case 15:
        return _struct._unique_name_item_15;
      case 16:
        return _struct._unique_name_item_16;
      case 17:
        return _struct._unique_name_item_17;
      case 18:
        return _struct._unique_name_item_18;
      case 19:
        return _struct._unique_name_item_19;
      case 20:
        return _struct._unique_name_item_20;
      case 21:
        return _struct._unique_name_item_21;
      case 22:
        return _struct._unique_name_item_22;
      case 23:
        return _struct._unique_name_item_23;
      case 24:
        return _struct._unique_name_item_24;
      case 25:
        return _struct._unique_name_item_25;
      case 26:
        return _struct._unique_name_item_26;
      case 27:
        return _struct._unique_name_item_27;
      case 28:
        return _struct._unique_name_item_28;
      case 29:
        return _struct._unique_name_item_29;
      case 30:
        return _struct._unique_name_item_30;
      case 31:
        return _struct._unique_name_item_31;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }

  void operator []=(int index, int value) {
    _checkBounds(index);
    switch (_absoluteIndex + index) {
      case 0:
        _struct._unique_name_item_0 = value;
        break;
      case 1:
        _struct._unique_name_item_1 = value;
        break;
      case 2:
        _struct._unique_name_item_2 = value;
        break;
      case 3:
        _struct._unique_name_item_3 = value;
        break;
      case 4:
        _struct._unique_name_item_4 = value;
        break;
      case 5:
        _struct._unique_name_item_5 = value;
        break;
      case 6:
        _struct._unique_name_item_6 = value;
        break;
      case 7:
        _struct._unique_name_item_7 = value;
        break;
      case 8:
        _struct._unique_name_item_8 = value;
        break;
      case 9:
        _struct._unique_name_item_9 = value;
        break;
      case 10:
        _struct._unique_name_item_10 = value;
        break;
      case 11:
        _struct._unique_name_item_11 = value;
        break;
      case 12:
        _struct._unique_name_item_12 = value;
        break;
      case 13:
        _struct._unique_name_item_13 = value;
        break;
      case 14:
        _struct._unique_name_item_14 = value;
        break;
      case 15:
        _struct._unique_name_item_15 = value;
        break;
      case 16:
        _struct._unique_name_item_16 = value;
        break;
      case 17:
        _struct._unique_name_item_17 = value;
        break;
      case 18:
        _struct._unique_name_item_18 = value;
        break;
      case 19:
        _struct._unique_name_item_19 = value;
        break;
      case 20:
        _struct._unique_name_item_20 = value;
        break;
      case 21:
        _struct._unique_name_item_21 = value;
        break;
      case 22:
        _struct._unique_name_item_22 = value;
        break;
      case 23:
        _struct._unique_name_item_23 = value;
        break;
      case 24:
        _struct._unique_name_item_24 = value;
        break;
      case 25:
        _struct._unique_name_item_25 = value;
        break;
      case 26:
        _struct._unique_name_item_26 = value;
        break;
      case 27:
        _struct._unique_name_item_27 = value;
        break;
      case 28:
        _struct._unique_name_item_28 = value;
        break;
      case 29:
        _struct._unique_name_item_29 = value;
        break;
      case 30:
        _struct._unique_name_item_30 = value;
        break;
      case 31:
        _struct._unique_name_item_31 = value;
        break;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }
}

/// Helper for array `label` in struct `gpiochip_info`.
class ArrayHelper_gpiochip_info_label_level0 {
  final gpiochip_info _struct;
  final List<int> dimensions;
  final int level;
  final int _absoluteIndex;
  int get length => dimensions[level];
  ArrayHelper_gpiochip_info_label_level0(this._struct, this.dimensions, this.level, this._absoluteIndex);
  void _checkBounds(int index) {
    if (index >= length || index < 0) {
      throw RangeError('Dimension $level: index not in range 0..$length exclusive.');
    }
  }

  int operator [](int index) {
    _checkBounds(index);
    switch (_absoluteIndex + index) {
      case 0:
        return _struct._unique_label_item_0;
      case 1:
        return _struct._unique_label_item_1;
      case 2:
        return _struct._unique_label_item_2;
      case 3:
        return _struct._unique_label_item_3;
      case 4:
        return _struct._unique_label_item_4;
      case 5:
        return _struct._unique_label_item_5;
      case 6:
        return _struct._unique_label_item_6;
      case 7:
        return _struct._unique_label_item_7;
      case 8:
        return _struct._unique_label_item_8;
      case 9:
        return _struct._unique_label_item_9;
      case 10:
        return _struct._unique_label_item_10;
      case 11:
        return _struct._unique_label_item_11;
      case 12:
        return _struct._unique_label_item_12;
      case 13:
        return _struct._unique_label_item_13;
      case 14:
        return _struct._unique_label_item_14;
      case 15:
        return _struct._unique_label_item_15;
      case 16:
        return _struct._unique_label_item_16;
      case 17:
        return _struct._unique_label_item_17;
      case 18:
        return _struct._unique_label_item_18;
      case 19:
        return _struct._unique_label_item_19;
      case 20:
        return _struct._unique_label_item_20;
      case 21:
        return _struct._unique_label_item_21;
      case 22:
        return _struct._unique_label_item_22;
      case 23:
        return _struct._unique_label_item_23;
      case 24:
        return _struct._unique_label_item_24;
      case 25:
        return _struct._unique_label_item_25;
      case 26:
        return _struct._unique_label_item_26;
      case 27:
        return _struct._unique_label_item_27;
      case 28:
        return _struct._unique_label_item_28;
      case 29:
        return _struct._unique_label_item_29;
      case 30:
        return _struct._unique_label_item_30;
      case 31:
        return _struct._unique_label_item_31;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }

  void operator []=(int index, int value) {
    _checkBounds(index);
    switch (_absoluteIndex + index) {
      case 0:
        _struct._unique_label_item_0 = value;
        break;
      case 1:
        _struct._unique_label_item_1 = value;
        break;
      case 2:
        _struct._unique_label_item_2 = value;
        break;
      case 3:
        _struct._unique_label_item_3 = value;
        break;
      case 4:
        _struct._unique_label_item_4 = value;
        break;
      case 5:
        _struct._unique_label_item_5 = value;
        break;
      case 6:
        _struct._unique_label_item_6 = value;
        break;
      case 7:
        _struct._unique_label_item_7 = value;
        break;
      case 8:
        _struct._unique_label_item_8 = value;
        break;
      case 9:
        _struct._unique_label_item_9 = value;
        break;
      case 10:
        _struct._unique_label_item_10 = value;
        break;
      case 11:
        _struct._unique_label_item_11 = value;
        break;
      case 12:
        _struct._unique_label_item_12 = value;
        break;
      case 13:
        _struct._unique_label_item_13 = value;
        break;
      case 14:
        _struct._unique_label_item_14 = value;
        break;
      case 15:
        _struct._unique_label_item_15 = value;
        break;
      case 16:
        _struct._unique_label_item_16 = value;
        break;
      case 17:
        _struct._unique_label_item_17 = value;
        break;
      case 18:
        _struct._unique_label_item_18 = value;
        break;
      case 19:
        _struct._unique_label_item_19 = value;
        break;
      case 20:
        _struct._unique_label_item_20 = value;
        break;
      case 21:
        _struct._unique_label_item_21 = value;
        break;
      case 22:
        _struct._unique_label_item_22 = value;
        break;
      case 23:
        _struct._unique_label_item_23 = value;
        break;
      case 24:
        _struct._unique_label_item_24 = value;
        break;
      case 25:
        _struct._unique_label_item_25 = value;
        break;
      case 26:
        _struct._unique_label_item_26 = value;
        break;
      case 27:
        _struct._unique_label_item_27 = value;
        break;
      case 28:
        _struct._unique_label_item_28 = value;
        break;
      case 29:
        _struct._unique_label_item_29 = value;
        break;
      case 30:
        _struct._unique_label_item_30 = value;
        break;
      case 31:
        _struct._unique_label_item_31 = value;
        break;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }
}

/// struct gpioline_info - Information about a certain GPIO line
/// @line_offset: the local offset on this GPIO device, fill this in when
/// requesting the line information from the kernel
/// @flags: various flags for this line
/// @name: the name of this GPIO line, such as the output pin of the line on the
/// chip, a rail or a pin header name on a board, as specified by the gpio
/// chip, may be empty (i.e. name[0] == '\0')
/// @consumer: a functional name for the consumer of this GPIO line as set by
/// whatever is using it, will be empty if there is no current user but may
/// also be empty if the consumer doesn't set this up
///
/// Note: This struct is part of ABI v1 and is deprecated.
/// Use &struct gpio_v2_line_info instead.
class gpioline_info extends ffi.Struct {
  @ffi.Uint32()
  external int line_offset;

  @ffi.Uint32()
  external int flags;

  @ffi.Uint8()
  external int _unique_name_item_0;
  @ffi.Uint8()
  external int _unique_name_item_1;
  @ffi.Uint8()
  external int _unique_name_item_2;
  @ffi.Uint8()
  external int _unique_name_item_3;
  @ffi.Uint8()
  external int _unique_name_item_4;
  @ffi.Uint8()
  external int _unique_name_item_5;
  @ffi.Uint8()
  external int _unique_name_item_6;
  @ffi.Uint8()
  external int _unique_name_item_7;
  @ffi.Uint8()
  external int _unique_name_item_8;
  @ffi.Uint8()
  external int _unique_name_item_9;
  @ffi.Uint8()
  external int _unique_name_item_10;
  @ffi.Uint8()
  external int _unique_name_item_11;
  @ffi.Uint8()
  external int _unique_name_item_12;
  @ffi.Uint8()
  external int _unique_name_item_13;
  @ffi.Uint8()
  external int _unique_name_item_14;
  @ffi.Uint8()
  external int _unique_name_item_15;
  @ffi.Uint8()
  external int _unique_name_item_16;
  @ffi.Uint8()
  external int _unique_name_item_17;
  @ffi.Uint8()
  external int _unique_name_item_18;
  @ffi.Uint8()
  external int _unique_name_item_19;
  @ffi.Uint8()
  external int _unique_name_item_20;
  @ffi.Uint8()
  external int _unique_name_item_21;
  @ffi.Uint8()
  external int _unique_name_item_22;
  @ffi.Uint8()
  external int _unique_name_item_23;
  @ffi.Uint8()
  external int _unique_name_item_24;
  @ffi.Uint8()
  external int _unique_name_item_25;
  @ffi.Uint8()
  external int _unique_name_item_26;
  @ffi.Uint8()
  external int _unique_name_item_27;
  @ffi.Uint8()
  external int _unique_name_item_28;
  @ffi.Uint8()
  external int _unique_name_item_29;
  @ffi.Uint8()
  external int _unique_name_item_30;
  @ffi.Uint8()
  external int _unique_name_item_31;

  /// Helper for array `name`.
  ArrayHelper_gpioline_info_name_level0 get name => ArrayHelper_gpioline_info_name_level0(this, [32], 0, 0);
  @ffi.Uint8()
  external int _unique_consumer_item_0;
  @ffi.Uint8()
  external int _unique_consumer_item_1;
  @ffi.Uint8()
  external int _unique_consumer_item_2;
  @ffi.Uint8()
  external int _unique_consumer_item_3;
  @ffi.Uint8()
  external int _unique_consumer_item_4;
  @ffi.Uint8()
  external int _unique_consumer_item_5;
  @ffi.Uint8()
  external int _unique_consumer_item_6;
  @ffi.Uint8()
  external int _unique_consumer_item_7;
  @ffi.Uint8()
  external int _unique_consumer_item_8;
  @ffi.Uint8()
  external int _unique_consumer_item_9;
  @ffi.Uint8()
  external int _unique_consumer_item_10;
  @ffi.Uint8()
  external int _unique_consumer_item_11;
  @ffi.Uint8()
  external int _unique_consumer_item_12;
  @ffi.Uint8()
  external int _unique_consumer_item_13;
  @ffi.Uint8()
  external int _unique_consumer_item_14;
  @ffi.Uint8()
  external int _unique_consumer_item_15;
  @ffi.Uint8()
  external int _unique_consumer_item_16;
  @ffi.Uint8()
  external int _unique_consumer_item_17;
  @ffi.Uint8()
  external int _unique_consumer_item_18;
  @ffi.Uint8()
  external int _unique_consumer_item_19;
  @ffi.Uint8()
  external int _unique_consumer_item_20;
  @ffi.Uint8()
  external int _unique_consumer_item_21;
  @ffi.Uint8()
  external int _unique_consumer_item_22;
  @ffi.Uint8()
  external int _unique_consumer_item_23;
  @ffi.Uint8()
  external int _unique_consumer_item_24;
  @ffi.Uint8()
  external int _unique_consumer_item_25;
  @ffi.Uint8()
  external int _unique_consumer_item_26;
  @ffi.Uint8()
  external int _unique_consumer_item_27;
  @ffi.Uint8()
  external int _unique_consumer_item_28;
  @ffi.Uint8()
  external int _unique_consumer_item_29;
  @ffi.Uint8()
  external int _unique_consumer_item_30;
  @ffi.Uint8()
  external int _unique_consumer_item_31;

  /// Helper for array `consumer`.
  ArrayHelper_gpioline_info_consumer_level0 get consumer => ArrayHelper_gpioline_info_consumer_level0(this, [32], 0, 0);
}

/// Helper for array `name` in struct `gpioline_info`.
class ArrayHelper_gpioline_info_name_level0 {
  final gpioline_info _struct;
  final List<int> dimensions;
  final int level;
  final int _absoluteIndex;
  int get length => dimensions[level];
  ArrayHelper_gpioline_info_name_level0(this._struct, this.dimensions, this.level, this._absoluteIndex);
  void _checkBounds(int index) {
    if (index >= length || index < 0) {
      throw RangeError('Dimension $level: index not in range 0..$length exclusive.');
    }
  }

  int operator [](int index) {
    _checkBounds(index);
    switch (_absoluteIndex + index) {
      case 0:
        return _struct._unique_name_item_0;
      case 1:
        return _struct._unique_name_item_1;
      case 2:
        return _struct._unique_name_item_2;
      case 3:
        return _struct._unique_name_item_3;
      case 4:
        return _struct._unique_name_item_4;
      case 5:
        return _struct._unique_name_item_5;
      case 6:
        return _struct._unique_name_item_6;
      case 7:
        return _struct._unique_name_item_7;
      case 8:
        return _struct._unique_name_item_8;
      case 9:
        return _struct._unique_name_item_9;
      case 10:
        return _struct._unique_name_item_10;
      case 11:
        return _struct._unique_name_item_11;
      case 12:
        return _struct._unique_name_item_12;
      case 13:
        return _struct._unique_name_item_13;
      case 14:
        return _struct._unique_name_item_14;
      case 15:
        return _struct._unique_name_item_15;
      case 16:
        return _struct._unique_name_item_16;
      case 17:
        return _struct._unique_name_item_17;
      case 18:
        return _struct._unique_name_item_18;
      case 19:
        return _struct._unique_name_item_19;
      case 20:
        return _struct._unique_name_item_20;
      case 21:
        return _struct._unique_name_item_21;
      case 22:
        return _struct._unique_name_item_22;
      case 23:
        return _struct._unique_name_item_23;
      case 24:
        return _struct._unique_name_item_24;
      case 25:
        return _struct._unique_name_item_25;
      case 26:
        return _struct._unique_name_item_26;
      case 27:
        return _struct._unique_name_item_27;
      case 28:
        return _struct._unique_name_item_28;
      case 29:
        return _struct._unique_name_item_29;
      case 30:
        return _struct._unique_name_item_30;
      case 31:
        return _struct._unique_name_item_31;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }

  void operator []=(int index, int value) {
    _checkBounds(index);
    switch (_absoluteIndex + index) {
      case 0:
        _struct._unique_name_item_0 = value;
        break;
      case 1:
        _struct._unique_name_item_1 = value;
        break;
      case 2:
        _struct._unique_name_item_2 = value;
        break;
      case 3:
        _struct._unique_name_item_3 = value;
        break;
      case 4:
        _struct._unique_name_item_4 = value;
        break;
      case 5:
        _struct._unique_name_item_5 = value;
        break;
      case 6:
        _struct._unique_name_item_6 = value;
        break;
      case 7:
        _struct._unique_name_item_7 = value;
        break;
      case 8:
        _struct._unique_name_item_8 = value;
        break;
      case 9:
        _struct._unique_name_item_9 = value;
        break;
      case 10:
        _struct._unique_name_item_10 = value;
        break;
      case 11:
        _struct._unique_name_item_11 = value;
        break;
      case 12:
        _struct._unique_name_item_12 = value;
        break;
      case 13:
        _struct._unique_name_item_13 = value;
        break;
      case 14:
        _struct._unique_name_item_14 = value;
        break;
      case 15:
        _struct._unique_name_item_15 = value;
        break;
      case 16:
        _struct._unique_name_item_16 = value;
        break;
      case 17:
        _struct._unique_name_item_17 = value;
        break;
      case 18:
        _struct._unique_name_item_18 = value;
        break;
      case 19:
        _struct._unique_name_item_19 = value;
        break;
      case 20:
        _struct._unique_name_item_20 = value;
        break;
      case 21:
        _struct._unique_name_item_21 = value;
        break;
      case 22:
        _struct._unique_name_item_22 = value;
        break;
      case 23:
        _struct._unique_name_item_23 = value;
        break;
      case 24:
        _struct._unique_name_item_24 = value;
        break;
      case 25:
        _struct._unique_name_item_25 = value;
        break;
      case 26:
        _struct._unique_name_item_26 = value;
        break;
      case 27:
        _struct._unique_name_item_27 = value;
        break;
      case 28:
        _struct._unique_name_item_28 = value;
        break;
      case 29:
        _struct._unique_name_item_29 = value;
        break;
      case 30:
        _struct._unique_name_item_30 = value;
        break;
      case 31:
        _struct._unique_name_item_31 = value;
        break;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }
}

/// Helper for array `consumer` in struct `gpioline_info`.
class ArrayHelper_gpioline_info_consumer_level0 {
  final gpioline_info _struct;
  final List<int> dimensions;
  final int level;
  final int _absoluteIndex;
  int get length => dimensions[level];
  ArrayHelper_gpioline_info_consumer_level0(this._struct, this.dimensions, this.level, this._absoluteIndex);
  void _checkBounds(int index) {
    if (index >= length || index < 0) {
      throw RangeError('Dimension $level: index not in range 0..$length exclusive.');
    }
  }

  int operator [](int index) {
    _checkBounds(index);
    switch (_absoluteIndex + index) {
      case 0:
        return _struct._unique_consumer_item_0;
      case 1:
        return _struct._unique_consumer_item_1;
      case 2:
        return _struct._unique_consumer_item_2;
      case 3:
        return _struct._unique_consumer_item_3;
      case 4:
        return _struct._unique_consumer_item_4;
      case 5:
        return _struct._unique_consumer_item_5;
      case 6:
        return _struct._unique_consumer_item_6;
      case 7:
        return _struct._unique_consumer_item_7;
      case 8:
        return _struct._unique_consumer_item_8;
      case 9:
        return _struct._unique_consumer_item_9;
      case 10:
        return _struct._unique_consumer_item_10;
      case 11:
        return _struct._unique_consumer_item_11;
      case 12:
        return _struct._unique_consumer_item_12;
      case 13:
        return _struct._unique_consumer_item_13;
      case 14:
        return _struct._unique_consumer_item_14;
      case 15:
        return _struct._unique_consumer_item_15;
      case 16:
        return _struct._unique_consumer_item_16;
      case 17:
        return _struct._unique_consumer_item_17;
      case 18:
        return _struct._unique_consumer_item_18;
      case 19:
        return _struct._unique_consumer_item_19;
      case 20:
        return _struct._unique_consumer_item_20;
      case 21:
        return _struct._unique_consumer_item_21;
      case 22:
        return _struct._unique_consumer_item_22;
      case 23:
        return _struct._unique_consumer_item_23;
      case 24:
        return _struct._unique_consumer_item_24;
      case 25:
        return _struct._unique_consumer_item_25;
      case 26:
        return _struct._unique_consumer_item_26;
      case 27:
        return _struct._unique_consumer_item_27;
      case 28:
        return _struct._unique_consumer_item_28;
      case 29:
        return _struct._unique_consumer_item_29;
      case 30:
        return _struct._unique_consumer_item_30;
      case 31:
        return _struct._unique_consumer_item_31;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }

  void operator []=(int index, int value) {
    _checkBounds(index);
    switch (_absoluteIndex + index) {
      case 0:
        _struct._unique_consumer_item_0 = value;
        break;
      case 1:
        _struct._unique_consumer_item_1 = value;
        break;
      case 2:
        _struct._unique_consumer_item_2 = value;
        break;
      case 3:
        _struct._unique_consumer_item_3 = value;
        break;
      case 4:
        _struct._unique_consumer_item_4 = value;
        break;
      case 5:
        _struct._unique_consumer_item_5 = value;
        break;
      case 6:
        _struct._unique_consumer_item_6 = value;
        break;
      case 7:
        _struct._unique_consumer_item_7 = value;
        break;
      case 8:
        _struct._unique_consumer_item_8 = value;
        break;
      case 9:
        _struct._unique_consumer_item_9 = value;
        break;
      case 10:
        _struct._unique_consumer_item_10 = value;
        break;
      case 11:
        _struct._unique_consumer_item_11 = value;
        break;
      case 12:
        _struct._unique_consumer_item_12 = value;
        break;
      case 13:
        _struct._unique_consumer_item_13 = value;
        break;
      case 14:
        _struct._unique_consumer_item_14 = value;
        break;
      case 15:
        _struct._unique_consumer_item_15 = value;
        break;
      case 16:
        _struct._unique_consumer_item_16 = value;
        break;
      case 17:
        _struct._unique_consumer_item_17 = value;
        break;
      case 18:
        _struct._unique_consumer_item_18 = value;
        break;
      case 19:
        _struct._unique_consumer_item_19 = value;
        break;
      case 20:
        _struct._unique_consumer_item_20 = value;
        break;
      case 21:
        _struct._unique_consumer_item_21 = value;
        break;
      case 22:
        _struct._unique_consumer_item_22 = value;
        break;
      case 23:
        _struct._unique_consumer_item_23 = value;
        break;
      case 24:
        _struct._unique_consumer_item_24 = value;
        break;
      case 25:
        _struct._unique_consumer_item_25 = value;
        break;
      case 26:
        _struct._unique_consumer_item_26 = value;
        break;
      case 27:
        _struct._unique_consumer_item_27 = value;
        break;
      case 28:
        _struct._unique_consumer_item_28 = value;
        break;
      case 29:
        _struct._unique_consumer_item_29 = value;
        break;
      case 30:
        _struct._unique_consumer_item_30 = value;
        break;
      case 31:
        _struct._unique_consumer_item_31 = value;
        break;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }
}

/// struct gpiohandle_request - Information about a GPIO handle request
/// @lineoffsets: an array of desired lines, specified by offset index for the
/// associated GPIO device
/// @flags: desired flags for the desired GPIO lines, such as
/// %GPIOHANDLE_REQUEST_OUTPUT, %GPIOHANDLE_REQUEST_ACTIVE_LOW etc, added
/// together. Note that even if multiple lines are requested, the same flags
/// must be applicable to all of them, if you want lines with individual
/// flags set, request them one by one. It is possible to select
/// a batch of input or output lines, but they must all have the same
/// characteristics, i.e. all inputs or all outputs, all active low etc
/// @default_values: if the %GPIOHANDLE_REQUEST_OUTPUT is set for a requested
/// line, this specifies the default output value, should be 0 (low) or
/// 1 (high), anything else than 0 or 1 will be interpreted as 1 (high)
/// @consumer_label: a desired consumer label for the selected GPIO line(s)
/// such as "my-bitbanged-relay"
/// @lines: number of lines requested in this request, i.e. the number of
/// valid fields in the above arrays, set to 1 to request a single line
/// @fd: if successful this field will contain a valid anonymous file handle
/// after a %GPIO_GET_LINEHANDLE_IOCTL operation, zero or negative value
/// means error
///
/// Note: This struct is part of ABI v1 and is deprecated.
/// Use &struct gpio_v2_line_request instead.
class gpiohandle_request extends ffi.Struct {
  @ffi.Uint32()
  external int _unique_lineoffsets_item_0;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_1;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_2;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_3;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_4;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_5;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_6;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_7;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_8;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_9;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_10;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_11;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_12;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_13;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_14;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_15;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_16;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_17;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_18;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_19;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_20;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_21;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_22;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_23;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_24;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_25;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_26;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_27;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_28;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_29;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_30;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_31;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_32;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_33;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_34;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_35;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_36;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_37;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_38;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_39;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_40;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_41;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_42;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_43;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_44;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_45;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_46;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_47;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_48;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_49;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_50;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_51;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_52;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_53;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_54;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_55;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_56;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_57;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_58;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_59;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_60;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_61;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_62;
  @ffi.Uint32()
  external int _unique_lineoffsets_item_63;

  /// Helper for array `lineoffsets`.
  ArrayHelper_gpiohandle_request_lineoffsets_level0 get lineoffsets =>
      ArrayHelper_gpiohandle_request_lineoffsets_level0(this, [64], 0, 0);
  @ffi.Uint32()
  external int flags;

  @ffi.Uint8()
  external int _unique_default_values_item_0;
  @ffi.Uint8()
  external int _unique_default_values_item_1;
  @ffi.Uint8()
  external int _unique_default_values_item_2;
  @ffi.Uint8()
  external int _unique_default_values_item_3;
  @ffi.Uint8()
  external int _unique_default_values_item_4;
  @ffi.Uint8()
  external int _unique_default_values_item_5;
  @ffi.Uint8()
  external int _unique_default_values_item_6;
  @ffi.Uint8()
  external int _unique_default_values_item_7;
  @ffi.Uint8()
  external int _unique_default_values_item_8;
  @ffi.Uint8()
  external int _unique_default_values_item_9;
  @ffi.Uint8()
  external int _unique_default_values_item_10;
  @ffi.Uint8()
  external int _unique_default_values_item_11;
  @ffi.Uint8()
  external int _unique_default_values_item_12;
  @ffi.Uint8()
  external int _unique_default_values_item_13;
  @ffi.Uint8()
  external int _unique_default_values_item_14;
  @ffi.Uint8()
  external int _unique_default_values_item_15;
  @ffi.Uint8()
  external int _unique_default_values_item_16;
  @ffi.Uint8()
  external int _unique_default_values_item_17;
  @ffi.Uint8()
  external int _unique_default_values_item_18;
  @ffi.Uint8()
  external int _unique_default_values_item_19;
  @ffi.Uint8()
  external int _unique_default_values_item_20;
  @ffi.Uint8()
  external int _unique_default_values_item_21;
  @ffi.Uint8()
  external int _unique_default_values_item_22;
  @ffi.Uint8()
  external int _unique_default_values_item_23;
  @ffi.Uint8()
  external int _unique_default_values_item_24;
  @ffi.Uint8()
  external int _unique_default_values_item_25;
  @ffi.Uint8()
  external int _unique_default_values_item_26;
  @ffi.Uint8()
  external int _unique_default_values_item_27;
  @ffi.Uint8()
  external int _unique_default_values_item_28;
  @ffi.Uint8()
  external int _unique_default_values_item_29;
  @ffi.Uint8()
  external int _unique_default_values_item_30;
  @ffi.Uint8()
  external int _unique_default_values_item_31;
  @ffi.Uint8()
  external int _unique_default_values_item_32;
  @ffi.Uint8()
  external int _unique_default_values_item_33;
  @ffi.Uint8()
  external int _unique_default_values_item_34;
  @ffi.Uint8()
  external int _unique_default_values_item_35;
  @ffi.Uint8()
  external int _unique_default_values_item_36;
  @ffi.Uint8()
  external int _unique_default_values_item_37;
  @ffi.Uint8()
  external int _unique_default_values_item_38;
  @ffi.Uint8()
  external int _unique_default_values_item_39;
  @ffi.Uint8()
  external int _unique_default_values_item_40;
  @ffi.Uint8()
  external int _unique_default_values_item_41;
  @ffi.Uint8()
  external int _unique_default_values_item_42;
  @ffi.Uint8()
  external int _unique_default_values_item_43;
  @ffi.Uint8()
  external int _unique_default_values_item_44;
  @ffi.Uint8()
  external int _unique_default_values_item_45;
  @ffi.Uint8()
  external int _unique_default_values_item_46;
  @ffi.Uint8()
  external int _unique_default_values_item_47;
  @ffi.Uint8()
  external int _unique_default_values_item_48;
  @ffi.Uint8()
  external int _unique_default_values_item_49;
  @ffi.Uint8()
  external int _unique_default_values_item_50;
  @ffi.Uint8()
  external int _unique_default_values_item_51;
  @ffi.Uint8()
  external int _unique_default_values_item_52;
  @ffi.Uint8()
  external int _unique_default_values_item_53;
  @ffi.Uint8()
  external int _unique_default_values_item_54;
  @ffi.Uint8()
  external int _unique_default_values_item_55;
  @ffi.Uint8()
  external int _unique_default_values_item_56;
  @ffi.Uint8()
  external int _unique_default_values_item_57;
  @ffi.Uint8()
  external int _unique_default_values_item_58;
  @ffi.Uint8()
  external int _unique_default_values_item_59;
  @ffi.Uint8()
  external int _unique_default_values_item_60;
  @ffi.Uint8()
  external int _unique_default_values_item_61;
  @ffi.Uint8()
  external int _unique_default_values_item_62;
  @ffi.Uint8()
  external int _unique_default_values_item_63;

  /// Helper for array `default_values`.
  ArrayHelper_gpiohandle_request_default_values_level0 get default_values =>
      ArrayHelper_gpiohandle_request_default_values_level0(this, [64], 0, 0);
  @ffi.Uint8()
  external int _unique_consumer_label_item_0;
  @ffi.Uint8()
  external int _unique_consumer_label_item_1;
  @ffi.Uint8()
  external int _unique_consumer_label_item_2;
  @ffi.Uint8()
  external int _unique_consumer_label_item_3;
  @ffi.Uint8()
  external int _unique_consumer_label_item_4;
  @ffi.Uint8()
  external int _unique_consumer_label_item_5;
  @ffi.Uint8()
  external int _unique_consumer_label_item_6;
  @ffi.Uint8()
  external int _unique_consumer_label_item_7;
  @ffi.Uint8()
  external int _unique_consumer_label_item_8;
  @ffi.Uint8()
  external int _unique_consumer_label_item_9;
  @ffi.Uint8()
  external int _unique_consumer_label_item_10;
  @ffi.Uint8()
  external int _unique_consumer_label_item_11;
  @ffi.Uint8()
  external int _unique_consumer_label_item_12;
  @ffi.Uint8()
  external int _unique_consumer_label_item_13;
  @ffi.Uint8()
  external int _unique_consumer_label_item_14;
  @ffi.Uint8()
  external int _unique_consumer_label_item_15;
  @ffi.Uint8()
  external int _unique_consumer_label_item_16;
  @ffi.Uint8()
  external int _unique_consumer_label_item_17;
  @ffi.Uint8()
  external int _unique_consumer_label_item_18;
  @ffi.Uint8()
  external int _unique_consumer_label_item_19;
  @ffi.Uint8()
  external int _unique_consumer_label_item_20;
  @ffi.Uint8()
  external int _unique_consumer_label_item_21;
  @ffi.Uint8()
  external int _unique_consumer_label_item_22;
  @ffi.Uint8()
  external int _unique_consumer_label_item_23;
  @ffi.Uint8()
  external int _unique_consumer_label_item_24;
  @ffi.Uint8()
  external int _unique_consumer_label_item_25;
  @ffi.Uint8()
  external int _unique_consumer_label_item_26;
  @ffi.Uint8()
  external int _unique_consumer_label_item_27;
  @ffi.Uint8()
  external int _unique_consumer_label_item_28;
  @ffi.Uint8()
  external int _unique_consumer_label_item_29;
  @ffi.Uint8()
  external int _unique_consumer_label_item_30;
  @ffi.Uint8()
  external int _unique_consumer_label_item_31;

  /// Helper for array `consumer_label`.
  ArrayHelper_gpiohandle_request_consumer_label_level0 get consumer_label =>
      ArrayHelper_gpiohandle_request_consumer_label_level0(this, [32], 0, 0);
  @ffi.Uint32()
  external int lines;

  @ffi.Int32()
  external int fd;
}

/// Helper for array `lineoffsets` in struct `gpiohandle_request`.
class ArrayHelper_gpiohandle_request_lineoffsets_level0 {
  final gpiohandle_request _struct;
  final List<int> dimensions;
  final int level;
  final int _absoluteIndex;
  int get length => dimensions[level];
  ArrayHelper_gpiohandle_request_lineoffsets_level0(this._struct, this.dimensions, this.level, this._absoluteIndex);
  void _checkBounds(int index) {
    if (index >= length || index < 0) {
      throw RangeError('Dimension $level: index not in range 0..$length exclusive.');
    }
  }

  int operator [](int index) {
    _checkBounds(index);
    switch (_absoluteIndex + index) {
      case 0:
        return _struct._unique_lineoffsets_item_0;
      case 1:
        return _struct._unique_lineoffsets_item_1;
      case 2:
        return _struct._unique_lineoffsets_item_2;
      case 3:
        return _struct._unique_lineoffsets_item_3;
      case 4:
        return _struct._unique_lineoffsets_item_4;
      case 5:
        return _struct._unique_lineoffsets_item_5;
      case 6:
        return _struct._unique_lineoffsets_item_6;
      case 7:
        return _struct._unique_lineoffsets_item_7;
      case 8:
        return _struct._unique_lineoffsets_item_8;
      case 9:
        return _struct._unique_lineoffsets_item_9;
      case 10:
        return _struct._unique_lineoffsets_item_10;
      case 11:
        return _struct._unique_lineoffsets_item_11;
      case 12:
        return _struct._unique_lineoffsets_item_12;
      case 13:
        return _struct._unique_lineoffsets_item_13;
      case 14:
        return _struct._unique_lineoffsets_item_14;
      case 15:
        return _struct._unique_lineoffsets_item_15;
      case 16:
        return _struct._unique_lineoffsets_item_16;
      case 17:
        return _struct._unique_lineoffsets_item_17;
      case 18:
        return _struct._unique_lineoffsets_item_18;
      case 19:
        return _struct._unique_lineoffsets_item_19;
      case 20:
        return _struct._unique_lineoffsets_item_20;
      case 21:
        return _struct._unique_lineoffsets_item_21;
      case 22:
        return _struct._unique_lineoffsets_item_22;
      case 23:
        return _struct._unique_lineoffsets_item_23;
      case 24:
        return _struct._unique_lineoffsets_item_24;
      case 25:
        return _struct._unique_lineoffsets_item_25;
      case 26:
        return _struct._unique_lineoffsets_item_26;
      case 27:
        return _struct._unique_lineoffsets_item_27;
      case 28:
        return _struct._unique_lineoffsets_item_28;
      case 29:
        return _struct._unique_lineoffsets_item_29;
      case 30:
        return _struct._unique_lineoffsets_item_30;
      case 31:
        return _struct._unique_lineoffsets_item_31;
      case 32:
        return _struct._unique_lineoffsets_item_32;
      case 33:
        return _struct._unique_lineoffsets_item_33;
      case 34:
        return _struct._unique_lineoffsets_item_34;
      case 35:
        return _struct._unique_lineoffsets_item_35;
      case 36:
        return _struct._unique_lineoffsets_item_36;
      case 37:
        return _struct._unique_lineoffsets_item_37;
      case 38:
        return _struct._unique_lineoffsets_item_38;
      case 39:
        return _struct._unique_lineoffsets_item_39;
      case 40:
        return _struct._unique_lineoffsets_item_40;
      case 41:
        return _struct._unique_lineoffsets_item_41;
      case 42:
        return _struct._unique_lineoffsets_item_42;
      case 43:
        return _struct._unique_lineoffsets_item_43;
      case 44:
        return _struct._unique_lineoffsets_item_44;
      case 45:
        return _struct._unique_lineoffsets_item_45;
      case 46:
        return _struct._unique_lineoffsets_item_46;
      case 47:
        return _struct._unique_lineoffsets_item_47;
      case 48:
        return _struct._unique_lineoffsets_item_48;
      case 49:
        return _struct._unique_lineoffsets_item_49;
      case 50:
        return _struct._unique_lineoffsets_item_50;
      case 51:
        return _struct._unique_lineoffsets_item_51;
      case 52:
        return _struct._unique_lineoffsets_item_52;
      case 53:
        return _struct._unique_lineoffsets_item_53;
      case 54:
        return _struct._unique_lineoffsets_item_54;
      case 55:
        return _struct._unique_lineoffsets_item_55;
      case 56:
        return _struct._unique_lineoffsets_item_56;
      case 57:
        return _struct._unique_lineoffsets_item_57;
      case 58:
        return _struct._unique_lineoffsets_item_58;
      case 59:
        return _struct._unique_lineoffsets_item_59;
      case 60:
        return _struct._unique_lineoffsets_item_60;
      case 61:
        return _struct._unique_lineoffsets_item_61;
      case 62:
        return _struct._unique_lineoffsets_item_62;
      case 63:
        return _struct._unique_lineoffsets_item_63;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }

  void operator []=(int index, int value) {
    _checkBounds(index);
    switch (_absoluteIndex + index) {
      case 0:
        _struct._unique_lineoffsets_item_0 = value;
        break;
      case 1:
        _struct._unique_lineoffsets_item_1 = value;
        break;
      case 2:
        _struct._unique_lineoffsets_item_2 = value;
        break;
      case 3:
        _struct._unique_lineoffsets_item_3 = value;
        break;
      case 4:
        _struct._unique_lineoffsets_item_4 = value;
        break;
      case 5:
        _struct._unique_lineoffsets_item_5 = value;
        break;
      case 6:
        _struct._unique_lineoffsets_item_6 = value;
        break;
      case 7:
        _struct._unique_lineoffsets_item_7 = value;
        break;
      case 8:
        _struct._unique_lineoffsets_item_8 = value;
        break;
      case 9:
        _struct._unique_lineoffsets_item_9 = value;
        break;
      case 10:
        _struct._unique_lineoffsets_item_10 = value;
        break;
      case 11:
        _struct._unique_lineoffsets_item_11 = value;
        break;
      case 12:
        _struct._unique_lineoffsets_item_12 = value;
        break;
      case 13:
        _struct._unique_lineoffsets_item_13 = value;
        break;
      case 14:
        _struct._unique_lineoffsets_item_14 = value;
        break;
      case 15:
        _struct._unique_lineoffsets_item_15 = value;
        break;
      case 16:
        _struct._unique_lineoffsets_item_16 = value;
        break;
      case 17:
        _struct._unique_lineoffsets_item_17 = value;
        break;
      case 18:
        _struct._unique_lineoffsets_item_18 = value;
        break;
      case 19:
        _struct._unique_lineoffsets_item_19 = value;
        break;
      case 20:
        _struct._unique_lineoffsets_item_20 = value;
        break;
      case 21:
        _struct._unique_lineoffsets_item_21 = value;
        break;
      case 22:
        _struct._unique_lineoffsets_item_22 = value;
        break;
      case 23:
        _struct._unique_lineoffsets_item_23 = value;
        break;
      case 24:
        _struct._unique_lineoffsets_item_24 = value;
        break;
      case 25:
        _struct._unique_lineoffsets_item_25 = value;
        break;
      case 26:
        _struct._unique_lineoffsets_item_26 = value;
        break;
      case 27:
        _struct._unique_lineoffsets_item_27 = value;
        break;
      case 28:
        _struct._unique_lineoffsets_item_28 = value;
        break;
      case 29:
        _struct._unique_lineoffsets_item_29 = value;
        break;
      case 30:
        _struct._unique_lineoffsets_item_30 = value;
        break;
      case 31:
        _struct._unique_lineoffsets_item_31 = value;
        break;
      case 32:
        _struct._unique_lineoffsets_item_32 = value;
        break;
      case 33:
        _struct._unique_lineoffsets_item_33 = value;
        break;
      case 34:
        _struct._unique_lineoffsets_item_34 = value;
        break;
      case 35:
        _struct._unique_lineoffsets_item_35 = value;
        break;
      case 36:
        _struct._unique_lineoffsets_item_36 = value;
        break;
      case 37:
        _struct._unique_lineoffsets_item_37 = value;
        break;
      case 38:
        _struct._unique_lineoffsets_item_38 = value;
        break;
      case 39:
        _struct._unique_lineoffsets_item_39 = value;
        break;
      case 40:
        _struct._unique_lineoffsets_item_40 = value;
        break;
      case 41:
        _struct._unique_lineoffsets_item_41 = value;
        break;
      case 42:
        _struct._unique_lineoffsets_item_42 = value;
        break;
      case 43:
        _struct._unique_lineoffsets_item_43 = value;
        break;
      case 44:
        _struct._unique_lineoffsets_item_44 = value;
        break;
      case 45:
        _struct._unique_lineoffsets_item_45 = value;
        break;
      case 46:
        _struct._unique_lineoffsets_item_46 = value;
        break;
      case 47:
        _struct._unique_lineoffsets_item_47 = value;
        break;
      case 48:
        _struct._unique_lineoffsets_item_48 = value;
        break;
      case 49:
        _struct._unique_lineoffsets_item_49 = value;
        break;
      case 50:
        _struct._unique_lineoffsets_item_50 = value;
        break;
      case 51:
        _struct._unique_lineoffsets_item_51 = value;
        break;
      case 52:
        _struct._unique_lineoffsets_item_52 = value;
        break;
      case 53:
        _struct._unique_lineoffsets_item_53 = value;
        break;
      case 54:
        _struct._unique_lineoffsets_item_54 = value;
        break;
      case 55:
        _struct._unique_lineoffsets_item_55 = value;
        break;
      case 56:
        _struct._unique_lineoffsets_item_56 = value;
        break;
      case 57:
        _struct._unique_lineoffsets_item_57 = value;
        break;
      case 58:
        _struct._unique_lineoffsets_item_58 = value;
        break;
      case 59:
        _struct._unique_lineoffsets_item_59 = value;
        break;
      case 60:
        _struct._unique_lineoffsets_item_60 = value;
        break;
      case 61:
        _struct._unique_lineoffsets_item_61 = value;
        break;
      case 62:
        _struct._unique_lineoffsets_item_62 = value;
        break;
      case 63:
        _struct._unique_lineoffsets_item_63 = value;
        break;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }
}

/// Helper for array `default_values` in struct `gpiohandle_request`.
class ArrayHelper_gpiohandle_request_default_values_level0 {
  final gpiohandle_request _struct;
  final List<int> dimensions;
  final int level;
  final int _absoluteIndex;
  int get length => dimensions[level];
  ArrayHelper_gpiohandle_request_default_values_level0(this._struct, this.dimensions, this.level, this._absoluteIndex);
  void _checkBounds(int index) {
    if (index >= length || index < 0) {
      throw RangeError('Dimension $level: index not in range 0..$length exclusive.');
    }
  }

  int operator [](int index) {
    _checkBounds(index);
    switch (_absoluteIndex + index) {
      case 0:
        return _struct._unique_default_values_item_0;
      case 1:
        return _struct._unique_default_values_item_1;
      case 2:
        return _struct._unique_default_values_item_2;
      case 3:
        return _struct._unique_default_values_item_3;
      case 4:
        return _struct._unique_default_values_item_4;
      case 5:
        return _struct._unique_default_values_item_5;
      case 6:
        return _struct._unique_default_values_item_6;
      case 7:
        return _struct._unique_default_values_item_7;
      case 8:
        return _struct._unique_default_values_item_8;
      case 9:
        return _struct._unique_default_values_item_9;
      case 10:
        return _struct._unique_default_values_item_10;
      case 11:
        return _struct._unique_default_values_item_11;
      case 12:
        return _struct._unique_default_values_item_12;
      case 13:
        return _struct._unique_default_values_item_13;
      case 14:
        return _struct._unique_default_values_item_14;
      case 15:
        return _struct._unique_default_values_item_15;
      case 16:
        return _struct._unique_default_values_item_16;
      case 17:
        return _struct._unique_default_values_item_17;
      case 18:
        return _struct._unique_default_values_item_18;
      case 19:
        return _struct._unique_default_values_item_19;
      case 20:
        return _struct._unique_default_values_item_20;
      case 21:
        return _struct._unique_default_values_item_21;
      case 22:
        return _struct._unique_default_values_item_22;
      case 23:
        return _struct._unique_default_values_item_23;
      case 24:
        return _struct._unique_default_values_item_24;
      case 25:
        return _struct._unique_default_values_item_25;
      case 26:
        return _struct._unique_default_values_item_26;
      case 27:
        return _struct._unique_default_values_item_27;
      case 28:
        return _struct._unique_default_values_item_28;
      case 29:
        return _struct._unique_default_values_item_29;
      case 30:
        return _struct._unique_default_values_item_30;
      case 31:
        return _struct._unique_default_values_item_31;
      case 32:
        return _struct._unique_default_values_item_32;
      case 33:
        return _struct._unique_default_values_item_33;
      case 34:
        return _struct._unique_default_values_item_34;
      case 35:
        return _struct._unique_default_values_item_35;
      case 36:
        return _struct._unique_default_values_item_36;
      case 37:
        return _struct._unique_default_values_item_37;
      case 38:
        return _struct._unique_default_values_item_38;
      case 39:
        return _struct._unique_default_values_item_39;
      case 40:
        return _struct._unique_default_values_item_40;
      case 41:
        return _struct._unique_default_values_item_41;
      case 42:
        return _struct._unique_default_values_item_42;
      case 43:
        return _struct._unique_default_values_item_43;
      case 44:
        return _struct._unique_default_values_item_44;
      case 45:
        return _struct._unique_default_values_item_45;
      case 46:
        return _struct._unique_default_values_item_46;
      case 47:
        return _struct._unique_default_values_item_47;
      case 48:
        return _struct._unique_default_values_item_48;
      case 49:
        return _struct._unique_default_values_item_49;
      case 50:
        return _struct._unique_default_values_item_50;
      case 51:
        return _struct._unique_default_values_item_51;
      case 52:
        return _struct._unique_default_values_item_52;
      case 53:
        return _struct._unique_default_values_item_53;
      case 54:
        return _struct._unique_default_values_item_54;
      case 55:
        return _struct._unique_default_values_item_55;
      case 56:
        return _struct._unique_default_values_item_56;
      case 57:
        return _struct._unique_default_values_item_57;
      case 58:
        return _struct._unique_default_values_item_58;
      case 59:
        return _struct._unique_default_values_item_59;
      case 60:
        return _struct._unique_default_values_item_60;
      case 61:
        return _struct._unique_default_values_item_61;
      case 62:
        return _struct._unique_default_values_item_62;
      case 63:
        return _struct._unique_default_values_item_63;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }

  void operator []=(int index, int value) {
    _checkBounds(index);
    switch (_absoluteIndex + index) {
      case 0:
        _struct._unique_default_values_item_0 = value;
        break;
      case 1:
        _struct._unique_default_values_item_1 = value;
        break;
      case 2:
        _struct._unique_default_values_item_2 = value;
        break;
      case 3:
        _struct._unique_default_values_item_3 = value;
        break;
      case 4:
        _struct._unique_default_values_item_4 = value;
        break;
      case 5:
        _struct._unique_default_values_item_5 = value;
        break;
      case 6:
        _struct._unique_default_values_item_6 = value;
        break;
      case 7:
        _struct._unique_default_values_item_7 = value;
        break;
      case 8:
        _struct._unique_default_values_item_8 = value;
        break;
      case 9:
        _struct._unique_default_values_item_9 = value;
        break;
      case 10:
        _struct._unique_default_values_item_10 = value;
        break;
      case 11:
        _struct._unique_default_values_item_11 = value;
        break;
      case 12:
        _struct._unique_default_values_item_12 = value;
        break;
      case 13:
        _struct._unique_default_values_item_13 = value;
        break;
      case 14:
        _struct._unique_default_values_item_14 = value;
        break;
      case 15:
        _struct._unique_default_values_item_15 = value;
        break;
      case 16:
        _struct._unique_default_values_item_16 = value;
        break;
      case 17:
        _struct._unique_default_values_item_17 = value;
        break;
      case 18:
        _struct._unique_default_values_item_18 = value;
        break;
      case 19:
        _struct._unique_default_values_item_19 = value;
        break;
      case 20:
        _struct._unique_default_values_item_20 = value;
        break;
      case 21:
        _struct._unique_default_values_item_21 = value;
        break;
      case 22:
        _struct._unique_default_values_item_22 = value;
        break;
      case 23:
        _struct._unique_default_values_item_23 = value;
        break;
      case 24:
        _struct._unique_default_values_item_24 = value;
        break;
      case 25:
        _struct._unique_default_values_item_25 = value;
        break;
      case 26:
        _struct._unique_default_values_item_26 = value;
        break;
      case 27:
        _struct._unique_default_values_item_27 = value;
        break;
      case 28:
        _struct._unique_default_values_item_28 = value;
        break;
      case 29:
        _struct._unique_default_values_item_29 = value;
        break;
      case 30:
        _struct._unique_default_values_item_30 = value;
        break;
      case 31:
        _struct._unique_default_values_item_31 = value;
        break;
      case 32:
        _struct._unique_default_values_item_32 = value;
        break;
      case 33:
        _struct._unique_default_values_item_33 = value;
        break;
      case 34:
        _struct._unique_default_values_item_34 = value;
        break;
      case 35:
        _struct._unique_default_values_item_35 = value;
        break;
      case 36:
        _struct._unique_default_values_item_36 = value;
        break;
      case 37:
        _struct._unique_default_values_item_37 = value;
        break;
      case 38:
        _struct._unique_default_values_item_38 = value;
        break;
      case 39:
        _struct._unique_default_values_item_39 = value;
        break;
      case 40:
        _struct._unique_default_values_item_40 = value;
        break;
      case 41:
        _struct._unique_default_values_item_41 = value;
        break;
      case 42:
        _struct._unique_default_values_item_42 = value;
        break;
      case 43:
        _struct._unique_default_values_item_43 = value;
        break;
      case 44:
        _struct._unique_default_values_item_44 = value;
        break;
      case 45:
        _struct._unique_default_values_item_45 = value;
        break;
      case 46:
        _struct._unique_default_values_item_46 = value;
        break;
      case 47:
        _struct._unique_default_values_item_47 = value;
        break;
      case 48:
        _struct._unique_default_values_item_48 = value;
        break;
      case 49:
        _struct._unique_default_values_item_49 = value;
        break;
      case 50:
        _struct._unique_default_values_item_50 = value;
        break;
      case 51:
        _struct._unique_default_values_item_51 = value;
        break;
      case 52:
        _struct._unique_default_values_item_52 = value;
        break;
      case 53:
        _struct._unique_default_values_item_53 = value;
        break;
      case 54:
        _struct._unique_default_values_item_54 = value;
        break;
      case 55:
        _struct._unique_default_values_item_55 = value;
        break;
      case 56:
        _struct._unique_default_values_item_56 = value;
        break;
      case 57:
        _struct._unique_default_values_item_57 = value;
        break;
      case 58:
        _struct._unique_default_values_item_58 = value;
        break;
      case 59:
        _struct._unique_default_values_item_59 = value;
        break;
      case 60:
        _struct._unique_default_values_item_60 = value;
        break;
      case 61:
        _struct._unique_default_values_item_61 = value;
        break;
      case 62:
        _struct._unique_default_values_item_62 = value;
        break;
      case 63:
        _struct._unique_default_values_item_63 = value;
        break;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }
}

/// Helper for array `consumer_label` in struct `gpiohandle_request`.
class ArrayHelper_gpiohandle_request_consumer_label_level0 {
  final gpiohandle_request _struct;
  final List<int> dimensions;
  final int level;
  final int _absoluteIndex;
  int get length => dimensions[level];
  ArrayHelper_gpiohandle_request_consumer_label_level0(this._struct, this.dimensions, this.level, this._absoluteIndex);
  void _checkBounds(int index) {
    if (index >= length || index < 0) {
      throw RangeError('Dimension $level: index not in range 0..$length exclusive.');
    }
  }

  int operator [](int index) {
    _checkBounds(index);
    switch (_absoluteIndex + index) {
      case 0:
        return _struct._unique_consumer_label_item_0;
      case 1:
        return _struct._unique_consumer_label_item_1;
      case 2:
        return _struct._unique_consumer_label_item_2;
      case 3:
        return _struct._unique_consumer_label_item_3;
      case 4:
        return _struct._unique_consumer_label_item_4;
      case 5:
        return _struct._unique_consumer_label_item_5;
      case 6:
        return _struct._unique_consumer_label_item_6;
      case 7:
        return _struct._unique_consumer_label_item_7;
      case 8:
        return _struct._unique_consumer_label_item_8;
      case 9:
        return _struct._unique_consumer_label_item_9;
      case 10:
        return _struct._unique_consumer_label_item_10;
      case 11:
        return _struct._unique_consumer_label_item_11;
      case 12:
        return _struct._unique_consumer_label_item_12;
      case 13:
        return _struct._unique_consumer_label_item_13;
      case 14:
        return _struct._unique_consumer_label_item_14;
      case 15:
        return _struct._unique_consumer_label_item_15;
      case 16:
        return _struct._unique_consumer_label_item_16;
      case 17:
        return _struct._unique_consumer_label_item_17;
      case 18:
        return _struct._unique_consumer_label_item_18;
      case 19:
        return _struct._unique_consumer_label_item_19;
      case 20:
        return _struct._unique_consumer_label_item_20;
      case 21:
        return _struct._unique_consumer_label_item_21;
      case 22:
        return _struct._unique_consumer_label_item_22;
      case 23:
        return _struct._unique_consumer_label_item_23;
      case 24:
        return _struct._unique_consumer_label_item_24;
      case 25:
        return _struct._unique_consumer_label_item_25;
      case 26:
        return _struct._unique_consumer_label_item_26;
      case 27:
        return _struct._unique_consumer_label_item_27;
      case 28:
        return _struct._unique_consumer_label_item_28;
      case 29:
        return _struct._unique_consumer_label_item_29;
      case 30:
        return _struct._unique_consumer_label_item_30;
      case 31:
        return _struct._unique_consumer_label_item_31;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }

  void operator []=(int index, int value) {
    _checkBounds(index);
    switch (_absoluteIndex + index) {
      case 0:
        _struct._unique_consumer_label_item_0 = value;
        break;
      case 1:
        _struct._unique_consumer_label_item_1 = value;
        break;
      case 2:
        _struct._unique_consumer_label_item_2 = value;
        break;
      case 3:
        _struct._unique_consumer_label_item_3 = value;
        break;
      case 4:
        _struct._unique_consumer_label_item_4 = value;
        break;
      case 5:
        _struct._unique_consumer_label_item_5 = value;
        break;
      case 6:
        _struct._unique_consumer_label_item_6 = value;
        break;
      case 7:
        _struct._unique_consumer_label_item_7 = value;
        break;
      case 8:
        _struct._unique_consumer_label_item_8 = value;
        break;
      case 9:
        _struct._unique_consumer_label_item_9 = value;
        break;
      case 10:
        _struct._unique_consumer_label_item_10 = value;
        break;
      case 11:
        _struct._unique_consumer_label_item_11 = value;
        break;
      case 12:
        _struct._unique_consumer_label_item_12 = value;
        break;
      case 13:
        _struct._unique_consumer_label_item_13 = value;
        break;
      case 14:
        _struct._unique_consumer_label_item_14 = value;
        break;
      case 15:
        _struct._unique_consumer_label_item_15 = value;
        break;
      case 16:
        _struct._unique_consumer_label_item_16 = value;
        break;
      case 17:
        _struct._unique_consumer_label_item_17 = value;
        break;
      case 18:
        _struct._unique_consumer_label_item_18 = value;
        break;
      case 19:
        _struct._unique_consumer_label_item_19 = value;
        break;
      case 20:
        _struct._unique_consumer_label_item_20 = value;
        break;
      case 21:
        _struct._unique_consumer_label_item_21 = value;
        break;
      case 22:
        _struct._unique_consumer_label_item_22 = value;
        break;
      case 23:
        _struct._unique_consumer_label_item_23 = value;
        break;
      case 24:
        _struct._unique_consumer_label_item_24 = value;
        break;
      case 25:
        _struct._unique_consumer_label_item_25 = value;
        break;
      case 26:
        _struct._unique_consumer_label_item_26 = value;
        break;
      case 27:
        _struct._unique_consumer_label_item_27 = value;
        break;
      case 28:
        _struct._unique_consumer_label_item_28 = value;
        break;
      case 29:
        _struct._unique_consumer_label_item_29 = value;
        break;
      case 30:
        _struct._unique_consumer_label_item_30 = value;
        break;
      case 31:
        _struct._unique_consumer_label_item_31 = value;
        break;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }
}

/// struct gpiohandle_config - Configuration for a GPIO handle request
/// @flags: updated flags for the requested GPIO lines, such as
/// %GPIOHANDLE_REQUEST_OUTPUT, %GPIOHANDLE_REQUEST_ACTIVE_LOW etc, added
/// together
/// @default_values: if the %GPIOHANDLE_REQUEST_OUTPUT is set in flags,
/// this specifies the default output value, should be 0 (low) or
/// 1 (high), anything else than 0 or 1 will be interpreted as 1 (high)
/// @padding: reserved for future use and should be zero filled
///
/// Note: This struct is part of ABI v1 and is deprecated.
/// Use &struct gpio_v2_line_config instead.
class gpiohandle_config extends ffi.Struct {
  @ffi.Uint32()
  external int flags;

  @ffi.Uint8()
  external int _unique_default_values_item_0;
  @ffi.Uint8()
  external int _unique_default_values_item_1;
  @ffi.Uint8()
  external int _unique_default_values_item_2;
  @ffi.Uint8()
  external int _unique_default_values_item_3;
  @ffi.Uint8()
  external int _unique_default_values_item_4;
  @ffi.Uint8()
  external int _unique_default_values_item_5;
  @ffi.Uint8()
  external int _unique_default_values_item_6;
  @ffi.Uint8()
  external int _unique_default_values_item_7;
  @ffi.Uint8()
  external int _unique_default_values_item_8;
  @ffi.Uint8()
  external int _unique_default_values_item_9;
  @ffi.Uint8()
  external int _unique_default_values_item_10;
  @ffi.Uint8()
  external int _unique_default_values_item_11;
  @ffi.Uint8()
  external int _unique_default_values_item_12;
  @ffi.Uint8()
  external int _unique_default_values_item_13;
  @ffi.Uint8()
  external int _unique_default_values_item_14;
  @ffi.Uint8()
  external int _unique_default_values_item_15;
  @ffi.Uint8()
  external int _unique_default_values_item_16;
  @ffi.Uint8()
  external int _unique_default_values_item_17;
  @ffi.Uint8()
  external int _unique_default_values_item_18;
  @ffi.Uint8()
  external int _unique_default_values_item_19;
  @ffi.Uint8()
  external int _unique_default_values_item_20;
  @ffi.Uint8()
  external int _unique_default_values_item_21;
  @ffi.Uint8()
  external int _unique_default_values_item_22;
  @ffi.Uint8()
  external int _unique_default_values_item_23;
  @ffi.Uint8()
  external int _unique_default_values_item_24;
  @ffi.Uint8()
  external int _unique_default_values_item_25;
  @ffi.Uint8()
  external int _unique_default_values_item_26;
  @ffi.Uint8()
  external int _unique_default_values_item_27;
  @ffi.Uint8()
  external int _unique_default_values_item_28;
  @ffi.Uint8()
  external int _unique_default_values_item_29;
  @ffi.Uint8()
  external int _unique_default_values_item_30;
  @ffi.Uint8()
  external int _unique_default_values_item_31;
  @ffi.Uint8()
  external int _unique_default_values_item_32;
  @ffi.Uint8()
  external int _unique_default_values_item_33;
  @ffi.Uint8()
  external int _unique_default_values_item_34;
  @ffi.Uint8()
  external int _unique_default_values_item_35;
  @ffi.Uint8()
  external int _unique_default_values_item_36;
  @ffi.Uint8()
  external int _unique_default_values_item_37;
  @ffi.Uint8()
  external int _unique_default_values_item_38;
  @ffi.Uint8()
  external int _unique_default_values_item_39;
  @ffi.Uint8()
  external int _unique_default_values_item_40;
  @ffi.Uint8()
  external int _unique_default_values_item_41;
  @ffi.Uint8()
  external int _unique_default_values_item_42;
  @ffi.Uint8()
  external int _unique_default_values_item_43;
  @ffi.Uint8()
  external int _unique_default_values_item_44;
  @ffi.Uint8()
  external int _unique_default_values_item_45;
  @ffi.Uint8()
  external int _unique_default_values_item_46;
  @ffi.Uint8()
  external int _unique_default_values_item_47;
  @ffi.Uint8()
  external int _unique_default_values_item_48;
  @ffi.Uint8()
  external int _unique_default_values_item_49;
  @ffi.Uint8()
  external int _unique_default_values_item_50;
  @ffi.Uint8()
  external int _unique_default_values_item_51;
  @ffi.Uint8()
  external int _unique_default_values_item_52;
  @ffi.Uint8()
  external int _unique_default_values_item_53;
  @ffi.Uint8()
  external int _unique_default_values_item_54;
  @ffi.Uint8()
  external int _unique_default_values_item_55;
  @ffi.Uint8()
  external int _unique_default_values_item_56;
  @ffi.Uint8()
  external int _unique_default_values_item_57;
  @ffi.Uint8()
  external int _unique_default_values_item_58;
  @ffi.Uint8()
  external int _unique_default_values_item_59;
  @ffi.Uint8()
  external int _unique_default_values_item_60;
  @ffi.Uint8()
  external int _unique_default_values_item_61;
  @ffi.Uint8()
  external int _unique_default_values_item_62;
  @ffi.Uint8()
  external int _unique_default_values_item_63;

  /// Helper for array `default_values`.
  ArrayHelper_gpiohandle_config_default_values_level0 get default_values =>
      ArrayHelper_gpiohandle_config_default_values_level0(this, [64], 0, 0);
  @ffi.Uint32()
  external int _unique_padding_item_0;
  @ffi.Uint32()
  external int _unique_padding_item_1;
  @ffi.Uint32()
  external int _unique_padding_item_2;
  @ffi.Uint32()
  external int _unique_padding_item_3;

  /// Helper for array `padding`.
  ArrayHelper_gpiohandle_config_padding_level0 get padding =>
      ArrayHelper_gpiohandle_config_padding_level0(this, [4], 0, 0);
}

/// Helper for array `default_values` in struct `gpiohandle_config`.
class ArrayHelper_gpiohandle_config_default_values_level0 {
  final gpiohandle_config _struct;
  final List<int> dimensions;
  final int level;
  final int _absoluteIndex;
  int get length => dimensions[level];
  ArrayHelper_gpiohandle_config_default_values_level0(this._struct, this.dimensions, this.level, this._absoluteIndex);
  void _checkBounds(int index) {
    if (index >= length || index < 0) {
      throw RangeError('Dimension $level: index not in range 0..$length exclusive.');
    }
  }

  int operator [](int index) {
    _checkBounds(index);
    switch (_absoluteIndex + index) {
      case 0:
        return _struct._unique_default_values_item_0;
      case 1:
        return _struct._unique_default_values_item_1;
      case 2:
        return _struct._unique_default_values_item_2;
      case 3:
        return _struct._unique_default_values_item_3;
      case 4:
        return _struct._unique_default_values_item_4;
      case 5:
        return _struct._unique_default_values_item_5;
      case 6:
        return _struct._unique_default_values_item_6;
      case 7:
        return _struct._unique_default_values_item_7;
      case 8:
        return _struct._unique_default_values_item_8;
      case 9:
        return _struct._unique_default_values_item_9;
      case 10:
        return _struct._unique_default_values_item_10;
      case 11:
        return _struct._unique_default_values_item_11;
      case 12:
        return _struct._unique_default_values_item_12;
      case 13:
        return _struct._unique_default_values_item_13;
      case 14:
        return _struct._unique_default_values_item_14;
      case 15:
        return _struct._unique_default_values_item_15;
      case 16:
        return _struct._unique_default_values_item_16;
      case 17:
        return _struct._unique_default_values_item_17;
      case 18:
        return _struct._unique_default_values_item_18;
      case 19:
        return _struct._unique_default_values_item_19;
      case 20:
        return _struct._unique_default_values_item_20;
      case 21:
        return _struct._unique_default_values_item_21;
      case 22:
        return _struct._unique_default_values_item_22;
      case 23:
        return _struct._unique_default_values_item_23;
      case 24:
        return _struct._unique_default_values_item_24;
      case 25:
        return _struct._unique_default_values_item_25;
      case 26:
        return _struct._unique_default_values_item_26;
      case 27:
        return _struct._unique_default_values_item_27;
      case 28:
        return _struct._unique_default_values_item_28;
      case 29:
        return _struct._unique_default_values_item_29;
      case 30:
        return _struct._unique_default_values_item_30;
      case 31:
        return _struct._unique_default_values_item_31;
      case 32:
        return _struct._unique_default_values_item_32;
      case 33:
        return _struct._unique_default_values_item_33;
      case 34:
        return _struct._unique_default_values_item_34;
      case 35:
        return _struct._unique_default_values_item_35;
      case 36:
        return _struct._unique_default_values_item_36;
      case 37:
        return _struct._unique_default_values_item_37;
      case 38:
        return _struct._unique_default_values_item_38;
      case 39:
        return _struct._unique_default_values_item_39;
      case 40:
        return _struct._unique_default_values_item_40;
      case 41:
        return _struct._unique_default_values_item_41;
      case 42:
        return _struct._unique_default_values_item_42;
      case 43:
        return _struct._unique_default_values_item_43;
      case 44:
        return _struct._unique_default_values_item_44;
      case 45:
        return _struct._unique_default_values_item_45;
      case 46:
        return _struct._unique_default_values_item_46;
      case 47:
        return _struct._unique_default_values_item_47;
      case 48:
        return _struct._unique_default_values_item_48;
      case 49:
        return _struct._unique_default_values_item_49;
      case 50:
        return _struct._unique_default_values_item_50;
      case 51:
        return _struct._unique_default_values_item_51;
      case 52:
        return _struct._unique_default_values_item_52;
      case 53:
        return _struct._unique_default_values_item_53;
      case 54:
        return _struct._unique_default_values_item_54;
      case 55:
        return _struct._unique_default_values_item_55;
      case 56:
        return _struct._unique_default_values_item_56;
      case 57:
        return _struct._unique_default_values_item_57;
      case 58:
        return _struct._unique_default_values_item_58;
      case 59:
        return _struct._unique_default_values_item_59;
      case 60:
        return _struct._unique_default_values_item_60;
      case 61:
        return _struct._unique_default_values_item_61;
      case 62:
        return _struct._unique_default_values_item_62;
      case 63:
        return _struct._unique_default_values_item_63;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }

  void operator []=(int index, int value) {
    _checkBounds(index);
    switch (_absoluteIndex + index) {
      case 0:
        _struct._unique_default_values_item_0 = value;
        break;
      case 1:
        _struct._unique_default_values_item_1 = value;
        break;
      case 2:
        _struct._unique_default_values_item_2 = value;
        break;
      case 3:
        _struct._unique_default_values_item_3 = value;
        break;
      case 4:
        _struct._unique_default_values_item_4 = value;
        break;
      case 5:
        _struct._unique_default_values_item_5 = value;
        break;
      case 6:
        _struct._unique_default_values_item_6 = value;
        break;
      case 7:
        _struct._unique_default_values_item_7 = value;
        break;
      case 8:
        _struct._unique_default_values_item_8 = value;
        break;
      case 9:
        _struct._unique_default_values_item_9 = value;
        break;
      case 10:
        _struct._unique_default_values_item_10 = value;
        break;
      case 11:
        _struct._unique_default_values_item_11 = value;
        break;
      case 12:
        _struct._unique_default_values_item_12 = value;
        break;
      case 13:
        _struct._unique_default_values_item_13 = value;
        break;
      case 14:
        _struct._unique_default_values_item_14 = value;
        break;
      case 15:
        _struct._unique_default_values_item_15 = value;
        break;
      case 16:
        _struct._unique_default_values_item_16 = value;
        break;
      case 17:
        _struct._unique_default_values_item_17 = value;
        break;
      case 18:
        _struct._unique_default_values_item_18 = value;
        break;
      case 19:
        _struct._unique_default_values_item_19 = value;
        break;
      case 20:
        _struct._unique_default_values_item_20 = value;
        break;
      case 21:
        _struct._unique_default_values_item_21 = value;
        break;
      case 22:
        _struct._unique_default_values_item_22 = value;
        break;
      case 23:
        _struct._unique_default_values_item_23 = value;
        break;
      case 24:
        _struct._unique_default_values_item_24 = value;
        break;
      case 25:
        _struct._unique_default_values_item_25 = value;
        break;
      case 26:
        _struct._unique_default_values_item_26 = value;
        break;
      case 27:
        _struct._unique_default_values_item_27 = value;
        break;
      case 28:
        _struct._unique_default_values_item_28 = value;
        break;
      case 29:
        _struct._unique_default_values_item_29 = value;
        break;
      case 30:
        _struct._unique_default_values_item_30 = value;
        break;
      case 31:
        _struct._unique_default_values_item_31 = value;
        break;
      case 32:
        _struct._unique_default_values_item_32 = value;
        break;
      case 33:
        _struct._unique_default_values_item_33 = value;
        break;
      case 34:
        _struct._unique_default_values_item_34 = value;
        break;
      case 35:
        _struct._unique_default_values_item_35 = value;
        break;
      case 36:
        _struct._unique_default_values_item_36 = value;
        break;
      case 37:
        _struct._unique_default_values_item_37 = value;
        break;
      case 38:
        _struct._unique_default_values_item_38 = value;
        break;
      case 39:
        _struct._unique_default_values_item_39 = value;
        break;
      case 40:
        _struct._unique_default_values_item_40 = value;
        break;
      case 41:
        _struct._unique_default_values_item_41 = value;
        break;
      case 42:
        _struct._unique_default_values_item_42 = value;
        break;
      case 43:
        _struct._unique_default_values_item_43 = value;
        break;
      case 44:
        _struct._unique_default_values_item_44 = value;
        break;
      case 45:
        _struct._unique_default_values_item_45 = value;
        break;
      case 46:
        _struct._unique_default_values_item_46 = value;
        break;
      case 47:
        _struct._unique_default_values_item_47 = value;
        break;
      case 48:
        _struct._unique_default_values_item_48 = value;
        break;
      case 49:
        _struct._unique_default_values_item_49 = value;
        break;
      case 50:
        _struct._unique_default_values_item_50 = value;
        break;
      case 51:
        _struct._unique_default_values_item_51 = value;
        break;
      case 52:
        _struct._unique_default_values_item_52 = value;
        break;
      case 53:
        _struct._unique_default_values_item_53 = value;
        break;
      case 54:
        _struct._unique_default_values_item_54 = value;
        break;
      case 55:
        _struct._unique_default_values_item_55 = value;
        break;
      case 56:
        _struct._unique_default_values_item_56 = value;
        break;
      case 57:
        _struct._unique_default_values_item_57 = value;
        break;
      case 58:
        _struct._unique_default_values_item_58 = value;
        break;
      case 59:
        _struct._unique_default_values_item_59 = value;
        break;
      case 60:
        _struct._unique_default_values_item_60 = value;
        break;
      case 61:
        _struct._unique_default_values_item_61 = value;
        break;
      case 62:
        _struct._unique_default_values_item_62 = value;
        break;
      case 63:
        _struct._unique_default_values_item_63 = value;
        break;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }
}

/// Helper for array `padding` in struct `gpiohandle_config`.
class ArrayHelper_gpiohandle_config_padding_level0 {
  final gpiohandle_config _struct;
  final List<int> dimensions;
  final int level;
  final int _absoluteIndex;
  int get length => dimensions[level];
  ArrayHelper_gpiohandle_config_padding_level0(this._struct, this.dimensions, this.level, this._absoluteIndex);
  void _checkBounds(int index) {
    if (index >= length || index < 0) {
      throw RangeError('Dimension $level: index not in range 0..$length exclusive.');
    }
  }

  int operator [](int index) {
    _checkBounds(index);
    switch (_absoluteIndex + index) {
      case 0:
        return _struct._unique_padding_item_0;
      case 1:
        return _struct._unique_padding_item_1;
      case 2:
        return _struct._unique_padding_item_2;
      case 3:
        return _struct._unique_padding_item_3;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }

  void operator []=(int index, int value) {
    _checkBounds(index);
    switch (_absoluteIndex + index) {
      case 0:
        _struct._unique_padding_item_0 = value;
        break;
      case 1:
        _struct._unique_padding_item_1 = value;
        break;
      case 2:
        _struct._unique_padding_item_2 = value;
        break;
      case 3:
        _struct._unique_padding_item_3 = value;
        break;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }
}

/// struct gpiohandle_data - Information of values on a GPIO handle
/// @values: when getting the state of lines this contains the current
/// state of a line, when setting the state of lines these should contain
/// the desired target state
///
/// Note: This struct is part of ABI v1 and is deprecated.
/// Use &struct gpio_v2_line_values instead.
class gpiohandle_data extends ffi.Struct {
  @ffi.Uint8()
  external int _unique_values_item_0;
  @ffi.Uint8()
  external int _unique_values_item_1;
  @ffi.Uint8()
  external int _unique_values_item_2;
  @ffi.Uint8()
  external int _unique_values_item_3;
  @ffi.Uint8()
  external int _unique_values_item_4;
  @ffi.Uint8()
  external int _unique_values_item_5;
  @ffi.Uint8()
  external int _unique_values_item_6;
  @ffi.Uint8()
  external int _unique_values_item_7;
  @ffi.Uint8()
  external int _unique_values_item_8;
  @ffi.Uint8()
  external int _unique_values_item_9;
  @ffi.Uint8()
  external int _unique_values_item_10;
  @ffi.Uint8()
  external int _unique_values_item_11;
  @ffi.Uint8()
  external int _unique_values_item_12;
  @ffi.Uint8()
  external int _unique_values_item_13;
  @ffi.Uint8()
  external int _unique_values_item_14;
  @ffi.Uint8()
  external int _unique_values_item_15;
  @ffi.Uint8()
  external int _unique_values_item_16;
  @ffi.Uint8()
  external int _unique_values_item_17;
  @ffi.Uint8()
  external int _unique_values_item_18;
  @ffi.Uint8()
  external int _unique_values_item_19;
  @ffi.Uint8()
  external int _unique_values_item_20;
  @ffi.Uint8()
  external int _unique_values_item_21;
  @ffi.Uint8()
  external int _unique_values_item_22;
  @ffi.Uint8()
  external int _unique_values_item_23;
  @ffi.Uint8()
  external int _unique_values_item_24;
  @ffi.Uint8()
  external int _unique_values_item_25;
  @ffi.Uint8()
  external int _unique_values_item_26;
  @ffi.Uint8()
  external int _unique_values_item_27;
  @ffi.Uint8()
  external int _unique_values_item_28;
  @ffi.Uint8()
  external int _unique_values_item_29;
  @ffi.Uint8()
  external int _unique_values_item_30;
  @ffi.Uint8()
  external int _unique_values_item_31;
  @ffi.Uint8()
  external int _unique_values_item_32;
  @ffi.Uint8()
  external int _unique_values_item_33;
  @ffi.Uint8()
  external int _unique_values_item_34;
  @ffi.Uint8()
  external int _unique_values_item_35;
  @ffi.Uint8()
  external int _unique_values_item_36;
  @ffi.Uint8()
  external int _unique_values_item_37;
  @ffi.Uint8()
  external int _unique_values_item_38;
  @ffi.Uint8()
  external int _unique_values_item_39;
  @ffi.Uint8()
  external int _unique_values_item_40;
  @ffi.Uint8()
  external int _unique_values_item_41;
  @ffi.Uint8()
  external int _unique_values_item_42;
  @ffi.Uint8()
  external int _unique_values_item_43;
  @ffi.Uint8()
  external int _unique_values_item_44;
  @ffi.Uint8()
  external int _unique_values_item_45;
  @ffi.Uint8()
  external int _unique_values_item_46;
  @ffi.Uint8()
  external int _unique_values_item_47;
  @ffi.Uint8()
  external int _unique_values_item_48;
  @ffi.Uint8()
  external int _unique_values_item_49;
  @ffi.Uint8()
  external int _unique_values_item_50;
  @ffi.Uint8()
  external int _unique_values_item_51;
  @ffi.Uint8()
  external int _unique_values_item_52;
  @ffi.Uint8()
  external int _unique_values_item_53;
  @ffi.Uint8()
  external int _unique_values_item_54;
  @ffi.Uint8()
  external int _unique_values_item_55;
  @ffi.Uint8()
  external int _unique_values_item_56;
  @ffi.Uint8()
  external int _unique_values_item_57;
  @ffi.Uint8()
  external int _unique_values_item_58;
  @ffi.Uint8()
  external int _unique_values_item_59;
  @ffi.Uint8()
  external int _unique_values_item_60;
  @ffi.Uint8()
  external int _unique_values_item_61;
  @ffi.Uint8()
  external int _unique_values_item_62;
  @ffi.Uint8()
  external int _unique_values_item_63;

  /// Helper for array `values`.
  ArrayHelper_gpiohandle_data_values_level0 get values => ArrayHelper_gpiohandle_data_values_level0(this, [64], 0, 0);
}

/// Helper for array `values` in struct `gpiohandle_data`.
class ArrayHelper_gpiohandle_data_values_level0 {
  final gpiohandle_data _struct;
  final List<int> dimensions;
  final int level;
  final int _absoluteIndex;
  int get length => dimensions[level];
  ArrayHelper_gpiohandle_data_values_level0(this._struct, this.dimensions, this.level, this._absoluteIndex);
  void _checkBounds(int index) {
    if (index >= length || index < 0) {
      throw RangeError('Dimension $level: index not in range 0..$length exclusive.');
    }
  }

  int operator [](int index) {
    _checkBounds(index);
    switch (_absoluteIndex + index) {
      case 0:
        return _struct._unique_values_item_0;
      case 1:
        return _struct._unique_values_item_1;
      case 2:
        return _struct._unique_values_item_2;
      case 3:
        return _struct._unique_values_item_3;
      case 4:
        return _struct._unique_values_item_4;
      case 5:
        return _struct._unique_values_item_5;
      case 6:
        return _struct._unique_values_item_6;
      case 7:
        return _struct._unique_values_item_7;
      case 8:
        return _struct._unique_values_item_8;
      case 9:
        return _struct._unique_values_item_9;
      case 10:
        return _struct._unique_values_item_10;
      case 11:
        return _struct._unique_values_item_11;
      case 12:
        return _struct._unique_values_item_12;
      case 13:
        return _struct._unique_values_item_13;
      case 14:
        return _struct._unique_values_item_14;
      case 15:
        return _struct._unique_values_item_15;
      case 16:
        return _struct._unique_values_item_16;
      case 17:
        return _struct._unique_values_item_17;
      case 18:
        return _struct._unique_values_item_18;
      case 19:
        return _struct._unique_values_item_19;
      case 20:
        return _struct._unique_values_item_20;
      case 21:
        return _struct._unique_values_item_21;
      case 22:
        return _struct._unique_values_item_22;
      case 23:
        return _struct._unique_values_item_23;
      case 24:
        return _struct._unique_values_item_24;
      case 25:
        return _struct._unique_values_item_25;
      case 26:
        return _struct._unique_values_item_26;
      case 27:
        return _struct._unique_values_item_27;
      case 28:
        return _struct._unique_values_item_28;
      case 29:
        return _struct._unique_values_item_29;
      case 30:
        return _struct._unique_values_item_30;
      case 31:
        return _struct._unique_values_item_31;
      case 32:
        return _struct._unique_values_item_32;
      case 33:
        return _struct._unique_values_item_33;
      case 34:
        return _struct._unique_values_item_34;
      case 35:
        return _struct._unique_values_item_35;
      case 36:
        return _struct._unique_values_item_36;
      case 37:
        return _struct._unique_values_item_37;
      case 38:
        return _struct._unique_values_item_38;
      case 39:
        return _struct._unique_values_item_39;
      case 40:
        return _struct._unique_values_item_40;
      case 41:
        return _struct._unique_values_item_41;
      case 42:
        return _struct._unique_values_item_42;
      case 43:
        return _struct._unique_values_item_43;
      case 44:
        return _struct._unique_values_item_44;
      case 45:
        return _struct._unique_values_item_45;
      case 46:
        return _struct._unique_values_item_46;
      case 47:
        return _struct._unique_values_item_47;
      case 48:
        return _struct._unique_values_item_48;
      case 49:
        return _struct._unique_values_item_49;
      case 50:
        return _struct._unique_values_item_50;
      case 51:
        return _struct._unique_values_item_51;
      case 52:
        return _struct._unique_values_item_52;
      case 53:
        return _struct._unique_values_item_53;
      case 54:
        return _struct._unique_values_item_54;
      case 55:
        return _struct._unique_values_item_55;
      case 56:
        return _struct._unique_values_item_56;
      case 57:
        return _struct._unique_values_item_57;
      case 58:
        return _struct._unique_values_item_58;
      case 59:
        return _struct._unique_values_item_59;
      case 60:
        return _struct._unique_values_item_60;
      case 61:
        return _struct._unique_values_item_61;
      case 62:
        return _struct._unique_values_item_62;
      case 63:
        return _struct._unique_values_item_63;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }

  void operator []=(int index, int value) {
    _checkBounds(index);
    switch (_absoluteIndex + index) {
      case 0:
        _struct._unique_values_item_0 = value;
        break;
      case 1:
        _struct._unique_values_item_1 = value;
        break;
      case 2:
        _struct._unique_values_item_2 = value;
        break;
      case 3:
        _struct._unique_values_item_3 = value;
        break;
      case 4:
        _struct._unique_values_item_4 = value;
        break;
      case 5:
        _struct._unique_values_item_5 = value;
        break;
      case 6:
        _struct._unique_values_item_6 = value;
        break;
      case 7:
        _struct._unique_values_item_7 = value;
        break;
      case 8:
        _struct._unique_values_item_8 = value;
        break;
      case 9:
        _struct._unique_values_item_9 = value;
        break;
      case 10:
        _struct._unique_values_item_10 = value;
        break;
      case 11:
        _struct._unique_values_item_11 = value;
        break;
      case 12:
        _struct._unique_values_item_12 = value;
        break;
      case 13:
        _struct._unique_values_item_13 = value;
        break;
      case 14:
        _struct._unique_values_item_14 = value;
        break;
      case 15:
        _struct._unique_values_item_15 = value;
        break;
      case 16:
        _struct._unique_values_item_16 = value;
        break;
      case 17:
        _struct._unique_values_item_17 = value;
        break;
      case 18:
        _struct._unique_values_item_18 = value;
        break;
      case 19:
        _struct._unique_values_item_19 = value;
        break;
      case 20:
        _struct._unique_values_item_20 = value;
        break;
      case 21:
        _struct._unique_values_item_21 = value;
        break;
      case 22:
        _struct._unique_values_item_22 = value;
        break;
      case 23:
        _struct._unique_values_item_23 = value;
        break;
      case 24:
        _struct._unique_values_item_24 = value;
        break;
      case 25:
        _struct._unique_values_item_25 = value;
        break;
      case 26:
        _struct._unique_values_item_26 = value;
        break;
      case 27:
        _struct._unique_values_item_27 = value;
        break;
      case 28:
        _struct._unique_values_item_28 = value;
        break;
      case 29:
        _struct._unique_values_item_29 = value;
        break;
      case 30:
        _struct._unique_values_item_30 = value;
        break;
      case 31:
        _struct._unique_values_item_31 = value;
        break;
      case 32:
        _struct._unique_values_item_32 = value;
        break;
      case 33:
        _struct._unique_values_item_33 = value;
        break;
      case 34:
        _struct._unique_values_item_34 = value;
        break;
      case 35:
        _struct._unique_values_item_35 = value;
        break;
      case 36:
        _struct._unique_values_item_36 = value;
        break;
      case 37:
        _struct._unique_values_item_37 = value;
        break;
      case 38:
        _struct._unique_values_item_38 = value;
        break;
      case 39:
        _struct._unique_values_item_39 = value;
        break;
      case 40:
        _struct._unique_values_item_40 = value;
        break;
      case 41:
        _struct._unique_values_item_41 = value;
        break;
      case 42:
        _struct._unique_values_item_42 = value;
        break;
      case 43:
        _struct._unique_values_item_43 = value;
        break;
      case 44:
        _struct._unique_values_item_44 = value;
        break;
      case 45:
        _struct._unique_values_item_45 = value;
        break;
      case 46:
        _struct._unique_values_item_46 = value;
        break;
      case 47:
        _struct._unique_values_item_47 = value;
        break;
      case 48:
        _struct._unique_values_item_48 = value;
        break;
      case 49:
        _struct._unique_values_item_49 = value;
        break;
      case 50:
        _struct._unique_values_item_50 = value;
        break;
      case 51:
        _struct._unique_values_item_51 = value;
        break;
      case 52:
        _struct._unique_values_item_52 = value;
        break;
      case 53:
        _struct._unique_values_item_53 = value;
        break;
      case 54:
        _struct._unique_values_item_54 = value;
        break;
      case 55:
        _struct._unique_values_item_55 = value;
        break;
      case 56:
        _struct._unique_values_item_56 = value;
        break;
      case 57:
        _struct._unique_values_item_57 = value;
        break;
      case 58:
        _struct._unique_values_item_58 = value;
        break;
      case 59:
        _struct._unique_values_item_59 = value;
        break;
      case 60:
        _struct._unique_values_item_60 = value;
        break;
      case 61:
        _struct._unique_values_item_61 = value;
        break;
      case 62:
        _struct._unique_values_item_62 = value;
        break;
      case 63:
        _struct._unique_values_item_63 = value;
        break;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }
}

/// struct gpioevent_request - Information about a GPIO event request
/// @lineoffset: the desired line to subscribe to events from, specified by
/// offset index for the associated GPIO device
/// @handleflags: desired handle flags for the desired GPIO line, such as
/// %GPIOHANDLE_REQUEST_ACTIVE_LOW or %GPIOHANDLE_REQUEST_OPEN_DRAIN
/// @eventflags: desired flags for the desired GPIO event line, such as
/// %GPIOEVENT_REQUEST_RISING_EDGE or %GPIOEVENT_REQUEST_FALLING_EDGE
/// @consumer_label: a desired consumer label for the selected GPIO line(s)
/// such as "my-listener"
/// @fd: if successful this field will contain a valid anonymous file handle
/// after a %GPIO_GET_LINEEVENT_IOCTL operation, zero or negative value
/// means error
///
/// Note: This struct is part of ABI v1 and is deprecated.
/// Use &struct gpio_v2_line_request instead.
class gpioevent_request extends ffi.Struct {
  @ffi.Uint32()
  external int lineoffset;

  @ffi.Uint32()
  external int handleflags;

  @ffi.Uint32()
  external int eventflags;

  @ffi.Uint8()
  external int _unique_consumer_label_item_0;
  @ffi.Uint8()
  external int _unique_consumer_label_item_1;
  @ffi.Uint8()
  external int _unique_consumer_label_item_2;
  @ffi.Uint8()
  external int _unique_consumer_label_item_3;
  @ffi.Uint8()
  external int _unique_consumer_label_item_4;
  @ffi.Uint8()
  external int _unique_consumer_label_item_5;
  @ffi.Uint8()
  external int _unique_consumer_label_item_6;
  @ffi.Uint8()
  external int _unique_consumer_label_item_7;
  @ffi.Uint8()
  external int _unique_consumer_label_item_8;
  @ffi.Uint8()
  external int _unique_consumer_label_item_9;
  @ffi.Uint8()
  external int _unique_consumer_label_item_10;
  @ffi.Uint8()
  external int _unique_consumer_label_item_11;
  @ffi.Uint8()
  external int _unique_consumer_label_item_12;
  @ffi.Uint8()
  external int _unique_consumer_label_item_13;
  @ffi.Uint8()
  external int _unique_consumer_label_item_14;
  @ffi.Uint8()
  external int _unique_consumer_label_item_15;
  @ffi.Uint8()
  external int _unique_consumer_label_item_16;
  @ffi.Uint8()
  external int _unique_consumer_label_item_17;
  @ffi.Uint8()
  external int _unique_consumer_label_item_18;
  @ffi.Uint8()
  external int _unique_consumer_label_item_19;
  @ffi.Uint8()
  external int _unique_consumer_label_item_20;
  @ffi.Uint8()
  external int _unique_consumer_label_item_21;
  @ffi.Uint8()
  external int _unique_consumer_label_item_22;
  @ffi.Uint8()
  external int _unique_consumer_label_item_23;
  @ffi.Uint8()
  external int _unique_consumer_label_item_24;
  @ffi.Uint8()
  external int _unique_consumer_label_item_25;
  @ffi.Uint8()
  external int _unique_consumer_label_item_26;
  @ffi.Uint8()
  external int _unique_consumer_label_item_27;
  @ffi.Uint8()
  external int _unique_consumer_label_item_28;
  @ffi.Uint8()
  external int _unique_consumer_label_item_29;
  @ffi.Uint8()
  external int _unique_consumer_label_item_30;
  @ffi.Uint8()
  external int _unique_consumer_label_item_31;

  /// Helper for array `consumer_label`.
  ArrayHelper_gpioevent_request_consumer_label_level0 get consumer_label =>
      ArrayHelper_gpioevent_request_consumer_label_level0(this, [32], 0, 0);
  @ffi.Int32()
  external int fd;
}

/// Helper for array `consumer_label` in struct `gpioevent_request`.
class ArrayHelper_gpioevent_request_consumer_label_level0 {
  final gpioevent_request _struct;
  final List<int> dimensions;
  final int level;
  final int _absoluteIndex;
  int get length => dimensions[level];
  ArrayHelper_gpioevent_request_consumer_label_level0(this._struct, this.dimensions, this.level, this._absoluteIndex);
  void _checkBounds(int index) {
    if (index >= length || index < 0) {
      throw RangeError('Dimension $level: index not in range 0..$length exclusive.');
    }
  }

  int operator [](int index) {
    _checkBounds(index);
    switch (_absoluteIndex + index) {
      case 0:
        return _struct._unique_consumer_label_item_0;
      case 1:
        return _struct._unique_consumer_label_item_1;
      case 2:
        return _struct._unique_consumer_label_item_2;
      case 3:
        return _struct._unique_consumer_label_item_3;
      case 4:
        return _struct._unique_consumer_label_item_4;
      case 5:
        return _struct._unique_consumer_label_item_5;
      case 6:
        return _struct._unique_consumer_label_item_6;
      case 7:
        return _struct._unique_consumer_label_item_7;
      case 8:
        return _struct._unique_consumer_label_item_8;
      case 9:
        return _struct._unique_consumer_label_item_9;
      case 10:
        return _struct._unique_consumer_label_item_10;
      case 11:
        return _struct._unique_consumer_label_item_11;
      case 12:
        return _struct._unique_consumer_label_item_12;
      case 13:
        return _struct._unique_consumer_label_item_13;
      case 14:
        return _struct._unique_consumer_label_item_14;
      case 15:
        return _struct._unique_consumer_label_item_15;
      case 16:
        return _struct._unique_consumer_label_item_16;
      case 17:
        return _struct._unique_consumer_label_item_17;
      case 18:
        return _struct._unique_consumer_label_item_18;
      case 19:
        return _struct._unique_consumer_label_item_19;
      case 20:
        return _struct._unique_consumer_label_item_20;
      case 21:
        return _struct._unique_consumer_label_item_21;
      case 22:
        return _struct._unique_consumer_label_item_22;
      case 23:
        return _struct._unique_consumer_label_item_23;
      case 24:
        return _struct._unique_consumer_label_item_24;
      case 25:
        return _struct._unique_consumer_label_item_25;
      case 26:
        return _struct._unique_consumer_label_item_26;
      case 27:
        return _struct._unique_consumer_label_item_27;
      case 28:
        return _struct._unique_consumer_label_item_28;
      case 29:
        return _struct._unique_consumer_label_item_29;
      case 30:
        return _struct._unique_consumer_label_item_30;
      case 31:
        return _struct._unique_consumer_label_item_31;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }

  void operator []=(int index, int value) {
    _checkBounds(index);
    switch (_absoluteIndex + index) {
      case 0:
        _struct._unique_consumer_label_item_0 = value;
        break;
      case 1:
        _struct._unique_consumer_label_item_1 = value;
        break;
      case 2:
        _struct._unique_consumer_label_item_2 = value;
        break;
      case 3:
        _struct._unique_consumer_label_item_3 = value;
        break;
      case 4:
        _struct._unique_consumer_label_item_4 = value;
        break;
      case 5:
        _struct._unique_consumer_label_item_5 = value;
        break;
      case 6:
        _struct._unique_consumer_label_item_6 = value;
        break;
      case 7:
        _struct._unique_consumer_label_item_7 = value;
        break;
      case 8:
        _struct._unique_consumer_label_item_8 = value;
        break;
      case 9:
        _struct._unique_consumer_label_item_9 = value;
        break;
      case 10:
        _struct._unique_consumer_label_item_10 = value;
        break;
      case 11:
        _struct._unique_consumer_label_item_11 = value;
        break;
      case 12:
        _struct._unique_consumer_label_item_12 = value;
        break;
      case 13:
        _struct._unique_consumer_label_item_13 = value;
        break;
      case 14:
        _struct._unique_consumer_label_item_14 = value;
        break;
      case 15:
        _struct._unique_consumer_label_item_15 = value;
        break;
      case 16:
        _struct._unique_consumer_label_item_16 = value;
        break;
      case 17:
        _struct._unique_consumer_label_item_17 = value;
        break;
      case 18:
        _struct._unique_consumer_label_item_18 = value;
        break;
      case 19:
        _struct._unique_consumer_label_item_19 = value;
        break;
      case 20:
        _struct._unique_consumer_label_item_20 = value;
        break;
      case 21:
        _struct._unique_consumer_label_item_21 = value;
        break;
      case 22:
        _struct._unique_consumer_label_item_22 = value;
        break;
      case 23:
        _struct._unique_consumer_label_item_23 = value;
        break;
      case 24:
        _struct._unique_consumer_label_item_24 = value;
        break;
      case 25:
        _struct._unique_consumer_label_item_25 = value;
        break;
      case 26:
        _struct._unique_consumer_label_item_26 = value;
        break;
      case 27:
        _struct._unique_consumer_label_item_27 = value;
        break;
      case 28:
        _struct._unique_consumer_label_item_28 = value;
        break;
      case 29:
        _struct._unique_consumer_label_item_29 = value;
        break;
      case 30:
        _struct._unique_consumer_label_item_30 = value;
        break;
      case 31:
        _struct._unique_consumer_label_item_31 = value;
        break;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }
}

/// struct gpioevent_data - The actual event being pushed to userspace
/// @timestamp: best estimate of time of event occurrence, in nanoseconds
/// @id: event identifier
///
/// Note: This struct is part of ABI v1 and is deprecated.
/// Use &struct gpio_v2_line_event instead.
class gpioevent_data extends ffi.Struct {
  @ffi.Uint64()
  external int timestamp;

  @ffi.Uint32()
  external int id;
}

/// struct spi_ioc_transfer - describes a single SPI transfer
/// @tx_buf: Holds pointer to userspace buffer with transmit data, or null.
/// If no data is provided, zeroes are shifted out.
/// @rx_buf: Holds pointer to userspace buffer for receive data, or null.
/// @len: Length of tx and rx buffers, in bytes.
/// @speed_hz: Temporary override of the device's bitrate.
/// @bits_per_word: Temporary override of the device's wordsize.
/// @delay_usecs: If nonzero, how long to delay after the last bit transfer
/// before optionally deselecting the device before the next transfer.
/// @cs_change: True to deselect device before starting the next transfer.
/// @word_delay_usecs: If nonzero, how long to wait between words within one
/// transfer. This property needs explicit support in the SPI controller,
/// otherwise it is silently ignored.
///
/// This structure is mapped directly to the kernel spi_transfer structure;
/// the fields have the same meanings, except of course that the pointers
/// are in a different address space (and may be of different sizes in some
/// cases, such as 32-bit i386 userspace over a 64-bit x86_64 kernel).
/// Zero-initialize the structure, including currently unused fields, to
/// accommodate potential future updates.
///
/// SPI_IOC_MESSAGE gives userspace the equivalent of kernel spi_sync().
/// Pass it an array of related transfers, they'll execute together.
/// Each transfer may be half duplex (either direction) or full duplex.
///
/// struct spi_ioc_transfer mesg[4];
/// ...
/// status = ioctl(fd, SPI_IOC_MESSAGE(4), mesg);
///
/// So for example one transfer might send a nine bit command (right aligned
/// in a 16-bit word), the next could read a block of 8-bit data before
/// terminating that command by temporarily deselecting the chip; the next
/// could send a different nine bit command (re-selecting the chip), and the
/// last transfer might write some register values.
class spi_ioc_transfer extends ffi.Struct {
  @ffi.Uint64()
  external int tx_buf;

  @ffi.Uint64()
  external int rx_buf;

  @ffi.Uint32()
  external int len;

  @ffi.Uint32()
  external int speed_hz;

  @ffi.Uint16()
  external int delay_usecs;

  @ffi.Uint8()
  external int bits_per_word;

  @ffi.Uint8()
  external int cs_change;

  @ffi.Uint8()
  external int tx_nbits;

  @ffi.Uint8()
  external int rx_nbits;

  @ffi.Uint8()
  external int word_delay_usecs;

  @ffi.Uint8()
  external int pad;

  static ffi.Pointer<spi_ioc_transfer> allocate({
    ffi.Allocator allocator = ffi.malloc,
    int count = 1,
  }) {
    return allocator.allocate(ffi.sizeOf<spi_ioc_transfer>() * count);
  }
}

class LibC {
  LibC._internal({
    required this.lookup,
    required this.ioctl,
    required this.epoll_create,
    required this.epoll_create1,
    required this.epoll_ctl,
    required this.epoll_wait,
    required this.errno_location,
    required this.open,
    required this.close,
    required this.read,
    required this.tcgetpgrp,
    required this.tcsetpgrp,
    required this.cfgetospeed,
    required this.cfgetispeed,
    required this.cfsetospeed,
    required this.cfsetispeed,
    required this.cfsetspeed,
    required this.tcgetattr,
    required this.tcsetattr,
    required this.cfmakeraw,
    required this.tcsendbreak,
    required this.tcdrain,
    required this.tcflush,
    required this.tcflow,
    required this.tcgetsid,
  });

  factory LibC.fromLookup(ffi.Pointer<T> Function<T extends ffi.NativeType>(String) lookup) {
    if (Arch.isArm) {
      final _libcArm = arm.LibCPlatformBackend.fromLookup(lookup);
      return LibC._internal(
        lookup: lookup,
        ioctl: _libcArm.ioctl,
        epoll_create: _libcArm.epoll_create,
        epoll_create1: _libcArm.epoll_create1,
        epoll_ctl: (__epfd, __op, __fd, __event) =>
            _libcArm.epoll_ctl(__epfd, __op, __fd, __event.cast<arm.epoll_event>()),
        epoll_wait: (__epfd, __events, __maxevents, __timeout) =>
            _libcArm.epoll_wait(__epfd, __events.cast<arm.epoll_event>(), __maxevents, __timeout),
        errno_location: _libcArm.errno_location,
        open: (__file, __oflag) => _libcArm.open(__file.cast<ffi.Uint8>(), __oflag),
        close: _libcArm.close,
        read: _libcArm.read,
        tcgetpgrp: _libcArm.tcgetpgrp,
        tcsetpgrp: _libcArm.tcsetpgrp,
        cfgetospeed: (__termios_p) => _libcArm.cfgetospeed(__termios_p.cast<arm.termios>()),
        cfgetispeed: (__termios_p) => _libcArm.cfgetispeed(__termios_p.cast<arm.termios>()),
        cfsetospeed: (__termios_p, __speed) => _libcArm.cfsetospeed(__termios_p.cast<arm.termios>(), __speed),
        cfsetispeed: (__termios_p, __speed) => _libcArm.cfsetispeed(__termios_p.cast<arm.termios>(), __speed),
        cfsetspeed: (__termios_p, __speed) => _libcArm.cfsetspeed(__termios_p.cast<arm.termios>(), __speed),
        tcgetattr: (__fd, __termios_p) => _libcArm.tcgetattr(__fd, __termios_p.cast<arm.termios>()),
        tcsetattr: (__fd, __optional_actions, __termios_p) =>
            _libcArm.tcsetattr(__fd, __optional_actions, __termios_p.cast<arm.termios>()),
        cfmakeraw: (__termios_p) => _libcArm.cfmakeraw(__termios_p.cast<arm.termios>()),
        tcsendbreak: _libcArm.tcsendbreak,
        tcdrain: _libcArm.tcdrain,
        tcflush: _libcArm.tcflush,
        tcflow: _libcArm.tcflow,
        tcgetsid: _libcArm.tcgetsid,
      );
    } else if (Arch.isArm64) {
      final _libcArm64 = arm64.LibCPlatformBackend.fromLookup(lookup);
      return LibC._internal(
        lookup: lookup,
        ioctl: _libcArm64.ioctl,
        epoll_create: _libcArm64.epoll_create,
        epoll_create1: _libcArm64.epoll_create1,
        epoll_ctl: (__epfd, __op, __fd, __event) =>
            _libcArm64.epoll_ctl(__epfd, __op, __fd, __event.cast<arm64.epoll_event>()),
        epoll_wait: (__epfd, __events, __maxevents, __timeout) =>
            _libcArm64.epoll_wait(__epfd, __events.cast<arm64.epoll_event>(), __maxevents, __timeout),
        errno_location: _libcArm64.errno_location,
        open: (__file, __oflag) => _libcArm64.open(__file.cast<ffi.Uint8>(), __oflag),
        close: _libcArm64.close,
        read: _libcArm64.read,
        tcgetpgrp: _libcArm64.tcgetpgrp,
        tcsetpgrp: _libcArm64.tcsetpgrp,
        cfgetospeed: (__termios_p) => _libcArm64.cfgetospeed(__termios_p.cast<arm64.termios>()),
        cfgetispeed: (__termios_p) => _libcArm64.cfgetispeed(__termios_p.cast<arm64.termios>()),
        cfsetospeed: (__termios_p, __speed) => _libcArm64.cfsetospeed(__termios_p.cast<arm64.termios>(), __speed),
        cfsetispeed: (__termios_p, __speed) => _libcArm64.cfsetispeed(__termios_p.cast<arm64.termios>(), __speed),
        cfsetspeed: (__termios_p, __speed) => _libcArm64.cfsetspeed(__termios_p.cast<arm64.termios>(), __speed),
        tcgetattr: (__fd, __termios_p) => _libcArm64.tcgetattr(__fd, __termios_p.cast<arm64.termios>()),
        tcsetattr: (__fd, __optional_actions, __termios_p) =>
            _libcArm64.tcsetattr(__fd, __optional_actions, __termios_p.cast<arm64.termios>()),
        cfmakeraw: (__termios_p) => _libcArm64.cfmakeraw(__termios_p.cast<arm64.termios>()),
        tcsendbreak: _libcArm64.tcsendbreak,
        tcdrain: _libcArm64.tcdrain,
        tcflush: _libcArm64.tcflush,
        tcflow: _libcArm64.tcflow,
        tcgetsid: _libcArm64.tcgetsid,
      );
    } else if (Arch.isI386) {
      final _libcI386 = i386.LibCPlatformBackend.fromLookup(lookup);
      return LibC._internal(
        lookup: lookup,
        ioctl: _libcI386.ioctl,
        epoll_create: _libcI386.epoll_create,
        epoll_create1: _libcI386.epoll_create1,
        epoll_ctl: (__epfd, __op, __fd, __event) =>
            _libcI386.epoll_ctl(__epfd, __op, __fd, __event.cast<i386.epoll_event>()),
        epoll_wait: (__epfd, __events, __maxevents, __timeout) =>
            _libcI386.epoll_wait(__epfd, __events.cast<i386.epoll_event>(), __maxevents, __timeout),
        errno_location: _libcI386.errno_location,
        open: (__file, __oflag) => _libcI386.open(__file.cast<ffi.Int8>(), __oflag),
        close: _libcI386.close,
        read: _libcI386.read,
        tcgetpgrp: _libcI386.tcgetpgrp,
        tcsetpgrp: _libcI386.tcsetpgrp,
        cfgetospeed: (__termios_p) => _libcI386.cfgetospeed(__termios_p.cast<i386.termios>()),
        cfgetispeed: (__termios_p) => _libcI386.cfgetispeed(__termios_p.cast<i386.termios>()),
        cfsetospeed: (__termios_p, __speed) => _libcI386.cfsetospeed(__termios_p.cast<i386.termios>(), __speed),
        cfsetispeed: (__termios_p, __speed) => _libcI386.cfsetispeed(__termios_p.cast<i386.termios>(), __speed),
        cfsetspeed: (__termios_p, __speed) => _libcI386.cfsetspeed(__termios_p.cast<i386.termios>(), __speed),
        tcgetattr: (__fd, __termios_p) => _libcI386.tcgetattr(__fd, __termios_p.cast<i386.termios>()),
        tcsetattr: (__fd, __optional_actions, __termios_p) =>
            _libcI386.tcsetattr(__fd, __optional_actions, __termios_p.cast<i386.termios>()),
        cfmakeraw: (__termios_p) => _libcI386.cfmakeraw(__termios_p.cast<i386.termios>()),
        tcsendbreak: _libcI386.tcsendbreak,
        tcdrain: _libcI386.tcdrain,
        tcflush: _libcI386.tcflush,
        tcflow: _libcI386.tcflow,
        tcgetsid: _libcI386.tcgetsid,
      );
    } else if (Arch.isAmd64) {
      final _libcAmd64 = amd64.LibCPlatformBackend.fromLookup(lookup);
      return LibC._internal(
        lookup: lookup,
        ioctl: _libcAmd64.ioctl,
        epoll_create: _libcAmd64.epoll_create,
        epoll_create1: _libcAmd64.epoll_create1,
        epoll_ctl: (__epfd, __op, __fd, __event) =>
            _libcAmd64.epoll_ctl(__epfd, __op, __fd, __event.cast<amd64.epoll_event>()),
        epoll_wait: (__epfd, __events, __maxevents, __timeout) =>
            _libcAmd64.epoll_wait(__epfd, __events.cast<amd64.epoll_event>(), __maxevents, __timeout),
        errno_location: _libcAmd64.errno_location,
        open: (__file, __oflag) => _libcAmd64.open(__file.cast<ffi.Int8>(), __oflag),
        close: _libcAmd64.close,
        read: _libcAmd64.read,
        tcgetpgrp: _libcAmd64.tcgetpgrp,
        tcsetpgrp: _libcAmd64.tcsetpgrp,
        cfgetospeed: (__termios_p) => _libcAmd64.cfgetospeed(__termios_p.cast<amd64.termios>()),
        cfgetispeed: (__termios_p) => _libcAmd64.cfgetispeed(__termios_p.cast<amd64.termios>()),
        cfsetospeed: (__termios_p, __speed) => _libcAmd64.cfsetospeed(__termios_p.cast<amd64.termios>(), __speed),
        cfsetispeed: (__termios_p, __speed) => _libcAmd64.cfsetispeed(__termios_p.cast<amd64.termios>(), __speed),
        cfsetspeed: (__termios_p, __speed) => _libcAmd64.cfsetspeed(__termios_p.cast<amd64.termios>(), __speed),
        tcgetattr: (__fd, __termios_p) => _libcAmd64.tcgetattr(__fd, __termios_p.cast<amd64.termios>()),
        tcsetattr: (__fd, __optional_actions, __termios_p) =>
            _libcAmd64.tcsetattr(__fd, __optional_actions, __termios_p.cast<amd64.termios>()),
        cfmakeraw: (__termios_p) => _libcAmd64.cfmakeraw(__termios_p.cast<amd64.termios>()),
        tcsendbreak: _libcAmd64.tcsendbreak,
        tcdrain: _libcAmd64.tcdrain,
        tcflush: _libcAmd64.tcflush,
        tcflow: _libcAmd64.tcflow,
        tcgetsid: _libcAmd64.tcgetsid,
      );
    } else {
      throw FallThroughError();
    }
  }

  factory LibC(ffi.DynamicLibrary dylib) {
    return LibC.fromLookup(dylib.lookup);
  }

  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName) lookup;

  _dart_ioctl_ptr? _ioctl_ptr;
  int ioctl_ptr(int __fd, int __request, ffi.Pointer __pointer) {
    if (Arch.isArm || Arch.isI386) {
      _ioctl_ptr ??= lookup<ffi.NativeFunction<Native_ioctl_ptr_32>>('ioctl').asFunction<_dart_ioctl_ptr>();
    } else if (Arch.isArm64 || Arch.isAmd64) {
      _ioctl_ptr ??= lookup<ffi.NativeFunction<Native_ioctl_ptr_64>>('ioctl').asFunction<_dart_ioctl_ptr>();
    }
    return _ioctl_ptr!(__fd, __request, __pointer.cast<ffi.Void>());
  }

  final _dart_ioctl ioctl;
  final _dart_epoll_create epoll_create;
  final _dart_epoll_create1 epoll_create1;
  final _dart_epoll_ctl epoll_ctl;
  final _dart_epoll_wait epoll_wait;
  final _dart_errno_location errno_location;
  final _dart_open open;
  final _dart_close close;
  final _dart_read read;
  final _dart_tcgetpgrp tcgetpgrp;
  final _dart_tcsetpgrp tcsetpgrp;
  final _dart_cfgetospeed cfgetospeed;
  final _dart_cfgetispeed cfgetispeed;
  final _dart_cfsetospeed cfsetospeed;
  final _dart_cfsetispeed cfsetispeed;
  final _dart_cfsetspeed cfsetspeed;
  final _dart_tcgetattr tcgetattr;
  final _dart_tcsetattr tcsetattr;
  final _dart_cfmakeraw cfmakeraw;
  final _dart_tcsendbreak tcsendbreak;
  final _dart_tcdrain tcdrain;
  final _dart_tcflush tcflush;
  final _dart_tcflow tcflow;
  final _dart_tcgetsid tcgetsid;
}

const int TCGETS = 21505;
const int TCSETS = 21506;
const int TCSETSW = 21507;
const int TCSETSF = 21508;
const int TCGETA = 21509;
const int TCSETA = 21510;
const int TCSETAW = 21511;
const int TCSETAF = 21512;
const int TCSBRK = 21513;
const int TCXONC = 21514;
const int TCFLSH = 21515;
const int TCSBRKP = 21541;
const int TCGETX = 21554;
const int TCSETX = 21555;
const int TCSETXF = 21556;
const int TCSETXW = 21557;
const int EPOLL_CLOEXEC = 524288;
const int EPOLLIN = 1;
const int EPOLLPRI = 2;
const int EPOLLOUT = 4;
const int EPOLLRDNORM = 64;
const int EPOLLRDBAND = 128;
const int EPOLLWRNORM = 256;
const int EPOLLWRBAND = 512;
const int EPOLLMSG = 1024;
const int EPOLLERR = 8;
const int EPOLLHUP = 16;
const int EPOLLRDHUP = 8192;
const int EPOLLEXCLUSIVE = 268435456;
const int EPOLLWAKEUP = 536870912;
const int EPOLLONESHOT = 1073741824;
const int EPOLLET = 2147483648;
const int EPOLL_CTL_ADD = 1;
const int EPOLL_CTL_DEL = 2;
const int EPOLL_CTL_MOD = 3;
const int EPERM = 1;
const int ENOENT = 2;
const int ESRCH = 3;
const int EINTR = 4;
const int EIO = 5;
const int ENXIO = 6;
const int E2BIG = 7;
const int ENOEXEC = 8;
const int EBADF = 9;
const int ECHILD = 10;
const int EAGAIN = 11;
const int ENOMEM = 12;
const int EACCES = 13;
const int EFAULT = 14;
const int ENOTBLK = 15;
const int EBUSY = 16;
const int EEXIST = 17;
const int EXDEV = 18;
const int ENODEV = 19;
const int ENOTDIR = 20;
const int EISDIR = 21;
const int EINVAL = 22;
const int ENFILE = 23;
const int EMFILE = 24;
const int ENOTTY = 25;
const int ETXTBSY = 26;
const int EFBIG = 27;
const int ENOSPC = 28;
const int ESPIPE = 29;
const int EROFS = 30;
const int EMLINK = 31;
const int EPIPE = 32;
const int EDOM = 33;
const int ERANGE = 34;
const int EDEADLK = 35;
const int ENAMETOOLONG = 36;
const int ENOLCK = 37;
const int ENOSYS = 38;
const int ENOTEMPTY = 39;
const int ELOOP = 40;
const int EWOULDBLOCK = 11;
const int ENOMSG = 42;
const int EIDRM = 43;
const int ECHRNG = 44;
const int EL2NSYNC = 45;
const int EL3HLT = 46;
const int EL3RST = 47;
const int ELNRNG = 48;
const int EUNATCH = 49;
const int ENOCSI = 50;
const int EL2HLT = 51;
const int EBADE = 52;
const int EBADR = 53;
const int EXFULL = 54;
const int ENOANO = 55;
const int EBADRQC = 56;
const int EBADSLT = 57;
const int EDEADLOCK = 35;
const int EBFONT = 59;
const int ENOSTR = 60;
const int ENODATA = 61;
const int ETIME = 62;
const int ENOSR = 63;
const int ENONET = 64;
const int ENOPKG = 65;
const int EREMOTE = 66;
const int ENOLINK = 67;
const int EADV = 68;
const int ESRMNT = 69;
const int ECOMM = 70;
const int EPROTO = 71;
const int EMULTIHOP = 72;
const int EDOTDOT = 73;
const int EBADMSG = 74;
const int EOVERFLOW = 75;
const int ENOTUNIQ = 76;
const int EBADFD = 77;
const int EREMCHG = 78;
const int ELIBACC = 79;
const int ELIBBAD = 80;
const int ELIBSCN = 81;
const int ELIBMAX = 82;
const int ELIBEXEC = 83;
const int EILSEQ = 84;
const int ERESTART = 85;
const int ESTRPIPE = 86;
const int EUSERS = 87;
const int ENOTSOCK = 88;
const int EDESTADDRREQ = 89;
const int EMSGSIZE = 90;
const int EPROTOTYPE = 91;
const int ENOPROTOOPT = 92;
const int EPROTONOSUPPORT = 93;
const int ESOCKTNOSUPPORT = 94;
const int EOPNOTSUPP = 95;
const int EPFNOSUPPORT = 96;
const int EAFNOSUPPORT = 97;
const int EADDRINUSE = 98;
const int EADDRNOTAVAIL = 99;
const int ENETDOWN = 100;
const int ENETUNREACH = 101;
const int ENETRESET = 102;
const int ECONNABORTED = 103;
const int ECONNRESET = 104;
const int ENOBUFS = 105;
const int EISCONN = 106;
const int ENOTCONN = 107;
const int ESHUTDOWN = 108;
const int ETOOMANYREFS = 109;
const int ETIMEDOUT = 110;
const int ECONNREFUSED = 111;
const int EHOSTDOWN = 112;
const int EHOSTUNREACH = 113;
const int EALREADY = 114;
const int EINPROGRESS = 115;
const int ESTALE = 116;
const int EUCLEAN = 117;
const int ENOTNAM = 118;
const int ENAVAIL = 119;
const int EISNAM = 120;
const int EREMOTEIO = 121;
const int EDQUOT = 122;
const int ENOMEDIUM = 123;
const int EMEDIUMTYPE = 124;
const int ECANCELED = 125;
const int ENOKEY = 126;
const int EKEYEXPIRED = 127;
const int EKEYREVOKED = 128;
const int EKEYREJECTED = 129;
const int EOWNERDEAD = 130;
const int ENOTRECOVERABLE = 131;
const int ERFKILL = 132;
const int EHWPOISON = 133;
const int ENOTSUP = 95;
const int O_ACCMODE = 3;
const int O_RDONLY = 0;
const int O_WRONLY = 1;
const int O_RDWR = 2;
const int O_CREAT = 64;
const int O_EXCL = 128;
const int O_NOCTTY = 256;
const int O_TRUNC = 512;
const int O_APPEND = 1024;
const int O_NONBLOCK = 2048;
const int O_NDELAY = 2048;
const int O_SYNC = 1052672;
const int O_FSYNC = 1052672;
const int O_ASYNC = 8192;
const int O_DIRECTORY = 65536;
const int O_NOFOLLOW = 131072;
const int O_CLOEXEC = 524288;
const int O_DSYNC = 4096;
const int O_RSYNC = 1052672;
const int VINTR = 0;
const int VQUIT = 1;
const int VERASE = 2;
const int VKILL = 3;
const int VEOF = 4;
const int VTIME = 5;
const int VMIN = 6;
const int VSWTC = 7;
const int VSTART = 8;
const int VSTOP = 9;
const int VSUSP = 10;
const int VEOL = 11;
const int VREPRINT = 12;
const int VDISCARD = 13;
const int VWERASE = 14;
const int VLNEXT = 15;
const int VEOL2 = 16;
const int IGNBRK = 1;
const int BRKINT = 2;
const int IGNPAR = 4;
const int PARMRK = 8;
const int INPCK = 16;
const int ISTRIP = 32;
const int INLCR = 64;
const int IGNCR = 128;
const int ICRNL = 256;
const int IUCLC = 512;
const int IXON = 1024;
const int IXANY = 2048;
const int IXOFF = 4096;
const int IMAXBEL = 8192;
const int OPOST = 1;
const int OLCUC = 2;
const int ONLCR = 4;
const int OCRNL = 8;
const int ONOCR = 16;
const int ONLRET = 32;
const int OFILL = 64;
const int OFDEL = 128;
const int NLDLY = 256;
const int CRDLY = 1536;
const int CR0 = 0;
const int CR1 = 512;
const int CR2 = 1024;
const int CR3 = 1536;
const int TABDLY = 6144;
const int BSDLY = 8192;
const int FFDLY = 32768;
const int VTDLY = 16384;
const int VT0 = 0;
const int VT1 = 16384;
const int B0 = 0;
const int B50 = 1;
const int B75 = 2;
const int B110 = 3;
const int B134 = 4;
const int B150 = 5;
const int B200 = 6;
const int B300 = 7;
const int B600 = 8;
const int B1200 = 9;
const int B1800 = 10;
const int B2400 = 11;
const int B4800 = 12;
const int B9600 = 13;
const int B19200 = 14;
const int B38400 = 15;
const int EXTA = 14;
const int EXTB = 15;
const int CBAUD = 4111;
const int CBAUDEX = 4096;
const int CIBAUD = 269418496;
const int CMSPAR = 1073741824;
const int CRTSCTS = 2147483648;
const int B57600 = 4097;
const int B115200 = 4098;
const int B230400 = 4099;
const int B460800 = 4100;
const int B500000 = 4101;
const int B576000 = 4102;
const int B921600 = 4103;
const int B1000000 = 4104;
const int B1152000 = 4105;
const int B1500000 = 4106;
const int B2000000 = 4107;
const int B2500000 = 4108;
const int B3000000 = 4109;
const int B3500000 = 4110;
const int B4000000 = 4111;
const int CSIZE = 48;
const int CS5 = 0;
const int CS6 = 16;
const int CS7 = 32;
const int CS8 = 48;
const int CSTOPB = 64;
const int CREAD = 128;
const int PARENB = 256;
const int PARODD = 512;
const int HUPCL = 1024;
const int CLOCAL = 2048;
const int ISIG = 1;
const int ICANON = 2;
const int XCASE = 4;
const int ECHO = 8;
const int ECHOE = 16;
const int ECHOK = 32;
const int ECHONL = 64;
const int NOFLSH = 128;
const int TOSTOP = 256;
const int ECHOCTL = 512;
const int ECHOPRT = 1024;
const int ECHOKE = 2048;
const int FLUSHO = 4096;
const int PENDIN = 16384;
const int IEXTEN = 32768;
const int EXTPROC = 65536;
const int TCOOFF = 0;
const int TCOON = 1;
const int TCIOFF = 2;
const int TCION = 3;
const int TCIFLUSH = 0;
const int TCOFLUSH = 1;
const int TCIOFLUSH = 2;
const int TCSANOW = 0;
const int TCSADRAIN = 1;
const int TCSAFLUSH = 2;
const int GPIO_MAX_NAME_SIZE = 32;
const int GPIO_V2_LINES_MAX = 64;
const int GPIO_V2_LINE_NUM_ATTRS_MAX = 10;
const int GPIOLINE_FLAG_KERNEL = 1;
const int GPIOLINE_FLAG_IS_OUT = 2;
const int GPIOLINE_FLAG_ACTIVE_LOW = 4;
const int GPIOLINE_FLAG_OPEN_DRAIN = 8;
const int GPIOLINE_FLAG_OPEN_SOURCE = 16;
const int GPIOLINE_FLAG_BIAS_PULL_UP = 32;
const int GPIOLINE_FLAG_BIAS_PULL_DOWN = 64;
const int GPIOLINE_FLAG_BIAS_DISABLE = 128;
const int GPIOHANDLES_MAX = 64;
const int GPIOHANDLE_REQUEST_INPUT = 1;
const int GPIOHANDLE_REQUEST_OUTPUT = 2;
const int GPIOHANDLE_REQUEST_ACTIVE_LOW = 4;
const int GPIOHANDLE_REQUEST_OPEN_DRAIN = 8;
const int GPIOHANDLE_REQUEST_OPEN_SOURCE = 16;
const int GPIOHANDLE_REQUEST_BIAS_PULL_UP = 32;
const int GPIOHANDLE_REQUEST_BIAS_PULL_DOWN = 64;
const int GPIOHANDLE_REQUEST_BIAS_DISABLE = 128;
const int GPIOEVENT_REQUEST_RISING_EDGE = 1;
const int GPIOEVENT_REQUEST_FALLING_EDGE = 2;
const int GPIOEVENT_REQUEST_BOTH_EDGES = 3;
const int GPIOEVENT_EVENT_RISING_EDGE = 1;
const int GPIOEVENT_EVENT_FALLING_EDGE = 2;
const int GPIO_GET_CHIPINFO_IOCTL = 2151986177;
const int GPIO_GET_LINEINFO_UNWATCH_IOCTL = 3221533708;
const int GPIO_V2_GET_LINEINFO_IOCTL = 3238048773;
const int GPIO_V2_GET_LINEINFO_WATCH_IOCTL = 3238048774;
const int GPIO_V2_GET_LINE_IOCTL = 3260068871;
const int GPIO_V2_LINE_SET_CONFIG_IOCTL = 3239097357;
const int GPIO_V2_LINE_GET_VALUES_IOCTL = 3222320142;
const int GPIO_V2_LINE_SET_VALUES_IOCTL = 3222320143;
const int GPIO_GET_LINEINFO_IOCTL = 3225990146;
const int GPIO_GET_LINEHANDLE_IOCTL = 3245126659;
const int GPIO_GET_LINEEVENT_IOCTL = 3224417284;
const int GPIOHANDLE_GET_LINE_VALUES_IOCTL = 3225465864;
const int GPIOHANDLE_SET_LINE_VALUES_IOCTL = 3225465865;
const int GPIOHANDLE_SET_CONFIG_IOCTL = 3226776586;
const int GPIO_GET_LINEINFO_WATCH_IOCTL = 3225990155;
const int SPI_CPHA = 1;
const int SPI_CPOL = 2;
const int SPI_MODE_0 = 0;
const int SPI_MODE_1 = 1;
const int SPI_MODE_2 = 2;
const int SPI_MODE_3 = 3;
const int SPI_CS_HIGH = 4;
const int SPI_LSB_FIRST = 8;
const int SPI_3WIRE = 16;
const int SPI_LOOP = 32;
const int SPI_NO_CS = 64;
const int SPI_READY = 128;
const int SPI_TX_DUAL = 256;
const int SPI_TX_QUAD = 512;
const int SPI_RX_DUAL = 1024;
const int SPI_RX_QUAD = 2048;
const int SPI_CS_WORD = 4096;
const int SPI_TX_OCTAL = 8192;
const int SPI_RX_OCTAL = 16384;
const int SPI_3WIRE_HIZ = 32768;
const int SPI_IOC_MAGIC = 107;
const int SPI_IOC_RD_MODE = 2147576577;
const int SPI_IOC_WR_MODE = 1073834753;
const int SPI_IOC_RD_LSB_FIRST = 2147576578;
const int SPI_IOC_WR_LSB_FIRST = 1073834754;
const int SPI_IOC_RD_BITS_PER_WORD = 2147576579;
const int SPI_IOC_WR_BITS_PER_WORD = 1073834755;
const int SPI_IOC_RD_MAX_SPEED_HZ = 2147773188;
const int SPI_IOC_WR_MAX_SPEED_HZ = 1074031364;
const int SPI_IOC_RD_MODE32 = 2147773189;
const int SPI_IOC_WR_MODE32 = 1074031365;
