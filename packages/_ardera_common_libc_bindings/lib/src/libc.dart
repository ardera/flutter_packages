// ignore_for_file: camel_case_types, non_constant_identifier_names, no_leading_underscores_for_local_identifiers

import 'dart:ffi' as ffi;

import 'package:meta/meta.dart';
import 'package:_ardera_common_libc_bindings/src/libc_arm.g.dart' as backend show LibCArm;
import 'package:_ardera_common_libc_bindings/src/libc_arm.g.dart' as arm;
import 'package:_ardera_common_libc_bindings/src/libc_arm64.g.dart' as backend show LibCArm64;
import 'package:_ardera_common_libc_bindings/src/libc_arm64.g.dart' as arm64;
import 'package:_ardera_common_libc_bindings/src/libc_i386.g.dart' as backend show LibCI386;
import 'package:_ardera_common_libc_bindings/src/libc_i386.g.dart' as i386;
import 'package:_ardera_common_libc_bindings/src/libc_amd64.g.dart' as backend show LibCAmd64;
import 'package:_ardera_common_libc_bindings/src/libc_amd64.g.dart' as amd64;

import 'package:_ardera_common_libc_bindings/src/libc_arm.g.dart'
    show termios, sockaddr, if_nameindex, ifreq, ifmap, can_frame;

