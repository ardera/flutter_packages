// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// LibCPlatformBackendGenerator
// **************************************************************************

// ignore_for_file: constant_identifier_names, non_constant_identifier_names, camel_case_types, unnecessary_brace_in_string_interps, unused_element, no_leading_underscores_for_local_identifiers

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
import 'dart:ffi' as ffi;
import 'ssize_t.dart' as pkg_ssizet;

/// libc backend for amd64
class LibCPlatformBackend {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName) _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  LibCPlatformBackend(ffi.DynamicLibrary dynamicLibrary) : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  LibCPlatformBackend.fromLookup(ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName) lookup)
      : _lookup = lookup;

  int ioctl(
    int __fd,
    int __request,
  ) {
    return _ioctl(
      __fd,
      __request,
    );
  }

  late final _ioctlPtr = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Int, ffi.UnsignedLong)>>('ioctl');
  late final _ioctl = _ioctlPtr.asFunction<int Function(int, int)>(isLeaf: true);

  int epoll_create(
    int __size,
  ) {
    return _epoll_create(
      __size,
    );
  }

  late final _epoll_createPtr = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Int)>>('epoll_create');
  late final _epoll_create = _epoll_createPtr.asFunction<int Function(int)>(isLeaf: true);

  int epoll_create1(
    int __flags,
  ) {
    return _epoll_create1(
      __flags,
    );
  }

  late final _epoll_create1Ptr = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Int)>>('epoll_create1');
  late final _epoll_create1 = _epoll_create1Ptr.asFunction<int Function(int)>(isLeaf: true);

  int epoll_ctl(
    int __epfd,
    int __op,
    int __fd,
    ffi.Pointer<epoll_event> __event,
  ) {
    return _epoll_ctl(
      __epfd,
      __op,
      __fd,
      __event,
    );
  }

  late final _epoll_ctlPtr =
      _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Int, ffi.Int, ffi.Int, ffi.Pointer<epoll_event>)>>('epoll_ctl');
  late final _epoll_ctl = _epoll_ctlPtr.asFunction<int Function(int, int, int, ffi.Pointer<epoll_event>)>(isLeaf: true);

  int epoll_wait(
    int __epfd,
    ffi.Pointer<epoll_event> __events,
    int __maxevents,
    int __timeout,
  ) {
    return _epoll_wait(
      __epfd,
      __events,
      __maxevents,
      __timeout,
    );
  }

  late final _epoll_waitPtr =
      _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Int, ffi.Pointer<epoll_event>, ffi.Int, ffi.Int)>>('epoll_wait');
  late final _epoll_wait =
      _epoll_waitPtr.asFunction<int Function(int, ffi.Pointer<epoll_event>, int, int)>(isLeaf: true);

  ffi.Pointer<ffi.Int> errno_location() {
    return _errno_location();
  }

  late final _errno_locationPtr = _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Int> Function()>>('__errno_location');
  late final _errno_location = _errno_locationPtr.asFunction<ffi.Pointer<ffi.Int> Function()>(isLeaf: true);

  int open(
    ffi.Pointer<ffi.Char> __file,
    int __oflag,
  ) {
    return _open(
      __file,
      __oflag,
    );
  }

  late final _openPtr = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>, ffi.Int)>>('open');
  late final _open = _openPtr.asFunction<int Function(ffi.Pointer<ffi.Char>, int)>(isLeaf: true);

  int close(
    int __fd,
  ) {
    return _close(
      __fd,
    );
  }

  late final _closePtr = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Int)>>('close');
  late final _close = _closePtr.asFunction<int Function(int)>(isLeaf: true);

  int read(
    int __fd,
    ffi.Pointer<ffi.Void> __buf,
    int __nbytes,
  ) {
    return _read(
      __fd,
      __buf,
      __nbytes,
    );
  }

  late final _readPtr =
      _lookup<ffi.NativeFunction<pkg_ssizet.SSize Function(ffi.Int, ffi.Pointer<ffi.Void>, ffi.Size)>>('read');
  late final _read = _readPtr.asFunction<int Function(int, ffi.Pointer<ffi.Void>, int)>(isLeaf: true);

  int cfgetospeed(
    ffi.Pointer<termios> __termios_p,
  ) {
    return _cfgetospeed(
      __termios_p,
    );
  }

  late final _cfgetospeedPtr =
      _lookup<ffi.NativeFunction<ffi.UnsignedInt Function(ffi.Pointer<termios>)>>('cfgetospeed');
  late final _cfgetospeed = _cfgetospeedPtr.asFunction<int Function(ffi.Pointer<termios>)>(isLeaf: true);

  int cfgetispeed(
    ffi.Pointer<termios> __termios_p,
  ) {
    return _cfgetispeed(
      __termios_p,
    );
  }

  late final _cfgetispeedPtr =
      _lookup<ffi.NativeFunction<ffi.UnsignedInt Function(ffi.Pointer<termios>)>>('cfgetispeed');
  late final _cfgetispeed = _cfgetispeedPtr.asFunction<int Function(ffi.Pointer<termios>)>(isLeaf: true);

  int cfsetospeed(
    ffi.Pointer<termios> __termios_p,
    int __speed,
  ) {
    return _cfsetospeed(
      __termios_p,
      __speed,
    );
  }

  late final _cfsetospeedPtr =
      _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<termios>, ffi.UnsignedInt)>>('cfsetospeed');
  late final _cfsetospeed = _cfsetospeedPtr.asFunction<int Function(ffi.Pointer<termios>, int)>(isLeaf: true);

  int cfsetispeed(
    ffi.Pointer<termios> __termios_p,
    int __speed,
  ) {
    return _cfsetispeed(
      __termios_p,
      __speed,
    );
  }

  late final _cfsetispeedPtr =
      _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<termios>, ffi.UnsignedInt)>>('cfsetispeed');
  late final _cfsetispeed = _cfsetispeedPtr.asFunction<int Function(ffi.Pointer<termios>, int)>(isLeaf: true);

  int tcgetattr(
    int __fd,
    ffi.Pointer<termios> __termios_p,
  ) {
    return _tcgetattr(
      __fd,
      __termios_p,
    );
  }

  late final _tcgetattrPtr = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Int, ffi.Pointer<termios>)>>('tcgetattr');
  late final _tcgetattr = _tcgetattrPtr.asFunction<int Function(int, ffi.Pointer<termios>)>(isLeaf: true);

  int tcsetattr(
    int __fd,
    int __optional_actions,
    ffi.Pointer<termios> __termios_p,
  ) {
    return _tcsetattr(
      __fd,
      __optional_actions,
      __termios_p,
    );
  }

  late final _tcsetattrPtr =
      _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Int, ffi.Int, ffi.Pointer<termios>)>>('tcsetattr');
  late final _tcsetattr = _tcsetattrPtr.asFunction<int Function(int, int, ffi.Pointer<termios>)>(isLeaf: true);

  int tcsendbreak(
    int __fd,
    int __duration,
  ) {
    return _tcsendbreak(
      __fd,
      __duration,
    );
  }

  late final _tcsendbreakPtr = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Int, ffi.Int)>>('tcsendbreak');
  late final _tcsendbreak = _tcsendbreakPtr.asFunction<int Function(int, int)>(isLeaf: true);

  int tcdrain(
    int __fd,
  ) {
    return _tcdrain(
      __fd,
    );
  }

  late final _tcdrainPtr = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Int)>>('tcdrain');
  late final _tcdrain = _tcdrainPtr.asFunction<int Function(int)>(isLeaf: true);

  int tcflush(
    int __fd,
    int __queue_selector,
  ) {
    return _tcflush(
      __fd,
      __queue_selector,
    );
  }

  late final _tcflushPtr = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Int, ffi.Int)>>('tcflush');
  late final _tcflush = _tcflushPtr.asFunction<int Function(int, int)>(isLeaf: true);

  int tcflow(
    int __fd,
    int __action,
  ) {
    return _tcflow(
      __fd,
      __action,
    );
  }

  late final _tcflowPtr = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Int, ffi.Int)>>('tcflow');
  late final _tcflow = _tcflowPtr.asFunction<int Function(int, int)>(isLeaf: true);

  int tcgetsid(
    int __fd,
  ) {
    return _tcgetsid(
      __fd,
    );
  }

  late final _tcgetsidPtr = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Int)>>('tcgetsid');
  late final _tcgetsid = _tcgetsidPtr.asFunction<int Function(int)>(isLeaf: true);

  late final addresses = _SymbolAddresses(this);
}

