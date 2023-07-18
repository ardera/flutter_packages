import 'dart:async';
import 'dart:ffi' as ffi;

import 'package:_ardera_common_libc_bindings/_ardera_common_libc_bindings.dart';
import 'package:_ardera_common_libc_bindings/epoll_event_loop.dart';
import 'package:_ardera_common_libc_bindings/linux_error.dart';
import 'package:ffi/ffi.dart' as ffi;
import 'package:linux_can/src/data_classes.dart';
import 'package:linux_can/src/platform_interface.dart';

/// CAN device
class CanDevice {
  CanDevice({
    required PlatformInterface platformInterface,
    required this.networkInterface,
  }) : _platformInterface = platformInterface;

  final PlatformInterface _platformInterface;
  final NetworkInterface networkInterface;

  CanInterfaceAttributes _queryAttributes({Set<CanInterfaceAttribute>? interests}) {
    return _platformInterface.queryAttributes(networkInterface.index, interests: interests);
  }

  CanInterfaceAttributes _queryAttribute(CanInterfaceAttribute attribute) {
    return _queryAttributes(interests: {attribute});
  }

  CanInterfaceAttributes queryAttributes() {
    return _queryAttributes();
  }

  Set<NetInterfaceFlag> get interfaceFlags {
    return _queryAttribute(CanInterfaceAttribute.interfaceFlags).interfaceFlags!;
  }

  int get txQueueLength {
    return _queryAttribute(CanInterfaceAttribute.txQueueLength).txQueueLength!;
  }

  NetInterfaceOperState get operationalState {
    /// TODO: Maybe cache these values?
    ///  They could change without our knowledge at any time though.
    return _queryAttribute(CanInterfaceAttribute.operState).operState!;
  }

  bool get isUp => operationalState == NetInterfaceOperState.up;

  NetInterfaceStats get stats {
    return _queryAttribute(CanInterfaceAttribute.stats).stats!;
  }

  int get numTxQueues {
    return _queryAttribute(CanInterfaceAttribute.numTxQueues).numTxQueues!;
  }

  int get numRxQueues {
    return _queryAttribute(CanInterfaceAttribute.numRxQueues).numRxQueues!;
  }

  CanDeviceStats get xstats {
    return _queryAttribute(CanInterfaceAttribute.xstats).xstats!;
  }

  CanBitTiming? get bitTiming {
    return _queryAttribute(CanInterfaceAttribute.bitTiming).bitTiming;
  }

  /// CAN hardware-dependent bit-timing constants
  ///
  /// Used for calculating and checking bit-timing parameters
  CanBitTimingLimits get bitTimingLimits {
    // ref: https://elixir.bootlin.com/linux/latest/source/drivers/net/can/dev/netlink.c#L555
    return _queryAttribute(CanInterfaceAttribute.bitTimingLimits).bitTimingLimits!;
  }

  String get hardwareName => bitTimingLimits.hardwareName;

  /// CAN system clock frequency in Hz
  int get clockFrequency {
    // ref: https://elixir.bootlin.com/linux/latest/source/drivers/net/can/dev/netlink.c#L558
    return _queryAttribute(CanInterfaceAttribute.clockFrequency).clockFrequency!;
  }

  /// CAN bus state
  CanState get state {
    return _queryAttribute(CanInterfaceAttribute.state).state!;
  }

  Set<CanModeFlag> get controllerMode {
    return _queryAttribute(CanInterfaceAttribute.controllerMode).controllerMode!;
  }

  Duration get restartDelay {
    return _queryAttribute(CanInterfaceAttribute.restartDelay).restartDelay!;
  }

  CanBusErrorCounters? get busErrorCounters {
    return _queryAttribute(CanInterfaceAttribute.busErrorCounters).busErrorCounters;
  }

  CanBitTiming? get dataBitTiming {
    return _queryAttribute(CanInterfaceAttribute.dataBitTiming).dataBitTiming;
  }

  CanBitTimingLimits? get dataBitTimingLimits {
    return _queryAttribute(CanInterfaceAttribute.dataBitTimingLimits).dataBitTimingLimits;
  }

  int? get termination {
    return _queryAttribute(CanInterfaceAttribute.termination).termination;
  }

  int? get fixedTermination {
    return _queryAttribute(CanInterfaceAttribute.fixedTermination).fixedTermination;
  }

  int? get fixedBitrate {
    return _queryAttribute(CanInterfaceAttribute.fixedBitrate).fixedBitrate;
  }

  int? get fixedDataBitRate {
    return _queryAttribute(CanInterfaceAttribute.fixedDataBitrate).fixedDataBitrate;
  }

  int? get maxBitrate {
    return _queryAttribute(CanInterfaceAttribute.maxBitrate).maxBitrate;
  }

  // TODO: Implement TDC info
  // ref:
  //   https://elixir.bootlin.com/linux/latest/source/drivers/net/can/dev/netlink.c#L467