export 'package:_ardera_common_libc_bindings/src/libc_arm.g.dart'
    show
        termios,
        spi_ioc_transfer,
        gpiochip_info,
        gpio_v2_line_values,
        gpio_v2_line_attribute,
        gpio_v2_line_config_attribute,
        gpio_v2_line_config,
        gpio_v2_line_info,
        gpio_v2_line_event,
        gpioline_info,
        gpioline_info_changed,
        gpiohandle_request,
        gpiohandle_config,
        gpiohandle_data,
        gpioevent_request,
        gpioevent_data,
        sockaddr,
        ifreq,
        ifmap,
        if_nameindex,
        sockaddr_can,
        sockaddr_nl,
        nlmsghdr,
        ifinfomsg,
        can_bittiming,
        can_bittiming_const,
        can_clock,
        can_state,
        can_berr_counter,
        can_ctrlmode,
        can_device_stats,
        can_frame,
        canfd_frame,
        EPOLL_EVENTS,
        EPOLL_CLOEXEC,
        GPIOLINE_CHANGED_REQUESTED,
        GPIOLINE_CHANGED_RELEASED,
        GPIOLINE_CHANGED_CONFIG,
        IFLA_CAN_UNSPEC,
        IFLA_CAN_BITTIMING,
        IFLA_CAN_BITTIMING_CONST,
        IFLA_CAN_CLOCK,
        IFLA_CAN_STATE,
        IFLA_CAN_CTRLMODE,
        IFLA_CAN_RESTART_MS,
        IFLA_CAN_RESTART,
        IFLA_CAN_BERR_COUNTER,
        IFLA_CAN_DATA_BITTIMING,
        IFLA_CAN_DATA_BITTIMING_CONST,
        IFLA_CAN_TERMINATION,
        IFLA_CAN_TERMINATION_CONST,
        IFLA_CAN_BITRATE_CONST,
        IFLA_CAN_DATA_BITRATE_CONST,
        IFLA_CAN_BITRATE_MAX,
        IFLA_CAN_TDC,
        IFLA_CAN_CTRLMODE_EXT,
        IFLA_CAN_MAX,
        IFLA_CAN_TDC_UNSPEC,
        IFLA_CAN_TDC_TDCV_MIN,
        IFLA_CAN_TDC_TDCV_MAX,
        IFLA_CAN_TDC_TDCO_MIN,
        IFLA_CAN_TDC_TDCO_MAX,
        IFLA_CAN_TDC_TDCF_MIN,
        IFLA_CAN_TDC_TDCF_MAX,
        IFLA_CAN_TDC_TDCV,
        IFLA_CAN_TDC_TDCO,
        IFLA_CAN_TDC_TDCF,
        IFLA_CAN_TDC_MAX,
        IFLA_CAN_CTRLMODE_UNSPEC,
        IFLA_CAN_CTRLMODE_SUPPORTED,
        IFLA_CAN_CTRLMODE_MAX,
        EPERM,
        ENOENT,
        ESRCH,
        EINTR,
        EIO,
        ENXIO,
        E2BIG,
        ENOEXEC,
        EBADF,
        ECHILD,
        EAGAIN,
        ENOMEM,
        EACCES,
        EFAULT,
        ENOTBLK,
        EBUSY,
        EEXIST,
        EXDEV,
        ENODEV,
        ENOTDIR,
        EISDIR,
        EINVAL,
        ENFILE,
        EMFILE,
        ENOTTY,
        ETXTBSY,
        EFBIG,
        ENOSPC,
        ESPIPE,
        EROFS,
        EMLINK,
        EPIPE,
        EDOM,
        ERANGE,
        EDEADLK,
        ENAMETOOLONG,
        ENOLCK,
        ENOSYS,
        ENOTEMPTY,
        ELOOP,
        EWOULDBLOCK,
        ENOMSG,
        EIDRM,
        ECHRNG,
        EL2NSYNC,
        EL3HLT,
        EL3RST,
        ELNRNG,
        EUNATCH,
        ENOCSI,
        EL2HLT,
        EBADE,
        EBADR,
        EXFULL,
        ENOANO,
        EBADRQC,
        EBADSLT,
        EDEADLOCK,
        EBFONT,
        ENOSTR,
        ENODATA,
        ETIME,
        ENOSR,
        ENONET,
        ENOPKG,
        EREMOTE,
        ENOLINK,
        EADV,
        ESRMNT,
        ECOMM,
        EPROTO,
        EMULTIHOP,
        EDOTDOT,
        EBADMSG,
        EOVERFLOW,
        ENOTUNIQ,
        EBADFD,
        EREMCHG,
        ELIBACC,
        ELIBBAD,
        ELIBSCN,
        ELIBMAX,
        ELIBEXEC,
        EILSEQ,
        ERESTART,
        ESTRPIPE,
        EUSERS,
        ENOTSOCK,
        EDESTADDRREQ,
        EMSGSIZE,
        EPROTOTYPE,
        ENOPROTOOPT,
        EPROTONOSUPPORT,
        ESOCKTNOSUPPORT,
        EOPNOTSUPP,
        EPFNOSUPPORT,
        EAFNOSUPPORT,
        EADDRINUSE,
        EADDRNOTAVAIL,
        ENETDOWN,
        ENETUNREACH,
        ENETRESET,
        ECONNABORTED,
        ECONNRESET,
        ENOBUFS,
        EISCONN,
        ENOTCONN,
        ESHUTDOWN,
        ETOOMANYREFS,
        ETIMEDOUT,
        ECONNREFUSED,
        EHOSTDOWN,
        EHOSTUNREACH,
        EALREADY,
        EINPROGRESS,
        ESTALE,
        EUCLEAN,
        ENOTNAM,
        ENAVAIL,
        EISNAM,
        EREMOTEIO,
        EDQUOT,
        ENOMEDIUM,
        EMEDIUMTYPE,
        ECANCELED,
        ENOKEY,
        EKEYEXPIRED,
        EKEYREVOKED,
        EKEYREJECTED,
        EOWNERDEAD,
        ENOTRECOVERABLE,
        ERFKILL,
        EHWPOISON,
        ENOTSUP,
        O_ACCMODE,
        O_RDONLY,
        O_WRONLY,
        O_RDWR,
        O_CREAT,
        O_EXCL,
        O_NOCTTY,
        O_TRUNC,
        O_APPEND,
        O_NONBLOCK,
        O_NDELAY,
        O_SYNC,
        O_FSYNC,
        O_ASYNC,
        O_CLOEXEC,
        O_DSYNC,
        O_RSYNC,
        SIOCADDRT,
        SIOCDELRT,
        SIOCRTMSG,
        SIOCGIFNAME,
        SIOCSIFLINK,
        SIOCGIFCONF,
        SIOCGIFFLAGS,
        SIOCSIFFLAGS,
        SIOCGIFADDR,
        SIOCSIFADDR,
        SIOCGIFDSTADDR,
        SIOCSIFDSTADDR,
        SIOCGIFBRDADDR,
        SIOCSIFBRDADDR,
        SIOCGIFNETMASK,
        SIOCSIFNETMASK,
        SIOCGIFMETRIC,
        SIOCSIFMETRIC,
        SIOCGIFMEM,
        SIOCSIFMEM,
        SIOCGIFMTU,
        SIOCSIFMTU,
        SIOCSIFNAME,
        SIOCSIFHWADDR,
        SIOCGIFENCAP,
        SIOCSIFENCAP,
        SIOCGIFHWADDR,
        SIOCGIFSLAVE,
        SIOCSIFSLAVE,
        SIOCADDMULTI,
        SIOCDELMULTI,
        SIOCGIFINDEX,
        SIOCSIFPFLAGS,
        SIOCGIFPFLAGS,
        SIOCDIFADDR,
        SIOCSIFHWBROADCAST,
        SIOCGIFCOUNT,
        SIOCGIFBR,
        SIOCSIFBR,
        SIOCGIFTXQLEN,
        SIOCSIFTXQLEN,
        SIOCDARP,
        SIOCGARP,
        SIOCSARP,
        SIOCDRARP,
        SIOCGRARP,
        SIOCSRARP,
        SIOCGIFMAP,
        SIOCSIFMAP,
        SIOCADDDLCI,
        SIOCDELDLCI,
        SIOCDEVPRIVATE,
        SIOCPROTOPRIVATE,
        EPOLL_CLOEXEC1,
        EPOLLIN,
        EPOLLPRI,
        EPOLLOUT,
        EPOLLRDNORM,
        EPOLLRDBAND,
        EPOLLWRNORM,
        EPOLLWRBAND,
        EPOLLMSG,
        EPOLLERR,
        EPOLLHUP,
        EPOLLRDHUP,
        EPOLLEXCLUSIVE,
        EPOLLWAKEUP,
        EPOLLONESHOT,
        EPOLLET,
        EPOLL_CTL_ADD,
        EPOLL_CTL_DEL,
        EPOLL_CTL_MOD,
        GPIO_MAX_NAME_SIZE,
        GPIO_V2_LINES_MAX,
        GPIO_V2_LINE_NUM_ATTRS_MAX,
        GPIOLINE_FLAG_KERNEL,
        GPIOLINE_FLAG_IS_OUT,
        GPIOLINE_FLAG_ACTIVE_LOW,
        GPIOLINE_FLAG_OPEN_DRAIN,
        GPIOLINE_FLAG_OPEN_SOURCE,
        GPIOLINE_FLAG_BIAS_PULL_UP,
        GPIOLINE_FLAG_BIAS_PULL_DOWN,
        GPIOLINE_FLAG_BIAS_DISABLE,
        GPIOHANDLES_MAX,
        GPIOHANDLE_REQUEST_INPUT,
        GPIOHANDLE_REQUEST_OUTPUT,
        GPIOHANDLE_REQUEST_ACTIVE_LOW,
        GPIOHANDLE_REQUEST_OPEN_DRAIN,
        GPIOHANDLE_REQUEST_OPEN_SOURCE,
        GPIOHANDLE_REQUEST_BIAS_PULL_UP,
        GPIOHANDLE_REQUEST_BIAS_PULL_DOWN,
        GPIOHANDLE_REQUEST_BIAS_DISABLE,
        GPIOEVENT_REQUEST_RISING_EDGE,
        GPIOEVENT_REQUEST_FALLING_EDGE,
        GPIOEVENT_REQUEST_BOTH_EDGES,
        GPIOEVENT_EVENT_RISING_EDGE,
        GPIOEVENT_EVENT_FALLING_EDGE,
        GPIO_GET_CHIPINFO_IOCTL,
        GPIO_GET_LINEINFO_UNWATCH_IOCTL,
        GPIO_V2_GET_LINEINFO_IOCTL,
        GPIO_V2_GET_LINEINFO_WATCH_IOCTL,
        GPIO_V2_GET_LINE_IOCTL,
        GPIO_V2_LINE_SET_CONFIG_IOCTL,
        GPIO_V2_LINE_GET_VALUES_IOCTL,
        GPIO_V2_LINE_SET_VALUES_IOCTL,
        GPIO_GET_LINEINFO_IOCTL,
        GPIO_GET_LINEHANDLE_IOCTL,
        GPIO_GET_LINEEVENT_IOCTL,
        GPIOHANDLE_GET_LINE_VALUES_IOCTL,
        GPIOHANDLE_SET_LINE_VALUES_IOCTL,
        GPIOHANDLE_SET_CONFIG_IOCTL,
        GPIO_GET_LINEINFO_WATCH_IOCTL,
        NCCS,
        VINTR,
        VQUIT,
        VKILL,
        VEOF,
        VTIME,
        VMIN,
        VSTART,
        VSTOP,
        VSUSP,
        VEOL,
        IGNBRK,
        BRKINT,
        IGNPAR,
        PARMRK,
        INPCK,
        ISTRIP,
        INLCR,
        IGNCR,
        ICRNL,
        IXON,
        IXANY,
        IXOFF,
        OPOST,
        ONLCR,
        OCRNL,
        ONOCR,
        ONLRET,
        OFILL,
        OFDEL,
        NLDLY,
        NL0,
        NL1,
        CRDLY,
        CR0,
        CR1,
        CR2,
        CR3,
        TABDLY,
        TAB0,
        TAB1,
        TAB2,
        TAB3,
        BSDLY,
        BS0,
        BS1,
        FFDLY,
        FF0,
        FF1,
        VTDLY,
        VT0,
        VT1,
        B0,
        B50,
        B75,
        B110,
        B134,
        B150,
        B200,
        B300,
        B600,
        B1200,
        B1800,
        B2400,
        B4800,
        B9600,
        B19200,
        B38400,
        EXTA,
        EXTB,
        B57600,
        B115200,
        B230400,
        B460800,
        B500000,
        B576000,
        B921600,
        B1000000,
        B1152000,
        B1500000,
        B2000000,
        B2500000,
        B3000000,
        B3500000,
        B4000000,
        CSIZE,
        CS5,
        CS6,
        CS7,
        CS8,
        CSTOPB,
        CREAD,
        PARENB,
        PARODD,
        HUPCL,
        CLOCAL,
        ISIG,
        ICANON,
        ECHO,
        ECHOE,
        ECHOK,
        ECHONL,
        NOFLSH,
        TOSTOP,
        ECHOCTL,
        ECHOPRT,
        ECHOKE,
        IEXTEN,
        EXTPROC,
        TCOOFF,
        TCOON,
        TCIOFF,
        TCION,
        TCIFLUSH,
        TCOFLUSH,
        TCIOFLUSH,
        TCSANOW,
        TCSADRAIN,
        TCSAFLUSH,
        SPI_CPHA,
        SPI_CPOL,
        SPI_MODE_0,
        SPI_MODE_1,
        SPI_MODE_2,
        SPI_MODE_3,
        SPI_MODE_X_MASK,
        SPI_CS_HIGH,
        SPI_LSB_FIRST,
        SPI_3WIRE,
        SPI_LOOP,
        SPI_NO_CS,
        SPI_READY,
        SPI_TX_DUAL,
        SPI_TX_QUAD,
        SPI_RX_DUAL,
        SPI_RX_QUAD,
        SPI_CS_WORD,
        SPI_TX_OCTAL,
        SPI_RX_OCTAL,
        SPI_3WIRE_HIZ,
        SPI_IOC_MAGIC,
        SPI_IOC_RD_MODE,
        SPI_IOC_WR_MODE,
        SPI_IOC_RD_LSB_FIRST,
        SPI_IOC_WR_LSB_FIRST,
        SPI_IOC_RD_BITS_PER_WORD,
        SPI_IOC_WR_BITS_PER_WORD,
        SPI_IOC_RD_MAX_SPEED_HZ,
        SPI_IOC_WR_MAX_SPEED_HZ,
        SPI_IOC_RD_MODE32,
        SPI_IOC_WR_MODE32,
        SOCK_STREAM,
        SOCK_DGRAM,
        SOCK_RAW,
        SOCK_RDM,
        SOCK_SEQPACKET,
        SOCK_DCCP,
        SOCK_PACKET,
        SOCK_CLOEXEC,
        SOCK_NONBLOCK,
        PF_CAN,
        AF_NETLINK,
        AF_CAN,
        SOL_RAW,
        SOL_DECNET,
        SOL_X25,
        SOL_PACKET,
        SOL_ATM,
        SOL_AAL,
        SOL_IRDA,
        SOL_NETBEUI,
        SOL_LLC,
        SOL_DCCP,
        SOL_NETLINK,
        SOL_TIPC,
        SOL_RXRPC,
        SOL_PPPOL2TP,
        SOL_BLUETOOTH,
        SOL_PNPIPE,
        SOL_RDS,
        SOL_IUCV,
        SOL_CAIF,
        SOL_ALG,
        SOL_NFC,
        SOL_KCM,
        SOL_TLS,
        SOL_XDP,
        SOL_MPTCP,
        SOL_MCTP,
        SOL_SMC,
        SIOCSPGRP,
        SIOCGPGRP,
        SIOCATMARK,
        SIOCGSTAMP_OLD,
        SIOCGSTAMPNS_OLD,
        SOL_SOCKET,
        SO_DEBUG,
        SO_REUSEADDR,
        SO_TYPE,
        SO_ERROR,
        SO_DONTROUTE,
        SO_BROADCAST,
        SO_SNDBUF,
        SO_RCVBUF,
        SO_SNDBUFFORCE,
        SO_RCVBUFFORCE,
        SO_KEEPALIVE,
        SO_OOBINLINE,
        SO_NO_CHECK,
        SO_PRIORITY,
        SO_LINGER,
        SO_BSDCOMPAT,
        SO_REUSEPORT,
        SO_PASSCRED,
        SO_PEERCRED,
        SO_RCVLOWAT,
        SO_SNDLOWAT,
        SO_RCVTIMEO_OLD,
        SO_SNDTIMEO_OLD,
        SO_SECURITY_AUTHENTICATION,
        SO_SECURITY_ENCRYPTION_TRANSPORT,
        SO_SECURITY_ENCRYPTION_NETWORK,
        SO_BINDTODEVICE,
        SO_ATTACH_FILTER,
        SO_DETACH_FILTER,
        SO_GET_FILTER,
        SO_PEERNAME,
        SO_ACCEPTCONN,
        SO_PEERSEC,
        SO_PASSSEC,
        SO_MARK,
        SO_PROTOCOL,
        SO_DOMAIN,
        SO_RXQ_OVFL,
        SO_WIFI_STATUS,
        SO_PEEK_OFF,
        SO_NOFCS,
        SO_LOCK_FILTER,
        SO_SELECT_ERR_QUEUE,
        SO_BUSY_POLL,
        SO_MAX_PACING_RATE,
        SO_BPF_EXTENSIONS,
        SO_INCOMING_CPU,
        SO_ATTACH_BPF,
        SO_DETACH_BPF,
        SO_ATTACH_REUSEPORT_CBPF,
        SO_ATTACH_REUSEPORT_EBPF,
        SO_CNX_ADVICE,
        SO_MEMINFO,
        SO_INCOMING_NAPI_ID,
        SO_COOKIE,
        SO_PEERGROUPS,
        SO_ZEROCOPY,
        SO_TXTIME,
        SO_BINDTOIFINDEX,
        SO_TIMESTAMP_OLD,
        SO_TIMESTAMPNS_OLD,
        SO_TIMESTAMPING_OLD,
        SO_TIMESTAMP_NEW,
        SO_TIMESTAMPNS_NEW,
        SO_TIMESTAMPING_NEW,
        SO_RCVTIMEO_NEW,
        SO_SNDTIMEO_NEW,
        SO_DETACH_REUSEPORT_BPF,
        SO_PREFER_BUSY_POLL,
        SO_BUSY_POLL_BUDGET,
        SO_NETNS_COOKIE,
        SO_BUF_LOCK,
        SO_RESERVE_MEM,
        SO_TXREHASH,
        SO_RCVMARK,
        SO_TIMESTAMP,
        SO_TIMESTAMPNS,
        SO_TIMESTAMPING,
        SO_RCVTIMEO,
        SO_SNDTIMEO,
        IF_NAMESIZE,
        IFNAMSIZ,
        SOCK_SNDBUF_LOCK,
        SOCK_RCVBUF_LOCK,
        SOCK_BUF_LOCK_MASK,
        SOCK_TXREHASH_DEFAULT,
        SOCK_TXREHASH_DISABLED,
        SOCK_TXREHASH_ENABLED,
        CAN_EFF_FLAG,
        CAN_RTR_FLAG,
        CAN_ERR_FLAG,
        CAN_SFF_MASK,
        CAN_EFF_MASK,
        CAN_ERR_MASK,
        CAN_SFF_ID_BITS,
        CAN_EFF_ID_BITS,
        CAN_MAX_DLC,
        CAN_MAX_RAW_DLC,
        CAN_MAX_DLEN,
        CANFD_MAX_DLC,
        CANFD_MAX_DLEN,
        CANFD_BRS,
        CANFD_ESI,
        CANFD_FDF,
        CAN_MTU,
        CANFD_MTU,
        CAN_RAW,
        CAN_BCM,
        CAN_TP16,
        CAN_TP20,
        CAN_MCNET,
        CAN_ISOTP,
        CAN_J1939,
        CAN_NPROTO,
        SOL_CAN_BASE,
        CAN_INV_FILTER,
        CAN_RAW_FILTER_MAX,
        SOL_CAN_RAW,
        NETLINK_ROUTE,
        NETLINK_UNUSED,
        NETLINK_USERSOCK,
        NETLINK_FIREWALL,
        NETLINK_SOCK_DIAG,
        NETLINK_NFLOG,
        NETLINK_XFRM,
        NETLINK_SELINUX,
        NETLINK_ISCSI,
        NETLINK_AUDIT,
        NETLINK_FIB_LOOKUP,
        NETLINK_CONNECTOR,
        NETLINK_NETFILTER,
        NETLINK_IP6_FW,
        NETLINK_DNRTMSG,
        NETLINK_KOBJECT_UEVENT,
        NETLINK_GENERIC,
        NETLINK_SCSITRANSPORT,
        NETLINK_ECRYPTFS,
        NETLINK_RDMA,
        NETLINK_CRYPTO,
        NETLINK_SMC,
        NETLINK_INET_DIAG,
        NETLINK_ADD_MEMBERSHIP,
        NETLINK_DROP_MEMBERSHIP,
        NETLINK_PKTINFO,
        NETLINK_BROADCAST_ERROR,
        NETLINK_NO_ENOBUFS,
        NETLINK_RX_RING,
        NETLINK_TX_RING,
        NETLINK_LISTEN_ALL_NSID,
        NETLINK_LIST_MEMBERSHIPS,
        NETLINK_CAP_ACK,
        NETLINK_EXT_ACK,
        NETLINK_GET_STRICT_CHK,
        CAN_CTRLMODE_LOOPBACK,
        CAN_CTRLMODE_LISTENONLY,
        CAN_CTRLMODE_3_SAMPLES,
        CAN_CTRLMODE_ONE_SHOT,
        CAN_CTRLMODE_BERR_REPORTING,
        CAN_CTRLMODE_FD,
        CAN_CTRLMODE_PRESUME_ACK,
        CAN_CTRLMODE_FD_NON_ISO,
        CAN_CTRLMODE_CC_LEN8_DLC,
        CAN_CTRLMODE_TDC_AUTO,
        CAN_CTRLMODE_TDC_MANUAL,
        CAN_TERMINATION_DISABLED;

