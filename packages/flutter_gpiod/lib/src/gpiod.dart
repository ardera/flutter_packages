import 'dart:async';
import 'dart:io';
import 'dart:ffi' as ffi;
import 'dart:isolate';

import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:ffi/ffi.dart' as ffi;
import 'package:_ardera_common_libc_bindings/_ardera_common_libc_bindings.dart';

import 'util.dart';
import 'linux_error.dart';

/// The direction of a gpiod line.
enum LineDirection { input, output }

/// The way high voltage / low voltage should be written
/// to the line.
enum OutputMode { pushPull, openDrain, openSource }

/// Whether there should be pull-up or -down
/// resistors connected to the line.
enum Bias { disable, pullUp, pullDown }

/// Whether the line should be high voltage when
/// it's active or low voltage.
enum ActiveState { high, low }

/// It's a rising edge when the voltage goes from low to high,
/// falling from high to low.
enum SignalEdge { rising, falling }

@immutable
class GlobalSignalEvent {
  const GlobalSignalEvent(this.lineHandle, this.signalEvent);

  final int lineHandle;
  final SignalEvent signalEvent;

  String toString() {
    return "GlobalSignalEvent(lineHandle: $lineHandle, signalEvent: $signalEvent)";
  }
}

/// An event that can ocurr on a line when
/// you are listening on it.
///
/// Contains the edge that triggered the event,
/// and the time when this event ocurred.
/// (which is given by the kernel)
@immutable
class SignalEvent {
  const SignalEvent(this.edge, this.timestampNanos, this.timestamp, this.time);

  /// The edge that was detected on the [GpioLine].
  final SignalEdge edge;

  /// The precise time at which this edge ocurred determined by the kernel
  /// using the system monotonic clock. This is not a realtime timestamp and
  /// only useful for relative measuring, e.g. measuring the delta between two
  /// signal events. The system realtime clock on the other hand may fluctuate so
  /// it's not 100% accurate.
  final int timestampNanos;

  /// Basically [timestampNanos] as a [Duration], only micro-second accurate
  /// instead of nano-second but easier to use.
  final Duration timestamp;

  /// The time this edge ocurred as a best effort guess. Not provided
  /// by the kernel and thus not that accurate.
  final DateTime time;

  String toString() {
    final edgeStr = edge == SignalEdge.falling ? "falling" : "rising";
    return "SignalEvent(edge: $edgeStr, timestamp: $timestamp, time: $time)";
  }
}

ffi.Pointer<T> newStruct<T extends ffi.NativeType>({
  required int elementSize,
  int count = 1,
  ffi.Allocator allocator = ffi.malloc,
}) {
  return allocator.allocate(elementSize * count);
}

void freeStruct<T extends ffi.NativeType>(
  ffi.Pointer<T> pointer, {
  ffi.Allocator allocator = ffi.malloc,
}) {
  return allocator.free(pointer);
}

ffi.Pointer<gpioevent_data> newGpioEventData({
  int count = 1,
  ffi.Allocator allocator = ffi.malloc,
}) {
  return newStruct<gpioevent_data>(
    count: count,
    elementSize: ffi.sizeOf<gpioevent_data>(),
    allocator: allocator,
  );
}

int _syscall3<A0, A1, A2>(
  ffi.Pointer<ffi.Int32> errnoPtr,
  int Function(A0, A1, A2) fn,
  A0 arg0,
  A1 arg1,
  A2 arg2,
) {
  late int ok, errno;

  do {
    ok = fn(arg0, arg1, arg2);
    if (ok < 0) {
      errno = errnoPtr.value;
    }
  } while (ok < 0 && errno == EINTR);

  return ok < 0 ? -errno : ok;
}

int _syscall4<A0, A1, A2, A3>(
  ffi.Pointer<ffi.Int32> errnoPtr,
  int Function(A0, A1, A2, A3) fn,
  A0 arg0,
  A1 arg1,
  A2 arg2,
  A3 arg3,
) {
  late int ok, errno;

  do {
    ok = fn(arg0, arg1, arg2, arg3);
    if (ok < 0) {
      errno = errnoPtr.value;
    }
  } while (ok < 0 && errno == EINTR);

  return ok < 0 ? -errno : ok;
}

typedef native_epoll_wait = ffi.NativeFunction<ffi.Int32 Function(ffi.Int32, ffi.Pointer, ffi.Int32, ffi.Int32)>;
typedef dart_epoll_wait = int Function(int, ffi.Pointer, int, int);

typedef native_epoll_ctl = ffi.NativeFunction<ffi.Int32 Function(ffi.Int32, ffi.Int32, ffi.Int32, ffi.Pointer)>;
typedef dart_epoll_ctl = int Function(int, int, int, ffi.Pointer);

typedef native_read = ffi.NativeFunction<ffi.Int32 Function(ffi.Int32, ffi.Pointer<ffi.Void>, ffi.Uint32)>;
typedef dart_read = int Function(int, ffi.Pointer<ffi.Void>, int);

typedef native_read64 = ffi.NativeFunction<ffi.Int64 Function(ffi.Int32, ffi.Pointer<ffi.Void>, ffi.Uint64)>;
typedef dart_read64 = dart_read;

