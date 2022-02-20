import 'dart:collection';
import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:ffi/ffi.dart' as ffi;
import 'libc_arm.dart' as arm;
import 'libc_arm64.dart' as arm64;
import 'libc_i386.dart' as i386;
import 'libc_amd64.dart' as amd64;

export 'libc_arm.dart';

// ignore_for_file: constant_identifier_names, non_constant_identifier_names, camel_case_types, unnecessary_brace_in_string_interps
class Arch {
  const Arch(this.name);

  final String name;

  static const arm = Arch('arm');
  static const arm64 = Arch('arm64');
  static const i386 = Arch('i386');
  static const amd64 = Arch('amd64');

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

class LibC {
  LibC._internal({
    required ffi.Pointer<T> Function<T extends ffi.NativeType>(String) lookup,
    required dynamic backend,
  })  : _lookup = lookup,
        _backend = backend;

  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String) _lookup;
  final dynamic _backend;

  factory LibC.fromLookup(ffi.Pointer<T> Function<T extends ffi.NativeType>(String) lookup) {
    if (Arch.isArm) {
      final _libcArm = arm.LibCPlatformBackend.fromLookup(lookup);
      return LibC._internal(
        lookup: lookup,
        backend: _libcArm,
      );
    } else if (Arch.isArm64) {
      final _libcArm64 = arm64.LibCPlatformBackend.fromLookup(lookup);
      return LibC._internal(
        lookup: lookup,
        backend: _libcArm64,
      );
    } else if (Arch.isI386) {
      final _libcI386 = i386.LibCPlatformBackend.fromLookup(lookup);
      return LibC._internal(
        lookup: lookup,
        backend: _libcI386,
      );
    } else if (Arch.isAmd64) {
      final _libcAmd64 = amd64.LibCPlatformBackend.fromLookup(lookup);
      return LibC._internal(
        lookup: lookup,
        backend: _libcAmd64,
      );
    } else {
      throw FallThroughError();
    }
  }

  factory LibC(ffi.DynamicLibrary dylib) {
    return LibC.fromLookup(dylib.lookup);
  }

  late final int Function(int, int, ffi.Pointer<ffi.Void>) ioctl_ptr = Arch.isArm || Arch.isI386
      ? (addresses.ioctl as ffi.Pointer)
          .cast<ffi.NativeFunction<ffi.Int32 Function(ffi.Int32, ffi.Uint32, ffi.Pointer<ffi.Void>)>>()
          .asFunction<int Function(int, int, ffi.Pointer<ffi.Void>)>(isLeaf: true)
      : (addresses.ioctl as ffi.Pointer)
          .cast<ffi.NativeFunction<ffi.Int32 Function(ffi.Int32, ffi.Uint64, ffi.Pointer<ffi.Void>)>>()
          .asFunction<int Function(int, int, ffi.Pointer<ffi.Void>)>(isLeaf: true);
  late final int Function(int, int) ioctl = _backend.ioctl;
  late final int Function(int) epoll_create = _backend.epoll_create;
  late final int Function(int) epoll_create1 = _backend.epoll_create1;

  int epoll_ctl(int __epfd, int __op, int __fd, epoll_event_ptr __event) {
    return _backend.epoll_ctl(__epfd, __op, __fd, __event.backing);
  }

  int epoll_wait(int __epfd, epoll_event_ptr __events, int __maxevents, int __timeout) {
    return _backend.epoll_wait(__epfd, __events.backing, __maxevents, __timeout);
  }

  late final int Function(ffi.Pointer<ffi.Int8>, int) open =
      Arch.isArm || Arch.isArm64 ? (file, oflag) => _backend.open(file.cast<ffi.Uint8>(), oflag) : _backend.open;

  late final int Function(int) close = _backend.close;
  late final int Function(int, ffi.Pointer<ffi.Void>, int) read = _backend.read;

  int cfgetospeed(termios_ptr __termios_p) {
    return _backend.cfgetospeed(__termios_p.backing);
  }

  int cfgetispeed(termios_ptr __termios_p) {
    return _backend.cfgetispeed(__termios_p.backing);
  }