typedef SymbolLookupFn = ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName);

class LibCArm extends LibC {
  final backend.LibCArm _backend;

  LibCArm.fromLookup(SymbolLookupFn _lookup)
      : _backend = backend.LibCArm.fromLookup(_lookup),
        super._fromLookup(_lookup);

  @override
  get addresses => throw UnimplementedError();

  @override
  int bind(int __fd, ffi.Pointer<sockaddr> __addr, int __len) {
    return _backend.bind(__fd, __addr.cast<arm.sockaddr>(), __len);
  }

  @override
  int getsockname(
    int __fd,
    ffi.Pointer<sockaddr> __addr,
    ffi.Pointer<ffi.UnsignedInt> __len,
  ) {
    return _backend.getsockname(
      __fd,
      __addr.cast<arm.sockaddr>(),
      __len,
    );
  }

  @override
  int cfgetispeed(ffi.Pointer<termios> __termios_p) {
    return _backend.cfgetispeed(__termios_p.cast<arm.termios>());
  }

  @override
  int cfgetospeed(ffi.Pointer<termios> __termios_p) {
    return _backend.cfgetospeed(__termios_p.cast<arm.termios>());
  }

  @override
  int cfsetispeed(ffi.Pointer<termios> __termios_p, int __speed) {
    return _backend.cfsetispeed(__termios_p.cast<arm.termios>(), __speed);
  }

