import 'dart:async';
import 'dart:ffi' as ffi;

import 'package:_ardera_common_libc_bindings/_ardera_common_libc_bindings.dart';
import 'package:_ardera_common_libc_bindings/epoll_event_loop.dart';
import 'package:_ardera_common_libc_bindings/linux_error.dart';
import 'package:ffi/ffi.dart' as ffi;
import 'package:linux_can/src/data_classes.dart';
import 'package:linux_can/src/platform_interface.dart';

A _fst<A, B>((A, B) pair) {
  return pair.$1;
}

B _snd<A, B>((A, B) pair) {
  return pair.$2;
}

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

      // Set no filter so we don't need to discard before receiving.
      _platformInterface.setFilter(fd, CanFilter.none);

      _platformInterface.setErrorReporting(fd, false);

      // Drain all frames in case a frame arrived between bind and setFilter.
      _platformInterface.drain(fd);

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

/// A CAN socket, a CAN device that's opened for reading and writing.
///
/// A CanSocket will not only receive frames incoming on the underlying CanDevice, but also frames outgoing on other
/// CanSockets of the same CanDevice. (This behaviour is dictated by the kernel SocketCAN implementation)
class CanSocket implements Sink<CanFrame> {
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
  Future<void> send(CanFrame frame, {bool block = true}) async {
    _checkOpen();

    // TODO: Do the blocking in the kernel or in a worker isolate
    //  and remove the block parameter.
    _platformInterface.write(_fd, frame, block: block);
  }

  /// Sends the base/extended CAN 2.0 frame [frame] using this socket.
  ///
  /// If [block] is true, and the kernel send-buffer is full, the send is re-attempted until it succeeds. This can
  /// happen when sending lots of frames in a short time period. If [block] is false, this will throw a [LinuxError]
  /// with errno [EWOULDBLOCK] (value 22) in this case.
  @override
  Future<void> add(CanFrame data, {bool block = true}) async {
    return send(data, block: block);
  }

  /// Receives a base/extended CAN 2.0 [CanFrame] using this socket.
  ///
  /// This method will wait for a frame to arrive. The returned future completes with
  /// an error if the socket is closed before a frame was received.
  ///
  /// The returned CanFrame might be a [CanDataFrame] or [CanRemoteFrame].
  Future<CanFrame> receiveSingle({bool emitErrors = false, CanFilter filter = CanFilter.anyData}) async {
    _checkOpen();
    return await receive(emitErrors: emitErrors, filter: filter).first;
  }

  /// Closes this [CanSocket] and releases all associated resources.
  ///
  /// The socket should not be used anymore after this function has started.
  @override
  Future<void> close() async {
    _checkOpen();

    if (_listening) {
      await _socketUnlisten();
    }

    await _socketController.close();

    assert(_open);
    _platformInterface.close(_fd);
    _open = false;
  }

  static List<CanFrameOrError>? _handleFdReady(EpollIsolate isolate, int fd, Set<EpollFlag> flags, dynamic bufferAddr) {
    assert(bufferAddr is int);

    final libc = isolate.libc;

    final buffer = ffi.Pointer<ffi.Void>.fromAddress(bufferAddr);

    final frames = <CanFrameOrError>[];
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

  /// Listen to the underlying CAN socket.
  ///
  /// Will add data and errors to the [_socketController].
  Future<void> _socketListen(
    void Function(List<CanFrameOrError>?) onFrame,
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
        assert(value is List<CanFrameOrError>?);
        onFrame(value);
      },
      onError: onError,
    );

