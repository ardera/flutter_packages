import 'dart:convert';
import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'package:_ardera_common_libc_bindings/_ardera_common_libc_bindings.dart';
import 'package:_ardera_common_libc_bindings/linux_error.dart';

class NetInterface {
  NetInterface({required this.index, required this.name});

  final int index;
  final String name;
}

/// Defines CAN bit-timing values.
///
/// For further reference, see: http://esd.cs.ucr.edu/webres/can20.pdf
class CanBitTiming {
  const CanBitTiming({
    required this.bitrate,
    required this.samplePoint,
    required this.tq,
    required this.propagationSegment,
    required this.phaseSegment1,
    required this.phaseSegment2,
    required this.syncJumpWidth,
    required this.bitratePrescaler,
  })  : assert(0 < bitrate),
        assert(0 <= samplePoint && samplePoint <= 1000),
        assert(0 < tq),
        assert(0 < propagationSegment),
        assert(0 < phaseSegment1),
        assert(0 < phaseSegment2),
        assert(0 < syncJumpWidth),
        assert(0 < bitratePrescaler);

  /// Bit-rate in bits/second, in absence of resynchronization,
  /// by an ideal transmitter.
  final int bitrate;

  /// Sample point in one-tenth of a percent.
  final int samplePoint;

  /// Time quanta (TQ) in nanoseconds.
  ///
  /// Other timings values in the struct are expressed as
  /// multiples of this value.
  final int tq;

  /// Propagation Segment in TQs.
  ///
  /// CAN 2.0 specification writes:
  ///   This part of the bit time is used to compensate for physical delay times
  ///   within the network.
  ///   It is twice the sum of the signal's propagation time on the bus line, the
  ///   input comparator delay, and the output driver delay.
  final int propagationSegment;

  /// Phase buffer segment 1 in TQs.
  ///
  /// CAN 2.0 specification writes:
  ///   These Phase-Buffer-Segments are used to compensate for edge phase errors.
  ///   These segments can be lengthened or shortened by resynchronization.
  final int phaseSegment1;

  /// Phase buffer segment 2 in TQs.
  ///
  /// CAN 2.0 specification writes:
  ///   These Phase-Buffer-Segments are used to compensate for edge phase errors.
  ///   These segments can be lengthened or shortened by resynchronization.
  final int phaseSegment2;

  /// Synchronisation jump width in TQs.
  final int syncJumpWidth;

  /// Bit-rate prescaler.
  final int bitratePrescaler;
}

enum CanModeFlag {
  loopback(CAN_CTRLMODE_LOOPBACK),
  listenOnly(CAN_CTRLMODE_LISTENONLY),
  tripleSample(CAN_CTRLMODE_3_SAMPLES),
  oneShot(CAN_CTRLMODE_ONE_SHOT),
  busErrorReporting(CAN_CTRLMODE_BERR_REPORTING),
  flexibleDatarate(CAN_CTRLMODE_FD),
  presumeAck(CAN_CTRLMODE_PRESUME_ACK),
  flexibleDatarateNonIso(CAN_CTRLMODE_FD_NON_ISO),
  classicCanDlc(CAN_CTRLMODE_CC_LEN8_DLC),
  tdcAuto(CAN_CTRLMODE_TDC_AUTO),
  tdcManual(CAN_CTRLMODE_TDC_MANUAL);

  const CanModeFlag(this.value);

  final int value;
}

class CanBitTimingConstants {
  const CanBitTimingConstants({
    required this.hardwareName,
    required this.timeSegment1Min,
    required this.timeSegment1Max,
    required this.timeSegment2Min,
    required this.timeSegment2Max,
    required this.synchronisationJumpWidth,
    required this.bitRatePrescalerMin,
    required this.bitRatePrescalerMax,
    required this.bitRatePrescalerIncrement,
  });

  final String hardwareName;
  final int timeSegment1Min;
  final int timeSegment1Max;
  final int timeSegment2Min;
  final int timeSegment2Max;
  final int synchronisationJumpWidth;
  final int bitRatePrescalerMin;
  final int bitRatePrescalerMax;
  final int bitRatePrescalerIncrement;
}

/// CAN operation and error states
///
/// ref:
///   https://elixir.bootlin.com/linux/latest/source/include/uapi/linux/can/netlink.h#L66
enum CanState {
  /// RX/TX error count < 96
  errorActive(0),

  /// RX/TX error count < 128
  errorWarning(1),

  /// RX/TX error count < 256
  errorPassive(2),

  /// RX/TX error count >= 256
  busOff(3),

  /// Device is stopped
  stopped(4),

  /// Device is sleeping
  sleeping(5);