  @override
  int cfsetospeed(ffi.Pointer<termios> __termios_p, int __speed) {
    return _backend.cfsetospeed(__termios_p.cast<arm.termios>(), __speed);
  }

  @override
  int close(int __fd) {
    return _backend.close(__fd);
  }

  @override
  int epoll_create(int __size) {
    return _backend.epoll_create(__size);
  }

  @override
  int epoll_create1(int __flags) {
    return _backend.epoll_create1(__flags);
  }

  @override
  int epoll_ctl(int __epfd, int __op, int __fd, ffi.Pointer<epoll_event> __event) {
    return _backend.epoll_ctl(__epfd, __op, __fd, __event.cast<arm.epoll_event>());
  }

  @override
  int epoll_wait(int __epfd, ffi.Pointer<epoll_event> __events, int __maxevents, int __timeout) {
    return _backend.epoll_wait(__epfd, __events.cast<arm.epoll_event>(), __maxevents, __timeout);
  }

  @override
  void if_freenameindex(ffi.Pointer<if_nameindex> __ptr) {
    return _backend.if_freenameindex(__ptr.cast<arm.if_nameindex>());
  }

  @override
  ffi.Pointer<ffi.Char> if_indextoname(int __ifindex, ffi.Pointer<ffi.Char> __ifname) {
    return _backend.if_indextoname(__ifindex, __ifname);
  }

  @override
  ffi.Pointer<if_nameindex> if_nameindex1() {
    return _backend.if_nameindex1().cast<if_nameindex>();
  }

  @override
  int if_nametoindex(ffi.Pointer<ffi.Char> __ifname) {
    return _backend.if_nametoindex(__ifname);
  }

  @override
  int ioctl(int __fd, int __request) {
    return _backend.ioctl(__fd, __request);
  }

  @override
  int open(ffi.Pointer<ffi.Char> __file, int __oflag) {
    return _backend.open(__file, __oflag);
  }

