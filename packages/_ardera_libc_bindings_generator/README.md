# _ardera_libc_bindings_generator

Dart package providing a build target for generating some c-bindings.
This package is not stable. I only published it because there's no way
to make [flutter_gpiod](https://pub.dev/packages/flutter_gpiod), [linux_serial](https://pub.dev/packages/linux_serial) and [linux_spidev](https://pub.dev/packages/linux_spidev)
depend on it without publishing to pub.dev. So I don't provide any support at all for any bugs, issues, feature requests, etc.

In case you still want to use it, you can look at the example.
The header files, structs, functions, globals etc to generate bindings for you need to specify in the `build.yaml`.

This package will download some linux sysroots which are used to generate the bindings to `C:\Users\hanne\AppData\Roaming\dart_libc_bindings_generator` or `$XDG_DATA_HOME/dart_libc_bindings_generator`.