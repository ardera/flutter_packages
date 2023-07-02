// ignore_for_file: no_leading_underscores_for_local_identifiers, non_constant_identifier_names

import 'dart:ffi' as ffi;

import 'package:_ardera_common_libc_bindings/src/libc_arm.g.dart' as backend show LibCArm;
import 'package:_ardera_common_libc_bindings/src/libc_arm.g.dart' as arm;
import 'package:_ardera_common_libc_bindings/src/libc_arm64.g.dart' as backend show LibCArm64;
import 'package:_ardera_common_libc_bindings/src/libc_arm64.g.dart' as arm64;
import 'package:_ardera_common_libc_bindings/src/libc_i386.g.dart' as backend show LibCI386;
import 'package:_ardera_common_libc_bindings/src/libc_i386.g.dart' as i386;
import 'package:_ardera_common_libc_bindings/src/libc_amd64.g.dart' as backend show LibCAmd64;
import 'package:_ardera_common_libc_bindings/src/libc_amd64.g.dart' as amd64;

import 'package:_ardera_common_libc_bindings/src/libc_structs.dart'
    show epoll_event, termios, sockaddr, if_nameindex, msghdr;

typedef SymbolLookupFn = ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName);

class LibCArm extends LibC {
  final backend.LibCArm _backend;

