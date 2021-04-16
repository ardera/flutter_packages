import 'package:build/build.dart';
import 'package:logging/logging.dart';
import 'package:source_gen/source_gen.dart';

import 'src/libc_bindings_generator.dart';

Builder libcBindingsBuilder(BuilderOptions options) {
  return LibraryBuilder(LibCBindingsGenerator(
    options: options.config,
    logger: Logger.root,
  ));
}

Builder libcPlatformBackendBuilder(BuilderOptions options) {
  print("constructing builder");
  return LibraryBuilder(
    LibCPlatformBackendGenerator(
      options: options.config,
      logger: Logger.root,
    ),
  );
}
