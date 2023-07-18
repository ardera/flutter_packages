// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:developer';
import 'dart:ffi' as ffi;

import 'package:_ardera_common_libc_bindings/_ardera_common_libc_bindings.dart';
import 'package:_ardera_common_libc_bindings/epoll_event_loop.dart';
import 'package:_ardera_common_libc_bindings/linux_error.dart';
import 'package:ffi/ffi.dart' as ffi;
import 'package:linux_can/src/can_device.dart';
import 'package:linux_can/src/data_classes.dart';

void _writeBytesToArray(List<int> bytes, int length, void Function(int index, int value) setElement) {
  bytes.take(length).toList().asMap().forEach(setElement);
}

void _writeStringToArrayHelper(
  String str,
  int length,
  void Function(int index, int value) setElement, {
  Encoding codec = utf8,
}) {
  final untruncatedBytes = List.of(codec.encode(str))..addAll(List.filled(length, 0));

  untruncatedBytes.take(length).toList().asMap().forEach(setElement);
}

List<T> _listFromArrayHelper<T>(int length, T Function(int index) getElement) {
  return List.generate(length, getElement, growable: false);
}

String _stringFromInlineArray(int maxLength, int Function(int index) getElement, {Encoding codec = utf8}) {
  final list = _listFromArrayHelper(maxLength, getElement);
  final indexOfZero = list.indexOf(0);
  final length = indexOfZero == -1 ? maxLength : indexOfZero;

  return codec.decode(list.sublist(0, length));
}

CanDeviceStats canDeviceStatsFromNative(ffi.Pointer<can_device_stats> native) {
  return CanDeviceStats(
    busError: native.ref.bus_error,
    errorWarning: native.ref.error_warning,
    errorPassive: native.ref.error_passive,
    busOff: native.ref.bus_off,
    arbitrationLost: native.ref.arbitration_lost,
    restarts: native.ref.restarts,
  );
}

CanBitTiming canBitTimingFromNative(ffi.Pointer<can_bittiming> native) {
  return CanBitTiming(
    bitrate: native.ref.bitrate,
    samplePoint: native.ref.sample_point,
    tq: native.ref.tq,
    propagationSegment: native.ref.prop_seg,
    phaseSegment1: native.ref.phase_seg1,
    phaseSegment2: native.ref.phase_seg2,
    syncJumpWidth: native.ref.sjw,
    bitratePrescaler: native.ref.brp,
  );
}

CanBitTimingLimits canBitTimingLimitsFromNative(ffi.Pointer<can_bittiming_const> native) {
  final name = _stringFromInlineArray(16, (i) => native.ref.name[i]);

  return CanBitTimingLimits(
    hardwareName: name,
    timeSegment1Min: native.ref.tseg1_min,
    timeSegment1Max: native.ref.tseg1_max,
    timeSegment2Min: native.ref.tseg2_min,
    timeSegment2Max: native.ref.tseg2_max,
    synchronisationJumpWidth: native.ref.sjw_max,
    bitRatePrescalerMin: native.ref.brp_min,
    bitRatePrescalerMax: native.ref.brp_max,
    bitRatePrescalerIncrement: native.ref.brp_inc,
  );
}

CanBusErrorCounters canBusErrorCountersFromNative(ffi.Pointer<can_berr_counter> native) {
  return CanBusErrorCounters(
    txErrors: native.ref.txerr,
    rxErrors: native.ref.rxerr,
  );
}

enum CanInterfaceAttribute {
  // general network interface attributes
  interfaceFlags,
  txQueueLength,
  operState,
  stats,
  numTxQueues,
  numRxQueues,

  // attribute is present for all network interfaces but
  // contains CAN-specific data
  xstats,

  // CAN-specific
  bitTiming,
  bitTimingLimits,
  clockFrequency,
  state,
  controllerMode,
  restartDelay,
  busErrorCounters,
  dataBitTiming,
  dataBitTimingLimits,
  termination,
  fixedTermination,
  fixedBitrate,
  fixedDataBitrate,
  maxBitrate,
  supportedControllerModes,

  /// TODO: Implement TDC and TDC limits
}

class _MutableCanInterfaceAttributes implements CanInterfaceAttributes {
  @override
  Set<NetInterfaceFlag>? interfaceFlags;

  @override
  int? txQueueLength;
  @override
  NetInterfaceOperState? operState;
  @override
  NetInterfaceStats? stats;
  @override
  int? numTxQueues;
  @override
  int? numRxQueues;

  @override
  CanDeviceStats? xstats;