class _SymbolAddresses {
  final LibCPlatformBackend _library;
  _SymbolAddresses(this._library);
  ffi.Pointer<ffi.NativeFunction<ffi.Int Function(ffi.Int, ffi.Int, ffi.Int, ffi.Pointer<epoll_event>)>>
      get epoll_ctl => _library._epoll_ctlPtr;
  ffi.Pointer<ffi.NativeFunction<ffi.Int Function(ffi.Int, ffi.Pointer<epoll_event>, ffi.Int, ffi.Int)>>
      get epoll_wait => _library._epoll_waitPtr;
  ffi.Pointer<ffi.NativeFunction<ffi.Pointer<ffi.Int> Function()>> get errno_location => _library._errno_locationPtr;
  ffi.Pointer<ffi.NativeFunction<pkg_ssizet.SSize Function(ffi.Int, ffi.Pointer<ffi.Void>, ffi.Size)>> get read =>
      _library._readPtr;
}

abstract class EPOLL_EVENTS {
  static const int EPOLLIN = 1;
  static const int EPOLLPRI = 2;
  static const int EPOLLOUT = 4;
  static const int EPOLLRDNORM = 64;
  static const int EPOLLRDBAND = 128;
  static const int EPOLLWRNORM = 256;
  static const int EPOLLWRBAND = 512;
  static const int EPOLLMSG = 1024;
  static const int EPOLLERR = 8;
  static const int EPOLLHUP = 16;
  static const int EPOLLRDHUP = 8192;
  static const int EPOLLEXCLUSIVE = 268435456;
  static const int EPOLLWAKEUP = 536870912;
  static const int EPOLLONESHOT = 1073741824;
  static const int EPOLLET = -2147483648;
}

