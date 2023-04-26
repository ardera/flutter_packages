import 'dart:convert';
import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'package:_ardera_common_libc_bindings/_ardera_common_libc_bindings.dart';
import 'package:_ardera_common_libc_bindings/linux_error.dart';

/// A linux network interface.
///
/// Combination of an interface index and interface name.
///
/// For example, `can0`, 5.
class NetworkInterface {
  NetworkInterface({required this.index, required this.name});

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

  const CanBitTiming.bitrateOnly({required this.bitrate})
      : samplePoint = 0,
        tq = 0,
        propagationSegment = 0,
        phaseSegment1 = 0,
        phaseSegment2 = 0,
        syncJumpWidth = 0,
        bitratePrescaler = 0;

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

/// CAN controller mode
///
/// ref
///   https://elixir.bootlin.com/linux/v6.3/source/include/uapi/linux/can/netlink.h#L95
///   https://elixir.bootlin.com/linux/v6.3/source/drivers/net/can/dev/netlink.c#L240
enum CanModeFlag {
  /// Loopback mode.
  ///
  /// ref:
  ///   https://elixir.bootlin.com/linux/v6.3/source/include/uapi/linux/can/netlink.h#L95
  loopback(CAN_CTRLMODE_LOOPBACK),

  /// Listen-only mode.
  ///
  /// ref:
  ///   https://elixir.bootlin.com/linux/v6.3/source/include/uapi/linux/can/netlink.h#L96
  listenOnly(CAN_CTRLMODE_LISTENONLY),

  /// Triple sampling mode.
  ///
  /// ref:
  ///   https://elixir.bootlin.com/linux/v6.3/source/include/uapi/linux/can/netlink.h#L97
  tripleSample(CAN_CTRLMODE_3_SAMPLES),

  /// One-Shot mode.
  ///
  /// ref:
  ///   https://elixir.bootlin.com/linux/v6.3/source/include/uapi/linux/can/netlink.h#L98
  oneShot(CAN_CTRLMODE_ONE_SHOT),

  /// Bus-error reporting.
  ///
  /// ref:
  ///   https://elixir.bootlin.com/linux/v6.3/source/include/uapi/linux/can/netlink.h#L99
  busErrorReporting(CAN_CTRLMODE_BERR_REPORTING),

  /// CAN Flexible Datarate (FD) mode.
  ///
  /// ref:
  ///   https://elixir.bootlin.com/linux/v6.3/source/include/uapi/linux/can/netlink.h#L100
  flexibleDatarate(CAN_CTRLMODE_FD),

  /// Ignore missing CAN ACKs
  ///
  /// ref:
  ///   https://elixir.bootlin.com/linux/v6.3/source/include/uapi/linux/can/netlink.h#L101
  presumeAck(CAN_CTRLMODE_PRESUME_ACK),

  /// CAN Flexible Datarate (FD) in non-ISO mode.
  ///
  /// ref:
  ///   https://elixir.bootlin.com/linux/v6.3/source/include/uapi/linux/can/netlink.h#L102
  flexibleDatarateNonIso(CAN_CTRLMODE_FD_NON_ISO),

  /// Classic CAN data-length-code (DLC) option.
  ///
  /// ref:
  ///   https://elixir.bootlin.com/linux/v6.3/source/include/uapi/linux/can/netlink.h#L103
  classicCanDlc(CAN_CTRLMODE_CC_LEN8_DLC),

  /// CAN transceiver automatically calculates TDCV
  ///
  /// (TDC = CAN FD Transmitter Delay Compensation)
  ///
  /// ref:
  ///   https://elixir.bootlin.com/linux/v6.3/source/include/uapi/linux/can/netlink.h#L104
  tdcAuto(CAN_CTRLMODE_TDC_AUTO),

  /// TDCV is manually set up by user
  ///
  /// (TDC = CAN FD Transmitter Delay Compensation)
  ///
  /// ref:
  ///   https://elixir.bootlin.com/linux/v6.3/source/include/uapi/linux/can/netlink.h#L105
  tdcManual(CAN_CTRLMODE_TDC_MANUAL);

  const CanModeFlag(this.value);

