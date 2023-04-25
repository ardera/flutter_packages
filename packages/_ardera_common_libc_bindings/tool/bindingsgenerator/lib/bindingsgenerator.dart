import 'dart:io';

import 'package:bindingsgenerator/src/ffigen_config.dart';
import 'package:bindingsgenerator/src/target_arch.dart';
import 'package:dart_style/dart_style.dart';
import 'package:ffigen/ffigen.dart' as ffigen;

// ignore: implementation_imports
import 'package:ffigen/src/strings.dart' as ffigen;
import 'package:yaml/yaml.dart';

Directory getSysrootForArch(TargetArch arch) {
  if (arch == TargetArch.i386) {
    return Directory('/tmp/debian-sid-i686-linux-gnu');
  }

  return Directory('/tmp/debian-sid-${arch.targetTriple}');
}

String generateForArch(TargetArch arch, YamlMap ffigenOptions) {
  final sysroot = getSysrootForArch(arch);
  final searchPaths = getIncludeSearchPaths(sysroot, arch);

  final classname = 'LibC${arch.name.replaceFirstMapped(RegExp('^.'), (match) => match.group(0)!.toUpperCase())}';

  final headerEntryPoints = getHeaderEntryPointsForSearchPaths(
    ffigenOptions[ffigen.headers][ffigen.entryPoints].cast<String>(),
    searchPaths,
  );

  /// Somehow, ffigen sometimes fails when the paths use `\` seperators
  /// because the globbing library used internally won't accept `\` seperators.
  final headerEntryPointsPosix = headerEntryPoints.map((e) => e.replaceAll(r'\', '/')).toList();

  final config = ffigen.Config.fromYaml(YamlMap.wrap({
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
        '// ignore_for_file: constant_identifier_names, non_constant_identifier_names, camel_case_types, unnecessary_brace_in_string_interps, unused_element, no_leading_underscores_for_local_identifiers, unused_field\n'
//    ffigen.useDartHandle: true,
  }));

  final library = ffigen.parse(config);

  final contents = library.generate();

  final formatted = DartFormatter().format(contents);

  return formatted;
}