class epoll_data extends ffi.Union {
  external ffi.Pointer<ffi.Void> ptr;

  @ffi.Int()
  external int fd;

  @ffi.Uint32()
  external int u32;

  @ffi.Uint64()
  external int u64;
}

class epoll_event extends ffi.Opaque {}

/// struct gpiochip_info - Information about a certain GPIO chip
/// @name: the Linux kernel name of this GPIO chip
/// @label: a functional name for this GPIO chip, such as a product
/// number, may be empty (i.e. label[0] == '\0')
/// @lines: number of GPIO lines on this chip
class gpiochip_info extends ffi.Struct {
  @ffi.Array.multi([32])
  external ffi.Array<ffi.Char> name;

  @ffi.Array.multi([32])
  external ffi.Array<ffi.Char> label;

  @ffi.Uint32()
  external int lines;
}

/// struct gpio_v2_line_values - Values of GPIO lines
/// @bits: a bitmap containing the value of the lines, set to 1 for active
/// and 0 for inactive.
/// @mask: a bitmap identifying the lines to get or set, with each bit
/// number corresponding to the index into &struct
/// gpio_v2_line_request.offsets.
class gpio_v2_line_values extends ffi.Struct {
  @ffi.Uint64()
  external int bits;

  @ffi.Uint64()
  external int mask;
}