  @override
  CanBitTiming? bitTiming;
  @override
  CanBitTimingLimits? bitTimingLimits;
  @override
  int? clockFrequency;
  @override
  CanState? state;
  @override
  Set<CanModeFlag>? controllerMode;
  @override
  Duration? restartDelay;
  @override
  CanBusErrorCounters? busErrorCounters;
  @override
  CanBitTiming? dataBitTiming;
  @override
  CanBitTimingLimits? dataBitTimingLimits;
  @override
  int? termination;
  @override
  int? fixedTermination;
  @override
  int? fixedBitrate;
  @override
  int? fixedDataBitrate;
  @override
  int? maxBitrate;
  @override
  Set<CanModeFlag>? supportedControllerModes;

  @override
  String toString() {
    return 'CanInterfaceAttributes(txQueueLength: $txQueueLength, operState: $operState, stats: $stats, numTxQueues: $numTxQueues, numRxQueues: $numRxQueues, xstats: $xstats, bitTiming: $bitTiming, bitTimingLimits: $bitTimingLimits, clockFrequency: $clockFrequency, state: $state, controllerMode: $controllerMode, restartDelay: $restartDelay, busErrorCounters: $busErrorCounters, dataBitTiming: $dataBitTiming, dataBitTimingLimits: $dataBitTimingLimits, termination: $termination, fixedTermination: $fixedTermination, fixedBitrate: $fixedBitrate, fixedDataBitrate: $fixedDataBitrate, bitrateMax: $maxBitrate, supportedControllerModes: $supportedControllerModes)';
  }
}

sealed class NetlinkMessage {
  const NetlinkMessage();
}

final class NetlinkAckMessage extends NetlinkMessage {
  final nlmsghdr nlh;

  const NetlinkAckMessage({
    required this.nlh,
  });

  @override
  String toString() => 'NetlinkAckMessage(nlh: $nlh)';

  @override
  bool operator ==(covariant NetlinkAckMessage other) {
    if (identical(this, other)) return true;

    return other.nlh == nlh;
  }

  @override
  int get hashCode => nlh.hashCode;
}

final class NetlinkErrorMessage extends NetlinkMessage {
  final int errno;
  final nlmsghdr nlh;

  const NetlinkErrorMessage({
    required this.errno,
    required this.nlh,
  });

  @override
  bool operator ==(covariant NetlinkErrorMessage other) {
    if (identical(this, other)) return true;

    return other.errno == errno && other.nlh == nlh;
  }

  @override
  int get hashCode => errno.hashCode ^ nlh.hashCode;

  @override
  String toString() => 'NetlinkErrorMessage(errno: $errno, nlh: $nlh)';
}

final class NetlinkDataMessage extends NetlinkMessage {
  final ffi.Pointer<nlmsghdr> nlh;
  final int size;

  const NetlinkDataMessage({
    required this.nlh,
    required this.size,
  });

  @override
  String toString() => 'NetlinkDataMessage(nlh: $nlh, size: $size)';

  @override
  bool operator ==(covariant NetlinkDataMessage other) {
    if (identical(this, other)) return true;

    return other.nlh == nlh && other.size == size;
  }

  @override
  int get hashCode => nlh.hashCode ^ size.hashCode;
}

class PlatformInterface {
  final libc = LibC(ffi.DynamicLibrary.open('libc.so.6'));

  late final _rtnetlinkFd = openRtNetlinkSocket();
  late final eventListener = EpollEventLoop(libc);

  static const _bufferSize = 16384;
  final _buffer = ffi.calloc.allocate<ffi.Void>(_bufferSize);

  final _debugOpenFds = <int>{};

  static const _linkInfoDataAttributes = {
    CanInterfaceAttribute.bitTiming,
    CanInterfaceAttribute.bitTimingLimits,
    CanInterfaceAttribute.clockFrequency,
    CanInterfaceAttribute.state,
    CanInterfaceAttribute.controllerMode,
    CanInterfaceAttribute.restartDelay,
    CanInterfaceAttribute.busErrorCounters,
    CanInterfaceAttribute.dataBitTiming,
    CanInterfaceAttribute.dataBitTimingLimits,
    CanInterfaceAttribute.termination,
    CanInterfaceAttribute.fixedTermination,
    CanInterfaceAttribute.fixedBitrate,
    CanInterfaceAttribute.fixedDataBitrate,
    CanInterfaceAttribute.maxBitrate,
    CanInterfaceAttribute.supportedControllerModes,
  };

  static const _linkInfoAttributes = {
    ..._linkInfoDataAttributes,
    CanInterfaceAttribute.xstats,
  };

  void _debugCheckOpenFd(int fd) {
    assert(_debugOpenFds.contains(fd));
  }