typedef native_errno_location = ffi.NativeFunction<ffi.Pointer<ffi.Int32> Function()>;
typedef dart_errno_location = ffi.Pointer<ffi.Int32> Function();

Future<void> _eventIsolateEntry2(List args) async {
  int ok;

  final sendPort = args[0] as SendPort;
  final epollFd = args[1] as int;
  final libc = LibC(ffi.DynamicLibrary.process());

  final maxEpollEvents = 64;
  final epollEvents = ffi.calloc.allocate<epoll_event>(ffi.sizeOf<epoll_event>() * maxEpollEvents);

  final maxEvents = 16;
  final events = newGpioEventData(count: maxEvents);

  while (true) {
    await Future.delayed(Duration.zero);

    ok = _syscall4(
      libc.errno_location(),
      libc.epoll_wait,
      epollFd,
      epollEvents,
      maxEpollEvents,
      200,
    );
    if (ok < 0) {
      freeStruct(epollEvents, allocator: ffi.calloc);
      freeStruct(events);
      throw LinuxError("Could not wait for GPIO events", "epoll_wait", -ok);
    }

    final convertedEvents = <List<int>>[];
    var nReady = ok;
    for (var i = 0; i < maxEpollEvents && nReady > 0; i++) {
      final epollEvent = epollEvents.elementAt(i);
      if (epollEvent.ref.events != 0) {
        ok = _syscall3(
          libc.errno_location(),
          libc.read,
          epollEvent.ref.data.u64,
          events.cast<ffi.Void>(),
          maxEvents * ffi.sizeOf<gpioevent_data>(),
        );
        if (ok < 0) {
          freeStruct(epollEvents, allocator: ffi.calloc);
          freeStruct(events);
          throw LinuxError("Could not read GPIO events from event line fd", "read", -ok);
        } else if (ok == 0) {
          throw LinuxError(
            'read(${epollEvent.ref.data.u64}, ${events}, ${maxEvents * ffi.sizeOf<gpioevent_data>()}) returned 0',
          );
        }

        final nEventsRead = ok / ffi.sizeOf<gpioevent_data>();
        for (var j = 0; j < nEventsRead; j++) {
          final event = events.elementAt(j).ref;
          convertedEvents.add(<int>[
            epollEvent.ref.data.u64,
            event.id,
            event.timestamp,
            DateTime.now().microsecondsSinceEpoch,
          ]);
        }

        nReady--;
      }
    }

    if (convertedEvents.isNotEmpty) {
      sendPort.send(convertedEvents);
    }
  }
}

/// Provides raw access to the platform-side methods.
class PlatformInterface {
  PlatformInterface._construct(
    this.libc,
    this._numChips,
    this._chipIndexToFd,
    this._epollFd,
    this._eventReceivePort,
  );

  factory PlatformInterface._private() {
    late final LibC libc;
    if (Platform.isAndroid) {
      libc = LibC(ffi.DynamicLibrary.open("libc.so"));
    } else if (Platform.isLinux) {
      libc = LibC(ffi.DynamicLibrary.open("libc.so.6"));
    }

    final numChips = Directory('/dev')
        .listSync(followLinks: false, recursive: false)
        .where((element) => basename(element.path).startsWith('gpiochip'))
        .length;

    final chipIndexToFd = <int, int>{};

    for (var i = 0; i < numChips; i++) {
      final pathPtr = '/dev/gpiochip$i'.toNativeUtf8();

      final fd = libc.open(pathPtr.cast<ffi.Char>(), O_RDWR | O_CLOEXEC);

      ffi.malloc.free(pathPtr);

      if (fd < 0) {
        chipIndexToFd.values.forEach((fd) => libc.close(fd));
        throw FileSystemException('Could not open GPIO chip $i', '/dev/gpiochip$i');
      }

      chipIndexToFd[i] = fd;
    }

    final epollFd = libc.epoll_create1(0);
    if (epollFd < 0) {
      throw LinuxError("Could not create epoll instance", "epoll_create1", libc.errno);
    }

    final receivePort = ReceivePort();
    final errorReceivePort = ReceivePort();

    print('before isolate.spawn');

    Isolate.spawn(
      _eventIsolateEntry2,
      [
        receivePort.sendPort,
        epollFd,
      ],
      onError: errorReceivePort.sendPort,
      debugName: 'flutter_gpiod event listener',
    );

    print('after isolate.spawn');

    errorReceivePort.listen((message) {
      throw RemoteError(message[0], message[1]);
    });

    return PlatformInterface._construct(libc, numChips, chipIndexToFd, epollFd, receivePort);
  }

  final LibC libc;
  final int _numChips;
  final Map<int, int> _chipIndexToFd;
  final int _epollFd;
  final ReceivePort _eventReceivePort;
  final _requestedLines = <int>{};
  final _lineHandleToLineHandleFd = <int, int>{};
  final _lineHandleToLineEventFd = <int, int>{};

  Stream<GlobalSignalEvent>? _eventStream;

  static PlatformInterface? _instance;

  static PlatformInterface get instance {
    if (_instance == null) {
      _instance = PlatformInterface._private();
    }
    return _instance!;
  }

