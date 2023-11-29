// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:io';

import 'package:build/build.dart';
import 'package:logging/logging.dart';
import 'package:source_gen/source_gen.dart' show Generator, LibraryReader;
import 'package:yaml/yaml.dart';
import 'package:ffigen/ffigen.dart' as ffigen;
import 'package:ffigen/src/strings.dart' as ffigen;
import 'package:dart_style/dart_style.dart';

import 'target_platform.dart';
import 'ffigen_config.dart';
import 'sysroot_dict.dart';
import 'target_arch.dart';
import 'util.dart';

class LibCPlatformBackend {
  final TargetArch arch;
  final TargetPlatform platform;
  final Directory? sysroot;
  final String? backendFileContents;
  final AssetId? backendFile;
  final LibraryReader? reader;

  const LibCPlatformBackend(
    this.arch,
    this.platform, [
    this.sysroot,
    this.backendFileContents,
    this.backendFile,
    this.reader,
  ]);

  factory LibCPlatformBackend.fromJsonAndPackage(dynamic json, String package) {
    final typedMap = (json as Map).cast<String, dynamic>();

    return LibCPlatformBackend(
      TargetArch.forNameOrAlias(typedMap['arch']),
      TargetPlatform.fromName(typedMap['distro']),
      null,
    );
  }

  LibCPlatformBackend withSysroot(Directory sysroot) {
    return LibCPlatformBackend(
      arch,
      platform,
      sysroot,
    );
  }

  LibCPlatformBackend withBackendFileContents(String contents) {
    return LibCPlatformBackend(
      arch,
      platform,
      sysroot,
      contents,
    );
  }

  LibCPlatformBackend withBackendFile(AssetId backendFile) {
    return LibCPlatformBackend(
      arch,
      platform,
      sysroot,
      backendFileContents,
      backendFile,
    );
  }

  LibCPlatformBackend withLoadedLibrary(LibraryReader lib) {
    return LibCPlatformBackend(
      arch,
      platform,
      sysroot,
      backendFileContents,
      backendFile,
      lib,
    );
  }
}

class LibCPlatformBackendGenerator extends Generator {
  LibCPlatformBackendGenerator({
    required Map<String, dynamic> options,
    required Logger logger,
  })  : this._options = options,
        this._logger = logger;

  static final _kTargetDistro = 'distro';
  static const _kSevenZipCommand = 'sevenZipCommand';
  static const _kWindowsLlvmPath = 'windowsLlvmPath';
  static const _kLinuxLlvmPath = 'linuxLlvmPath';
  static const _kFfigenOptions = 'ffigen-options';
  static const _cacheDirName = 'dart_libc_bindings_generator';

  final Logger _logger;
  final Map<String, dynamic> _options;

  String get _sevenZipCommand => _options[_kSevenZipCommand] as String? ?? '7za';

