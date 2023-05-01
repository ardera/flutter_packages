import 'dart:convert';
import 'dart:ffi' as ffi;

import 'package:_ardera_common_libc_bindings/_ardera_common_libc_bindings.dart';
import 'package:_ardera_common_libc_bindings/epoll_event_loop.dart';
import 'package:_ardera_common_libc_bindings/linux_error.dart';
import 'package:ffi/ffi.dart' as ffi;
import 'package:linux_can/linux_can.dart';

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

  late final RtnetlinkSocket rtnetlinkSocket = RtnetlinkSocket(
    fd: openRtNetlinkSocket(),
    platformInterface: this,
  );

  late final eventListener = EpollEventLoop(libc);

  static const _bufferSize = 16384;
  final _buffer = ffi.calloc.allocate<ffi.Void>(_bufferSize);

  final openFds = <int>{};

  PlatformInterface() : libc = LibC(ffi.DynamicLibrary.open('libc.so.6'));

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
            netlinkSocket: rtnetlinkSocket,
            networkInterface: interface,
          ),
    ];
  }

  int retry(int Function() syscall) {
    late int result;
    do {
      result = syscall();
    } while ((result < 0) && libc.errno == EAGAIN);

    return result;
  }

  int createCanSocket() {
    final socket = retry(() => libc.socket(PF_CAN, SOCK_RAW | SOCK_CLOEXEC | SOCK_NONBLOCK, CAN_RAW));
    if (socket < 0) {
      throw LinuxError('Could not create CAN socket.', 'socket', libc.errno);
    }

    openFds.add(socket);

    return socket;
  }

  int getCanInterfaceMTU(int fd, String interfaceName) {
    assert(openFds.contains(fd));

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
    assert(openFds.contains(fd));
    return getCanInterfaceMTU(fd, interfaceName) == CANFD_MTU;
  }

  void bind(int fd, int interfaceIndex) {
    assert(openFds.contains(fd));

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
    assert(openFds.contains(fd));

    final ok = libc.close(fd);

    openFds.remove(fd);

    if (ok < 0) {
      throw LinuxError('Could not close CAN socket fd.', 'close', libc.errno);
    }
  }

  void write(int fd, CanFrame frame) {
    assert(openFds.contains(fd));

    final nativeFrame = ffi.calloc<can_frame>();

    if (frame is CanDataFrame) {
      nativeFrame.ref.can_id = frame.id;
      if (frame is CanExtendedDataFrame) {
        nativeFrame.ref.can_id |= CAN_EFF_FLAG;
      }

      assert(frame.data.length <= 8);

      nativeFrame.ref.len = frame.data.length;
      _writeBytesToArray(
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

    final ok = retry(() => libc.write(fd, nativeFrame.cast<ffi.Void>(), ffi.sizeOf<can_frame>()));

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
    assert(openFds.contains(fd));
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

    openFds.add(fd);

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
    final maxLength = NLMSG_SPACE(ffi.sizeOf<ifinfomsg>() + 2048);

    final nl = ffi.calloc.allocate<nlmsghdr>(maxLength);

    try {
      nl.ref.nlmsg_len = NLMSG_LENGTH(ffi.sizeOf<ifinfomsg>());
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

      ffi.Pointer<T> allocateAttr<T extends ffi.NativeType>(int type, int lengthInBytes) {
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
        final data = allocateAttr<ffi.Uint32>(type, ffi.sizeOf<ffi.Uint32>());
        data.value = value;
      }

      void addStringAttr(int type, String str) {
        final encoded = utf8.encode(str);

        final data = allocateAttr<ffi.Uint8>(type, encoded.length);
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
            final bittimingPtr = allocateAttr<can_bittiming>(IFLA_CAN_BITTIMING, ffi.sizeOf<can_bittiming>());

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
            final ctrlmodePtr = allocateAttr<can_ctrlmode>(IFLA_CAN_CTRLMODE, ffi.sizeOf<can_ctrlmode>());

            for (final flag in ctrlModeFlags.keys) {
              ctrlmodePtr.ref.mask |= flag.value;

              if (ctrlModeFlags[flag]!) {
                ctrlmodePtr.ref.flags |= flag.value;
              }
            }
          }

          if (dataBitTiming != null) {
            final bittimingPtr = allocateAttr<can_bittiming>(IFLA_CAN_DATA_BITTIMING, ffi.sizeOf<can_bittiming>());

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
            final terminationPtr = allocateAttr<ffi.Uint32>(IFLA_CAN_TERMINATION, ffi.sizeOf<ffi.Uint32>());

            terminationPtr.value = termination;
          }
        });
      });

      final nladdr = ffi.calloc<sockaddr_nl>();

      nladdr.ref.nl_family = AF_NETLINK;
      nladdr.ref.nl_pid = 0;
      nladdr.ref.nl_groups = 0;

      final iov = ffi.calloc<iovec>();

      iov.ref.iov_base = nl.cast<ffi.Void>();
      iov.ref.iov_len = nl.ref.nlmsg_len;

      final msg = ffi.calloc<msghdr>();

      msg.ref.msg_name = nladdr.cast<ffi.Void>();
      msg.ref.msg_namelen = ffi.sizeOf<sockaddr_nl>();
      msg.ref.msg_iov = iov;
      msg.ref.msg_iovlen = 1;

      const bufLen = 16384;
      final buf = ffi.calloc<ffi.Uint8>(bufLen);

      // Could be unneccessary
      nl.ref.nlmsg_seq = 0;
      nl.ref.nlmsg_flags |= NLM_F_ACK;

      try {
        var ok = libc.sendmsg(netlinkFd, msg, 0);
        if (ok < 0) {
          throw LinuxError('Error sending message to rtnetlink.', 'sendmsg', libc.errno);
        }

        iov.ref.iov_base = buf.cast<ffi.Void>();
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
              if (nh.ref.nlmsg_len < NLMSG_SPACE(ffi.sizeOf<nlmsgerr>())) {
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
        ffi.calloc.free(nladdr);
        ffi.calloc.free(iov);
        ffi.calloc.free(msg);
        ffi.calloc.free(buf);
      }
    } finally {
      ffi.calloc.free(nl);
    }
  }

  void sendDumpRequest(int netlinkFd, int interfaceIndex, int family, int type) {
    assert(openFds.contains(netlinkFd));

    final nl = ffi.calloc.allocate<nlmsghdr>(NLMSG_SPACE(ffi.sizeOf<ifinfomsg>()));

    nl.ref.nlmsg_len = NLMSG_LENGTH(ffi.sizeOf<ifinfomsg>());
    nl.ref.nlmsg_type = type;
    nl.ref.nlmsg_flags = NLM_F_REQUEST;
    nl.ref.nlmsg_pid = 0;
    nl.ref.nlmsg_seq = 0;

    final ifi = NLMSG_DATA<ifinfomsg>(nl);

    ifi.ref.ifi_family = family;
    ifi.ref.ifi_index = interfaceIndex;

    try {
      final ok = libc.send(netlinkFd, nl.cast<ffi.Void>(), nl.ref.nlmsg_len, 0);

      if (ok < 0) {
        throw LinuxError('Could not send info request to RTNETLINK.', 'send', libc.errno);
      }
    } finally {
      ffi.calloc.free(nl);
    }
  }
}