  void _ioctl(int fd, int request, ffi.Pointer argp) {
    final result = libc.ioctlPtr(fd, request, argp.cast<ffi.Void>());
    if (result < 0) {
      throw LinuxError("GPIO ioctl failed", "ioctl", libc.errno);
    }
  }

  int _chipFdFromChipIndex(int chipIndex) {
    return _chipIndexToFd[chipIndex]!;
  }

  int _lineFdFromLineHandle(int lineHandle) {
    return _lineHandleToLineHandleFd[lineHandle] ?? _lineHandleToLineEventFd[lineHandle]!;
  }

  int _chipIndexFromLineHandle(int lineHandle) {
    return lineHandle >> 32;
  }

  int _chipFdFromLineHandle(int lineHandle) {
    return _chipIndexToFd[_chipIndexFromLineHandle(lineHandle)]!;
  }

  int _lineIndexFromLineHandle(int lineHandle) {
    return lineHandle & 0xFFFFFFFF;
  }

  Stream<GlobalSignalEvent> get eventStream {
    if (_eventStream == null) {
      _eventStream = _eventReceivePort
          .cast<List<List<int>>>()
          .expand((element) {
            // sort with increasing timestamps
            element.sort((a, b) => a[2].compareTo(b[2]));
            return element;
          })
          .map((list) {
            final lineHandle = _lineHandleToLineEventFd.entries
                .singleWhere(
                  (e) => e.value == list[0],
                  // use -1 as a special sentinel lineHandle for lines that aren't found.
                  // happens for example when the line was removed before the epoll
                  // listener noticed.
                  orElse: () => MapEntry(-1, list[0]),
                )
                .key;

            final edge = list[1] == GPIOEVENT_EVENT_RISING_EDGE ? SignalEdge.rising : SignalEdge.falling;
            final timestampNanos = list[2];
            final timestamp = Duration(microseconds: timestampNanos ~/ 1000);
            final time = DateTime.fromMicrosecondsSinceEpoch(list[3]);

            return GlobalSignalEvent(lineHandle, SignalEvent(edge, timestampNanos, timestamp, time));
          })
          .where((event) => event.lineHandle != -1)
          .asBroadcastStream();
    }

    return _eventStream!;
  }

  int getNumChips() {
    return _numChips;
  }

  Map<String, dynamic> getChipDetails(int chipIndex) {
    final structPtr = newStruct<gpiochip_info>(elementSize: ffi.sizeOf<gpiochip_info>());
    final struct = structPtr.ref;

    Map<String, dynamic> map;

    try {
      _ioctl(_chipFdFromChipIndex(chipIndex), GPIO_GET_CHIPINFO_IOCTL, structPtr);

      map = <String, dynamic>{
        'name': stringFromInlineArray(32, (i) => struct.name[i]),
        'label': stringFromInlineArray(32, (i) => struct.label[i]),
        'numLines': struct.lines
      };
    } finally {
      freeStruct(structPtr);
    }

    return map;
  }

  int getLineHandle(int chipIndex, int lineIndex) {
    return (chipIndex << 32) + lineIndex;
  }

  LineInfo getLineInfo(int lineHandle) {
    final fd = _chipFdFromLineHandle(lineHandle);
    final offset = _lineIndexFromLineHandle(lineHandle);

    final structPtr = newStruct<gpioline_info>(elementSize: ffi.sizeOf<gpioline_info>());
    final struct = structPtr.ref;

    struct.line_offset = offset;

    LineInfo info;

    try {
      _ioctl(fd, GPIO_GET_LINEINFO_IOCTL, structPtr);

      final isOut = struct.flags & GPIOLINE_FLAG_IS_OUT > 0;
      final isOpenDrain = struct.flags & GPIOLINE_FLAG_OPEN_DRAIN > 0;
      final isOpenSource = struct.flags & GPIOLINE_FLAG_OPEN_SOURCE > 0;
      final isActiveLow = struct.flags & GPIOLINE_FLAG_ACTIVE_LOW > 0;
      final isKernel = struct.flags & GPIOLINE_FLAG_KERNEL > 0;

      info = LineInfo(
        name: stringFromInlineArray(32, (i) => struct.name[i]),
        consumer: stringFromInlineArray(32, (i) => struct.consumer[i]),
        direction: isOut ? LineDirection.output : LineDirection.input,
        outputMode: isOpenDrain
            ? OutputMode.openDrain
            : isOpenSource
                ? OutputMode.openSource
                : OutputMode.pushPull,
        bias: Bias.disable,
        activeState: isActiveLow ? ActiveState.low : ActiveState.high,
        isUsed: isKernel || _requestedLines.contains(lineHandle),
        isRequested: _requestedLines.contains(lineHandle),
      );
    } finally {
      freeStruct(structPtr);
    }

    return info;
  }