  @override
  int read(int __fd, ffi.Pointer<ffi.Void> __buf, int __nbytes) {
    return _backend.read(__fd, __buf, __nbytes);
  }

  @override
  int write(int __fd, ffi.Pointer<ffi.Void> __buf, int __n) {
    return _backend.write(__fd, __buf, __n);
  }

  @override
  int setsockopt(int __fd, int __level, int __optname, ffi.Pointer<ffi.Void> __optval, int __optlen) {
    return _backend.setsockopt(__fd, __level, __optname, __optval, __optlen);
  }

  @override
  int socket(int __domain, int __type, int __protocol) {
    return _backend.socket(__domain, __type, __protocol);
  }

  @override
  int tcdrain(int __fd) {
    return _backend.tcdrain(__fd);
  }

  @override
  int tcflow(int __fd, int __action) {
    return _backend.tcflow(__fd, __action);
  }

  @override
  int tcflush(int __fd, int __queue_selector) {
    return _backend.tcflush(__fd, __queue_selector);
  }

  @override
  int tcgetattr(int __fd, ffi.Pointer<termios> __termios_p) {
    return _backend.tcgetattr(__fd, __termios_p.cast<arm.termios>());
  }

  @override
  int tcgetsid(int __fd) {
    return _backend.tcgetsid(__fd);
  }

  @override
  int tcsendbreak(int __fd, int __duration) {
    return _backend.tcsendbreak(__fd, __duration);
  }

  @override
  int tcsetattr(int __fd, int __optional_actions, ffi.Pointer<termios> __termios_p) {
    return _backend.tcsetattr(__fd, __optional_actions, __termios_p.cast<arm.termios>());
  }
}

class LibCArm64 extends LibC {
  final backend.LibCArm64 _backend;

  LibCArm64.fromLookup(SymbolLookupFn _lookup)
      : _backend = backend.LibCArm64.fromLookup(_lookup),
        super._fromLookup(_lookup);

  @override
  get addresses => throw UnimplementedError();

  @override
  int bind(int __fd, ffi.Pointer<sockaddr> __addr, int __len) {
    return _backend.bind(__fd, __addr.cast<arm64.sockaddr>(), __len);
  }

  @override
  int getsockname(
    int __fd,
    ffi.Pointer<sockaddr> __addr,
    ffi.Pointer<ffi.UnsignedInt> __len,
  ) {
    return _backend.getsockname(
      __fd,
      __addr.cast<arm64.sockaddr>(),
      __len,
    );
  }

  @override
  int cfgetispeed(ffi.Pointer<termios> __termios_p) {
    return _backend.cfgetispeed(__termios_p.cast<arm64.termios>());
  }

  @override
  int cfgetospeed(ffi.Pointer<termios> __termios_p) {
    return _backend.cfgetospeed(__termios_p.cast<arm64.termios>());
  }

  @override
  int cfsetispeed(ffi.Pointer<termios> __termios_p, int __speed) {
    return _backend.cfsetispeed(__termios_p.cast<arm64.termios>(), __speed);
  }

  @override
  int cfsetospeed(ffi.Pointer<termios> __termios_p, int __speed) {
    return _backend.cfsetospeed(__termios_p.cast<arm64.termios>(), __speed);
  }

  @override
  int close(int __fd) {
    return _backend.close(__fd);
  }

  @override
  int epoll_create(int __size) {
    return _backend.epoll_create(__size);
  }

  @override
  int epoll_create1(int __flags) {
    return _backend.epoll_create1(__flags);
  }

  @override
  int epoll_ctl(int __epfd, int __op, int __fd, ffi.Pointer<epoll_event> __event) {
    return _backend.epoll_ctl(__epfd, __op, __fd, __event.cast<arm64.epoll_event>());
  }

  @override
  int epoll_wait(int __epfd, ffi.Pointer<epoll_event> __events, int __maxevents, int __timeout) {
    return _backend.epoll_wait(__epfd, __events.cast<arm64.epoll_event>(), __maxevents, __timeout);
  }

  @override
  void if_freenameindex(ffi.Pointer<if_nameindex> __ptr) {
    return _backend.if_freenameindex(__ptr.cast<arm64.if_nameindex>());
  }

  @override
  ffi.Pointer<ffi.Char> if_indextoname(int __ifindex, ffi.Pointer<ffi.Char> __ifname) {
    return _backend.if_indextoname(__ifindex, __ifname);
  }

  @override
  ffi.Pointer<if_nameindex> if_nameindex1() {
    return _backend.if_nameindex1().cast<if_nameindex>();
  }

  @override
  int if_nametoindex(ffi.Pointer<ffi.Char> __ifname) {
    return _backend.if_nametoindex(__ifname);
  }

  @override
  int ioctl(int __fd, int __request) {
    return _backend.ioctl(__fd, __request);
  }

  @override
  int open(ffi.Pointer<ffi.Char> __file, int __oflag) {
    return _backend.open(__file, __oflag);
  }

  @override
  int read(int __fd, ffi.Pointer<ffi.Void> __buf, int __nbytes) {
    return _backend.read(__fd, __buf, __nbytes);
  }

  @override
  int write(int __fd, ffi.Pointer<ffi.Void> __buf, int __n) {
    return _backend.write(__fd, __buf, __n);
  }

  @override
  int setsockopt(int __fd, int __level, int __optname, ffi.Pointer<ffi.Void> __optval, int __optlen) {
    return _backend.setsockopt(__fd, __level, __optname, __optval, __optlen);
  }

  @override
  int socket(int __domain, int __type, int __protocol) {
    return _backend.socket(__domain, __type, __protocol);
  }

  @override
  int tcdrain(int __fd) {
    return _backend.tcdrain(__fd);
  }

  @override
  int tcflow(int __fd, int __action) {
    return _backend.tcflow(__fd, __action);
  }

  @override
  int tcflush(int __fd, int __queue_selector) {
    return _backend.tcflush(__fd, __queue_selector);
  }

  @override
  int tcgetattr(int __fd, ffi.Pointer<termios> __termios_p) {
    return _backend.tcgetattr(__fd, __termios_p.cast<arm64.termios>());
  }

  @override
  int tcgetsid(int __fd) {
    return _backend.tcgetsid(__fd);
  }

  @override
  int tcsendbreak(int __fd, int __duration) {
    return _backend.tcsendbreak(__fd, __duration);
  }

  @override
  int tcsetattr(int __fd, int __optional_actions, ffi.Pointer<termios> __termios_p) {
    return _backend.tcsetattr(__fd, __optional_actions, __termios_p.cast<arm64.termios>());
  }
}

class LibCI386 extends LibC {
  final backend.LibCI386 _backend;

  LibCI386.fromLookup(SymbolLookupFn _lookup)
      : _backend = backend.LibCI386.fromLookup(_lookup),
        super._fromLookup(_lookup);

  @override
  get addresses => throw UnimplementedError();

