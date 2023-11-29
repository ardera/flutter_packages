import 'dart:io';

import 'package:path/path.dart' as path;

Future<void> run(String executable, List<String> arguments) async {
  final result = await Process.start(
    executable,
    arguments,
    mode: ProcessStartMode.inheritStdio,
  );

  final exitCode = await result.exitCode;
  if (exitCode != 0) {
    throw ProcessException(executable, arguments, 'Process exited with exit code', exitCode);
  }
}

void main(List<String> arguments) async {
  assert(Platform.script.isScheme('file'));

  // final current = path.current;

  final scriptUri = Platform.script;

  assert(scriptUri.pathSegments.last == 'bindingsgenerator.dart');
  assert(scriptUri.pathSegments[scriptUri.pathSegments.length - 1] == 'tool');
  assert(scriptUri.pathSegments[scriptUri.pathSegments.length - 2] == '_ardera_common_libc_bindings');

  final script = scriptUri.toFilePath();
  final dockerfile = path.relative(path.join(script, '../Dockerfile'));
  final bindings = path.relative(path.join(script, '../..'));
  final bindingsAbsolute = path.normalize(path.join(script, '../..'));
  print('relative path of bindings library: $bindings');

  await run(
    'docker',
    ['build', '-f', dockerfile, bindings, '--tag=bindingsgen:latest'],
  );

  await run(
    'docker',
    ['run', '-v', '$bindingsAbsolute:/tmp/_ardera_common_libc_bindings_output', '-it', 'bindingsgen:latest'],
  );
}