  void requestLine({
    required int lineHandle,
    required String consumer,
    required LineDirection direction,
    OutputMode? outputMode,
    Bias? bias,
    ActiveState activeState = ActiveState.high,
    Set<SignalEdge> triggers = const {},
    bool? initialValue,
  }) {
    final isInput = direction == LineDirection.input;
    final isEvent = triggers.isNotEmpty;

    if (isEvent && !isInput) {
      throw ArgumentError('Line must be requested as input when triggers are requested.');
    }

    if (isInput) {
      if (outputMode != null) {
        throw ArgumentError.value(
          outputMode,
          'outputMode',
          'Must be null when line is requested as input.',
        );
      }
      if (initialValue != null) {
        throw ArgumentError.value(
          initialValue,
          'initialValue',
          'Must be null when line is requested as input.',
        );
      }
    } else {
      ArgumentError.checkNotNull(outputMode, 'outputMode');
      ArgumentError.checkNotNull(initialValue, 'initialValue');
    }

    final fd = _chipFdFromLineHandle(lineHandle);
    final offset = _lineIndexFromLineHandle(lineHandle);

    if (!isEvent) {
      final requestPtr = newStruct<gpiohandle_request>(elementSize: ffi.sizeOf<gpiohandle_request>());
      final request = requestPtr.ref;

      request.lines = 1;
      request.lineoffsets[0] = offset;

      writeStringToArrayHelper(
        consumer,
        32,
        (i, v) => request.consumer_label[i] = v,
      );

      request.flags = (direction == LineDirection.input ? GPIOHANDLE_REQUEST_INPUT : GPIOHANDLE_REQUEST_OUTPUT) |
          (outputMode == OutputMode.openDrain
              ? GPIOHANDLE_REQUEST_OPEN_DRAIN
              : outputMode == OutputMode.openSource
                  ? GPIOHANDLE_REQUEST_OPEN_SOURCE
                  : 0) |
          (bias == Bias.disable
              ? GPIOHANDLE_REQUEST_BIAS_DISABLE
              : bias == Bias.pullDown
                  ? GPIOHANDLE_REQUEST_BIAS_PULL_DOWN
                  : bias == Bias.pullUp
                      ? GPIOHANDLE_REQUEST_BIAS_PULL_UP
                      : 0) |
          (activeState == ActiveState.low ? GPIOHANDLE_REQUEST_ACTIVE_LOW : 0);

      if (initialValue != null) {
        request.default_values[0] = initialValue ? 1 : 0;
      }

      try {
        _ioctl(fd, GPIO_GET_LINEHANDLE_IOCTL, requestPtr);
        _requestedLines.add(lineHandle);
        _lineHandleToLineHandleFd[lineHandle] = request.fd;
      } finally {
        freeStruct(requestPtr);
      }
    } else {
      final requestPtr = newStruct<gpioevent_request>(elementSize: ffi.sizeOf<gpioevent_request>());
      final request = requestPtr.ref;

      request.lineoffset = offset;
      writeStringToArrayHelper(consumer, 32, (i, v) => request.consumer_label[i] = v);
      request.handleflags = GPIOHANDLE_REQUEST_INPUT |
          (bias == Bias.disable
              ? GPIOHANDLE_REQUEST_BIAS_DISABLE
              : bias == Bias.pullDown
                  ? GPIOHANDLE_REQUEST_BIAS_PULL_DOWN
                  : bias == Bias.pullUp
                      ? GPIOHANDLE_REQUEST_BIAS_PULL_UP
                      : 0) |
          (activeState == ActiveState.low ? GPIOHANDLE_REQUEST_ACTIVE_LOW : 0);
      request.eventflags = triggers == {SignalEdge.rising}
          ? GPIOEVENT_REQUEST_RISING_EDGE
          : triggers == {SignalEdge.falling}
              ? GPIOEVENT_REQUEST_FALLING_EDGE
              : GPIOEVENT_REQUEST_BOTH_EDGES;

      try {
        _ioctl(fd, GPIO_GET_LINEEVENT_IOCTL, requestPtr);

        _requestedLines.add(lineHandle);
        _lineHandleToLineEventFd[lineHandle] = request.fd;

        final epollEvent = ffi.calloc.allocate<epoll_event>(ffi.sizeOf<epoll_event>());
        epollEvent.ref.events = EPOLL_EVENTS.EPOLLIN | EPOLL_EVENTS.EPOLLPRI;
        epollEvent.ref.data.u64 = request.fd;
        final result = libc.epoll_ctl(_epollFd, EPOLL_CTL_ADD, request.fd, epollEvent);
        ffi.calloc.free(epollEvent);

        if (result < 0) {
          final errno = libc.errno;
          releaseLine(lineHandle);
          throw LinuxError("Could not add GPIO line event fd to epoll instance", "epoll_ctl", errno);
        }
      } finally {
        freeStruct(requestPtr);
      }
    }
  }

  void releaseLine(int lineHandle) {
    assert(_requestedLines.contains(lineHandle));

    final fd = _lineFdFromLineHandle(lineHandle);
    var ok = libc.close(fd);
    var errno = libc.errno;
    if (ok != 0) {
      throw LinuxError("Couldn't release line by closing line handle file descriptor.", "close", errno);
    }

    _requestedLines.remove(lineHandle);
    _lineHandleToLineHandleFd.remove(lineHandle);
    _lineHandleToLineEventFd.remove(lineHandle);
  }