  const CanState(this.value);

  final int value;
}

/// CAN bus error counters
///
/// ref:
///   https://elixir.bootlin.com/linux/latest/source/include/uapi/linux/can/netlink.h#L79
class CanBusErrorCounters {
  const CanBusErrorCounters({
    required this.txErrors,
    required this.rxErrors,
  })  : assert(txErrors >= 0),
        assert(rxErrors >= 0);

  final int txErrors;
  final int rxErrors;
}

/// CAN device statistics
class CanDeviceStats {
  const CanDeviceStats({
    required this.busError,
    required this.errorWarning,
    required this.errorPassive,
    required this.busOff,
    required this.arbitrationLost,
    required this.restarts,
  });

  /// Bus errors
  final int busError;

  /// Changes to error warning state
  final int errorWarning;

  /// Changes to error passive state
  final int errorPassive;

  /// Changes to bus off state
  final int busOff;

  /// Arbitration lost errors
  final int arbitrationLost;

  /// CAN controller re-starts
  final int restarts;
}

class CanDevice {
  CanDevice({
    required this.platformInterface,
    required this.netInterface,
  });

  final PlatformInterface platformInterface;
  final NetInterface netInterface;

  /// TODO: Implement
  bool get isUp {
    throw UnimplementedError();
  }

  /// TODO: Implement
  set isUp(bool value) {
    throw UnimplementedError();
  }

  /// TODO: Implement
  CanBitTiming get bitTiming {
    throw UnimplementedError();
  }

  /// TODO: Implement
  set bitTiming(CanBitTiming timing) {
    throw UnimplementedError();
  }

  /// TODO: Implement
  set bitrate(int bitrate) {
    throw UnimplementedError();
  }

  /// CAN hardware-dependent bit-timing constants
  ///
  /// Used for calculating and checking bit-timing parameters
  ///
  /// TODO: Implement
  CanBitTimingConstants get bitTimingConstants {
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
  Set<CanModeFlag> get controllerMode {
    throw UnimplementedError();
  }

  /// TODO: Implement
  set controllerMode(Set<CanModeFlag> flags) {
    throw UnimplementedError();
  }

  /// TODO: Implement
  int get restartDelayMillis {
    throw UnimplementedError();
  }

  /// TODO: Implement
  set restartDelayMillis(int millis) {
    throw UnimplementedError();
  }

  /// TODO: Implement
  void restart() {
    throw UnimplementedError();
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
    throw UnimplementedError();
  }

  /// TODO: Implement
  CanBitTimingConstants get dataBitTimingConstants {
    throw UnimplementedError();
  }

  /// TODO: Implement
  int get termination {
    throw UnimplementedError();
  }

  /// TODO: Implement
  set termination(int termination) {
    // not all values accepted
    // ref: https://elixir.bootlin.com/linux/latest/source/drivers/net/can/dev/netlink.c#L365
    throw UnimplementedError();
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
    final fd = platformInterface.createCanSocket();
    try {
      platformInterface.bind(fd, netInterface.index);

      return CanSocket(
        platformInterface: platformInterface,
        fd: fd,
        netInterface: netInterface,
      );
    } on Object {
      platformInterface.close(fd);
      rethrow;
    }
  }
}

/// Classical CAN frame structure (aka CAN 2.0B)
class CanFrame {
  CanFrame.raw({
    required this.id,
    required this.data,
    this.extendedFrameFormat = false,
    this.remoteTransmissionRequest = false,
    this.errorFrame = false,
  })  : assert(extendedFrameFormat || id & ~CAN_SFF_MASK == 0),
        assert(id & ~CAN_EFF_MASK == 0),
        assert(data.length <= 8);

  factory CanFrame({
    required int id,
    required List<int> data,
    bool extendedFrameFormat = false,
    bool remoteTransmissionRequest = false,
    bool errorFrame = false,
  }) {
    data = List.unmodifiable(data);

    return CanFrame.raw(
        id: id,
        data: data,
        extendedFrameFormat: extendedFrameFormat,
        remoteTransmissionRequest: remoteTransmissionRequest,
        errorFrame: errorFrame);
  }

  /// CAN ID of the frame.
  final int id;

  /// Extended frame format
  final bool extendedFrameFormat;

  /// Remote transmission request
  final bool remoteTransmissionRequest;

  /// Error message frame
  final bool errorFrame;

  /// CAN frame payload (up to 8 bytes)
  final List<int> data;
}

class CanSocket {
  CanSocket({
    required this.platformInterface,
    required this.fd,
    required this.netInterface,
  });

  final PlatformInterface platformInterface;
  final int fd;
  final NetInterface netInterface;
  var _open = true;

