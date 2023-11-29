// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'dart:ffi' as ffi;

import 'package:meta/meta.dart';

import 'package:_ardera_common_libc_bindings/src/libc_arm.g.dart' show sockaddr, ifreq, ifmap, can_frame;

export 'libc_arm.g.dart'
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
        nlmsgerr,
        ifinfomsg,
        rtattr,
        iovec,
        msghdr,
        can_bittiming,
        can_bittiming_const,
        can_clock,
        can_state,
        can_berr_counter,
        can_ctrlmode,
        can_device_stats,
        can_frame,
        canfd_frame,
        can_filter,
        EPOLL_EVENTS;

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