  String? get _windowsLlvmPath => _options[_kWindowsLlvmPath] as String?;
  String? get _linuxLlvmPath => _options[_kLinuxLlvmPath] as String?;
  String? get _llvmPath {
    if (Platform.isWindows) {
      return _windowsLlvmPath;
    } else if (Platform.isLinux) {
      return _linuxLlvmPath;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  Map<String, dynamic>? get _ffigenOptions => (_options[_kFfigenOptions] as Map?)?.cast<String, dynamic>();

  Future<LibCPlatformBackend> _ensureSysrootInstalled({required LibCPlatformBackend backend}) async {
    final cacheDir = getApplicationSupportDirectory(_cacheDirName);

    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    final entry = await SysrootDict.instance.lookupForTarget(
      arch: backend.arch,
      platform: backend.platform,
    );

    final sysrootDir = cacheDir.childDir(entry.sysrootDir);
    final backendWithSysroot = backend.withSysroot(sysrootDir);

    if (await sysrootDir.exists()) {
      // already installed
      return backendWithSysroot;
    }

    _logger.info('Installing sysroot for ${backend.arch}, ${backend.platform}');
    _logger.info('Downloading ${entry.tarball}...');
    final tarball = cacheDir.childFile(entry.tarball);
    await downloadFile(
      uri: entry.tarballUri,
      dest: tarball,
      logger: _logger,
    );

    _logger.info('Checking SHA1...');
    final sha1Correct = await checkSha1(
      file: tarball,
      sha1sum: entry.sha1sum,
      logger: _logger,
    );
    if (!sha1Correct) {
      await tarball.delete();
      throw Exception('Incorrect sysroot tarball hash.');
    }

    _logger.info('Extracting tarball...');
    await extractTarball(
      tarball: tarball,
      dest: sysrootDir,
      logger: _logger,
      sevenZipCommand: _sevenZipCommand,
    );

    await tarball.delete();

    return backendWithSysroot;
  }

  Future<LibCPlatformBackend> _generatePlatformBackend({
    required LibCPlatformBackend backend,
    required Map<String, dynamic> ffigenOptions,
  }) async {
    final arch = backend.arch;
    final sysroot = backend.sysroot!;
    final searchPaths = getIncludeSearchPaths(sysroot, arch);

    final classname = 'LibCPlatformBackend';

    final headerEntryPoints = getHeaderEntryPointsForSearchPaths(
      ffigenOptions[ffigen.headers][ffigen.entryPoints].cast<String>(),
      searchPaths,
    );

    /// Somehow, ffigen sometimes fails when the paths use `\` seperators
    /// because the globbing library used internally won't accept `\` seperators.
    final headerEntryPointsPosix = headerEntryPoints.map((e) => e.replaceAll(r'\', '/')).toList();

    final config = ffigen.Config.fromYaml(YamlMap.wrap({
      if (_llvmPath != null) ffigen.llvmPath: [_llvmPath],
      ffigen.output: Directory.systemTemp.path,
      ffigen.headers: {
        ffigen.entryPoints: YamlList.wrap(headerEntryPointsPosix),
        if (ffigenOptions[ffigen.headers][ffigen.includeDirectives] != null)
          ffigen.includeDirectives: ffigenOptions[ffigen.headers][ffigen.includeDirectives],
      },
      ffigen.compilerOpts: YamlList.wrap([
        '--target=${arch.targetTriple}',
        ...getClangIncludeDirectives(searchPaths),
        '-nostdinc',
        '-nostdlib',
        if (arch == TargetArch.arm) '-D__ARM_PCS_VFP',
        ...?ffigenOptions[ffigen.compilerOpts]
      ]),
//    ffigen.compilerOptsAuto: {
//      ffigen.macos: {
//        ffigen.includeCStdLib: null,
//      },
//    },
      ffigen.functions: ffigenOptions[ffigen.functions],
//    {
//      ffigen.include: ffigenOptions['functionIncludes'],
//      ffigen.exclude: ffigenOptions[],
//      ffigen.rename: ffigenOptions['functionRenames'],
//      ffigen.symbolAddress: {
//        ffigen.include: ffigenOptions['functionSymbolAddressIncludes'],
//        ffigen.exclude: ffigenOptions['functionSymbolAddressExcldues']
//      },
//      ffigen.exposeFunctionTypedefs: true,
//      ffigen.leafFunctions: {
//        ffigen.include: ffigenOptions['leafFunctionIncludes'],
//        ffigen.exclude: ffigenOptions['leafFunctionExcludes']
//      }
//    },
      ffigen.structs: ffigenOptions[ffigen.structs],
//    ffigen.structs: {
//      ffigen.include: structIncludes,
//      ffigen.exclude: [],
//      ffigen.rename: {},
//      ffigen.memberRename: {},
//      ffigen.symbolAddress: {},
//      ffigen.dependencyOnly: ffigen.fullCompoundDependencies
//       ffigen.structPack:
//    },
      ffigen.unions: ffigenOptions[ffigen.unions],
//    ffigen.unions: {
//      ffigen.include: unionIncludes,
//      ffigen.exclude: [],
//      ffigen.rename: {},
//      ffigen.memberRename: {},
//      ffigen.symbolAddress: {},
//      ffigen.dependencyOnly: ffigen.fullCompoundDependencies
//    },
      ffigen.enums: ffigenOptions[ffigen.enums],
//    ffigen.enums: {
//      ffigen.include: enumIncludes,
//      ffigen.exclude: [],
//      ffigen.rename: enumRenames,
//      ffigen.memberRename: {},
//      ffigen.symbolAddress: {},
//    },
      ffigen.unnamedEnums: ffigenOptions[ffigen.unnamedEnums],
//    ffigen.unnamedEnums: {
//      ffigen.include: unnamedEnumInludes,
//      ffigen.exclude: ['.*'],
//      ffigen.rename: {},
//      ffigen.memberRename: {},
//      ffigen.symbolAddress: {},
//    },
      ffigen.globals: ffigenOptions[ffigen.globals],
//    ffigen.globals: {
//      ffigen.include: [],
//      ffigen.exclude: ['.*'],
//      ffigen.rename: {},
//      ffigen.memberRename: {},
//      ffigen.symbolAddress: {},
//    },
      ffigen.macros: ffigenOptions[ffigen.macros],
//    ffigen.macros: {
//      ffigen.include: macroIncludes,
//      ffigen.exclude: [],
//      ffigen.rename: {},
//      ffigen.memberRename: {},
//      ffigen.symbolAddress: {},
//    },
      ffigen.typedefs: ffigenOptions[ffigen.typedefs],
//    ffigen.typedefs: {
//      ffigen.include: typedefIncludes,
//      ffigen.exclude: [],
//      ffigen.rename: {},
//      ffigen.memberRename: {},
//      ffigen.symbolAddress: {},
//    },
//    ffigen.sizemap_native_mapping: YamlMap.wrap({
//      ffigen.SChar: arch.charSize,
//      ffigen.UChar: arch.unsignedCharSize,
//      ffigen.Short: arch.shortSize,
//      ffigen.UShort: arch.unsignedShortSize,
//      ffigen.Int: arch.intSize,
//      ffigen.UInt: arch.unsignedIntSize,
//      ffigen.Long: arch.longSize,
//      ffigen.ULong: arch.unsignedLongSize,
//      ffigen.LongLong: arch.longLongSize,
//      ffigen.ULongLong: arch.unsignedLongLongSize,
//      ffigen.Enum: arch.enumSize,
//    }),
      ffigen.useSupportedTypedefs: true,
      ffigen.libraryImports: YamlMap.wrap({
        'pkg_ssizet': 'ssize_t.dart',
      }),
      ffigen.typeMap: YamlMap.wrap({
        ffigen.typeMapTypedefs: YamlMap.wrap({
          '__u8': YamlMap.wrap({
            ffigen.lib: 'ffi',
            ffigen.cType: 'Uint8',
            ffigen.dartType: 'int',
          }),
          '__u16': YamlMap.wrap({
            ffigen.lib: 'ffi',
            ffigen.cType: 'Uint16',
            ffigen.dartType: 'int',
          }),
          '__u32': YamlMap.wrap({
            ffigen.lib: 'ffi',
            ffigen.cType: 'Uint32',
            ffigen.dartType: 'int',
          }),
          '__u64': YamlMap.wrap({
            ffigen.lib: 'ffi',
            ffigen.cType: 'Uint64',
            ffigen.dartType: 'int',
          }),
          '__s8': YamlMap.wrap({
            ffigen.lib: 'ffi',
            ffigen.cType: 'Int8',
            ffigen.dartType: 'int',
          }),
          '__s16': YamlMap.wrap({
            ffigen.lib: 'ffi',
            ffigen.cType: 'Int16',
            ffigen.dartType: 'int',
          }),
          '__s32': YamlMap.wrap({
            ffigen.lib: 'ffi',
            ffigen.cType: 'Int32',
            ffigen.dartType: 'int',
          }),
          '__s64': YamlMap.wrap({
            ffigen.lib: 'ffi',
            ffigen.cType: 'Int64',
            ffigen.dartType: 'int',
          }),
          'ssize_t': YamlMap.wrap({
            ffigen.lib: 'pkg_ssizet',
            ffigen.cType: 'SSize',
            ffigen.dartType: 'int',
          }),
        }),
      }),
//    ffigen.typedefmap: {},
      ffigen.sort: false,
//    ffigen.useSupportedTypedefs: true,
//    ffigen.comments: {ffigen.style: 'any', ffigen.length: 'full'},
//    ffigen.dartBool: true,
      ffigen.name: classname,
      ffigen.description: 'libc backend for ${arch.name}',
      ffigen.preamble:
          '// ignore_for_file: constant_identifier_names, non_constant_identifier_names, camel_case_types, unnecessary_brace_in_string_interps, unused_element, no_leading_underscores_for_local_identifiers\n'
//    ffigen.useDartHandle: true,
    }));

    _logger.info('Generating bindings...');
    final library = ffigen.parse(config);

    final contents = library.generate();

    return backend.withBackendFileContents(contents);
  }

  @override
  Future<String> generate(library, buildStep) async {
    print("generating");

    var backend = LibCPlatformBackend(
      TargetArch.forNameOrAlias(
        RegExp(r'_([a-zA-Z0-9]+)\.dart$').allMatches(buildStep.inputId.pathSegments.last).single.group(1)!,
      ),
      TargetPlatform.fromName(_options[_kTargetDistro] as String),
    );

    _logger.info('Installing sysroot for $backend');
    backend = await _ensureSysrootInstalled(backend: backend);

    _logger.info('Generating backend $backend...');
    backend = await _generatePlatformBackend(
      backend: backend,
      ffigenOptions: _ffigenOptions ?? const <String, dynamic>{},
    );

    return DartFormatter().format(backend.backendFileContents!);
  }
}