/// struct gpio_v2_line_attribute - a configurable attribute of a line
/// @id: attribute identifier with value from &enum gpio_v2_line_attr_id
/// @padding: reserved for future use and must be zero filled
/// @flags: if id is %GPIO_V2_LINE_ATTR_ID_FLAGS, the flags for the GPIO
/// line, with values from &enum gpio_v2_line_flag, such as
/// %GPIO_V2_LINE_FLAG_ACTIVE_LOW, %GPIO_V2_LINE_FLAG_OUTPUT etc, added
/// together.  This overrides the default flags contained in the &struct
/// gpio_v2_line_config for the associated line.
/// @values: if id is %GPIO_V2_LINE_ATTR_ID_OUTPUT_VALUES, a bitmap
/// containing the values to which the lines will be set, with each bit
/// number corresponding to the index into &struct
/// gpio_v2_line_request.offsets.
/// @debounce_period_us: if id is %GPIO_V2_LINE_ATTR_ID_DEBOUNCE, the
/// desired debounce period, in microseconds
class gpio_v2_line_attribute extends ffi.Struct {
  @ffi.Uint32()
  external int id;

  @ffi.Uint32()
  external int padding;
}

/// struct gpio_v2_line_config_attribute - a configuration attribute
/// associated with one or more of the requested lines.
/// @attr: the configurable attribute
/// @mask: a bitmap identifying the lines to which the attribute applies,
/// with each bit number corresponding to the index into &struct
/// gpio_v2_line_request.offsets.
class gpio_v2_line_config_attribute extends ffi.Struct {
  external gpio_v2_line_attribute attr;

  @ffi.Uint64()
  external int mask;
}

/// struct gpio_v2_line_config - Configuration for GPIO lines
/// @flags: flags for the GPIO lines, with values from &enum
/// gpio_v2_line_flag, such as %GPIO_V2_LINE_FLAG_ACTIVE_LOW,
/// %GPIO_V2_LINE_FLAG_OUTPUT etc, added together.  This is the default for
/// all requested lines but may be overridden for particular lines using
/// @attrs.
/// @num_attrs: the number of attributes in @attrs
/// @padding: reserved for future use and must be zero filled
/// @attrs: the configuration attributes associated with the requested
/// lines.  Any attribute should only be associated with a particular line
/// once.  If an attribute is associated with a line multiple times then the
/// first occurrence (i.e. lowest index) has precedence.
class gpio_v2_line_config extends ffi.Struct {
  @ffi.Uint64()
  external int flags;

  @ffi.Uint32()
  external int num_attrs;

  @ffi.Array.multi([5])
  external ffi.Array<ffi.Uint32> padding;

  @ffi.Array.multi([10])
  external ffi.Array<gpio_v2_line_config_attribute> attrs;
}

/// struct gpio_v2_line_request - Information about a request for GPIO lines
/// @offsets: an array of desired lines, specified by offset index for the
/// associated GPIO chip
/// @consumer: a desired consumer label for the selected GPIO lines such as
/// "my-bitbanged-relay"
/// @config: requested configuration for the lines.
/// @num_lines: number of lines requested in this request, i.e. the number
/// of valid fields in the %GPIO_V2_LINES_MAX sized arrays, set to 1 to
/// request a single line
/// @event_buffer_size: a suggested minimum number of line events that the
/// kernel should buffer.  This is only relevant if edge detection is
/// enabled in the configuration. Note that this is only a suggested value
/// and the kernel may allocate a larger buffer or cap the size of the
/// buffer. If this field is zero then the buffer size defaults to a minimum
/// of @num_lines * 16.
/// @padding: reserved for future use and must be zero filled
/// @fd: if successful this field will contain a valid anonymous file handle
/// after a %GPIO_GET_LINE_IOCTL operation, zero or negative value means
/// error
class gpio_v2_line_request extends ffi.Struct {
  @ffi.Array.multi([64])
  external ffi.Array<ffi.Uint32> offsets;

  @ffi.Array.multi([32])
  external ffi.Array<ffi.Char> consumer;

  external gpio_v2_line_config config;

  @ffi.Uint32()
  external int num_lines;

  @ffi.Uint32()
  external int event_buffer_size;