  @override
  int bind(int __fd, ffi.Pointer<sockaddr> __addr, int __len) {
    return _backend.bind(__fd, __addr.cast<i386.sockaddr>(), __len);
  }

  @override
  int getsockname(
    int __fd,
    ffi.Pointer<sockaddr> __addr,
    ffi.Pointer<ffi.UnsignedInt> __len,
  ) {
    return _backend.getsockname(
      __fd,
      __addr.cast<i386.sockaddr>(),
      __len,
    );
  }

  @override
  int cfgetispeed(ffi.Pointer<termios> __termios_p) {
    return _backend.cfgetispeed(__termios_p.cast<i386.termios>());
  }

  @override
  int cfgetospeed(ffi.Pointer<termios> __termios_p) {
    return _backend.cfgetospeed(__termios_p.cast<i386.termios>());
  }

  @override
  int cfsetispeed(ffi.Pointer<termios> __termios_p, int __speed) {
    return _backend.cfsetispeed(__termios_p.cast<i386.termios>(), __speed);
  }

  @override
  int cfsetospeed(ffi.Pointer<termios> __termios_p, int __speed) {
    return _backend.cfsetospeed(__termios_p.cast<i386.termios>(), __speed);
  }

  @override
  int close(int __fd) {
    return _backend.close(__fd);
  }

  @override
  int epoll_create(int __size) {
    return _backend.epoll_create(__size);
  }

  @override
  int epoll_create1(int __flags) {
    return _backend.epoll_create1(__flags);
  }

  @override
  int epoll_ctl(int __epfd, int __op, int __fd, ffi.Pointer<epoll_event> __event) {
    return _backend.epoll_ctl(__epfd, __op, __fd, __event.cast<i386.epoll_event>());
  }

  @override
  int epoll_wait(int __epfd, ffi.Pointer<epoll_event> __events, int __maxevents, int __timeout) {
    return _backend.epoll_wait(__epfd, __events.cast<i386.epoll_event>(), __maxevents, __timeout);
  }

  @override
  void if_freenameindex(ffi.Pointer<if_nameindex> __ptr) {
    return _backend.if_freenameindex(__ptr.cast<i386.if_nameindex>());
  }

  @override
  ffi.Pointer<ffi.Char> if_indextoname(int __ifindex, ffi.Pointer<ffi.Char> __ifname) {
    return _backend.if_indextoname(__ifindex, __ifname);
  }

  @override
  ffi.Pointer<if_nameindex> if_nameindex1() {
    return _backend.if_nameindex1().cast<if_nameindex>();
  }

  @override
  int if_nametoindex(ffi.Pointer<ffi.Char> __ifname) {
    return _backend.if_nametoindex(__ifname);
  }

  @override
  int ioctl(int __fd, int __request) {
    return _backend.ioctl(__fd, __request);
  }

  @override
  int open(ffi.Pointer<ffi.Char> __file, int __oflag) {
    return _backend.open(__file, __oflag);
  }

  @override
  int read(int __fd, ffi.Pointer<ffi.Void> __buf, int __nbytes) {
    return _backend.read(__fd, __buf, __nbytes);
  }

  @override
  int write(int __fd, ffi.Pointer<ffi.Void> __buf, int __n) {
    return _backend.write(__fd, __buf, __n);
  }

  @override
  int setsockopt(int __fd, int __level, int __optname, ffi.Pointer<ffi.Void> __optval, int __optlen) {
    return _backend.setsockopt(__fd, __level, __optname, __optval, __optlen);
  }

  @override
  int socket(int __domain, int __type, int __protocol) {
    return _backend.socket(__domain, __type, __protocol);
  }

  @override
  int tcdrain(int __fd) {
    return _backend.tcdrain(__fd);
  }

  @override
  int tcflow(int __fd, int __action) {
    return _backend.tcflow(__fd, __action);
  }

  @override
  int tcflush(int __fd, int __queue_selector) {
    return _backend.tcflush(__fd, __queue_selector);
  }

  @override
  int tcgetattr(int __fd, ffi.Pointer<termios> __termios_p) {
    return _backend.tcgetattr(__fd, __termios_p.cast<i386.termios>());
  }

  @override
  int tcgetsid(int __fd) {
    return _backend.tcgetsid(__fd);
  }

  @override
  int tcsendbreak(int __fd, int __duration) {
    return _backend.tcsendbreak(__fd, __duration);
  }

  @override
  int tcsetattr(int __fd, int __optional_actions, ffi.Pointer<termios> __termios_p) {
    return _backend.tcsetattr(__fd, __optional_actions, __termios_p.cast<i386.termios>());
  }
}

class LibCAmd64 extends LibC {
  final backend.LibCAmd64 _backend;

  LibCAmd64.fromLookup(SymbolLookupFn _lookup)
      : _backend = backend.LibCAmd64.fromLookup(_lookup),
        super._fromLookup(_lookup);

  @override
  get addresses => throw UnimplementedError();

  @override
  int bind(int __fd, ffi.Pointer<sockaddr> __addr, int __len) {
    return _backend.bind(__fd, __addr.cast<amd64.sockaddr>(), __len);
  }

  @override
  int getsockname(
    int __fd,
    ffi.Pointer<sockaddr> __addr,
    ffi.Pointer<ffi.UnsignedInt> __len,
  ) {
    return _backend.getsockname(
      __fd,
      __addr.cast<amd64.sockaddr>(),
      __len,
    );
  }

  @override
  int cfgetispeed(ffi.Pointer<termios> __termios_p) {
    return _backend.cfgetispeed(__termios_p.cast<amd64.termios>());
  }

  @override
  int cfgetospeed(ffi.Pointer<termios> __termios_p) {
    return _backend.cfgetospeed(__termios_p.cast<amd64.termios>());
  }

  @override
  int cfsetispeed(ffi.Pointer<termios> __termios_p, int __speed) {
    return _backend.cfsetispeed(__termios_p.cast<amd64.termios>(), __speed);
  }

  @override
  int cfsetospeed(ffi.Pointer<termios> __termios_p, int __speed) {
    return _backend.cfsetospeed(__termios_p.cast<amd64.termios>(), __speed);
  }

  @override
  int close(int __fd) {
    return _backend.close(__fd);
  }

  @override
  int epoll_create(int __size) {
    return _backend.epoll_create(__size);
  }

  @override
  int epoll_create1(int __flags) {
    return _backend.epoll_create1(__flags);
  }

  @override
  int epoll_ctl(int __epfd, int __op, int __fd, ffi.Pointer<epoll_event> __event) {
    return _backend.epoll_ctl(__epfd, __op, __fd, __event.cast<amd64.epoll_event>());
  }

  @override
  int epoll_wait(int __epfd, ffi.Pointer<epoll_event> __events, int __maxevents, int __timeout) {
    return _backend.epoll_wait(__epfd, __events.cast<amd64.epoll_event>(), __maxevents, __timeout);
  }