  void write(CanFrame frame) {
    assert(_open);
    platformInterface.write(fd, frame);
  }

  void close() {
    assert(_open);
    platformInterface.close(fd);
    _open = false;
  }
}

void writeBytesToArray(List<int> bytes, int length, void Function(int index, int value) setElement) {
  bytes.take(length).toList().asMap().forEach(setElement);
}

void writeStringToArrayHelper(
  String str,
  int length,
  void Function(int index, int value) setElement, {
  Encoding codec = utf8,
}) {
  final untruncatedBytes = List.of(codec.encode(str))..addAll(List.filled(length, 0));

  untruncatedBytes.take(length).toList().asMap().forEach(setElement);
}

class PlatformInterface {
  final LibC libc;

  PlatformInterface() : libc = LibC(DynamicLibrary.open('libc.so.6'));

  int getInterfaceIndex(String interfaceName) {
    final native = interfaceName.toNativeUtf8();

    try {
      final index = libc.if_nametoindex(native.cast<Char>());

      if (index == 0) {
        throw LinuxError(
            'Could not query interface index for interface name "$interfaceName".', 'if_nametoindex', libc.errno);
      }

      return index;
    } finally {
      malloc.free(native);
    }
  }

  List<NetInterface> getNetworkInterfaces() {
    final nameindex = libc.if_nameindex1();

    try {
      final interfaces = <NetInterface>[];
      for (var offset = 0; nameindex.elementAt(offset).ref.if_index != 0; offset++) {
        final element = nameindex.elementAt(offset);

        interfaces.add(
          NetInterface(
            index: element.ref.if_index,
            name: element.ref.if_name.toString(),
          ),
        );
      }

      return interfaces;
    } finally {
      libc.if_freenameindex(nameindex);
    }
  }

  List<CanDevice> getCanDevices() {
    return getNetworkInterfaces()
        .where((interface) => interface.name.startsWith('can'))
        .map<CanDevice>((interface) => CanDevice(platformInterface: this, netInterface: interface))
        .toList();
  }

  int createCanSocket() {
    final socket = libc.socket(PF_CAN, SOCK_RAW, CAN_RAW);
    if (socket < 0) {
      throw LinuxError('Could not create CAN socket.', 'socket', libc.errno);
    }

    return socket;
  }

  int getCanInterfaceMTU(int fd, String interfaceName) {
    final req = calloc<ifreq>();

    writeStringToArrayHelper(interfaceName, IF_NAMESIZE, (index, byte) => req.ref.ifr_name[index] = byte);

    req.ref.ifr_ifindex = 0;

    final ok = libc.ioctlPtr(fd, SIOCGIFMTU, req);
    if (ok < 0) {
      calloc.free(req);
      throw LinuxError('Could not get CAN interface MTU.', 'ioctl', libc.errno);
    }

    final mtu = req.ref.ifr_mtu;

    calloc.free(req);

    return mtu;
  }

  bool isFlexibleDatarateCapable(int fd, String interfaceName) {
    return getCanInterfaceMTU(fd, interfaceName) == CANFD_MTU;
  }

  void bind(int fd, int interfaceIndex) {
    final addr = calloc<sockaddr_can>();
    try {
      addr.ref.can_family = AF_CAN;
      addr.ref.can_ifindex = interfaceIndex;

      final ok = libc.bind(fd, addr.cast<sockaddr>(), sizeOf<sockaddr_can>());
      if (ok < 0) {
        throw LinuxError('Couldn\'t bind socket to CAN interface.', 'bind', libc.errno);
      }
    } finally {
      calloc.free(addr);
    }
  }

  void close(int fd) {
    libc.close(fd);
  }

  void write(int fd, CanFrame frame) {
    final nativeFrame = calloc<can_frame>();

    nativeFrame.ref.can_id = frame.id;

    if (frame.extendedFrameFormat) {
      nativeFrame.ref.can_id |= CAN_EFF_FLAG;
    }
    if (frame.remoteTransmissionRequest) {
      nativeFrame.ref.can_id |= CAN_RTR_FLAG;
    }
    if (frame.errorFrame) {
      nativeFrame.ref.can_id |= CAN_ERR_FLAG;
    }

    assert(frame.data.length <= 8);
    nativeFrame.ref.len = frame.data.length;

    writeBytesToArray(frame.data, 8, (index, value) => nativeFrame.ref.data[index] = value);

    final ok = libc.write(fd, nativeFrame.cast<Void>(), sizeOf<can_frame>());

    calloc.free(nativeFrame);

    if (ok < 0) {
      throw LinuxError('Couldn\'t write CAN frame to socket.', 'write', libc.errno);
    } else if (ok != CAN_MTU) {
      throw LinuxError('Incomplete write.', 'write');
    }
  }

