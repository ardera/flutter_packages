import 'dart:io';

import 'target_arch.dart';
import 'util.dart';

const headerIncludeDirectives = [
  '**ioctl**.h',
  '**types**.h',
  '**stat**.h',
  '**epoll**.h',
  '**errno**.h',
  '**fcntl**.h',
  '**unistd**.h',
  '**termios**.h',
  '**spidev**.h',
  '**gpio**.h',
  //'**socket**.h',
  //'**iovec**.h',
  //'**can**.h',
  //'**error**.h',
  //'**raw**.h',
  //'**if**.h',
];

List<String> getHeaderEntryPointsForSearchPath(Directory searchPath) {
  Directory sys = searchPath.childDir('sys');
  Directory linux = searchPath.childDir('linux');
  //Directory linuxCan = linux.childDir('can');
  Directory linuxSpi = linux.childDir('spi');
  //Directory net = searchPath.childDir('net');

  return [
    // /usr/include headers
    ...[
      'errno.h',
      'fcntl.h',
      'unistd.h',
      'termios.h',
    ].map(searchPath.childFile),

    // /usr/include/sys headers
    ...[
      'ioctl.h',
      'types.h',
      'stat.h',
      'epoll.h',
      //'socket.h',
    ].map(sys.childFile),

    /*
    ...[
      'if.h',
    ].map(net.childFile),
    */

    // /usr/include/linux headers
    ...[
      'gpio.h',
      //'can.h',
    ].map(linux.childFile),

    // /usr/include/linux/can
    /*
    ...[
      'raw.h',
      'error.h',
    ].map(linuxCan.childFile),
    */

    // /usr/include/linux/spi headers
    ...[
      'spidev.h',
    ].map(linuxSpi.childFile),
  ].map((f) => f.path).toList();
}

List<String> getHeaderEntryPointsForSearchPaths(List<Directory> searchPaths) {
  return [for (final searchPath in searchPaths) ...getHeaderEntryPointsForSearchPath(searchPath)];
}

List<Directory> getIncludeSearchPaths(Directory sysroot, TargetArch arch) {
  final usr = sysroot.childDir('usr');
  final usrLib = usr.childDir('lib');
  final usrLibGcc = usrLib.childDir('gcc');
  final usrLibGccTarget = usrLibGcc.childDir(arch.gccDirName);
  final usrLibGccTargetVersion = usrLibGccTarget.childDir('10');
  final usrLibGccTargetVersionInclude = usrLibGccTargetVersion.childDir('include');
  final usrLibGccTargetVersionIncludeFixed = usrLibGccTargetVersion.childDir('include-fixed');

  final usrInclude = usr.childDir('include');
  final usrIncludeTarget = usrInclude.childDir(arch.targetTriple);

  return [
    usrLibGccTargetVersionInclude,
    usr.childDir('local').childDir('include'),
    usrLibGccTargetVersionIncludeFixed,
    usrIncludeTarget,
    usrInclude
  ];
}

List<String> getClangIncludeDirectives(List<Directory> searchPaths) {
  return searchPaths.map((p) => '-I${p.path}').toList();
}

const functionIncludes = [
  // general libc
  'open',
  'read',
  'write',
  'close',
  'ioctl',

  // socket
  /*
  'socket',
  'socketpair',
  'bind',
  'getsockname',
  'connect',
  'getpeername',
  'send',
  'recv',
  'recvfrom',
  'sendmsg',
  'recvmsg',
  'getsockopt',
  'setsockopt',
  'listen',
  'accept',
  'shutdown',
  */

  // epoll
  'epoll_ctl',
  'epoll_create1?',
  'epoll_wait',
  '__errno_location',

  // serial
  'tc[a-z]*',
  'cf[a-z]*',
];

const functionRenames = {
  '__errno_location': 'errno_location',
};

const structIncludes = [
  // serial
  'termios',

  // SPI
  'spi.*',

  // GPIO
  'gpio.*',

  // Socket
  /*
  'sockaddr',
  'sockaddr_storage',
  'msghdr',
  'cmsghdr',
  'linger',
  'iovec',
  'if_nameindex',
  'ifaddr',
  'ifmap',
  'ifreq',
  'ifconf',
  */

  // CAN
  /*
  'can_frame',
  'canfd_frame',
  'sockaddr_can',
  'can_filter'
  */
];

const unnamedEnumInludes = [
  /*
  'SHUT_.*',
  'MSG_.*',
  'SCM_.*',
  'IFF_.*',
  'CAN_.*',
  */
];

const enumIncludes = [
  // general libc
  'EPOLL.*',
  //'SOCK_.*',
  //'__socket_type',
];

const enumRenames = {
  //'__socket_type': 'socket_type',
};

const macroIncludes = [
  // general libc
  'O.*',
  'E.*',
  'EPOLL.*',

  // serial
  'BRKINT',
  'I[A-Z]*',
  'O[A-Z]*',
  '[A-Z]*DLY',
  'C[A-Z0-9]*',
  'PAR[A-Z]*',
  'HUPCL',
  'LOBLK',
  'XCASE',
  'ECHO[A-Z]*',
  'FLUSHO',
  'NOFLSH',
  'TOSTOP',
  'PENDIN',
  'V[A-Z0-9]*',
  'TC[A-Z0-9]*',
  'B[0-9]*',

  // SPI
  'SPI.*',

  // GPIO
  'GPIO.*',

  // socket
  /*
  'PF_.*',
  'AF_.*',
  'SOL_.*',
  'SOMAXCONN',

  'SHUT_.*',
  'MSG_.*',
  'SO_.*',
  'SOCK_.*',
  'SOL_.*',
  */

  // CAN
  /*
  'CAN_.*',
  'CANFD_.*',
  */
];
