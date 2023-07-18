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

  /// Query all attributes for this CAN interface.
  ///
  /// This is how the individual attribute getters of this class are implemented internally.
  /// This operation can take some time (~2ms on a Pi 4), so be careful to not invoke it too often.
  ///
  /// The values are always fetched directly from the kernel and are not cached internally.
  CanInterfaceAttributes queryAttributes() {
    return _queryAttributes();
  }

  /// The Set of active network interface flags for this CAN interface.
  ///
  /// Basically describe the state of this CAN device.
  ///
  /// See [NetInterfaceFlag] for more info.
  Set<NetInterfaceFlag> get interfaceFlags {
    return _queryAttribute(CanInterfaceAttribute.interfaceFlags).interfaceFlags!;
  }

  /// The length of the transmission queue of this CAN interface in packets (CAN frames).
  int get txQueueLength {
    return _queryAttribute(CanInterfaceAttribute.txQueueLength).txQueueLength!;
  }

  /// The operational state of this network interface (up, down, error, etc).
  ///
  /// Some values can only be read when the [operationalState] is [NetInterfaceOperState.up].
  NetInterfaceOperState get operationalState {
    /// TODO: Maybe cache these values?
    ///  They could change without our knowledge at any time though.
    return _queryAttribute(CanInterfaceAttribute.operState).operState!;
  }

  /// True if the network interface is up, i.e. [operationalState] is [NetInterfaceOperState.up].
  bool get isUp => operationalState == NetInterfaceOperState.up;

  /// Some general statistics for this network interface.
  ///
  /// Not yet implemented.
  NetInterfaceStats get stats {
    return _queryAttribute(CanInterfaceAttribute.stats).stats!;
  }

  /// The number of transmission queues for this CAN interface.
  ///
  /// Typically this is 1.
  int get numTxQueues {
    return _queryAttribute(CanInterfaceAttribute.numTxQueues).numTxQueues!;
  }

  /// The number of receive queues for this CAN interface.
  ///
  /// Typically this is 1.
  int get numRxQueues {
    return _queryAttribute(CanInterfaceAttribute.numRxQueues).numRxQueues!;
  }

  /// CAN device statistics for this device.
  CanDeviceStats get xstats {
    return _queryAttribute(CanInterfaceAttribute.xstats).xstats!;
  }

  /// CAN bit timings in use by this device for for sending and receiving data on the bus.
  ///
  /// Only non-null when the device is up and running, i.e.
  /// [isUp] is true.
  CanBitTiming? get bitTiming {
    return _queryAttribute(CanInterfaceAttribute.bitTiming).bitTiming;
  }

  /// CAN hardware-dependent bit-timing constants.
  ///
  /// Used for calculating and checking bit-timing parameters.
  CanBitTimingLimits get bitTimingLimits {
    // ref: https://elixir.bootlin.com/linux/latest/source/drivers/net/can/dev/netlink.c#L555
    return _queryAttribute(CanInterfaceAttribute.bitTimingLimits).bitTimingLimits!;
  }

  /// Name of the CAN controller hardware.
  String get hardwareName => bitTimingLimits.hardwareName;

  /// CAN system clock frequency in Hz.
  int get clockFrequency {
    // ref: https://elixir.bootlin.com/linux/latest/source/drivers/net/can/dev/netlink.c#L558
    return _queryAttribute(CanInterfaceAttribute.clockFrequency).clockFrequency!;
  }

  /// State of CAN device.
  ///
  /// Depends on the number of receive/transmit errors.
  ///
  /// If too many errors happen, the device will switch off. (But
  /// maybe restart automatically if [restartDelay] is not zero)
  CanState get state {
    return _queryAttribute(CanInterfaceAttribute.state).state!;
  }

  /// Enabled CAN controller modes.
  ///
  /// Every [CanModeFlag] present in the returned set is active.
  /// All flags not present are inactive (and might be unsupported.)
  Set<CanModeFlag> get controllerMode {
    return _queryAttribute(CanInterfaceAttribute.controllerMode).controllerMode!;
  }

  /// Duration that the CAN device should wait after [CanState.busOff] was reached
  /// before restarting the controller automatically.
  ///
  /// Returns [Duration.zero] if the controller won't restart automatically.
  Duration get restartDelay {
    return _queryAttribute(CanInterfaceAttribute.restartDelay).restartDelay!;
  }

  /// Returns the count of transmit and receive errors for this CAN device.
  ///
  /// Null if the controller doesn't support this query.
  CanBusErrorCounters? get busErrorCounters {
    return _queryAttribute(CanInterfaceAttribute.busErrorCounters).busErrorCounters;
  }

  /// Bittiming used for the CAN frame data.
  ///
  /// Only applies to CAN FD (Flexible Datarate).
  ///
  /// Null if interface is not up & running (see [isUp]), CAN FD is not supported by
  /// the controller, or the controller doesn't support this query.
  CanBitTiming? get dataBitTiming {
    return _queryAttribute(CanInterfaceAttribute.dataBitTiming).dataBitTiming;
  }

  /// Hardware-dependent constraints for the data bittiming.
  ///
  /// Only applies to CAN FD (Flexible Datarate).
  ///
  /// Null if the controller doesn't support this query or CAN FD.
  CanBitTimingLimits? get dataBitTimingLimits {
    return _queryAttribute(CanInterfaceAttribute.dataBitTimingLimits).dataBitTimingLimits;
  }

  /// CAN Bus termination resistance applied by the controller in Ohms.
  ///
  /// 0: The CAN device will not terminate the bus. (Default)
  /// 1..65535: The CAN device will terminate the bus with a resistance of 1..65535 Ohms.
  ///
  /// Null if the controller doesn't support this query or can't act as a bus termination.
  int? get termination {
    return _queryAttribute(CanInterfaceAttribute.termination).termination;
  }

  /// List of supported CAN Bus terminations resistances that can be applied by the controller (in Ohms).
  ///
  /// Null if the controller doesn't support this query  or can't act as a bus termination.
  List<int>? get supportedTerminations {
    return _queryAttribute(CanInterfaceAttribute.supportedTerminations).supportedTerminations;
  }

  /// List of bitrates supported by the controller.
  ///
  /// Null if the controller doesn't support this query.
  List<int>? get supportedBitrates {
    return _queryAttribute(CanInterfaceAttribute.supportedBitrates).supportedBitrates;
  }

  /// List of data bitrates supported by the controller.
  ///
  /// Only applies to CAN FD (Flexible Datarate).
  ///
  /// Null if the controller doesn't support this query.
  List<int>? get supportedDataBitrates {
    return _queryAttribute(CanInterfaceAttribute.supportedDataBitrates).supportedDataBitrates;
  }

  /// Maximum bitrate supported by the controller.
  ///
  /// Null if the controller doesn't support this query.
  int? get maxBitrate {
    return _queryAttribute(CanInterfaceAttribute.maxBitrate).maxBitrate;
  }

  // TODO: Implement TDC info
  // ref:
  //   https://elixir.bootlin.com/linux/latest/source/drivers/net/can/dev/netlink.c#L467

  /// The set of controller modes supported.
  ///
  /// Null if the controller doesn't support this query.
  Set<CanModeFlag>? get supportedControllerModes {
    return _queryAttribute(CanInterfaceAttribute.supportedControllerModes).supportedControllerModes;
  }

  /// Creates a new CanSocket for sending/receiving frames on this CAN device.
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

  void _checkOpen() {
    if (!_open) {
      throw StateError('CanSocket is closed');
    }
  }

  /// Returns the current send buffer size of this socket.
  ///
  /// Every CAN frame sent with this socket will first go into the send buffer, before it's actually sent, and then
  /// the kernel will send each frame in the send buffer as soon as possible.
  /// The larger the send buffer, the more more CAN frames can be sent in a short time-period.
  ///
  /// The default value used by the kernel is given inside /proc/sys/net/core/wmem_default.
  ///
  /// It's actually surprisingly hard to determine exactly how many CAN frames fit into the send buffer.
  /// There's some overhead by the SocketCAN implementation, some overhead of the Linux Socket implementation in general,
  /// some overhead by alignments, paddings, and it also seems like the kernel will allocate a single page for every
  /// frame.
  int get sendBufSize => _platformInterface.getSendBufSize(_fd);

  /// Sets the send buffer size of this socket.
  ///
  /// Normally, you don't need to change this.
  ///
  /// Every CAN frame sent with this socket will first go into the send buffer, before it's actually sent, and then
  /// the kernel will send each frame in the send buffer as soon as possible.
  /// The larger the send buffer, the more more CAN frames can be sent in a short time-period.
  ///
  /// There's limits on the socket send buffer size, it must satisfy:
  /// 1024 <= value <= /proc/sys/net/core/wmem_max.
  ///
  /// The default value is given inside /proc/sys/net/core/wmem_default.
  set sendBufSize(int value) => _platformInterface.setSendBufSize(_fd, value);

  /// Sends the base/extended CAN 2.0 frame [frame] using this socket.
  ///
  /// If [block] is true, and the kernel send-buffer is full, the send is re-attempted until it succeeds. This can
  /// happen when sending lots of frames in a short time period. If [block] is false, this will throw a [LinuxError]
  /// with errno [EWOULDBLOCK] (value 22) in this case.
  void write(CanFrame frame, {bool block = true}) {
    _checkOpen();

    _platformInterface.write(_fd, frame, block: block);
  }

  /// Tries to receive a base/extended CAN 2.0 [CanFrame] using this socket.
  ///
  /// This method will not wait for a frame to arrive. If no frame is available right now,
  /// null is returned.
  ///
  /// The returned CanFrame might be a [CanDataFrame], [CanRemoteFrame] or [CanErrorFrame].
  CanFrame? read() {
    _checkOpen();
    return _platformInterface.read(_fd);
  }

  /// Closes this CanSocket and releases all associated resources.
  ///
  /// The socket should not be used anymore after this function has started.
  Future<void> close() async {
    _checkOpen();

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
    _checkOpen();

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
    _checkOpen();

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

  /// Gets a broadcast stream of CanFrames arriving on this socket.
  ///
  /// The stream is only valid while this socket is open, i.e. before
  /// [CanSocket.close] is called.
  Stream<CanFrame> get frames => _controller.stream;
}