  // int openNetlinkSocket() {
  //   final fd = libc.socket(AF_NETLINK, SOCK_RAW, NETLINK_ROUTE);
  //   if (fd < 0) {
  //     throw LinuxError('Couldn\'t open netlink socket.', 'socket', libc.errno);
  //   }
  //
  //   try {
  //     final sndbuf = malloc<Int>();
  //     final rcvbuf = malloc<Int>();
  //
  //     try {
  //       sndbuf.value = 32768;
  //       rcvbuf.value = 32768;
  //
  //       var ok = libc.setsockopt(fd, SOL_SOCKET, SO_SNDBUF, sndbuf.cast<Void>(), sizeOf<Int>());
  //       if (ok < 0) {
  //         throw LinuxError('Couldn\'t set netlink socket sndbuf size.', 'setsockopt', libc.errno);
  //       }
  //
  //       libc.setsockopt(fd, SOL_SOCKET, SO_RCVBUF, rcvbuf.cast<Void>(), sizeOf<Int>());
  //       if (ok < 0) {
  //         throw LinuxError('Couldn\'t set netlink socket rcvbuf size.', 'setsockopt', libc.errno);
  //       }
  //     } finally {
  //       malloc.free(sndbuf);
  //       malloc.free(rcvbuf);
  //     }
  //
  //     final local = calloc<sockaddr_nl>();
  //
  //     try {
  //       local.ref.nl_family = AF_NETLINK;
  //       local.ref.nl_groups = 0;
  //
  //       var ok = libc.bind(fd, local.cast<sockaddr>(), sizeOf<sockaddr_nl>());
  //       if (ok < 0) {
  //         throw LinuxError('Could\'t bind netlink socket.', 'bind', libc.errno);
  //       }
  //
  //       final addrLen = calloc<UnsignedInt>();
  //
  //       try {
  //         addrLen.value = sizeOf<sockaddr_nl>();
  //
  //         ok = libc.getsockname(fd, local.cast<sockaddr>(), addrLen);
  //         if (ok < 0) {
  //           throw LinuxError('Error', 'getsockname', libc.errno);
  //         }
  //
  //         if (addrLen.value != sizeOf<sockaddr_nl>()) {
  //           throw StateError('Invalid address length: ${addrLen.value}, should be: ${sizeOf<sockaddr_nl>()}');
  //         }
  //
  //         if (local.ref.nl_family != AF_NETLINK) {
  //           throw StateError('Invalid address family ${local.ref.nl_family}, should be: $AF_NETLINK');
  //         }
  //       } finally {
  //         calloc.free(addrLen);
  //       }
  //     } finally {
  //       calloc.free(local);
  //     }
  //   } on Object {
  //     libc.close(fd);
  //     rethrow;
  //   }
  //
  //   return fd;
  // }
  //
  // static int _nlmsgAlign(int len) => (len + 4 - 1) & ~(4 - 1);
  //
  // static late final _nlmsgHdrlen = _nlmsgAlign(sizeOf<nlmsghdr>());
  //
  // static int _nlmsgLength(int len) => len + _nlmsgHdrlen;
  //
  // static int _nlmsgSpace(int len) => _nlmsgAlign(_nlmsgLength(len));
  //
  // static Pointer<T> _nlmsgData<T extends NativeType>(Pointer<nlmsghdr> nlh) =>
  //     Pointer<T>.fromAddress(nlh.address + _nlmsgHdrlen);
  //
  // int setCanInterfaceAttributes(
  //   int netlinkFd,
  //   int interfaceIndex, {
  //   bool? setUpDown,
  //   can_bittiming? bitTiming,
  //   int? canCtrlMode,
  //   int? restartMs,
  //   bool? restart,
  //   can_bittiming? dataBitTiming,
  //   int? termination,
  // }) {
  //   var length = _nlmsgLength(sizeOf<ifinfomsg>());
  //
  //   final maxLength = _nlmsgLength(sizeOf<ifinfomsg>()) + 2048;
  //
  //   final req = calloc.allocate<nlmsghdr>(maxLength);
  //
  //   req.ref.nlmsg_len = 0;
  //   req.ref.nlmsg_flags = 0;
  //   req.ref.nlmsg_type = 0;
  //
  //   final data = _nlmsgData<ifinfomsg>(req);
  // }
  //
  // void setBitrate(int socket, String interfaceName) {}
}

class LinuxCan {
  final PlatformInterface _interface = PlatformInterface();

  List<CanDevice> get devices {
    return _interface.getCanDevices();
  }
}