  Set<CanModeFlag>? get supportedControllerModes {
    return _queryAttribute(CanInterfaceAttribute.supportedControllerModes).supportedControllerModes;
  }

  CanSocket open() {
    final fd = _platformInterface.createCanSocket();
    try {
      _platformInterface.bind(fd, networkInterface.index);

      return CanSocket(
        platformInterface: _platformInterface,
        fd: fd,
        networkInterface: networkInterface,
      );
    } on Object {
      _platformInterface.close(fd);
      rethrow;
    }
  }
}

class CanSocket {
  CanSocket({
    required PlatformInterface platformInterface,
    required int fd,
    required this.networkInterface,
  })  : _fd = fd,
        _platformInterface = platformInterface;

  final PlatformInterface _platformInterface;
  final int _fd;
  final NetworkInterface networkInterface;
  var _open = true;

  var _listening = false;
  FdHandler? _fdListener;
  ffi.Pointer<can_frame>? _fdHandlerBuffer;

  /// Returns the current send buffer size of this socket.
  ///
  /// Every CAN frame sent with this socket will first go into the send buffer, before it's actually sent.
  ///
  /// It's actually surprisingly hard to determine exactly how many CAN frames fit into the send buffer.
  /// There's some overhead by the SocketCAN implementation, some overhead of the Linux Socket implementation in general,
  /// some overhead by alignments, paddings, and it also seems like the kernel will allocate a single page for every
  /// frame.
  int get sendBufSize => _platformInterface.getSendBufSize(_fd);

  /// Sets the send buffer size of this socket.
  ///
  /// The larger the send buffer, the more more CAN frames can be sent in a short time-period.
  ///
  /// There's limits on the socket send buffer size, it must satisfy:
  /// 1024 <= value <= /proc/sys/net/core/wmem_max.
  ///
  /// The default value is given inside /proc/sys/net/core/wmem_default.
  set sendBufSize(int value) => _platformInterface.setSendBufSize(_fd, value);

  /// Sends the standard CAN frame [frame] using this socket.
  ///
  /// If [block] is true, the send is re-attempted even though the send buffer is full, until it succeeds. This can
  /// happen when sending lots of frames in a short time period. If [block] is false, this will throw a [LinuxError]
  /// with errno [EWOULDBLOCK] (value 22) in this case.
  void write(CanFrame frame, {bool block = true}) {
    assert(_open);

    _platformInterface.write(_fd, frame, block: block);
  }

  CanFrame? read() {
    assert(_open);
    return _platformInterface.read(_fd);
  }

  Future<void> close() async {
    if (_listening) {
      await _fdUnlisten();
    }

    await _controller.close();

    assert(_open);
    _platformInterface.close(_fd);
    _open = false;
  }

  static List<CanFrame>? _handleFdReady(EpollIsolate isolate, int fd, Set<EpollFlag> flags, dynamic bufferAddr) {
    assert(bufferAddr is int);

    final libc = isolate.libc;

    final buffer = ffi.Pointer<ffi.Void>.fromAddress(bufferAddr);

    final frames = <CanFrame>[];
    while (true) {
      final frame = PlatformInterface.readStatic(libc, fd, buffer, ffi.sizeOf<can_frame>());
      if (frame != null) {
        frames.add(frame);
      } else {
        break;
      }
    }

    return frames.isEmpty ? null : frames;
  }

  Future<void> _fdListen(
    void Function(List<CanFrame>?) onFrame,
    void Function(Object error, StackTrace? stackTrace) onError,
  ) async {
    assert(_open);
    assert(!_listening);
    assert(_fdListener == null);
    assert(_fdHandlerBuffer == null);

    _fdHandlerBuffer = ffi.calloc<can_frame>();

    _fdListener = await _platformInterface.eventListener.add(
      fd: _fd,
      events: {EpollFlag.inReady},
      isolateCallback: _handleFdReady,
      isolateCallbackContext: _fdHandlerBuffer!.address,
      onValue: (value) {
        assert(value is List<CanFrame>?);
        onFrame(value);
      },
      onError: onError,
    );

    _listening = true;
  }

  Future<void> _fdUnlisten() async {
    assert(_open);
    assert(_listening);
    assert(_fdListener != null);
    assert(_fdHandlerBuffer != null);

    await _platformInterface.eventListener.delete(
      listener: _fdListener!,
    );

    ffi.calloc.free(_fdHandlerBuffer!);

    _fdHandlerBuffer = null;
    _fdListener = null;
    _listening = false;
  }

  late final StreamController<CanFrame> _controller = StreamController.broadcast(
    onListen: () {
      _fdListen(
        (frames) => frames?.forEach(_controller.add),
        _controller.addError,
      );
    },
    onCancel: () {
      _fdUnlisten();
    },
  );

  Stream<CanFrame> get frames => _controller.stream;
}