  LibCArm.fromLookup(SymbolLookupFn _lookup)
      : _backend = backend.LibCArm.fromLookup(_lookup),
        super._fromLookup(_lookup);

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
  int eventfd(int __count, int __flags) {
    return _backend.eventfd(__count, __flags);
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
  int send(int __fd, ffi.Pointer<ffi.Void> __buf, int __n, int __flags) {
    return _backend.send(__fd, __buf, __n, __flags);
  }

  @override
  int sendmsg(
    int __fd,
    ffi.Pointer<msghdr> __message,
    int __flags,
  ) {
    return _backend.sendmsg(
      __fd,
      __message.cast<arm.msghdr>(),
      __flags,
    );
  }

  @override
  int recvmsg(
    int __fd,
    ffi.Pointer<msghdr> __message,
    int __flags,
  ) {
    return _backend.recvmsg(
      __fd,
      __message.cast<arm.msghdr>(),
      __flags,
    );
  }

  @override
  int setsockopt(int __fd, int __level, int __optname, ffi.Pointer<ffi.Void> __optval, int __optlen) {
    return _backend.setsockopt(__fd, __level, __optname, __optval, __optlen);
  }

  @override
  int getsockopt(
    int __fd,
    int __level,
    int __optname,
    ffi.Pointer<ffi.Void> __optval,
    ffi.Pointer<ffi.UnsignedInt> __optlen,
  ) {
    return _backend.getsockopt(__fd, __level, __optname, __optval, __optlen);
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
  int eventfd(int __count, int __flags) {
    return _backend.eventfd(__count, __flags);
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
  int send(int __fd, ffi.Pointer<ffi.Void> __buf, int __n, int __flags) {
    return _backend.send(__fd, __buf, __n, __flags);
  }

  @override
  int sendmsg(
    int __fd,
    ffi.Pointer<msghdr> __message,
    int __flags,
  ) {
    return _backend.sendmsg(
      __fd,
      __message.cast<arm64.msghdr>(),
      __flags,
    );
  }

  @override
  int recvmsg(
    int __fd,
    ffi.Pointer<msghdr> __message,
    int __flags,
  ) {
    return _backend.recvmsg(
      __fd,
      __message.cast<arm64.msghdr>(),
      __flags,
    );
  }

  @override
  int setsockopt(int __fd, int __level, int __optname, ffi.Pointer<ffi.Void> __optval, int __optlen) {
    return _backend.setsockopt(__fd, __level, __optname, __optval, __optlen);
  }

  @override
  int getsockopt(
    int __fd,
    int __level,
    int __optname,
    ffi.Pointer<ffi.Void> __optval,
    ffi.Pointer<ffi.UnsignedInt> __optlen,
  ) {
    return _backend.getsockopt(__fd, __level, __optname, __optval, __optlen);
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
  int eventfd(int __count, int __flags) {
    return _backend.eventfd(__count, __flags);
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
  int send(int __fd, ffi.Pointer<ffi.Void> __buf, int __n, int __flags) {
    return _backend.send(__fd, __buf, __n, __flags);
  }

  @override
  int sendmsg(
    int __fd,
    ffi.Pointer<msghdr> __message,
    int __flags,
  ) {
    return _backend.sendmsg(
      __fd,
      __message.cast<i386.msghdr>(),
      __flags,
    );
  }

  @override
  int recvmsg(
    int __fd,
    ffi.Pointer<msghdr> __message,
    int __flags,
  ) {
    return _backend.recvmsg(
      __fd,
      __message.cast<i386.msghdr>(),
      __flags,
    );
  }

  @override
  int setsockopt(int __fd, int __level, int __optname, ffi.Pointer<ffi.Void> __optval, int __optlen) {
    return _backend.setsockopt(__fd, __level, __optname, __optval, __optlen);
  }

  @override
  int getsockopt(
    int __fd,
    int __level,
    int __optname,
    ffi.Pointer<ffi.Void> __optval,
    ffi.Pointer<ffi.UnsignedInt> __optlen,
  ) {
    return _backend.getsockopt(__fd, __level, __optname, __optval, __optlen);
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
  int eventfd(int __count, int __flags) {
    return _backend.eventfd(__count, __flags);
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
  int send(int __fd, ffi.Pointer<ffi.Void> __buf, int __n, int __flags) {
    return _backend.send(__fd, __buf, __n, __flags);
  }

  @override
  int sendmsg(
    int __fd,
    ffi.Pointer<msghdr> __message,
    int __flags,
  ) {
    return _backend.sendmsg(
      __fd,
      __message.cast<amd64.msghdr>(),
      __flags,
    );
  }

  @override
  int recvmsg(
    int __fd,
    ffi.Pointer<msghdr> __message,
    int __flags,
  ) {
    return _backend.recvmsg(
      __fd,
      __message.cast<amd64.msghdr>(),
      __flags,
    );
  }

  @override
  int setsockopt(int __fd, int __level, int __optname, ffi.Pointer<ffi.Void> __optval, int __optlen) {
    return _backend.setsockopt(__fd, __level, __optname, __optval, __optlen);
  }

  @override
  int getsockopt(
    int __fd,
    int __level,
    int __optname,
    ffi.Pointer<ffi.Void> __optval,
    ffi.Pointer<ffi.UnsignedInt> __optlen,
  ) {
    return _backend.getsockopt(__fd, __level, __optname, __optval, __optlen);
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

  int cfgetispeed(ffi.Pointer<termios> __termios_p);

  int cfgetospeed(ffi.Pointer<termios> __termios_p);

  int cfsetispeed(ffi.Pointer<termios> __termios_p, int __speed);

  int cfsetospeed(ffi.Pointer<termios> __termios_p, int __speed);

  int close(int __fd);

  int epoll_create(int __size);

  int epoll_create1(int __flags);

  int epoll_ctl(int __epfd, int __op, int __fd, ffi.Pointer<epoll_event> __event);

  int epoll_wait(int __epfd, ffi.Pointer<epoll_event> __events, int __maxevents, int __timeout);

  int eventfd(int __count, int __flags);

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

  int send(int __fd, ffi.Pointer<ffi.Void> __buf, int __n, int __flags);

  int sendmsg(int __fd, ffi.Pointer<msghdr> __message, int __flags);

  int recvmsg(int __fd, ffi.Pointer<msghdr> __message, int __flags);

  int setsockopt(int __fd, int __level, int __optname, ffi.Pointer<ffi.Void> __optval, int __optlen);

  int getsockopt(
    int __fd,
    int __level,
    int __optname,
    ffi.Pointer<ffi.Void> __optval,
    ffi.Pointer<ffi.UnsignedInt> __optlen,
  );

  int if_nametoindex(ffi.Pointer<ffi.Char> __ifname);

  ffi.Pointer<ffi.Char> if_indextoname(int __ifindex, ffi.Pointer<ffi.Char> __ifname);

  ffi.Pointer<if_nameindex> if_nameindex1();

  void if_freenameindex(ffi.Pointer<if_nameindex> __ptr);

  late final _ioctl_ptrPtr = (() {
    final ptr = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Int, ffi.Size, ffi.Pointer<ffi.Void>)>>('ioctl');
    return ptr;
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