  final int value;
}

class CanBitTimingLimits {
  const CanBitTimingLimits({
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

/// CAN device
class CanDevice {
  CanDevice({
    required this.platformInterface,
    required this.netlinkSocket,
    required this.netInterface,
  });

  final PlatformInterface platformInterface;
  final RtnetlinkSocket netlinkSocket;
  final NetworkInterface netInterface;

  void _setCanInterfaceAttributes({
    bool? setUpDown,
    CanBitTiming? bitTiming,
    Map<CanModeFlag, bool>? ctrlModeFlags,
    int? restartMs,
    bool restart = false,
    CanBitTiming? dataBitTiming,
    int? termination,
  }) {
    return netlinkSocket.setCanInterfaceAttributes(
      netInterface.index,
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
abstract class CanFrame {
  const CanFrame();

  /// Data frame,
  /// CAN 2.0B Standard Frame Format
  factory CanFrame.standard({required int id, required List<int> data}) {
    return CanStandardDataFrame(id: id, data: data);
  }

  /// Data frame,
  /// CAN 2.0B Extended Frame Format
  factory CanFrame.extended({required int id, required List<int> data}) {
    return CanExtendedDataFrame(id: id, data: data);
  }

  /// Remote Frame / Remote Transmission Request,
  /// CAN 2.0B Standard Frame Format
  factory CanFrame.standardRemote({required int id}) {
    return CanStandardRemoteFrame(id: id);
  }

  /// Remote Frame / Remote Transmission Request,
  /// CAN 2.0B Extended Frame Format
  factory CanFrame.extendedRemote({required int id}) {
    return CanExtendedRemoteFrame(id: id);
  }

  /// Error Frame
  factory CanFrame.error() {
    return CanErrorFrame();
  }
}

abstract class CanDataFrame extends CanFrame {
  const CanDataFrame({required this.id, required this.data}) : assert(0 <= data.length && data.length <= 8);

  /// CAN ID of the frame.
  final int id;

  final List<int> data;
}

class CanStandardDataFrame extends CanDataFrame {
  const CanStandardDataFrame({required super.id, required super.data}) : assert(id & ~CAN_SFF_MASK == 0);
}

class CanExtendedDataFrame extends CanDataFrame {
  const CanExtendedDataFrame({required super.id, required super.data}) : assert(id & ~CAN_EFF_MASK == 0);
}

abstract class CanRemoteFrame extends CanFrame {
  const CanRemoteFrame({required this.id});

  /// CAN ID of the frame.
  final int id;
}

class CanStandardRemoteFrame extends CanRemoteFrame {
  const CanStandardRemoteFrame({required super.id}) : assert(id & ~CAN_SFF_MASK == 0);
}

class CanExtendedRemoteFrame extends CanRemoteFrame {
  const CanExtendedRemoteFrame({required super.id}) : assert(id & ~CAN_EFF_MASK == 0);
}

class CanErrorFrame extends CanFrame {
  const CanErrorFrame();
}

class CanSocket {
  CanSocket({
    required this.platformInterface,
    required this.fd,
    required this.netInterface,
  });

  final PlatformInterface platformInterface;
  final int fd;
  final NetworkInterface netInterface;
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

class RtnetlinkSocket {
  RtnetlinkSocket({required this.fd, required this.platformInterface});

  final int fd;
  final PlatformInterface platformInterface;

  void setCanInterfaceAttributes(
    int interfaceIndex, {
    bool? setUpDown,
    CanBitTiming? bitTiming,
    Map<CanModeFlag, bool>? ctrlModeFlags,
    int? restartMs,
    bool restart = false,
    CanBitTiming? dataBitTiming,
    int? termination,
  }) {
    return platformInterface.setCanInterfaceAttributes(
      fd,
      interfaceIndex,
      setUpDown: setUpDown,
      bitTiming: bitTiming,
      ctrlModeFlags: ctrlModeFlags,
      restartMs: restartMs,
      restart: restart,
      dataBitTiming: dataBitTiming,
      termination: termination,
    );
  }
}

class PlatformInterface {
  final LibC libc;

  late final RtnetlinkSocket _rtnetlinkSocket = RtnetlinkSocket(
    fd: openRtNetlinkSocket(),
    platformInterface: this,
  );

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

  List<NetworkInterface> getNetworkInterfaces() {
    final nameindex = libc.if_nameindex1();

    try {
      final interfaces = <NetworkInterface>[];
      for (var offset = 0; nameindex.elementAt(offset).ref.if_index != 0; offset++) {
        final element = nameindex.elementAt(offset);

        interfaces.add(
          NetworkInterface(
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
    return <CanDevice>[
      for (final interface in getNetworkInterfaces())
        if (interface.name.startsWith('can'))
          CanDevice(
            platformInterface: this,
            netlinkSocket: _rtnetlinkSocket,
            netInterface: interface,
          ),
    ];
  }

  int createCanSocket() {
    final socket = libc.socket(PF_CAN, SOCK_RAW | SOCK_CLOEXEC, CAN_RAW);
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

    if (frame is CanDataFrame) {
      nativeFrame.ref.can_id = frame.id;
      if (frame is CanExtendedDataFrame) {
        nativeFrame.ref.can_id |= CAN_EFF_FLAG;
      }

      assert(frame.data.length <= 8);

      nativeFrame.ref.len = frame.data.length;
      writeBytesToArray(
        frame.data,
        8,
        (index, value) => nativeFrame.ref.data[index] = value,
      );
    } else if (frame is CanRemoteFrame) {
      nativeFrame.ref.can_id = frame.id;
      if (frame is CanExtendedRemoteFrame) {
        nativeFrame.ref.can_id |= CAN_EFF_FLAG;
      }
      nativeFrame.ref.can_id |= CAN_RTR_FLAG;

      nativeFrame.ref.len = 0;
    } else if (frame is CanErrorFrame) {
      nativeFrame.ref.can_id |= CAN_ERR_FLAG;

      nativeFrame.ref.len = 0;
    }

    final ok = libc.write(fd, nativeFrame.cast<Void>(), sizeOf<can_frame>());

    calloc.free(nativeFrame);

    if (ok < 0) {
      throw LinuxError('Couldn\'t write CAN frame to socket.', 'write', libc.errno);
    } else if (ok != CAN_MTU) {
      throw LinuxError('Incomplete write.', 'write');
    }
  }

  /// Opens an rtnetlink socket for kernel network interface manipulation.
  ///
  /// See: https://man7.org/linux/man-pages/man7/rtnetlink.7.html
  int openRtNetlinkSocket() {
    final fd = libc.socket(AF_NETLINK, SOCK_RAW, NETLINK_ROUTE);
    if (fd < 0) {
      throw LinuxError('Couldn\'t open netlink socket.', 'socket', libc.errno);
    }

    try {
      final sndbuf = malloc<Int>();
      final rcvbuf = malloc<Int>();

      try {
        sndbuf.value = 32768;
        rcvbuf.value = 32768;

        var ok = libc.setsockopt(fd, SOL_SOCKET, SO_SNDBUF, sndbuf.cast<Void>(), sizeOf<Int>());
        if (ok < 0) {
          throw LinuxError('Couldn\'t set netlink socket sndbuf size.', 'setsockopt', libc.errno);
        }

        libc.setsockopt(fd, SOL_SOCKET, SO_RCVBUF, rcvbuf.cast<Void>(), sizeOf<Int>());
        if (ok < 0) {
          throw LinuxError('Couldn\'t set netlink socket rcvbuf size.', 'setsockopt', libc.errno);
        }
      } finally {
        malloc.free(sndbuf);
        malloc.free(rcvbuf);
      }

      final local = calloc<sockaddr_nl>();

      try {
        local.ref.nl_family = AF_NETLINK;
        local.ref.nl_groups = 0;

        var ok = libc.bind(fd, local.cast<sockaddr>(), sizeOf<sockaddr_nl>());
        if (ok < 0) {
          throw LinuxError('Could\'t bind netlink socket.', 'bind', libc.errno);
        }

        final addrLen = calloc<UnsignedInt>();

        try {
          addrLen.value = sizeOf<sockaddr_nl>();

          ok = libc.getsockname(fd, local.cast<sockaddr>(), addrLen);
          if (ok < 0) {
            throw LinuxError('Error', 'getsockname', libc.errno);
          }

          if (addrLen.value != sizeOf<sockaddr_nl>()) {
            throw StateError('Invalid address length: ${addrLen.value}, should be: ${sizeOf<sockaddr_nl>()}');
          }

          if (local.ref.nl_family != AF_NETLINK) {
            throw StateError('Invalid address family ${local.ref.nl_family}, should be: $AF_NETLINK');
          }
        } finally {
          calloc.free(addrLen);
        }
      } finally {
        calloc.free(local);
      }
    } on Object {
      libc.close(fd);
      rethrow;
    }

    return fd;
  }

  void setCanInterfaceAttributes(
    int netlinkFd,
    int interfaceIndex, {
    bool? setUpDown,
    CanBitTiming? bitTiming,
    Map<CanModeFlag, bool>? ctrlModeFlags,
    int? restartMs,
    bool restart = false,
    CanBitTiming? dataBitTiming,
    int? termination,
  }) {
    final maxLength = NLMSG_SPACE(sizeOf<ifinfomsg>() + 2048);

    final nl = calloc.allocate<nlmsghdr>(maxLength);

    try {
      nl.ref.nlmsg_len = NLMSG_LENGTH(sizeOf<ifinfomsg>());
      nl.ref.nlmsg_flags = NLM_F_REQUEST | NLM_F_ACK;
      nl.ref.nlmsg_type = RTM_NEWLINK;

      final ifinfo = NLMSG_DATA<ifinfomsg>(nl);

      ifinfo.ref.ifi_family = 0;
      ifinfo.ref.ifi_index = interfaceIndex;
      ifinfo.ref.ifi_change = 0;

      if (setUpDown == true) {
        ifinfo.ref.ifi_change |= IFF_UP;
        ifinfo.ref.ifi_flags &= ~IFF_UP;
      } else if (setUpDown == false) {
        ifinfo.ref.ifi_change |= IFF_UP;
        ifinfo.ref.ifi_flags |= IFF_UP;
      }

      Pointer<T> allocateAttr<T extends NativeType>(int type, int lengthInBytes) {
        final len = RTA_LENGTH(lengthInBytes);
        if (NLMSG_SPACE(NLMSG_ALIGN(nl.ref.nlmsg_len) + RTA_ALIGN(len)) > maxLength) {
          throw StateError('rtnetlink message exceeded maximum size of $maxLength');
        }

        final rta = NLMSG_TAIL<rtattr>(nl);

        rta.ref.rta_type = type;
        rta.ref.rta_len = len;

        final data = RTA_DATA<T>(rta);

        nl.ref.nlmsg_len = NLMSG_ALIGN(nl.ref.nlmsg_len) + RTA_ALIGN(len);

        return data;
      }

      void addUint32Attr(int type, int value) {
        final data = allocateAttr<Uint32>(type, sizeOf<Uint32>());
        data.value = value;
      }

      void addStringAttr(int type, String str) {
        final encoded = utf8.encode(str);

        final data = allocateAttr<Uint8>(type, encoded.length);
        data.asTypedList(encoded.length).setAll(0, encoded);
      }

      void addVoidAttr(int type) {
        allocateAttr(type, 0);
      }

      void addSection(int type, void Function() section) {
        final sectionAttr = NLMSG_TAIL<rtattr>(nl);

        addVoidAttr(type);

        section();

        sectionAttr.ref.rta_len = NLMSG_TAIL(nl).address - sectionAttr.address;
      }

      addSection(IFLA_LINKINFO, () {
        addStringAttr(IFLA_INFO_KIND, 'can');

        addSection(IFLA_INFO_DATA, () {
          if (restartMs != null) {
            addUint32Attr(IFLA_CAN_RESTART_MS, restartMs);
          }

          if (restart) {
            addUint32Attr(IFLA_CAN_RESTART, 1);
          }

          if (bitTiming != null) {
            final bittimingPtr = allocateAttr<can_bittiming>(IFLA_CAN_BITTIMING, sizeOf<can_bittiming>());

            bittimingPtr.ref.bitrate = bitTiming.bitrate;
            bittimingPtr.ref.sample_point = bitTiming.samplePoint;
            bittimingPtr.ref.tq = bitTiming.tq;
            bittimingPtr.ref.prop_seg = bitTiming.propagationSegment;
            bittimingPtr.ref.phase_seg1 = bitTiming.phaseSegment1;
            bittimingPtr.ref.phase_seg2 = bitTiming.phaseSegment2;
            bittimingPtr.ref.sjw = bitTiming.syncJumpWidth;
            bittimingPtr.ref.brp = bitTiming.bitratePrescaler;
          }

          if (ctrlModeFlags != null) {
            final ctrlmodePtr = allocateAttr<can_ctrlmode>(IFLA_CAN_CTRLMODE, sizeOf<can_ctrlmode>());

            for (final flag in ctrlModeFlags.keys) {
              ctrlmodePtr.ref.mask |= flag.value;

              if (ctrlModeFlags[flag]!) {
                ctrlmodePtr.ref.flags |= flag.value;
              }
            }
          }

          if (dataBitTiming != null) {
            final bittimingPtr = allocateAttr<can_bittiming>(IFLA_CAN_DATA_BITTIMING, sizeOf<can_bittiming>());

            bittimingPtr.ref.bitrate = dataBitTiming.bitrate;
            bittimingPtr.ref.sample_point = dataBitTiming.samplePoint;
            bittimingPtr.ref.tq = dataBitTiming.tq;
            bittimingPtr.ref.prop_seg = dataBitTiming.propagationSegment;
            bittimingPtr.ref.phase_seg1 = dataBitTiming.phaseSegment1;
            bittimingPtr.ref.phase_seg2 = dataBitTiming.phaseSegment2;
            bittimingPtr.ref.sjw = dataBitTiming.syncJumpWidth;
            bittimingPtr.ref.brp = dataBitTiming.bitratePrescaler;
          }

          if (termination != null) {
            final terminationPtr = allocateAttr<Uint32>(IFLA_CAN_TERMINATION, sizeOf<Uint32>());

            terminationPtr.value = termination;
          }
        });
      });

      final nladdr = calloc<sockaddr_nl>();

      nladdr.ref.nl_family = AF_NETLINK;
      nladdr.ref.nl_pid = 0;
      nladdr.ref.nl_groups = 0;

      final iov = calloc<iovec>();

      iov.ref.iov_base = nl.cast<Void>();
      iov.ref.iov_len = nl.ref.nlmsg_len;

      final msg = calloc<msghdr>();

      msg.ref.msg_name = nladdr.cast<Void>();
      msg.ref.msg_namelen = sizeOf<sockaddr_nl>();
      msg.ref.msg_iov = iov;
      msg.ref.msg_iovlen = 1;

      const bufLen = 16384;
      final buf = calloc<Uint8>(bufLen);

      // Could be unneccessary
      nl.ref.nlmsg_seq = 0;
      nl.ref.nlmsg_flags |= NLM_F_ACK;

      try {
        var ok = libc.sendmsg(netlinkFd, msg, 0);
        if (ok < 0) {
          throw LinuxError('Error sending message to rtnetlink.', 'sendmsg', libc.errno);
        }

        iov.ref.iov_base = buf.cast<Void>();
        while (true) {
          iov.ref.iov_len = bufLen;

          ok = libc.recvmsg(netlinkFd, msg, 0);
          if (ok < 0) {
            throw LinuxError('Could not receive message from rtnetlink.', 'recvmsg', libc.errno);
          }

          var bytesRemaining = ok;

          var nh = buf.cast<nlmsghdr>();
          while (NLMSG_OK(nh, bytesRemaining)) {
            if (nh.ref.nlmsg_type == NLMSG_DONE) {
              // done processing
              return;
            }

            if (nh.ref.nlmsg_type == NLMSG_ERROR) {
              // error
              final err = NLMSG_DATA<nlmsgerr>(nh);
              if (nh.ref.nlmsg_len < NLMSG_SPACE(sizeOf<nlmsgerr>())) {
                throw LinuxError('Error message received from rtnetlink was truncated.');
              }

              if (err.ref.error < 0) {
                throw LinuxError('RTNETLINK answers', null, -err.ref.error);
              } else {
                return;
              }
            }

            final tuple = NLMSG_NEXT(nh, bytesRemaining);
            nh = tuple.item1;
            bytesRemaining = tuple.item2;
          }

          if (bytesRemaining > 0) {
            throw LinuxError('Message received from rtnetlink was truncated.');
          }
        }
      } finally {
        calloc.free(nladdr);
        calloc.free(iov);
        calloc.free(msg);
        calloc.free(buf);
      }
    } finally {
      calloc.free(nl);
    }
  }

  void sendDumpRequest(int netlinkFd, int interfaceIndex, int family, int type) {
    final nl = calloc.allocate<nlmsghdr>(NLMSG_SPACE(sizeOf<ifinfomsg>()));

    nl.ref.nlmsg_len = NLMSG_LENGTH(sizeOf<ifinfomsg>());
    nl.ref.nlmsg_type = type;
    nl.ref.nlmsg_flags = NLM_F_REQUEST;
    nl.ref.nlmsg_pid = 0;
    nl.ref.nlmsg_seq = 0;

    final ifi = NLMSG_DATA<ifinfomsg>(nl);

    ifi.ref.ifi_family = family;
    ifi.ref.ifi_index = interfaceIndex;

    try {
      final ok = libc.send(netlinkFd, nl.cast<Void>(), nl.ref.nlmsg_len, 0);

      if (ok < 0) {
        throw LinuxError('Could not send info request to RTNETLINK.', 'send', libc.errno);
      }
    } finally {
      calloc.free(nl);
    }
  }
}

class LinuxCan {
  final PlatformInterface _interface = PlatformInterface();

  List<CanDevice> get devices {
    return _interface.getCanDevices();
  }
}