  int cfsetospeed(termios_ptr __termios_p, int __speed) {
    return _backend.cfsetospeed(__termios_p.backing, __speed);
  }

  int cfsetispeed(termios_ptr __termios_p, int __speed) {
    return _backend.cfsetispeed(__termios_p.backing, __speed);
  }

  int tcgetattr(int __fd, termios_ptr __termios_p) {
    return _backend.tcgetattr(__fd, __termios_p.backing);
  }

  int tcsetattr(int __fd, int __optional_actions, termios_ptr __termios_p) {
    return _backend.tcsetattr(__fd, __optional_actions, __termios_p.backing);
  }

  late final int Function(int __fd, int __duration) tcsendbreak = _backend.tcsendbreak;
  late final int Function(int __fd) tcdrain = _backend.tcdrain;
  late final int Function(int __fd, int __queue_selector) tcflush = _backend.tcflush;
  late final int Function(int __fd, int __action) tcflow = _backend.tcflow;
  late final int Function(int __fd) tcgetsid = _backend.tcgetsid;

  late final addresses = _backend.addresses;

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
  ffi.Pointer<ffi.Int32> get errno_location =>
      errno_location_symbol_address.asFunction<ffi.Pointer<ffi.Int32> Function()>()();
  int get errno => errno_location.value;
}

class epoll_event_ptr {
  epoll_event_ptr(this.allocator, this.backing);

  final ffi.Allocator allocator;
  final ffi.Pointer backing;
  bool _isAllocated = true;

  set events(int events) => _ref.events = events;
  int get events => _ref.events;

  set ptr(ffi.Pointer<ffi.Void> ptr) => _ref.data.ptr = ptr;
  ffi.Pointer<ffi.Void> get ptr => _ref.data.ptr;

  set fd(int fd) => _ref.data.fd = fd;
  int get fd => _ref.data.fd;

  set u32(int u32) => _ref.data.u32 = u32;
  int get u32 => _ref.data.u32;

  set u64(int u64) => _ref.data.u64 = u64;
  int get u64 => _ref.data.u64;

  epoll_event_ptr elementAt(int index) {
    late final ffi.Pointer ptr;
    if (Arch.isArm) {
      ptr = backing.cast<arm.epoll_event>().elementAt(index);
    } else if (Arch.isArm64) {
      ptr = backing.cast<arm64.epoll_event>().elementAt(index);
    } else if (Arch.isI386) {
      ptr = backing.cast<amd64.epoll_event>().elementAt(index);
    } else if (Arch.isAmd64) {
      ptr = backing.cast<i386.epoll_event>().elementAt(index);
    } else {
      throw FallThroughError();
    }
    return epoll_event_ptr(allocator, ptr);
  }

  dynamic get _ref {
    if (Arch.isArm) {
      return backing.cast<arm.epoll_event>().ref;
    } else if (Arch.isArm64) {
      return backing.cast<arm64.epoll_event>().ref;
    } else if (Arch.isI386) {
      return backing.cast<amd64.epoll_event>().ref;
    } else if (Arch.isAmd64) {
      return backing.cast<i386.epoll_event>().ref;
    } else {
      throw FallThroughError();
    }
  }

  static epoll_event_ptr allocate({
    ffi.Allocator allocator = ffi.malloc,
    int count = 1,
  }) {
    final bytes = sizeOf() * count;
    return epoll_event_ptr(allocator, allocator.allocate(bytes));
  }

  void free() {
    assert(_isAllocated);
    allocator.free(backing);
    _isAllocated = false;
  }

  static int sizeOf() {
    if (Arch.isArm) {
      return ffi.sizeOf<arm.epoll_event>();
    } else if (Arch.isArm64) {
      return ffi.sizeOf<arm64.epoll_event>();
    } else if (Arch.isI386) {
      return ffi.sizeOf<i386.epoll_event>();
    } else if (Arch.isAmd64) {
      return ffi.sizeOf<amd64.epoll_event>();
    } else {
      throw FallThroughError();
    }
  }

  static epoll_event_ptr nullptr = epoll_event_ptr(ffi.malloc, ffi.nullptr);
}

class _DelegatingFixedList<E> extends ListBase<E> {
  _DelegatingFixedList(this._length, this._set, this._get);