    _listening = true;
  }

  /// Unlisten from the underlying CAN socket.
  ///
  /// Once the future completes, no more data and errors will be added to the [_socketController].
  Future<void> _socketUnlisten() async {
    _checkOpen();

    assert(_listening);
    assert(_fdListener != null);
    assert(_fdHandlerBuffer != null);

    final buffer = _fdHandlerBuffer;
    final listener = _fdListener;

    _fdHandlerBuffer = null;
    _fdListener = null;
    _listening = false;

    await _platformInterface.eventListener.delete(
      listener: listener!,
    );

    ffi.calloc.free(buffer!);
  }

  /// The current CAN filter configured in the kernel for this socket.
  ///
  /// The default filter by the kernel uses mask 0 and can_id 0,
  /// so it matches all frames.
  /// We apply CanFilter.none in CanDevice.open though, so use CanFilter.none here.
  var _socketFilter = CanFilter.none;

  /// True if the kernel currently emits error frames on this socket.
  ///
  /// We set the error mask to 0 in CanDevice.open, so it's false
  /// by default.
  var _socketReportingErrors = false;

  late final StreamController<CanFrame> _socketController = StreamController.broadcast(
    onListen: () {
      // we don't need to drain here since the filter was
      // set to CanFilter.none directly after opening.
      _socketListen(
        (frames) {
          frames?.forEach((frame) {
            frame.either(
              (errors) => errors.forEach(_socketController.addError),
              _socketController.add,
            );
          });
        },
        _socketController.addError,
      );
    },
    onCancel: () {
      if (_listening) {
        _socketUnlisten();
      }
    },
  );

  /// The CAN filters and 'emit errors' booleans for all streams listening to the socket right now.
  ///
  /// We use that to determine the "global" CAN filter and emit-errors boolean that should be applied to the whole
  /// socket.
  ///
  /// For example, right now, if a single stream is listening, we just use whatever CAN filter and emit-errors value
  /// that stream uses.
  ///
  /// If more streams are listening, we use CanFilter.any for the socket and manually filter in the stream, and use
  /// the logical or of the emit-errors value and filter the errors in the stream as well.
  var _socketFilters = <(CanFilter, bool)>[];

  void _applySocketFilters(Iterable<(CanFilter, bool)> filters) {
    late CanFilter filter;
    if (filters.isEmpty) {
      filter = CanFilter.none;
    } else if (filters.length == 1) {
      filter = filters.single.$1;
    } else {
      filter = CanFilter.or(filters.map(_fst));
    }

    final reportErrors = filters.map(_snd).fold(false, (value, element) {
      return value || element;
    });

    final oldFilter = _socketFilter;
    if (filter != _socketFilter) {
      _platformInterface.setFilter(_fd, filter);
      _socketFilter = filter;
    }

    try {
      if (reportErrors != _socketReportingErrors) {
        _platformInterface.setErrorReporting(_fd, reportErrors);
        _socketReportingErrors = reportErrors;
      }
    } on Object {
      if (oldFilter != _socketFilter) {
        _platformInterface.setFilter(_fd, oldFilter);
        _socketFilter = oldFilter;
      }

      rethrow;
    }

    _socketFilters = filters.toList();
  }

  void _addSocketFilter((CanFilter, bool) filter) {
    _applySocketFilters(_socketFilters.followedBy([filter]));
  }

  void _removeSocketFilter((CanFilter, bool) filter) {
    _applySocketFilters(
      _socketFilters.toList()..remove(filter),
    );
  }

  /// Gets a broadcast stream of [CanFrame]s arriving on this socket.
  ///
  /// The stream is only valid while this socket is open, i.e. before
  /// [CanSocket.close] is called.
  ///
  /// If [emitErrors] is true, all [CanError]s received from the kernel
  /// will be added as errors to the stream.
  /// If [emitErrors] is false, no errors will be emitted.
  ///
  /// If [filter] is given, only CAN frames that match the filter will be emitted on the stream.
  /// The filtering will be done in the kernel, if possible.
  Stream<CanFrame> receive({bool emitErrors = false, CanFilter filter = CanFilter.anyData}) {
    final controller = StreamController<CanFrame>.broadcast(sync: true);

    void addIfNotCanError(Object object, StackTrace? stackTrace) {
      if (object is CanError) {
        return;
      }

      controller.addError(object, stackTrace);
    }

    void addMaybeCheckFilterMatches(CanFrame frame) {
      if (_socketFilter != filter) {
        if (filter.matches(frame)) {
          controller.add(frame);
        }
      } else {
        controller.add(frame);
      }
    }

    StreamSubscription<CanFrame>? subscription;

    var filterEntry = (filter, emitErrors);

    // We apply the filter and emitErrors in onListen and onCancel.
    controller.onListen = () {
      try {
        _addSocketFilter(filterEntry);
      } on CanFilterNotRepresentableException {
        // If we can't apply the filter, because it violates some SocketCAN restrictions,
        // we apply no filter at all and do the filtering in dart.
        // Happens for example when having and AND filter inside on OR filter,
        // or when we have too many rules.
        filterEntry = (CanFilter.any, emitErrors);
        _addSocketFilter(filterEntry);
      }

      subscription = _socketController.stream.listen(
        addMaybeCheckFilterMatches,
        onError: emitErrors ? controller.addError : addIfNotCanError,
        onDone: controller.close,
      );
    };

    controller.onCancel = () async {
      await subscription!.cancel();
      subscription = null;

      // it's possible this is called after the socket is already closed.
      if (_open) {
        _removeSocketFilter(filterEntry);
      }
    };

    return controller.stream;
  }
}
