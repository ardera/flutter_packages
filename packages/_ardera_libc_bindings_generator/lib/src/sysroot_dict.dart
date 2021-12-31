import 'dart:convert';

import 'target_arch.dart';
import 'target_platform.dart';
import 'util.dart';

const _urlPrefix = 'https://commondatastorage.googleapis.com';
const _urlPath = 'chrome-linux-sysroot/toolchain';

class SysrootDictEntry {
  const SysrootDictEntry(this.sha1sum, this.sysrootDir, this.tarball);

  final String sha1sum;
  final String sysrootDir;
  final String tarball;

  Uri get tarballUri => Uri.parse('$_urlPrefix/$_urlPath/$sha1sum/$tarball');
}

class SysrootDict {
  static final instance = SysrootDict();

  late final _chromiumSysrootDictUri = Uri.parse(
    'https://chromium.googlesource.com/chromium/src/build/+/master/linux/sysroot_scripts/sysroots.json?format=TEXT',
  );

  late final Uri _dartSysrootDictUri = Uri.parse(
    'https://raw.githubusercontent.com/dart-lang/sdk/master/build/linux/sysroot_scripts/sysroots.json',
  );

  Future<Map<String, dynamic>> get _json async {
    final chromiumJsonString =
        await httpGetString(_chromiumSysrootDictUri, base64: true);
    final dartJsonString = await httpGetString(_dartSysrootDictUri);

    final chromiumJson = jsonDecode(chromiumJsonString);
    final dartJson = jsonDecode(dartJsonString);

    return Map<String, dynamic>.from(chromiumJson as Map)
      ..addAll((dartJson as Map).cast<String, dynamic>());
  }

  Future<SysrootDictEntry> lookupForTarget({
    required TargetArch arch,
    TargetPlatform platform = TargetPlatform.sid,
  }) async {
    final json = await _json;
    final element = json['${platform.name}_${arch.name}'];

    return SysrootDictEntry(
      element['Sha1Sum'],
      element['SysrootDir'],
      element['Tarball'],
    );
  }
}
