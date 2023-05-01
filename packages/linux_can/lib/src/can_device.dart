import 'dart:async';
import 'dart:ffi' as ffi;

import 'package:_ardera_common_libc_bindings/_ardera_common_libc_bindings.dart';
import 'package:_ardera_common_libc_bindings/epoll_event_loop.dart';
import 'package:ffi/ffi.dart' as ffi;
import 'package:linux_can/src/data_classes.dart';
import 'package:linux_can/src/platform_interface.dart';

/// CAN device
class CanDevice {
  CanDevice({
    required PlatformInterface platformInterface,
    required RtnetlinkSocket netlinkSocket,
    required this.networkInterface,
  })  : _platformInterface = platformInterface,
        _netlinkSocket = netlinkSocket;

  final PlatformInterface _platformInterface;
  final RtnetlinkSocket _netlinkSocket;
  final NetworkInterface networkInterface;

  void _setCanInterfaceAttributes({
    bool? setUpDown,
    CanBitTiming? bitTiming,
    Map<CanModeFlag, bool>? ctrlModeFlags,
    int? restartMs,
    bool restart = false,
    CanBitTiming? dataBitTiming,
    int? termination,
  }) {
    return _netlinkSocket.setCanInterfaceAttributes(
      networkInterface.index,
      setUpDown: setUpDown,
      bitTiming: bitTiming,
      ctrlModeFlags: ctrlModeFlags,
      restartMs: restartMs,
      restart: restart,
      dataBitTiming: dataBitTiming,
      termination: termination,
    );
  }

  /// TODO: Implement
  bool get isUp {
    /// TODO: Maybe cache these values?
    ///  They could change without our knowledge at any time though.
    throw UnimplementedError();
  }

  set isUp(bool value) {
    _setCanInterfaceAttributes(setUpDown: true);
  }

  /// TODO: Implement
  CanBitTiming get bitTiming {
    throw UnimplementedError();
  }

  set bitTiming(CanBitTiming timing) {
    /// TODO: Should we allow a way to force set these,
    ///  without checking isUp?
    assert(!isUp);

    // TODO: Check value is accepted beforehand
    _setCanInterfaceAttributes(bitTiming: bitTiming);
  }

  set bitrate(int bitrate) {
    // TODO: Check value is accepted beforehand
    _setCanInterfaceAttributes(
      bitTiming: CanBitTiming.bitrateOnly(bitrate: bitrate),
    );
  }

  /// CAN hardware-dependent bit-timing constants
  ///
  /// Used for calculating and checking bit-timing parameters
  ///
  /// TODO: Implement
  CanBitTimingLimits get bitTimingConstants {
    // ref: https://elixir.bootlin.com/linux/latest/source/drivers/net/can/dev/netlink.c#L555
    throw UnimplementedError();
  }

  String get hardwareName => bitTimingConstants.hardwareName;

  /// CAN system clock frequency in Hz
  /// TODO: Implement
  int get clockFrequency {
    // ref: https://elixir.bootlin.com/linux/latest/source/drivers/net/can/dev/netlink.c#L558
    throw UnimplementedError();
  }

  /// CAN bus state
  /// TODO: Implement
  CanState get state {
    throw UnimplementedError();
  }

  /// TODO: Implement
  Map<CanModeFlag, bool> get controllerMode {
    throw UnimplementedError();
  }

  /// TODO: Implement
  set controllerMode(Map<CanModeFlag, bool> flags) {
    _setCanInterfaceAttributes(ctrlModeFlags: flags);
  }

  /// TODO: Implement
  int get restartDelayMillis {
    throw UnimplementedError();
  }

  /// TODO: Implement
  set restartDelayMillis(int millis) {
    _setCanInterfaceAttributes(restartMs: millis);
  }

  /// TODO: Implement
  void restart() {
    _setCanInterfaceAttributes(restart: true);
  }

  /// TODO: Implement
  CanBusErrorCounters get busErrorCounters {
    throw UnimplementedError();
  }

  /// TODO: Implement
  CanBitTiming get dataBitTiming {
    throw UnimplementedError();
  }

  /// TODO: Implement
  set dataBitTiming(CanBitTiming timing) {
    assert(!isUp);

    // ref: https://elixir.bootlin.com/linux/latest/source/drivers/net/can/dev/netlink.c#L303

    _setCanInterfaceAttributes(dataBitTiming: timing);
  }

  /// TODO: Implement
  CanBitTimingLimits get dataBitTimingConstants {
    throw UnimplementedError();
  }

  /// TODO: Implement
  int get termination {
    throw UnimplementedError();
  }

  /// TODO: Implement
  set termination(int termination) {
    // not all values accepted
    // TODO: Check value is accepted beforehand
    // ref: https://elixir.bootlin.com/linux/latest/source/drivers/net/can/dev/netlink.c#L365

    _setCanInterfaceAttributes(termination: termination);
  }

  /// TODO: Implement
  int get terminationConst {
    throw UnimplementedError();
  }

  /// TODO: Implement
  int get bitrateConst {
    throw UnimplementedError();
  }

  /// TODO: Implement
  int get dataBitRateConst {
    throw UnimplementedError();
  }

  /// TODO: Implement
  int get bitRateMax {
    throw UnimplementedError();
  }

  // TODO: Implement TDC info
  // ref:
  //   https://elixir.bootlin.com/linux/latest/source/drivers/net/can/dev/netlink.c#L467

  // TODO: Implement supported controller modes
  // ref:
  //   https://elixir.bootlin.com/linux/latest/source/drivers/net/can/dev/netlink.c#L520

  // TODO: Implement device statistics
  // ref:
  //   https://elixir.bootlin.com/linux/latest/source/drivers/net/can/dev/netlink.c#L614

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

  void write(CanFrame frame) {
    assert(_open);
    _platformInterface.write(_fd, frame);
  }

  CanFrame? read() {
    assert(_open);
    return _platformInterface.read(_fd);
  }

  Future<void> close() async {
    if (_listening) {
      await _fdUnlisten();
    }

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

  Stream<CanFrame>? _frames;
  Stream<CanFrame> get frames {
    assert(_open);

    if (_frames == null) {
      late StreamController<CanFrame> controller;

      controller = StreamController.broadcast(
        onListen: () {
          _fdListen(
            (frames) => frames?.forEach(controller.add),
            controller.addError,
          );
        },
        onCancel: () {
          _fdUnlisten();
        },
      );

      _frames = controller.stream;
    }

    return _frames!;
  }
}