  @ffi.Array.multi([5])
  external ffi.Array<ffi.Uint32> padding;

  @ffi.Int32()
  external int fd;
}

/// struct gpio_v2_line_info - Information about a certain GPIO line
/// @name: the name of this GPIO line, such as the output pin of the line on
/// the chip, a rail or a pin header name on a board, as specified by the
/// GPIO chip, may be empty (i.e. name[0] == '\0')
/// @consumer: a functional name for the consumer of this GPIO line as set
/// by whatever is using it, will be empty if there is no current user but
/// may also be empty if the consumer doesn't set this up
/// @offset: the local offset on this GPIO chip, fill this in when
/// requesting the line information from the kernel
/// @num_attrs: the number of attributes in @attrs
/// @flags: flags for the GPIO lines, with values from &enum
/// gpio_v2_line_flag, such as %GPIO_V2_LINE_FLAG_ACTIVE_LOW,
/// %GPIO_V2_LINE_FLAG_OUTPUT etc, added together.
/// @attrs: the configuration attributes associated with the line
/// @padding: reserved for future use
class gpio_v2_line_info extends ffi.Struct {
  @ffi.Array.multi([32])
  external ffi.Array<ffi.Char> name;

  @ffi.Array.multi([32])
  external ffi.Array<ffi.Char> consumer;

  @ffi.Uint32()
  external int offset;

  @ffi.Uint32()
  external int num_attrs;

  @ffi.Uint64()
  external int flags;

  @ffi.Array.multi([10])
  external ffi.Array<gpio_v2_line_attribute> attrs;

  @ffi.Array.multi([4])
  external ffi.Array<ffi.Uint32> padding;
}

/// struct gpio_v2_line_event - The actual event being pushed to userspace
/// @timestamp_ns: best estimate of time of event occurrence, in nanoseconds.
/// The @timestamp_ns is read from %CLOCK_MONOTONIC and is intended to allow
/// the accurate measurement of the time between events. It does not provide
/// the wall-clock time.
/// @id: event identifier with value from &enum gpio_v2_line_event_id
/// @offset: the offset of the line that triggered the event
/// @seqno: the sequence number for this event in the sequence of events for
/// all the lines in this line request
/// @line_seqno: the sequence number for this event in the sequence of
/// events on this particular line
/// @padding: reserved for future use
class gpio_v2_line_event extends ffi.Struct {
  @ffi.Uint64()
  external int timestamp_ns;

  @ffi.Uint32()
  external int id;

  @ffi.Uint32()
  external int offset;

  @ffi.Uint32()
  external int seqno;

  @ffi.Uint32()
  external int line_seqno;

  @ffi.Array.multi([6])
  external ffi.Array<ffi.Uint32> padding;
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

  @ffi.Array.multi([32])
  external ffi.Array<ffi.Char> name;

  @ffi.Array.multi([32])
  external ffi.Array<ffi.Char> consumer;
}

/// struct gpioline_info_changed - Information about a change in status
/// of a GPIO line
/// @info: updated line information
/// @timestamp: estimate of time of status change occurrence, in nanoseconds
/// @event_type: one of %GPIOLINE_CHANGED_REQUESTED,
/// %GPIOLINE_CHANGED_RELEASED and %GPIOLINE_CHANGED_CONFIG
/// @padding: reserved for future use
///
/// The &struct gpioline_info embedded here has 32-bit alignment on its own,
/// but it works fine with 64-bit alignment too. With its 72 byte size, we can
/// guarantee there are no implicit holes between it and subsequent members.
/// The 20-byte padding at the end makes sure we don't add any implicit padding
/// at the end of the structure on 64-bit architectures.
///
/// Note: This struct is part of ABI v1 and is deprecated.
/// Use &struct gpio_v2_line_info_changed instead.
class gpioline_info_changed extends ffi.Struct {
  external gpioline_info info;

  @ffi.Uint64()
  external int timestamp;

  @ffi.Uint32()
  external int event_type;

