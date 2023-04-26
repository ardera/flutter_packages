// ignore_for_file: non_constant_identifier_names

import 'dart:ffi' as ffi;

import 'package:_ardera_common_libc_bindings/src/libc_arm.g.dart'
    show nlmsghdr, rtattr, NLMSG_HDRLEN, NLMSG_ALIGNTO, RTA_ALIGNTO;
import 'package:tuple/tuple.dart';

// dart versions of linux macros for netlink messages.
// See: https://man7.org/linux/man-pages/man3/netlink.3.html

/// Round the length of a netlink message up to align it properly.
int NLMSG_ALIGN(int len) => (len + NLMSG_ALIGNTO - 1) & ~(NLMSG_ALIGNTO - 1);

// final NLMSG_HDRLEN = NLMSG_ALIGN(ffi.sizeOf<nlmsghdr>());

/// Given the payload length [len], this macro returns the aligned length
/// to store in the [nlmsghdr.nlmsg_len] field.
int NLMSG_LENGTH(int len) => len + NLMSG_HDRLEN;

/// Return the number of bytes that a netlink message of with payload length [len] would occupy.
int NLMSG_SPACE(int len) => NLMSG_ALIGN(NLMSG_LENGTH(len));

/// Return a pointer to the payload associated with the passed [nlmsghdr].
ffi.Pointer<T> NLMSG_DATA<T extends ffi.NativeType>(ffi.Pointer<nlmsghdr> nlh) {
  final addr = nlh.address + NLMSG_HDRLEN;
  return ffi.Pointer<T>.fromAddress(addr);
}

Tuple2<ffi.Pointer<nlmsghdr>, int> NLMSG_NEXT(ffi.Pointer<nlmsghdr> nlh, int len) {
  final newLen = len - NLMSG_ALIGN(nlh.ref.nlmsg_len);

  final addr = nlh.address + NLMSG_ALIGN(nlh.ref.nlmsg_len);
  final newNlh = ffi.Pointer<nlmsghdr>.fromAddress(addr);

  return Tuple2(newNlh, newLen);
}

bool NLMSG_OK(ffi.Pointer<nlmsghdr> nlh, int len) {
  return len >= ffi.sizeOf<nlmsghdr>() && nlh.ref.nlmsg_len >= ffi.sizeOf<nlmsghdr>() && nlh.ref.nlmsg_len <= len;
}

int NLMSG_PAYLOAD(ffi.Pointer<nlmsghdr> nlh, int len) {
  return nlh.ref.nlmsg_len - NLMSG_SPACE(len);
}

/// Return a pointer to the first byte after the payload of the passed [nlmsghdr].
ffi.Pointer<T> NLMSG_TAIL<T extends ffi.NativeType>(ffi.Pointer<nlmsghdr> nlh) {
  final addr = nlh.address + NLMSG_ALIGN(nlh.ref.nlmsg_len);
  return ffi.Pointer<T>.fromAddress(addr);
}

// dart versions of linux macros for rtnetlink messages
// See: https://man7.org/linux/man-pages/man3/rtnetlink.3.html

int RTA_ALIGN(int len) => (len + RTA_ALIGNTO - 1) & ~(RTA_ALIGNTO - 1);

bool RTA_OK(ffi.Pointer<rtattr> rta, int len) {
  return len >= ffi.sizeOf<rtattr>() && rta.ref.rta_len >= ffi.sizeOf<rtattr>() && rta.ref.rta_len <= len;
}

Tuple2<ffi.Pointer<rtattr>, int> RTA_NEXT(ffi.Pointer<rtattr> rta, int attrlen) {
  final newAttrlen = attrlen - RTA_ALIGN(rta.ref.rta_len);

  final addr = rta.address + RTA_ALIGN(rta.ref.rta_len);
  final ptr = ffi.Pointer<rtattr>.fromAddress(addr);

  return Tuple2(ptr, newAttrlen);
}

int RTA_LENGTH(int len) => RTA_ALIGN(ffi.sizeOf<rtattr>() + len);

int RTA_SPACE(int len) => RTA_ALIGN(RTA_LENGTH(len));

ffi.Pointer<T> RTA_DATA<T extends ffi.NativeType>(ffi.Pointer<rtattr> rta) {
  final addr = rta.address + RTA_LENGTH(0);
  return ffi.Pointer<T>.fromAddress(addr);
}

int RTA_PAYLOAD(ffi.Pointer<rtattr> rta) => rta.ref.rta_len - RTA_LENGTH(0);
