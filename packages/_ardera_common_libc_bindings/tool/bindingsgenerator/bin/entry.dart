import 'dart:io';
import 'package:bindingsgenerator/bindingsgenerator.dart';
import 'package:bindingsgenerator/src/target_arch.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

void main() {
  assert(Platform.script.isScheme('file'));

  // final current = path.current;

  final scriptUri = Platform.script;

  assert(scriptUri.pathSegments.last == 'entry.dart');
  assert(scriptUri.pathSegments[scriptUri.pathSegments.length - 2] == 'bindingsgenerator');
  assert(scriptUri.pathSegments[scriptUri.pathSegments.length - 3] == 'tool');
  assert(scriptUri.pathSegments[scriptUri.pathSegments.length - 4] == '_ardera_common_libc_bindings');

  final script = scriptUri.toFilePath();
  // final dockerfile = path.relative(path.join(script, '../../Dockerfile'));
  // final bindings = path.relative(path.join(script, '../../../..'));
  final bindingsAbsolute = path.normalize(path.join(script, '../../../..'));

  final configFile = File(path.join(bindingsAbsolute, 'bindingsgen.yaml'));

  final configFileContents = configFile.readAsStringSync();

  final yaml = loadYaml(configFileContents, sourceUrl: configFile.uri);
  if (yaml is! YamlMap) {
    throw Exception('Expected YAML config file to be a map, but was: $yaml');
  }

  const archs = [TargetArch.arm, TargetArch.arm64, TargetArch.i386, TargetArch.amd64];

  for (final arch in archs) {
    final fileContents = generateForArch(arch, yaml['ffigen-options']);
    final outputFile = File(path.join(bindingsAbsolute, 'lib', 'src', 'libc_${arch.name}.g.dart'));
    outputFile.writeAsStringSync(fileContents);
  }
}