  @ffi.Array.multi([5])
  external ffi.Array<ffi.Uint32> padding;
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
  @ffi.Array.multi([64])
  external ffi.Array<ffi.Uint32> lineoffsets;

  @ffi.Uint32()
  external int flags;

  @ffi.Array.multi([64])
  external ffi.Array<ffi.Uint8> default_values;

  @ffi.Array.multi([32])
  external ffi.Array<ffi.Char> consumer_label;

  @ffi.Uint32()
  external int lines;

  @ffi.Int()
  external int fd;
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

  @ffi.Array.multi([64])
  external ffi.Array<ffi.Uint8> default_values;

  @ffi.Array.multi([4])
  external ffi.Array<ffi.Uint32> padding;
}

/// struct gpiohandle_data - Information of values on a GPIO handle
/// @values: when getting the state of lines this contains the current
/// state of a line, when setting the state of lines these should contain
/// the desired target state
///
/// Note: This struct is part of ABI v1 and is deprecated.
/// Use &struct gpio_v2_line_values instead.
class gpiohandle_data extends ffi.Struct {
  @ffi.Array.multi([64])
  external ffi.Array<ffi.Uint8> values;
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

  @ffi.Array.multi([32])
  external ffi.Array<ffi.Char> consumer_label;

  @ffi.Int()
  external int fd;
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

class termios extends ffi.Struct {
  @ffi.UnsignedInt()
  external int c_iflag;

  @ffi.UnsignedInt()
  external int c_oflag;

  @ffi.UnsignedInt()
  external int c_cflag;

  @ffi.UnsignedInt()
  external int c_lflag;

  @ffi.UnsignedChar()
  external int c_line;

  @ffi.Array.multi([32])
  external ffi.Array<ffi.UnsignedChar> c_cc;

  @ffi.UnsignedInt()
  external int c_ispeed;

  @ffi.UnsignedInt()
  external int c_ospeed;
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
}

const int EPOLL_CLOEXEC = 524288;

const int GPIOLINE_CHANGED_REQUESTED = 1;

const int GPIOLINE_CHANGED_RELEASED = 2;

const int GPIOLINE_CHANGED_CONFIG = 3;

const int EPOLL_CLOEXEC1 = 524288;

const int EPOLL_CTL_ADD = 1;

const int EPOLL_CTL_DEL = 2;

const int EPOLL_CTL_MOD = 3;

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

const int NCCS = 32;

const int VINTR = 0;

const int VQUIT = 1;

const int VKILL = 3;

const int VEOF = 4;

const int VTIME = 5;

const int VSTART = 8;

const int VSTOP = 9;

const int VSUSP = 10;

const int VEOL = 11;

const int IGNBRK = 1;

const int BRKINT = 2;

const int IGNPAR = 4;

const int PARMRK = 8;

const int INPCK = 16;

const int ISTRIP = 32;

const int IGNCR = 128;

const int ICRNL = 256;

const int IXON = 1024;

const int IXANY = 2048;

const int IXOFF = 4096;

const int OPOST = 1;

const int ONLCR = 4;

const int OCRNL = 8;

const int ONOCR = 16;

const int ONLRET = 32;

const int OFILL = 64;

const int OFDEL = 128;

const int NLDLY = 256;

const int NL0 = 0;

const int NL1 = 256;

const int CRDLY = 1536;

const int CR0 = 0;

const int CR1 = 512;

const int CR2 = 1024;

const int CR3 = 1536;

const int TABDLY = 6144;

const int TAB0 = 0;

const int TAB1 = 2048;

const int TAB2 = 4096;

const int TAB3 = 6144;

const int BSDLY = 8192;

const int BS0 = 0;

const int BS1 = 8192;

const int FFDLY = 32768;

const int FF0 = 0;

const int FF1 = 32768;

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

const int ECHO = 8;

const int ECHOE = 16;

const int ECHOK = 32;

const int ECHONL = 64;

const int NOFLSH = 128;

const int TOSTOP = 256;

const int IEXTEN = 32768;

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
