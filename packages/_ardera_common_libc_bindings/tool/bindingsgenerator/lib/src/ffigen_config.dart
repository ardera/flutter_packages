import 'dart:io';

import 'target_arch.dart';
import 'util.dart';

List<String> getHeaderEntryPointsForSearchPath(List<String> entryPoints, Directory searchPath) {
  return [
    for (final entryPoint in entryPoints) searchPath.childFile(entryPoint).path,
  ];
}

List<String> getHeaderEntryPointsForSearchPaths(List<String> entryPoints, List<Directory> searchPaths) {
  return [for (final searchPath in searchPaths) ...getHeaderEntryPointsForSearchPath(entryPoints, searchPath)];
}

List<Directory> getIncludeSearchPaths(Directory sysroot, TargetArch arch) {
  //final usr = sysroot.childDir('usr');

  // final usrLib = sysroot.childDir('lib');
  // final usrLibGcc = usrLib.childDir('gcc');
  // final usrLibGccTarget = usrLibGcc.childDir(arch.gccDirName);
  // final usrLibGccTargetVersion = usrLibGccTarget.childDir('10');
  // final usrLibGccTargetVersionInclude = usrLibGccTargetVersion.childDir('include');
  // final usrLibGccTargetVersionIncludeFixed = usrLibGccTargetVersion.childDir('include-fixed');

  final usrInclude = sysroot.childDir('include');
  // final usrIncludeTarget = usrInclude.childDir(arch.targetTriple);

  return [
    // usrLibGccTargetVersionInclude,
    // usr.childDir('local').childDir('include'),
    // usrLibGccTargetVersionIncludeFixed,
    // usrIncludeTarget,
    usrInclude
  ];
}

List<String> getClangIncludeDirectives(List<Directory> searchPaths) {
  return searchPaths.map((p) => '-I${p.path}').toList();
}