  final int _length;
  final void Function(int, E) _set;
  final E Function(int) _get;

  @override
  int get length => _length;

  @override
  E operator [](int index) => _get(index);

  @override
  void add(E element) {
    throw UnsupportedError("Cannot add to a fixed-length list");
  }

  @override
  set length(int newLength) {
    throw UnsupportedError("Cannot change the length of a fixed-length list");
  }

  @override
  void operator []=(int index, E element) => _set(index, element);
}

class termios_ptr {
  termios_ptr(this.allocator, this.backing);

  final ffi.Allocator allocator;
  final ffi.Pointer backing;
  bool _isAllocated = true;

  int get c_iflag => _ref.c_iflag;
  set c_iflag(int value) => _ref.c_iflag = value;

  int get c_oflag => _ref.c_oflag;
  set c_oflag(int value) => _ref.c_oflag = value;

  int get c_cflag => _ref.c_cflag;
  set c_cflag(int value) => _ref.c_cflag = value;

  int get c_lflag => _ref.c_lflag;
  set c_lflag(int value) => _ref.c_lflag = value;

  late final List<int> c_cc = _DelegatingFixedList(
    _nccs(),
    (i, v) => _ref.c_cc[i] = v,
    (i) => _ref.c_cc[i],
  );

  set events(int events) => _ref.events = events;
  int get events => _ref.events;

  set ptr(ffi.Pointer<ffi.Void> ptr) => _ref.data.ptr = ptr;
  ffi.Pointer<ffi.Void> get ptr => _ref.data.ptr;

  set fd(int fd) => _ref.data.fd = fd;
  int get fd => _ref.data.fd;

  set u32(int u32) => _ref.data.u32 = u32;
  int get u32 => _ref.data.u32;

  set u64(int u64) => _ref.data.u64 = u64;
  int get u64 => _ref.data.u64;

  static int _nccs() {
    if (Arch.isArm) {
      return arm.NCCS;
    } else if (Arch.isArm64) {
      return arm64.NCCS;
    } else if (Arch.isI386) {
      return amd64.NCCS;
    } else if (Arch.isAmd64) {
      return i386.NCCS;
    } else {
      throw FallThroughError();
    }
  }

  termios_ptr elementAt(int index) {
    late final ffi.Pointer ptr;
    if (Arch.isArm) {
      ptr = backing.cast<arm.termios>().elementAt(index);
    } else if (Arch.isArm64) {
      ptr = backing.cast<arm64.termios>().elementAt(index);
    } else if (Arch.isI386) {
      ptr = backing.cast<amd64.termios>().elementAt(index);
    } else if (Arch.isAmd64) {
      ptr = backing.cast<i386.termios>().elementAt(index);
    } else {
      throw FallThroughError();
    }
    return termios_ptr(allocator, ptr);
  }

  dynamic get _ref {
    if (Arch.isArm) {
      return backing.cast<arm.termios>().ref;
    } else if (Arch.isArm64) {
      return backing.cast<arm64.termios>().ref;
    } else if (Arch.isI386) {
      return backing.cast<amd64.termios>().ref;
    } else if (Arch.isAmd64) {
      return backing.cast<i386.termios>().ref;
    } else {
      throw FallThroughError();
    }
  }

  static termios_ptr allocate({
    ffi.Allocator allocator = ffi.malloc,
    int count = 1,
  }) {
    final bytes = sizeOf() * count;
    return termios_ptr(allocator, allocator.allocate(bytes));
  }

  void free() {
    assert(_isAllocated);
    allocator.free(backing);
    _isAllocated = false;
  }

  static int sizeOf() {
    if (Arch.isArm) {
      return ffi.sizeOf<arm.termios>();
    } else if (Arch.isArm64) {
      return ffi.sizeOf<arm64.termios>();
    } else if (Arch.isI386) {
      return ffi.sizeOf<i386.termios>();
    } else if (Arch.isAmd64) {
      return ffi.sizeOf<amd64.termios>();
    } else {
      throw FallThroughError();
    }
  }

  static termios_ptr nullptr = termios_ptr(ffi.malloc, ffi.nullptr);
}