  int getInterfaceIndex(String interfaceName) {
    final native = interfaceName.toNativeUtf8();

    try {
      final index = libc.if_nametoindex(native.cast<ffi.Char>());

      if (index == 0) {
        throw LinuxError(
            'Could not query interface index for interface name "$interfaceName".', 'if_nametoindex', libc.errno);
      }

      return index;
    } finally {
      ffi.malloc.free(native);
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
            name: element.ref.if_name.cast<ffi.Utf8>().toDartString(),
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
            networkInterface: interface,
          ),
    ];
  }

  int _retry(int Function() syscall, {Set<int> retryErrorCodes = const {EINTR}}) {
    late int result;
    do {
      result = syscall();
    } while ((result < 0) && retryErrorCodes.contains(libc.errno));

    return result;
  }

  int createCanSocket() {
    final socket = _retry(() => libc.socket(PF_CAN, SOCK_RAW | SOCK_CLOEXEC | SOCK_NONBLOCK, CAN_RAW));
    if (socket < 0) {
      throw LinuxError('Could not create CAN socket.', 'socket', libc.errno);
    }

    _debugOpenFds.add(socket);

    return socket;
  }

  int getCanInterfaceMTU(int fd, String interfaceName) {
    assert(_debugOpenFds.contains(fd));

    final req = ffi.calloc<ifreq>();

    _writeStringToArrayHelper(interfaceName, IF_NAMESIZE, (index, byte) => req.ref.ifr_name[index] = byte);

    req.ref.ifr_ifindex = 0;

    final ok = libc.ioctlPtr(fd, SIOCGIFMTU, req);
    if (ok < 0) {
      ffi.calloc.free(req);
      throw LinuxError('Could not get CAN interface MTU.', 'ioctl', libc.errno);
    }

    final mtu = req.ref.ifr_mtu;

    ffi.calloc.free(req);

    return mtu;
  }

  bool isFlexibleDatarateCapable(int fd, String interfaceName) {
    assert(_debugOpenFds.contains(fd));
    return getCanInterfaceMTU(fd, interfaceName) == CANFD_MTU;
  }

  void bind(int fd, int interfaceIndex) {
    assert(_debugOpenFds.contains(fd));

    final addr = ffi.calloc<sockaddr_can>();
    try {
      addr.ref.can_family = AF_CAN;
      addr.ref.can_ifindex = interfaceIndex;

      final ok = libc.bind(fd, addr.cast<sockaddr>(), ffi.sizeOf<sockaddr_can>());
      if (ok < 0) {
        throw LinuxError('Couldn\'t bind socket to CAN interface.', 'bind', libc.errno);
      }
    } finally {
      ffi.calloc.free(addr);
    }
  }

  void close(int fd) {
    _debugCheckOpenFd(fd);

    final ok = libc.close(fd);

    _debugOpenFds.remove(fd);

    if (ok < 0) {
      throw LinuxError('Could not close CAN socket fd.', 'close', libc.errno);
    }
  }

  void write(int fd, CanFrame frame, {bool block = true}) {
    _debugCheckOpenFd(fd);

    final nativeFrame = ffi.calloc<can_frame>();

    switch (frame) {
      case CanDataFrame(data: var data):
        nativeFrame.ref.can_id = switch (frame) {
          CanStandardDataFrame(id: var id) => id,
          CanExtendedDataFrame(id: var id) => id | CAN_EFF_FLAG,
        };

        nativeFrame.ref.len = frame.data.length;
        _writeBytesToArray(
          data,
          8,
          (index, value) => nativeFrame.ref.data[index] = value,
        );
      case CanRemoteFrame _:
        nativeFrame.ref.can_id = switch (frame) {
          CanStandardRemoteFrame(id: var id) => id | CAN_RTR_FLAG,
          CanExtendedRemoteFrame(id: var id) => id | CAN_RTR_FLAG | CAN_EFF_FLAG,
        };
        nativeFrame.ref.len = 0;
      case CanErrorFrame _:
        nativeFrame.ref.can_id = CAN_ERR_FLAG;
        nativeFrame.ref.len = 0;
    }

    /// TODO: use sendmsg and MSG_DONTWAIT for non-blocking sends, and make blocking sends block in the kernel
    ///  instead of spinning here.
    final ok = _retry(
      () => libc.write(fd, nativeFrame.cast<ffi.Void>(), ffi.sizeOf<can_frame>()),
      retryErrorCodes: {EINTR, if (block) EAGAIN},
    );

    ffi.calloc.free(nativeFrame);

    if (ok < 0) {
      throw LinuxError('Couldn\'t write CAN frame to socket.', 'write', libc.errno);
    } else if (ok != CAN_MTU) {
      throw LinuxError('Incomplete write.', 'write');
    }
  }

  static CanFrame canFrameFromNative(can_frame native) {
    final eff = native.can_id & CAN_EFF_FLAG != 0;
    final rtr = native.can_id & CAN_RTR_FLAG != 0;
    final err = native.can_id & CAN_ERR_FLAG != 0;

    if (err) {
      return CanFrame.error();
    } else if (eff) {
      final id = native.can_id & CAN_EFF_MASK;

      if (rtr) {
        return CanFrame.extendedRemote(id: id);
      } else {
        return CanFrame.extended(
          id: id,
          data: List.generate(
            native.len,
            (index) => native.data[index],
            growable: false,
          ),
        );
      }
    } else {
      final id = native.can_id & CAN_SFF_MASK;

      if (rtr) {
        return CanFrame.standardRemote(id: id);
      } else {
        return CanFrame.standard(
          id: id,
          data: List.generate(
            native.len,
            (index) => native.data[index],
            growable: false,
          ),
        );
      }
    }
  }

  static CanFrame? readStatic(LibC libc, int fd, ffi.Pointer<ffi.Void> buffer, int bufferSize) {
    assert(bufferSize >= ffi.sizeOf<can_frame>());
    assert(CAN_MTU == ffi.sizeOf<can_frame>());

    final ok = libc.read(fd, buffer, ffi.sizeOf<can_frame>());
    if (ok < 0 && libc.errno == EAGAIN) {
      // no frame available right now.
      return null;
    } else if (ok < 0) {
      throw LinuxError('Could not read CAN frame.', 'read', libc.errno);
    }

    if (ok != CAN_MTU) {
      throw LinuxError('Malformed CAN frame. Expected received frame to be $CAN_MTU bytes large, was: $ok.', 'read');
    }

    return canFrameFromNative(buffer.cast<can_frame>().ref);
  }

  CanFrame? read(int fd) {
    _debugCheckOpenFd(fd);
    return readStatic(libc, fd, _buffer, _bufferSize);
  }

  /// Opens an rtnetlink socket for kernel network interface manipulation.
  ///
  /// See: https://man7.org/linux/man-pages/man7/rtnetlink.7.html
  int openRtNetlinkSocket() {
    final fd = libc.socket(AF_NETLINK, SOCK_RAW, NETLINK_ROUTE);
    if (fd < 0) {
      throw LinuxError('Couldn\'t open netlink socket.', 'socket', libc.errno);
    }

    _debugOpenFds.add(fd);

    try {
      final sndbuf = ffi.malloc<ffi.Int>();
      final rcvbuf = ffi.malloc<ffi.Int>();

      try {
        sndbuf.value = 32768;
        rcvbuf.value = 32768;

        var ok = libc.setsockopt(fd, SOL_SOCKET, SO_SNDBUF, sndbuf.cast<ffi.Void>(), ffi.sizeOf<ffi.Int>());
        if (ok < 0) {
          throw LinuxError('Couldn\'t set netlink socket sndbuf size.', 'setsockopt', libc.errno);
        }

        libc.setsockopt(fd, SOL_SOCKET, SO_RCVBUF, rcvbuf.cast<ffi.Void>(), ffi.sizeOf<ffi.Int>());
        if (ok < 0) {
          throw LinuxError('Couldn\'t set netlink socket rcvbuf size.', 'setsockopt', libc.errno);
        }
      } finally {
        ffi.malloc.free(sndbuf);
        ffi.malloc.free(rcvbuf);
      }

      final local = ffi.calloc<sockaddr_nl>();

      try {
        local.ref.nl_family = AF_NETLINK;
        local.ref.nl_groups = 0;

        var ok = libc.bind(fd, local.cast<sockaddr>(), ffi.sizeOf<sockaddr_nl>());
        if (ok < 0) {
          throw LinuxError('Could\'t bind netlink socket.', 'bind', libc.errno);
        }

        final addrLen = ffi.calloc<ffi.UnsignedInt>();

        try {
          addrLen.value = ffi.sizeOf<sockaddr_nl>();

          ok = libc.getsockname(fd, local.cast<sockaddr>(), addrLen);
          if (ok < 0) {
            throw LinuxError('Error', 'getsockname', libc.errno);
          }

          if (addrLen.value != ffi.sizeOf<sockaddr_nl>()) {
            throw StateError('Invalid address length: ${addrLen.value}, should be: ${ffi.sizeOf<sockaddr_nl>()}');
          }

          if (local.ref.nl_family != AF_NETLINK) {
            throw StateError('Invalid address family ${local.ref.nl_family}, should be: $AF_NETLINK');
          }
        } finally {
          ffi.calloc.free(addrLen);
        }
      } finally {
        ffi.calloc.free(local);
      }
    } on Object {
      libc.close(fd);
      _debugOpenFds.remove(fd);
      rethrow;
    }

    return fd;
  }

  Iterable<NetlinkMessage> _rtnetlinkTalk({
    required ffi.Allocator allocator,
    required int netlinkFd,
    required int interfaceIndex,
    required void Function(ffi.Pointer<nlmsghdr> nlh, int size) setupMessage,
  }) sync* {
    final msg = allocator<msghdr>();

    final sockaddr = allocator<sockaddr_nl>();

    final iov = allocator<iovec>();

    final size = 8 * 1024;
    final buffer = allocator.allocate<ffi.Void>(8 * 1024);

    sockaddr.ref.nl_family = AF_NETLINK;
    sockaddr.ref.nl_pad = 0;
    sockaddr.ref.nl_pid = 0;
    sockaddr.ref.nl_groups = 0;

    /// TODO: Not sure this is necessary, since we use msg for recvmsg only anyway
    msg.ref.msg_name = sockaddr.cast<ffi.Void>();
    msg.ref.msg_namelen = 1;
    msg.ref.msg_iov = iov;
    msg.ref.msg_iovlen = 1;
    msg.ref.msg_control = ffi.nullptr;
    msg.ref.msg_controllen = 0;
    msg.ref.msg_flags = 0;

    iov.ref.iov_base = buffer;
    iov.ref.iov_len = 0;

    {
      final nl = buffer.cast<nlmsghdr>();

      setupMessage(nl, size);

      final ok = Timeline.timeSync('send', () {
        return _retry(() => libc.send(netlinkFd, buffer, nl.ref.nlmsg_len, 0));
      });
      if (ok < 0) {
        throw LinuxError('Could not send info request to RTNETLINK.', 'sendmsg', libc.errno);
      }
    }

    {
      iov.ref.iov_base = buffer;
      iov.ref.iov_len = size;

      final ok = Timeline.timeSync('recvmsg', () {
        return _retry(() => libc.recvmsg(netlinkFd, msg, 0));
      });
      if (ok < 0) {
        throw LinuxError('Could not receive info message from RTNETLINK.', 'recvmsg', libc.errno);
      } else if (ok == 0) {
        throw LinuxError('Got EOF on rtnetlink socket.', 'recvmsg');
      }

      if (msg.ref.msg_namelen != ffi.sizeOf<sockaddr_nl>()) {
        throw LinuxError('Invalid sender address.', 'recvmsg');
      }

      var nlh = buffer.cast<nlmsghdr>();
      var bytesRemaining = ok;

      if (!NLMSG_OK(nlh, bytesRemaining)) {
        if (msg.ref.msg_flags & MSG_TRUNC != 0) {
          throw LinuxError('rtnetlink message was truncated.', 'recvmsg');
        } else {
          throw LinuxError('rtnetlink message was malformed.', 'recvmsg');
        }
      }

      while (true) {
        if (!NLMSG_OK(nlh, bytesRemaining)) {
          break;
        }

        if (nlh.ref.nlmsg_type == NLMSG_DONE) {
          break;
        } else if (nlh.ref.nlmsg_type == NLMSG_ERROR) {
          if (NLMSG_LENGTH(ffi.sizeOf<nlmsgerr>()) < nlh.ref.nlmsg_len) {
            throw LinuxError('rtnetlink message was truncated.', 'recvmsg');
          }

          final nlerr = NLMSG_DATA<nlmsgerr>(nlh);
          if (nlerr.ref.error == 0) {
            yield NetlinkAckMessage(nlh: nlerr.ref.msg);
          } else {
            yield NetlinkErrorMessage(errno: -nlerr.ref.error, nlh: nlerr.ref.msg);
          }
        } else {
          yield NetlinkDataMessage(nlh: nlh, size: bytesRemaining);
        }

        final tuple = NLMSG_NEXT(nlh, bytesRemaining);
        nlh = tuple.item1;
        bytesRemaining = tuple.item2;
      }
    }
  }

  Iterable<ffi.Pointer<rtattr>> _nestedRtas(ffi.Pointer<rtattr> rta) sync* {
    var size = RTA_PAYLOAD(rta);
    rta = RTA_DATA(rta);

    while (RTA_OK(rta, size)) {
      yield rta;

      final tuple = RTA_NEXT(rta, size);
      rta = tuple.item1;
      size = tuple.item2;
    }
  }

  Iterable<ffi.Pointer<rtattr>> _rtas(ffi.Pointer<rtattr> rta, int size) sync* {
    while (RTA_OK(rta, size)) {
      yield rta;

      final tuple = RTA_NEXT(rta, size);
      rta = tuple.item1;
      size = tuple.item2;
    }
  }

  String _parseRtaString(ffi.Pointer<rtattr> rta) {
    final data = RTA_DATA<ffi.Utf8>(rta);
    final str = data.toDartString();
    return str;
  }

  int _parseRtaUint32(ffi.Pointer<rtattr> rta) {
    if (RTA_PAYLOAD(rta) != ffi.sizeOf<ffi.Uint32>()) {
      throw LinuxError('Malformed rtnetlink message.', 'recvmsg');
    }
    return RTA_DATA<ffi.Uint32>(rta).value;
  }

  int _parseRtaUint8(ffi.Pointer<rtattr> rta) {
    if (RTA_PAYLOAD(rta) != ffi.sizeOf<ffi.Uint8>()) {
      throw LinuxError('Malformed rtnetlink message.', 'recvmsg');
    }
    return RTA_DATA<ffi.Uint8>(rta).value;
  }

  ffi.Pointer<T> _parseRtaTyped<T extends ffi.NativeType>(ffi.Pointer<rtattr> rta, int sizeInBytes) {
    if (RTA_PAYLOAD(rta) != sizeInBytes) {
      throw LinuxError('Malformed rtnetlink message.', 'recvmsg');
    }
    return RTA_DATA<T>(rta);
  }

  void _parseCanLinkInfoDataAttributes(
    _MutableCanInterfaceAttributes attributes,
    Set<CanInterfaceAttribute> interests,
    ffi.Pointer<rtattr> rta,
  ) {
    final it = _nestedRtas(rta).iterator;

    interests = interests.intersection(_linkInfoDataAttributes);
    while (interests.isNotEmpty && it.moveNext()) {
      final rta = it.current;

      switch (rta.ref.rta_type) {
        case IFLA_CAN_BITTIMING:
          if (!interests.contains(CanInterfaceAttribute.bitTiming)) break;

          final native = _parseRtaTyped<can_bittiming>(rta, ffi.sizeOf<can_bittiming>());
          attributes.bitTiming = canBitTimingFromNative(native);
          interests.remove(CanInterfaceAttribute.bitTiming);

        case IFLA_CAN_BITTIMING_CONST:
          if (!interests.contains(CanInterfaceAttribute.bitTimingLimits)) break;

          final native = _parseRtaTyped<can_bittiming_const>(rta, ffi.sizeOf<can_bittiming_const>());
          attributes.bitTimingLimits = canBitTimingLimitsFromNative(native);
          interests.remove(CanInterfaceAttribute.bitTimingLimits);

        case IFLA_CAN_CLOCK:
          if (!interests.contains(CanInterfaceAttribute.clockFrequency)) break;

          final native = _parseRtaTyped<can_clock>(rta, ffi.sizeOf<can_clock>());
          attributes.clockFrequency = native.ref.freq;
          interests.remove(CanInterfaceAttribute.clockFrequency);

        case IFLA_CAN_STATE:
          if (!interests.contains(CanInterfaceAttribute.state)) break;

          final native = _parseRtaUint32(rta);
          attributes.state = CanState.values.singleWhere((element) => element.value == native);
          interests.remove(CanInterfaceAttribute.state);

        case IFLA_CAN_CTRLMODE:
          if (!interests.contains(CanInterfaceAttribute.controllerMode)) break;

          final native = _parseRtaTyped<can_ctrlmode>(rta, ffi.sizeOf<can_ctrlmode>());
          attributes.controllerMode = CanModeFlag.values.where((mode) => (mode.value & native.ref.flags) != 0).toSet();
          interests.remove(CanInterfaceAttribute.controllerMode);

        case IFLA_CAN_RESTART_MS:
          if (!interests.contains(CanInterfaceAttribute.restartDelay)) break;

          final restartDelayMillis = _parseRtaUint32(rta);
          attributes.restartDelay = Duration(milliseconds: restartDelayMillis);
          interests.remove(CanInterfaceAttribute.restartDelay);

        case IFLA_CAN_BERR_COUNTER:
          if (!interests.contains(CanInterfaceAttribute.busErrorCounters)) break;

          final native = _parseRtaTyped<can_berr_counter>(rta, ffi.sizeOf<can_berr_counter>());
          attributes.busErrorCounters = canBusErrorCountersFromNative(native);
          interests.remove(CanInterfaceAttribute.busErrorCounters);

        case IFLA_CAN_DATA_BITTIMING:
          if (!interests.contains(CanInterfaceAttribute.dataBitTiming)) break;

          final native = _parseRtaTyped<can_bittiming>(rta, ffi.sizeOf<can_bittiming>());
          attributes.dataBitTiming = canBitTimingFromNative(native);
          interests.remove(CanInterfaceAttribute.dataBitTiming);

        case IFLA_CAN_DATA_BITTIMING_CONST:
          if (!interests.contains(CanInterfaceAttribute.dataBitTimingLimits)) break;

          final native = _parseRtaTyped<can_bittiming_const>(rta, ffi.sizeOf<can_bittiming_const>());
          attributes.dataBitTimingLimits = canBitTimingLimitsFromNative(native);
          interests.remove(CanInterfaceAttribute.dataBitTimingLimits);

        case IFLA_CAN_TERMINATION:
          if (!interests.contains(CanInterfaceAttribute.termination)) break;

          attributes.termination = _parseRtaUint32(rta);
          interests.remove(CanInterfaceAttribute.termination);

        case IFLA_CAN_TERMINATION_CONST:
          if (!interests.contains(CanInterfaceAttribute.fixedTermination)) break;

          attributes.fixedTermination = _parseRtaUint32(rta);
          interests.remove(CanInterfaceAttribute.fixedTermination);

        case IFLA_CAN_BITRATE_CONST:
          if (!interests.contains(CanInterfaceAttribute.fixedBitrate)) break;

          attributes.fixedBitrate = _parseRtaUint32(rta);
          interests.remove(CanInterfaceAttribute.fixedBitrate);

        case IFLA_CAN_DATA_BITRATE_CONST:
          if (!interests.contains(CanInterfaceAttribute.fixedDataBitrate)) break;

          attributes.fixedDataBitrate = _parseRtaUint32(rta);
          interests.remove(CanInterfaceAttribute.fixedDataBitrate);

        case IFLA_CAN_BITRATE_MAX:
          if (!interests.contains(CanInterfaceAttribute.maxBitrate)) break;

          attributes.maxBitrate = _parseRtaUint32(rta);
          interests.remove(CanInterfaceAttribute.maxBitrate);

        case IFLA_CAN_CTRLMODE_EXT:
          if (!interests.contains(CanInterfaceAttribute.supportedControllerModes)) break;

          for (final rta in _nestedRtas(rta)) {
            if (rta.ref.rta_type == IFLA_CAN_CTRLMODE_SUPPORTED) {
              final native = _parseRtaUint32(rta);
              attributes.supportedControllerModes =
                  CanModeFlag.values.where((mode) => (mode.value & native) != 0).toSet();

              break;
            }
          }

          interests.remove(CanInterfaceAttribute.supportedControllerModes);
      }
    }
  }

  void _parseCanLinkInfoAttributes(
    _MutableCanInterfaceAttributes attributes,
    Set<CanInterfaceAttribute> interests,
    ffi.Pointer<rtattr> rta,
  ) {
    final it = _nestedRtas(rta).iterator;

    interests = interests.intersection(_linkInfoAttributes);

    var isCan = false;
    while (interests.isNotEmpty && it.moveNext()) {
      final rta = it.current;

      switch (rta.ref.rta_type) {
        case IFLA_INFO_KIND:
          final kind = _parseRtaString(rta);
          if (kind == 'can') {
            isCan = true;
          }

        case IFLA_INFO_DATA:
          if (!isCan || interests.intersection(_linkInfoDataAttributes).isEmpty) break;

          Timeline.timeSync('parseCanLinkInfoDataAttributes', () {
            _parseCanLinkInfoDataAttributes(attributes, interests, rta);
          });
          interests.removeAll(_linkInfoDataAttributes);

        case IFLA_INFO_XSTATS:
          if (!interests.contains(CanInterfaceAttribute.xstats)) break;

          final native = _parseRtaTyped<can_device_stats>(rta, ffi.sizeOf<can_device_stats>());
          attributes.xstats = canDeviceStatsFromNative(native);
          interests.remove(CanInterfaceAttribute.xstats);
      }
    }
  }

  void _parseCanInterfaceAttributes(
    _MutableCanInterfaceAttributes attributes,
    Set<CanInterfaceAttribute> interests,
    ffi.Pointer<rtattr> rta,
    int size,
  ) {
    final it = _rtas(rta, size).iterator;
    while (interests.isNotEmpty && it.moveNext()) {
      final rta = it.current;

      switch (rta.ref.rta_type) {
        case IFLA_STATS:
          if (!interests.contains(CanInterfaceAttribute.stats)) break;

          interests.remove(CanInterfaceAttribute.stats);

        case IFLA_TXQLEN:
          if (!interests.contains(CanInterfaceAttribute.txQueueLength)) break;

          attributes.txQueueLength = _parseRtaUint32(rta);
          interests.remove(CanInterfaceAttribute.txQueueLength);

        case IFLA_OPERSTATE:
          if (!interests.contains(CanInterfaceAttribute.operState)) break;

          final native = _parseRtaUint8(rta);
          attributes.operState = NetInterfaceOperState.values.singleWhere(
            (operState) => operState.value == native,
          );
          interests.remove(CanInterfaceAttribute.operState);

        case IFLA_LINKINFO:
          if (interests.intersection(_linkInfoAttributes).isEmpty) break;

          Timeline.timeSync('parseCanLinkInfoAttributes', () {
            _parseCanLinkInfoAttributes(attributes, interests, rta);
          });
          interests.removeAll(_linkInfoAttributes);

        case IFLA_NUM_TX_QUEUES:
          if (!interests.contains(CanInterfaceAttribute.numTxQueues)) break;

          attributes.numTxQueues = _parseRtaUint32(rta);
          interests.remove(CanInterfaceAttribute.numTxQueues);

        case IFLA_NUM_RX_QUEUES:
          if (!interests.contains(CanInterfaceAttribute.numRxQueues)) break;

          attributes.numRxQueues = _parseRtaUint32(rta);
          interests.remove(CanInterfaceAttribute.numRxQueues);
      }
    }
  }

  CanInterfaceAttributes _queryAttributes(
    int interfaceIndex, {
    Set<CanInterfaceAttribute>? interests,
  }) {
    _debugCheckOpenFd(_rtnetlinkFd);

    final allocator = ffi.Arena();

    try {
      final messages = _rtnetlinkTalk(
        allocator: allocator,
        netlinkFd: _rtnetlinkFd,
        interfaceIndex: interfaceIndex,
        setupMessage: (nlh, size) {
          nlh.ref.nlmsg_len = NLMSG_LENGTH(ffi.sizeOf<ifinfomsg>());
          nlh.ref.nlmsg_type = RTM_GETLINK;
          nlh.ref.nlmsg_flags = NLM_F_REQUEST;
          nlh.ref.nlmsg_pid = 0;
          nlh.ref.nlmsg_seq = 0;

          final ifi = NLMSG_DATA<ifinfomsg>(nlh);

          ifi.ref.ifi_family = 0 /* AF_UNSPEC */;
          ifi.ref.ifi_type = 0;
          ifi.ref.ifi_index = interfaceIndex;
          ifi.ref.ifi_flags = 0;
          ifi.ref.ifi_change = 0;
        },
      );

      for (final msg in messages) {
        switch (msg) {
          case NetlinkDataMessage(nlh: var nlh, size: var size):
            if (nlh.ref.nlmsg_type != RTM_NEWLINK) {
              break;
            }

            if (NLMSG_LENGTH(ffi.sizeOf<ifinfomsg>()) > nlh.ref.nlmsg_len) {
              throw LinuxError('malformed rtnetlink message.', 'recvmsg');
            }

            final ifi = NLMSG_DATA<ifinfomsg>(nlh);
            size -= NLMSG_LENGTH(ffi.sizeOf<ifinfomsg>());

            var rta = IFLA_RTA(ifi);
            if (!RTA_OK(rta, size)) {
              throw LinuxError('malformed rtnetlink message.', 'recvmsg');
            }

            final attributes = _MutableCanInterfaceAttributes();
            interests ??= CanInterfaceAttribute.values.toSet();

            /// FIXME: We don't actually need to talk to RTNETLINK for basic stuff such as the
            ///  interface flags, mtu, txqlen
            if (interests.contains(CanInterfaceAttribute.interfaceFlags)) {
              final native = ifi.ref.ifi_flags;
              attributes.interfaceFlags = NetInterfaceFlag.values
                  .where(
                    (flag) => (native & flag.nativeValue) != 0,
                  )
                  .toSet();

              interests.remove(CanInterfaceAttribute.interfaceFlags);
            }

            if (interests.isNotEmpty) {
              Timeline.timeSync('parseCanInterfaceAttributes', () {
                _parseCanInterfaceAttributes(attributes, interests!, rta, size);
              });
            }

            return attributes;
          case NetlinkAckMessage _:
            break;
          case NetlinkErrorMessage(errno: var errno):
            throw LinuxError('rtnetlink responded with error', null, errno);
        }
      }

      throw LinuxError('rtnetlink didn\'t provide any data.');
    } finally {
      allocator.releaseAll();
    }
  }

  CanInterfaceAttributes queryAttributes(
    int interfaceIndex, {
    Set<CanInterfaceAttribute>? interests,
  }) {
    return Timeline.timeSync(
      'query CAN interface attributes',
      () => _queryAttributes(interfaceIndex, interests: interests),
      arguments: {
        'interests': interests?.toList().map((interest) => interest.toString()).toList(),
      },
    );
  }

  int getSendBufSize(int fd, {bool canfd = false}) {
    final valuePtr = _buffer.cast<ffi.Int>();
    final lengthPtr = valuePtr.elementAt(1).cast<ffi.UnsignedInt>();

    lengthPtr.value = ffi.sizeOf<ffi.Int>();

    final ok = libc.getsockopt(fd, SOL_SOCKET, SO_SNDBUF, valuePtr.cast<ffi.Void>(), lengthPtr);
    if (ok < 0) {
      throw LinuxError('Could not get SO_SNDBUF socket option.', 'getsockopt', libc.errno);
    }

    // According to the kernel docs: https://man7.org/linux/man-pages/man7/socket.7.html
    // setsockopt(..., SO_SNDBUF, ...) actually doubles the value given to it to leave some space for kernel bookkeeping.
    // To not totally confuse people, we divide by 2 here.
    final workingMemory = valuePtr.value ~/ 2;

    return workingMemory;
  }

  void setSendBufSize(int fd, int size, {bool canfd = false}) {
    final valuePtr = _buffer.cast<ffi.Int>();
    valuePtr.value = size;

    final ok = libc.setsockopt(fd, SOL_SOCKET, SO_SNDBUF, valuePtr.cast<ffi.Void>(), ffi.sizeOf<ffi.Int>());
    if (ok < 0) {
      throw LinuxError('Could not set SO_SNDBUF socket option.', 'setsockopt', libc.errno);
    }
  }
}