  void reconfigureLine({
    required int lineHandle,
    required LineDirection direction,
    OutputMode? outputMode,
    Bias? bias,
    ActiveState activeState = ActiveState.high,
    bool? initialValue,
  }) async {
    final isInput = direction == LineDirection.input;

    if (isInput) {
      if (outputMode != null) {
        throw ArgumentError.value(
          outputMode,
          'outputMode',
          'Must be null when line is requested as input.',
        );
      }
      if (initialValue != null) {
        throw ArgumentError.value(
          initialValue,
          'initialValue',
          'Must be null when line is requested as input.',
        );
      }
    } else {
      ArgumentError.checkNotNull(outputMode, 'outputMode');
      ArgumentError.checkNotNull(initialValue, 'initialValue');
    }

    final requestPtr = newStruct<gpiohandle_config>(elementSize: ffi.sizeOf<gpiohandle_config>());
    final request = requestPtr.ref;

    request.flags = (direction == LineDirection.input ? GPIOHANDLE_REQUEST_INPUT : GPIOHANDLE_REQUEST_OUTPUT) |
        (outputMode == OutputMode.openDrain
            ? GPIOHANDLE_REQUEST_OPEN_DRAIN
            : outputMode == OutputMode.openSource
                ? GPIOHANDLE_REQUEST_OPEN_SOURCE
                : 0) |
        (bias == Bias.disable
            ? GPIOHANDLE_REQUEST_BIAS_DISABLE
            : bias == Bias.pullDown
                ? GPIOHANDLE_REQUEST_BIAS_PULL_DOWN
                : bias == Bias.pullUp
                    ? GPIOHANDLE_REQUEST_BIAS_PULL_UP
                    : 0) |
        (activeState == ActiveState.low ? GPIOHANDLE_REQUEST_ACTIVE_LOW : 0);

    if (initialValue != null) {
      request.default_values[0] = initialValue ? 1 : 0;
    }

    try {
      _ioctl(_lineFdFromLineHandle(lineHandle), GPIOHANDLE_SET_CONFIG_IOCTL, requestPtr);
    } finally {
      freeStruct(requestPtr);
    }
  }

  bool getLineValue(int lineHandle) {
    assert(_requestedLines.contains(lineHandle));

    final fd = _lineFdFromLineHandle(lineHandle);

    final structPtr = newStruct<gpiohandle_data>(elementSize: ffi.sizeOf<gpiohandle_data>());
    final struct = structPtr.ref;

    bool result;

    try {
      _ioctl(fd, GPIOHANDLE_GET_LINE_VALUES_IOCTL, structPtr);
      result = struct.values[0] != 0;
    } finally {
      freeStruct(structPtr);
    }

    return result;
  }

  void setLineValue(int lineHandle, bool value) {
    assert(_requestedLines.contains(lineHandle));
    assert(_lineHandleToLineHandleFd.containsKey(lineHandle));

    final structPtr = newStruct<gpiohandle_data>(elementSize: ffi.sizeOf<gpiohandle_data>());
    final struct = structPtr.ref;

    struct.values[0] = value ? 1 : 0;
    try {
      _ioctl(_lineFdFromLineHandle(lineHandle), GPIOHANDLE_SET_LINE_VALUES_IOCTL, structPtr);
    } finally {
      freeStruct(structPtr);
    }
  }

  bool supportsBias() {
    if (Platform.isAndroid) {
      return false;
    } else if (!Platform.isLinux) {
      throw StateError("Unsupported OS: ${Platform.operatingSystem}");
    }

    final matches = RegExp("^Linux (\\d*)\\.(\\d*)").firstMatch(Platform.operatingSystemVersion)!;
    if (matches.groupCount == 2) {
      final major = int.parse(matches.group(1)!);
      final minor = int.parse(matches.group(2)!);

      if (major > 5) {
        return true;
      } else if (major == 5) {
        if (minor >= 5) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } else {
      throw StateError(
          "Could not parse linux release number from `Platform.operatingSystemVersion`: \"${Platform.operatingSystemVersion}\")");
    }
  }

  bool supportsLineReconfiguration() {
    return supportsBias();
  }
}

/// Global interface to the linux kernel GPIO interface.
///
/// Starting-point for querying GPIO chips or lines,
/// and finding the line you want to control.
class FlutterGpiod {
  FlutterGpiod._internal(this.chips, this.supportsBias, this.supportsLineReconfiguration);

  static FlutterGpiod? _instance;

  /// The list of GPIO chips attached to this system.
  final List<GpioChip> chips;

  /// Whether setting and getting GPIO line bias is supported.
  ///
  /// See [GpioLine.requestInput], [GpioLine.requestOutput],
  /// [GpioLine.reconfigureInput] and [GpioLine.reconfigureOutput].
  final bool supportsBias;

  /// Whether GPIO line reconfiguration is supported.
  ///
  /// See [GpioLine.reconfigureInput] and [GpioLine.reconfigureOutput].
  final bool supportsLineReconfiguration;

  Stream<GlobalSignalEvent>? __onGlobalSignalEvent;

  /// Gets the global instance of [FlutterGpiod].
  ///
  /// If none exists, one will be constructed.
  static FlutterGpiod get instance {
    if (_instance == null) {
      final chips =
          List.generate(PlatformInterface.instance.getNumChips(), (i) => GpioChip._fromIndex(i), growable: false);

      final bias = PlatformInterface.instance.supportsBias();
      final reconfig = PlatformInterface.instance.supportsLineReconfiguration();

      _instance = FlutterGpiod._internal(List.unmodifiable(chips), bias, reconfig);
    }

    return _instance!;
  }