  @override
  void if_freenameindex(ffi.Pointer<if_nameindex> __ptr) {
    return _backend.if_freenameindex(__ptr.cast<amd64.if_nameindex>());
  }

  @override
  ffi.Pointer<ffi.Char> if_indextoname(int __ifindex, ffi.Pointer<ffi.Char> __ifname) {
    return _backend.if_indextoname(__ifindex, __ifname);
  }

  @override
  ffi.Pointer<if_nameindex> if_nameindex1() {
    return _backend.if_nameindex1().cast<if_nameindex>();
  }

  @override
  int if_nametoindex(ffi.Pointer<ffi.Char> __ifname) {
    return _backend.if_nametoindex(__ifname);
  }

  @override
  int ioctl(int __fd, int __request) {
    return _backend.ioctl(__fd, __request);
  }

  @override
  int open(ffi.Pointer<ffi.Char> __file, int __oflag) {
    return _backend.open(__file, __oflag);
  }

  @override
  int read(int __fd, ffi.Pointer<ffi.Void> __buf, int __nbytes) {
    return _backend.read(__fd, __buf, __nbytes);
  }

  @override
  int write(int __fd, ffi.Pointer<ffi.Void> __buf, int __n) {
    return _backend.write(__fd, __buf, __n);
  }

  @override
  int setsockopt(int __fd, int __level, int __optname, ffi.Pointer<ffi.Void> __optval, int __optlen) {
    return _backend.setsockopt(__fd, __level, __optname, __optval, __optlen);
  }

  @override
  int socket(int __domain, int __type, int __protocol) {
    return _backend.socket(__domain, __type, __protocol);
  }

  @override
  int tcdrain(int __fd) {
    return _backend.tcdrain(__fd);
  }

  @override
  int tcflow(int __fd, int __action) {
    return _backend.tcflow(__fd, __action);
  }

  @override
  int tcflush(int __fd, int __queue_selector) {
    return _backend.tcflush(__fd, __queue_selector);
  }

  @override
  int tcgetattr(int __fd, ffi.Pointer<termios> __termios_p) {
    return _backend.tcgetattr(__fd, __termios_p.cast<amd64.termios>());
  }

  @override
  int tcgetsid(int __fd) {
    return _backend.tcgetsid(__fd);
  }

  @override
  int tcsendbreak(int __fd, int __duration) {
    return _backend.tcsendbreak(__fd, __duration);
  }

  @override
  int tcsetattr(int __fd, int __optional_actions, ffi.Pointer<termios> __termios_p) {
    return _backend.tcsetattr(__fd, __optional_actions, __termios_p.cast<amd64.termios>());
  }
}

abstract class LibC {
  final SymbolLookupFn _lookup;

  LibC._fromLookup(this._lookup);

  factory LibC(ffi.DynamicLibrary dynamicLibrary) {
    return LibC.fromLookup(dynamicLibrary.lookup);
  }

  factory LibC.fromLookup(SymbolLookupFn lookup) {
    final abi = ffi.Abi.current();

    if (abi == ffi.Abi.linuxArm) {
      return LibCArm.fromLookup(lookup);
    } else if (abi == ffi.Abi.linuxArm64) {
      return LibCArm64.fromLookup(lookup);
    } else if (abi == ffi.Abi.linuxIA32) {
      return LibCI386.fromLookup(lookup);
    } else if (abi == ffi.Abi.linuxX64) {
      return LibCAmd64.fromLookup(lookup);
    } else {
      throw UnsupportedError(
          'LibC bindings are only support on linux arm, arm64, i386 and x64, but the current ABI is: ${ffi.Abi.current()}');
    }
  }

  dynamic get addresses;

  int cfgetispeed(ffi.Pointer<termios> __termios_p);

  int cfgetospeed(ffi.Pointer<termios> __termios_p);

  int cfsetispeed(ffi.Pointer<termios> __termios_p, int __speed);

  int cfsetospeed(ffi.Pointer<termios> __termios_p, int __speed);

  int close(int __fd);

  int epoll_create(int __size);

  int epoll_create1(int __flags);

  int epoll_ctl(int __epfd, int __op, int __fd, ffi.Pointer<epoll_event> __event);

  int epoll_wait(int __epfd, ffi.Pointer<epoll_event> __events, int __maxevents, int __timeout);

  int ioctl(int __fd, int __request);

  int open(ffi.Pointer<ffi.Char> __file, int __oflag);

  int read(int __fd, ffi.Pointer<ffi.Void> __buf, int __nbytes);

  int write(int __fd, ffi.Pointer<ffi.Void> __buf, int __n);

  int tcdrain(int __fd);

  int tcflow(int __fd, int __action);

  int tcflush(int __fd, int __queue_selector);

  int tcgetattr(int __fd, ffi.Pointer<termios> __termios_p);

  int tcgetsid(int __fd);

  int tcsendbreak(int __fd, int __duration);

  int tcsetattr(int __fd, int __optional_actions, ffi.Pointer<termios> __termios_p);

  int socket(int __domain, int __type, int __protocol);

  int bind(int __fd, ffi.Pointer<sockaddr> __addr, int __len);

  int getsockname(int __fd, ffi.Pointer<sockaddr> __addr, ffi.Pointer<ffi.UnsignedInt> __len);

  int setsockopt(int __fd, int __level, int __optname, ffi.Pointer<ffi.Void> __optval, int __optlen);

  int if_nametoindex(ffi.Pointer<ffi.Char> __ifname);

  ffi.Pointer<ffi.Char> if_indextoname(int __ifindex, ffi.Pointer<ffi.Char> __ifname);

  ffi.Pointer<if_nameindex> if_nameindex1();

  void if_freenameindex(ffi.Pointer<if_nameindex> __ptr);

  late final _ioctl_ptrPtr = (() {
    final ffi.Pointer ptr = addresses.ioctl;
    return ptr.cast<ffi.NativeFunction<ffi.Int Function(ffi.Int, ffi.Size, ffi.Pointer<ffi.Void>)>>();
  })();

  late final _ioctl_ptr = _ioctl_ptrPtr.asFunction<int Function(int, int, ffi.Pointer<ffi.Void>)>(isLeaf: true);

  int ioctlPtr(
    int fd,
    int request,
    ffi.Pointer ptr,
  ) {
    return _ioctl_ptr(fd, request, ptr.cast<ffi.Void>());
  }

  late final ffi.Pointer<ffi.NativeFunction<ffi.Pointer<ffi.Int32> Function()>> errno_location_addr = (() {
    ffi.Pointer<ffi.NativeFunction<ffi.Pointer<ffi.Int32> Function()>>? tryLookup(String name) {
      try {
        return _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Int32> Function()>>(name);
      } on ArgumentError {
        return null;
      }
    }

    ffi.Pointer<ffi.NativeFunction<ffi.Pointer<ffi.Int32> Function()>> throwStateError() {
      throw StateError('Couldn\'t resolve the errno location function.');
    }

    return tryLookup('__errno_location') ??
        tryLookup('__errno') ??
        tryLookup('errno') ??
        tryLookup('_dl_errno') ??
        tryLookup('__libc_errno') ??
        throwStateError();
  })();

