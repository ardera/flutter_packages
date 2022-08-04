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

List<String> getHeaderEntryPointsForSearchPath(List<String> entryPoints, Directory searchPath) {
  return [
    for (final entryPoint in entryPoints) searchPath.childFile(entryPoint).path,
  ];
}

List<String> getHeaderEntryPointsForSearchPaths(List<String> entryPoints, List<Directory> searchPaths) {
  return [for (final searchPath in searchPaths) ...getHeaderEntryPointsForSearchPath(entryPoints, searchPath)];
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

const leafFunctions = [
  '**',
];

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

const unionIncludes = [];

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

const macroExcludes = [
  // somehow these have different values depending on ABI.
  'O_NOFOLLOW',
  'O_DIRECTORY'
];

const typedefIncludes = [];