  Stream<GlobalSignalEvent> get _onGlobalSignalEvent {
    __onGlobalSignalEvent ??= PlatformInterface.instance.eventStream;
    return __onGlobalSignalEvent!;
  }

  Stream<SignalEvent> _onSignalEvent(int lineHandle) {
    return _onGlobalSignalEvent.where((e) => e.lineHandle == lineHandle).map((e) => e.signalEvent);
  }
}

/// A single GPIO chip providing access to
/// some number of GPIO lines / pins.
@immutable
class GpioChip {
  /// The index of the GPIO chip in the [FlutterGpiod.chips] list,
  /// and at the same time, the numerical suffix of [name].
  final int index;

  /// The name of this GPIO chip.
  ///
  /// This is the filename of the underlying GPIO device, so
  /// for example `gpiochip0` or `gpiochip1`.
  final String name;

  /// The label of this GPIO chip.
  ///
  /// This is the hardware label of the underlying GPIO device.
  /// The main GPIO chip of the Raspberry Pi 4 has the label
  /// `pinctrl-bcm2835` for example.
  final String label;

  final int _numLines;

  /// The GPIO lines (pins) associated with this chip.
  final List<GpioLine> lines;

  GpioChip._(this.index, this.name, this.label, this._numLines, this.lines);

  factory GpioChip._fromIndex(int chipIndex) {
    final details = PlatformInterface.instance.getChipDetails(chipIndex);

    final lines = List.generate(
      details['numLines'],
      (i) => GpioLine._fromHandle(
        PlatformInterface.instance.getLineHandle(chipIndex, i),
      ),
      growable: false,
    );

    return GpioChip._(
      chipIndex,
      details['name'],
      details['label'],
      details['numLines'],
      List.unmodifiable(lines),
    );
  }

  @override
  String toString() {
    return "GpiodChip(index: $index, name: '$name', label: '$label', numLines: $_numLines)";
  }
}

/// Info about a GPIO line. Also contains
/// the line configuration.
@immutable
class LineInfo {
  /// The name (determined by the driver or device tree) of this line.
  ///
  /// Can be null, is limited and truncated to 32 characters.
  ///
  /// For example, `PWR_LED_OFF` is the name of a GPIO line on
  /// Raspberry Pi.
  final String? name;

  /// A label given to the line by the application currently using this
  /// line, ideally describing what the line is used for right now.
  ///
  /// Can be null, is limited and truncated to 32 characters.
  final String? consumer;

  /// Whether the line is currently used by any application (including this one).
  final bool isUsed;

  /// Whether the line is requested / owned by _this_ application.
  final bool isRequested;

  bool get isFree => !isUsed;

  /// The direction of the line.
  final LineDirection direction;

  /// The output mode of the line.
  final OutputMode? outputMode;

  /// The bias of the line.
  final Bias? bias;

  /// The active state of the GPIO line.
  ///
  /// Defines the mapping of active/inactive to low/high voltage.
  /// [ActiveState.low] is the counter-intuitive one,
  /// which maps active (i.e. `line.setValue(true)`) to low voltage and inactive to high voltage.
  final ActiveState activeState;

  const LineInfo({
    this.name,
    this.consumer,
    required this.direction,
    this.outputMode,
    this.bias,
    required this.activeState,
    required this.isUsed,
    required this.isRequested,
  });

  String toString() {
    final params = <String>[];

    if (name != null) {
      params.add("name: '$name'");
    }

    if (consumer != null) {
      params.add("consumer: '$consumer'");
    }

    if (direction == LineDirection.input) {
      params.add("direction:  input");
    } else {
      params.add("direction: output");

      if (outputMode == OutputMode.openDrain) {
        params.add("outputMode:  openDrain");
      } else if (outputMode == OutputMode.openSource) {
        params.add("outputMode: openSource");
      }
    }

    if (bias == Bias.disable) {
      params.add("bias:  disable");
    } else if (bias == Bias.pullDown) {
      params.add("bias: pullDown");
    } else if (bias == Bias.pullUp) {
      params.add("bias:   pullUp");
    }

    if (activeState == ActiveState.low) {
      params.add("activeState: low");
    }

    params.add("isUsed: $isUsed");
    params.add("isRequested: $isRequested");
    params.add("isFree: $isFree");

    return "LineInfo(${params.join(", ")})";
  }
}

/// Provides access to a single GPIO line / pin.
///
/// Basically has 5 states that define the methods you can call:
/// - unrequested & unused: [requestInput], [requestOutput]
/// - unrequested & used: none
/// - requested input without triggers: [getValue], [release], [reconfigureInput], [reconfigureOutput] (if supported)
/// - requested input with triggers:  [getValue], [release], [reconfigureInput], [reconfigureOutput] (if supported)
/// - requested output: [setValue], [getValue], [release], [reconfigureInput], [reconfigureOutput] (if supported)
///
/// The [info] can be retrieved in all states.
///
/// Example usage of [GpioLine]:
/// ```dart
/// import 'package:flutter_gpiod/flutter_gpiod.dart';
///
/// // find the chip with label 'pinctrl-bcm2835'
/// // (the main Raspberry Pi IO chip)
/// final chip = FlutterGpiod.instance.chips.singleWhere(
///   (chip) => chip.label == 'pinctrl-bcm2835'
/// );
///
/// // get line 22 of that chip
/// final line = chip.lines[22];
///
/// print("pinctrl-bcm2835, line 22: $(line.info)");
///
/// // request is as output and initialize it with false
/// await line.requestOutput(
///   consumer: "flutter_gpiod output test",
///   initialValue: false
/// );
///
/// // set the line active
/// line.setValue(true);
///
/// await Future.delayed(Duration(milliseconds: 500));
///
/// // set the line inactive again
/// line.setValue(false);
///
/// line.release();
///
/// // request the line as input, and listen for both edges
/// // we don't use `line.reconfigure` because that doesn't
/// // allow us to specify triggers.
/// line.requestInput(
///   consumer: "flutter_gpiod input test",
///   triggers: const {SignalEdge.rising, SignalEdge.falling}
/// ));
///
/// // print line events for eternity
/// await for (final event in line.onEvent) {
///   print("gpio line signal event: $event");
/// }
///
/// // line.release();
/// ```
class GpioLine {
  GpioLine._internal(
    this._lineHandle,
    this._requested,
    this._info,
    this._triggers,
    this._value,
  );