  late final _errno_location_ptr = errno_location_addr.asFunction<ffi.Pointer<ffi.Int32> Function()>();

  ffi.Pointer<ffi.Int32> errno_location() {
    return _errno_location_ptr();
  }

  int get errno => errno_location().value;
}

/// Hack to get make epoll_event work with dart FFI.
///
/// epoll_event has __attribute__((packed)) on i386 and amd64, so the struct is 12-bytes large there.
/// on arm 32-bit and 64-bit it's 16-bytes always.
///
/// Let's specify @ffi.Packed(1) unconditionally, but instead of making the first events field a Uint32,
/// we make it a union:
///    union {
///      uint32_t events;
///      uint64_t padding;  // for arm 32-bit and 64-bit
///      uint32_t padding;  // for x86 and x86_64
///    }
///
/// Only thing we need to look out for is the offsets still matching.

@ffi.Packed(1)
class epoll_data extends ffi.Union {
  external ffi.Pointer<ffi.Void> ptr;

  @ffi.Int()
  external int fd;

  @ffi.Uint32()
  external int u32;

  @ffi.Uint64()
  external int u64;
}

@ffi.AbiSpecificIntegerMapping({
  ffi.Abi.androidArm: ffi.Uint64(),
  ffi.Abi.androidArm64: ffi.Uint64(),
  ffi.Abi.androidIA32: ffi.Uint64(),
  ffi.Abi.androidX64: ffi.Uint64(),
  ffi.Abi.fuchsiaArm64: ffi.Uint64(),
  ffi.Abi.fuchsiaX64: ffi.Uint64(),
  ffi.Abi.iosArm: ffi.Uint64(),
  ffi.Abi.iosArm64: ffi.Uint64(),
  ffi.Abi.linuxArm: ffi.Uint64(),
  ffi.Abi.linuxArm64: ffi.Uint64(),
  ffi.Abi.linuxIA32: ffi.Uint32(),
  ffi.Abi.linuxX64: ffi.Uint32(),
  ffi.Abi.linuxRiscv32: ffi.Uint64(),
  ffi.Abi.linuxRiscv64: ffi.Uint64(),
  ffi.Abi.macosArm64: ffi.Uint64(),
  ffi.Abi.macosX64: ffi.Uint64(),
  ffi.Abi.windowsIA32: ffi.Uint64(),
  ffi.Abi.windowsX64: ffi.Uint64(),
})
class epoll_event_align extends ffi.AbiSpecificInteger {
  const epoll_event_align();
}

@ffi.Packed(1)
class epoll_event_align_union extends ffi.Union {
  @ffi.Uint32()
  external int events;

  @epoll_event_align()
  external int align;
}

@ffi.Packed(1)
class epoll_event extends ffi.Struct {
  @visibleForTesting
  external epoll_event_align_union align_hack;

  int get events => align_hack.events;
  set events(int value) => align_hack.events = value;

  external epoll_data data;
}

extension IfreqMacros on ifreq {
  // #define ifr_name	ifr_ifrn.ifrn_name	/* interface name 	*/
  // #define ifr_hwaddr	ifr_ifru.ifru_hwaddr	/* MAC address 		*/
  // #define	ifr_addr	ifr_ifru.ifru_addr	/* address		*/
  // #define	ifr_dstaddr	ifr_ifru.ifru_dstaddr	/* other end of p-p lnk	*/
  // #define	ifr_broadaddr	ifr_ifru.ifru_broadaddr	/* broadcast address	*/
  // #define	ifr_netmask	ifr_ifru.ifru_netmask	/* interface net mask	*/
  // #define	ifr_flags	ifr_ifru.ifru_flags	/* flags		*/
  // #define	ifr_metric	ifr_ifru.ifru_ivalue	/* metric		*/
  // #define	ifr_mtu		ifr_ifru.ifru_mtu	/* mtu			*/
  // #define ifr_map		ifr_ifru.ifru_map	/* device map		*/
  // #define ifr_slave	ifr_ifru.ifru_slave	/* slave device		*/
  // #define	ifr_data	ifr_ifru.ifru_data	/* for use by interface	*/
  // #define ifr_ifindex	ifr_ifru.ifru_ivalue	/* interface index	*/
  // #define ifr_bandwidth	ifr_ifru.ifru_ivalue    /* link bandwidth	*/
  // #define ifr_qlen	ifr_ifru.ifru_ivalue	/* Queue length 	*/
  // #define ifr_newname	ifr_ifru.ifru_newname	/* New name		*/
  // #define ifr_settings	ifr_ifru.ifru_settings	/* Device/proto settings*/

  ffi.Array<ffi.Char> get ifr_name => ifr_ifrn.ifrn_name;

  sockaddr get ifr_hwaddr => ifr_ifru.ifru_hwaddr;

  sockaddr get ifr_addr => ifr_ifru.ifru_addr;

  sockaddr get ifr_dstaddr => ifr_ifru.ifru_dstaddr;

  sockaddr get ifr_broadaddr => ifr_ifru.ifru_broadaddr;

  sockaddr get ifr_netmask => ifr_ifru.ifru_netmask;

  int get ifr_flags => ifr_ifru.ifru_flags;
  set ifr_flags(int value) => ifr_ifru.ifru_flags = value;

  int get ifr_metric => ifr_ifru.ifru_ivalue;
  set ifr_metric(int value) => ifr_ifru.ifru_ivalue = value;

  int get ifr_mtu => ifr_ifru.ifru_ivalue;
  set ifr_mtu(int value) => ifr_ifru.ifru_ivalue = value;

  ifmap get ifr_map => ifr_ifru.ifru_map;

  ffi.Array<ffi.Char> get ifr_slave => ifr_ifru.ifru_slave;

  ffi.Pointer<ffi.Char> get ifr_data => ifr_ifru.ifru_data;

  int get ifr_ifindex => ifr_ifru.ifru_ivalue;
  set ifr_ifindex(int value) => ifr_ifru.ifru_ivalue = value;

  int get ifr_bandwidth => ifr_ifru.ifru_ivalue;
  set ifr_bandwidth(int value) => ifr_ifru.ifru_ivalue = value;

  int get ifr_qlen => ifr_ifru.ifru_ivalue;
  set ifr_qlen(int value) => ifr_ifru.ifru_ivalue = value;

  ffi.Array<ffi.Char> get ifr_newname => ifr_ifru.ifru_newname;

  // get ifr_settings => ifr_ifru.ifru_settings;
}

extension CanFrameUnnamedUnion on can_frame {
  int get len => unnamed.len;
  set len(int value) => unnamed.len = value;
}
