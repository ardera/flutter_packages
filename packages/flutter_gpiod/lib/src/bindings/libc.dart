import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:ffi/ffi.dart' as ffi;
import 'libc_arm.dart' as arm;
import 'libc_arm64.dart' as arm64;
import 'libc_i386.dart' as i386;
import 'libc_amd64.dart' as amd64;

export 'libc_arm.dart'
    show
        EPOLL_EVENTS,
        gpiochip_info,
        gpio_v2_line_values,
        gpio_v2_line_attribute,
        gpio_v2_line_config_attribute,
        gpio_v2_line_config,
        gpio_v2_line_request,
        gpio_v2_line_info,
        gpio_v2_line_event,
        gpioline_info,
        gpioline_info_changed,
        gpiohandle_request,
        gpiohandle_config,
        gpiohandle_data,
        gpioevent_request,
        gpioevent_data,
        EPOLL_CLOEXEC,
        GPIOLINE_CHANGED_REQUESTED,
        GPIOLINE_CHANGED_RELEASED,
        GPIOLINE_CHANGED_CONFIG,
        EPOLL_CTL_ADD,
        EPOLL_CTL_DEL,
        EPOLL_CTL_MOD,
        O_ACCMODE,
        O_RDONLY,
        O_WRONLY,
        O_RDWR,
        O_CREAT,
        O_EXCL,
        O_NOCTTY,
        O_TRUNC,
        O_APPEND,
        O_NONBLOCK,
        O_NDELAY,
        O_SYNC,
        O_FSYNC,
        O_ASYNC,
        O_DIRECTORY,
        O_NOFOLLOW,
        O_CLOEXEC,
        O_DSYNC,
        O_RSYNC,
        GPIO_MAX_NAME_SIZE,
        GPIO_V2_LINES_MAX,
        GPIO_V2_LINE_NUM_ATTRS_MAX,
        GPIOLINE_FLAG_KERNEL,
        GPIOLINE_FLAG_IS_OUT,
        GPIOLINE_FLAG_ACTIVE_LOW,
        GPIOLINE_FLAG_OPEN_DRAIN,
        GPIOLINE_FLAG_OPEN_SOURCE,
        GPIOLINE_FLAG_BIAS_PULL_UP,
        GPIOLINE_FLAG_BIAS_PULL_DOWN,
        GPIOLINE_FLAG_BIAS_DISABLE,
        GPIOHANDLES_MAX,
        GPIOHANDLE_REQUEST_INPUT,
        GPIOHANDLE_REQUEST_OUTPUT,
        GPIOHANDLE_REQUEST_ACTIVE_LOW,
        GPIOHANDLE_REQUEST_OPEN_DRAIN,
        GPIOHANDLE_REQUEST_OPEN_SOURCE,
        GPIOHANDLE_REQUEST_BIAS_PULL_UP,
        GPIOHANDLE_REQUEST_BIAS_PULL_DOWN,
        GPIOHANDLE_REQUEST_BIAS_DISABLE,
        GPIOEVENT_REQUEST_RISING_EDGE,
        GPIOEVENT_REQUEST_FALLING_EDGE,
        GPIOEVENT_REQUEST_BOTH_EDGES,
        GPIOEVENT_EVENT_RISING_EDGE,
        GPIOEVENT_EVENT_FALLING_EDGE,
        GPIO_GET_CHIPINFO_IOCTL,
        GPIO_GET_LINEINFO_UNWATCH_IOCTL,
        GPIO_V2_GET_LINEINFO_IOCTL,
        GPIO_V2_GET_LINEINFO_WATCH_IOCTL,
        GPIO_V2_GET_LINE_IOCTL,
        GPIO_V2_LINE_SET_CONFIG_IOCTL,
        GPIO_V2_LINE_GET_VALUES_IOCTL,
        GPIO_V2_LINE_SET_VALUES_IOCTL,
        GPIO_GET_LINEINFO_IOCTL,
        GPIO_GET_LINEHANDLE_IOCTL,
        GPIO_GET_LINEEVENT_IOCTL,
        GPIOHANDLE_GET_LINE_VALUES_IOCTL,
        GPIOHANDLE_SET_LINE_VALUES_IOCTL,
        GPIOHANDLE_SET_CONFIG_IOCTL,
        GPIO_GET_LINEINFO_WATCH_IOCTL;

// ignore_for_file: unnecessary_brace_in_string_interps
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

class LibC {
  LibC._internal({
    required ffi.Pointer<T> Function<T extends ffi.NativeType>(String) lookup,
    required dynamic backend,
  })  : _lookup = lookup,
        _backend = backend;

  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String) _lookup;
  final _backend;

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
          .cast<ffi.NativeFunction<ffi.Int32 Function(ffi.Int32, ffi.Uint64, ffi.Pointer<ffi.Void>)>>()
          .asFunction<int Function(int, int, ffi.Pointer<ffi.Void>)>(isLeaf: true)
      : (addresses.ioctl as ffi.Pointer)
          .cast<ffi.NativeFunction<ffi.Int32 Function(ffi.Int32, ffi.Uint32, ffi.Pointer<ffi.Void>)>>()
          .asFunction<int Function(int, int, ffi.Pointer<ffi.Void>)>(isLeaf: true);
  late final int Function(int, int) ioctl = _backend.ioctl;
  late final int Function(int) epoll_create = _backend.epoll_create;
  late final int Function(int) epoll_create1 = _backend.epoll_create1;
  late final int Function(int, int, int, epoll_event_ptr) epoll_ctl = (a, b, c, ptr) {
    return _backend.epoll_ctl(a, b, c, ptr.backing);
  };
  late final int Function(int, epoll_event_ptr, int, int) epoll_wait = (a, ptr, b, c) {
    return _backend.epoll_wait(a, ptr.backing, b, c);
  };
  late final int Function(ffi.Pointer<ffi.Int8>, int) open = _backend.open;
  late final int Function(int) close = _backend.close;
  late final int Function(int, ffi.Pointer<ffi.Void>, int) read = _backend.read;
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

  static epoll_event_ptr allocate({ffi.Allocator allocator = ffi.malloc, int count = 1}) {
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