  final int _lineHandle;
  bool _requested;
  LineInfo? _info;
  Set<SignalEdge> _triggers;
  bool? _value;

  factory GpioLine._fromHandle(int lineHandle) {
    final info = PlatformInterface.instance.getLineInfo(lineHandle);

    if (info.isRequested) {
      return GpioLine._internal(lineHandle, true, info, const {}, PlatformInterface.instance.getLineValue(lineHandle));
    } else {
      return GpioLine._internal(lineHandle, false, null, const {}, null);
    }
  }

  /// Returns the line info for this line.
  LineInfo get info {
    if (_info != null) {
      return _info!;
    }

    return PlatformInterface.instance.getLineInfo(_lineHandle);
  }

  /// Whether this line is requested (owned by you) right now.
  ///
  /// `requested == true` means that you own the line,
  /// and can do things with it.
  ///
  /// If `requested == false` then you can't do more
  /// than retrieve the line info using the [info] property.
  bool get requested => _requested;

  /// The signal edges that this line is listening on right now,
  /// or equivalently, the signal edges that will trigger a [SignalEvent]
  /// that can be retrieved by listening on [GpioLine.onEvent].
  ///
  /// The triggers can be specified when requesting the line with [requestInput], but
  /// can __not__ be changed using [reconfigureInput] when the line is already requested.
  ///
  /// You can, of course, release the line and re-request it with
  /// different triggers if you need to, though.
  Set<SignalEdge> get triggers => Set.of(_triggers);

  void _checkSupportsBiasValue(Bias? bias) {
    if ((bias != null) && !FlutterGpiod.instance.supportsBias) {
      throw UnsupportedError("Line bias is not supported on this platform."
          "Expected `bias` to be null.");
    }
  }

  /// Requests ownership of a GPIO line with the given configuration.
  ///
  /// If [FlutterGpiod.supportsBias] is false, [bias] must be `null`,
  /// otherwise a [UnsupportedError] will be thrown.
  ///
  /// Only a free line can be requested.
  void requestInput({
    required String consumer,
    Bias? bias,
    ActiveState activeState = ActiveState.high,
    Set<SignalEdge> triggers = const {},
  }) {
    ArgumentError.checkNotNull(activeState, "activeState");
    ArgumentError.checkNotNull(triggers, "triggers");
    _checkSupportsBiasValue(bias);

    // we need to lock both info and ownership.
    if (_requested) {
      throw StateError("Can't request line because it is already requested.");
    }

    PlatformInterface.instance.requestLine(
      lineHandle: _lineHandle,
      consumer: consumer,
      direction: LineDirection.input,
      bias: bias,
      activeState: activeState,
      triggers: triggers,
    );

    _info = PlatformInterface.instance.getLineInfo(_lineHandle);

    _requested = true;
  }

  /// Requests ownership of a GPIO line with the given configuration.
  ///
  /// If [FlutterGpiod.supportsBias] is false, [bias] must be `null`,
  /// otherwise a [UnsupportedError] will be thrown.
  ///
  /// Only a free line can be requested.
  void requestOutput({
    required String consumer,
    OutputMode outputMode = OutputMode.pushPull,
    Bias? bias,
    ActiveState activeState = ActiveState.high,
    required bool initialValue,
  }) {
    ArgumentError.checkNotNull(outputMode, "outputMode");
    ArgumentError.checkNotNull(activeState, "activeState");
    ArgumentError.checkNotNull(initialValue, "initialValue");
    _checkSupportsBiasValue(bias);

    if (_requested) {
      throw StateError("Can't request line because it is already requested.");
    }

    PlatformInterface.instance.requestLine(
      lineHandle: _lineHandle,
      consumer: consumer,
      direction: LineDirection.output,
      outputMode: outputMode,
      bias: bias,
      activeState: activeState,
      initialValue: initialValue,
    );

    _info = PlatformInterface.instance.getLineInfo(_lineHandle);
    _value = initialValue;
    _requested = true;
  }

