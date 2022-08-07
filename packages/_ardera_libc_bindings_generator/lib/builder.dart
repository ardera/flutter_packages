import 'package:build/build.dart';
import 'package:logging/logging.dart';
import 'package:source_gen/source_gen.dart';

import 'src/libc_bindings_generator.dart';

Builder libcPlatformBackendBuilder(BuilderOptions options) {
  return LibraryBuilder(
    LibCPlatformBackendGenerator(
      options: options.config,
      logger: Logger.root,
    ),
  );
}