  void _checkSupportsLineReconfiguration() {
    if (!FlutterGpiod.instance.supportsLineReconfiguration) {
      throw UnsupportedError("Can't reconfigure line because that's not supported by "
          "the underlying version of libgpiod. "
          "You need to check `FlutterGpiod.supportsLineReconfiguration` "
          "to make sure you can reconfigure.");
    }
  }

  /// Reconfigures the line as input with the given configuration.
  ///
  /// If [FlutterGpiod.supportsBias] is false, [bias] must be `null`,
  /// otherwise a [UnsupportedError] will be thrown.
  ///
  /// This will throw a [UnsupportedError] if
  /// [FlutterGpiod.supportsLineReconfiguration] is false.
  ///
  /// You can't specify triggers here because of platform
  /// limitations.
  void reconfigureInput({Bias? bias, ActiveState activeState = ActiveState.high}) {
    ArgumentError.checkNotNull(activeState, "activeState");
    _checkSupportsBiasValue(bias);
    _checkSupportsLineReconfiguration();

    // we only change the info, not the ownership
    _info = null;
    _value = null;

    if (!_requested) {
      throw StateError("Can't reconfigured line because it is not requested.");
    }

    PlatformInterface.instance.reconfigureLine(
      lineHandle: _lineHandle,
      direction: LineDirection.input,
      bias: bias,
      activeState: activeState,
    );

    _info = PlatformInterface.instance.getLineInfo(_lineHandle);
  }

  /// Reconfigures the line as output with the given configuration.
  ///
  /// If [FlutterGpiod.supportsBias] is false, [bias] must be `null`,
  /// otherwise a [UnsupportedError] will be thrown.
  ///
  /// This will throw a [UnsupportedError] if
  /// [FlutterGpiod.supportsLineReconfiguration] is false.
  void reconfigureOutput({
    OutputMode outputMode = OutputMode.pushPull,
    Bias? bias,
    ActiveState activeState = ActiveState.high,
    required bool initialValue,
  }) {
    ArgumentError.checkNotNull(outputMode, "outputMode");
    _checkSupportsBiasValue(bias);
    ArgumentError.checkNotNull(activeState, "activeState");
    ArgumentError.checkNotNull(initialValue, "initialValue");
    _checkSupportsLineReconfiguration();

    _info = null;
    _value = null;

    if (!_requested) {
      throw StateError("Can't reconfigured line because it is not requested.");
    }

    PlatformInterface.instance.reconfigureLine(
      lineHandle: _lineHandle,
      direction: LineDirection.output,
      outputMode: outputMode,
      bias: bias,
      activeState: activeState,
      initialValue: initialValue,
    );

    _value = initialValue;
    _info = PlatformInterface.instance.getLineInfo(_lineHandle);
  }

  /// Releases the line, so you don't own it anymore.
  void release() {
    if (!_requested) {
      throw StateError("Can't release line because it is not requested.");
    }

    PlatformInterface.instance.releaseLine(_lineHandle);

    _requested = false;
    _info = null;
    _triggers = const {};
    _value = null;
  }

  /// Sets the value of the line to active (true) or inactive (false).
  ///
  /// Throws a [StateError] if the line is not requested as output.
  void setValue(bool value) {
    ArgumentError.checkNotNull(value, "value");

    if (_requested == false) {
      throw StateError("Can't set line value because line is not requested and configured as output.");
    }

    if (_info!.direction != LineDirection.output) {
      throw StateError("Can't set line value because line is not configured as output.");
    }

    if (_value == value) return;

    PlatformInterface.instance.setLineValue(_lineHandle, value);

    _value = value;
  }

  /// Reads the value of the line (active / inactive)
  ///
  /// Throws a [StateError] if the line is not requested.
  ///
  /// If the line is in output mode, the last written value
  /// using [setValue] will be returned.
  /// If [setValue] was never called, the `initialValue`
  /// given to [request] or [release] will be returned.
  ///
  /// If `direction == LineDirection.input` this will obtain a
  /// fresh value from the platform side.
  bool getValue() {
    if (_requested == false) {
      throw StateError("Can't get line value because line is not requested.");
    }

    if (_info!.direction == LineDirection.input) {
      return PlatformInterface.instance.getLineValue(_lineHandle);
    } else {
      return _value!;
    }
  }

  /// Gets a broadcast stream of [SignalEvent]s for this line.
  ///
  /// Note that platforms can and do emit events with same
  /// [SignalEvent.edge] in sequence, with no event
  /// with different edge between.
  ///
  /// So, it often happens that platforms emit events
  /// like this: `rising`, `rising`, `rising`, `falling`, `rising`,
  /// even though that doesn't seem to make any sense
  /// at first glance.
  Stream<SignalEvent> get onEvent => FlutterGpiod.instance._onSignalEvent(_lineHandle);

  /// Broadcast stream of signal edges.
  ///
  /// Basically the [onEvent] stream without the timestamp.
  Stream<SignalEdge> get onEdge => onEvent.map((e) => e.edge);

  String toString() {
    return "GpioLine(info: $info)";
  }
}
