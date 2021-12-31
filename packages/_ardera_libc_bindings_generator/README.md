# _ardera_libc_bindings_generator

Dart package providing a build target for generating some C-bindings.
This package is not stable. I only published it because there's no way
to make [_ardera_common_libc_bindings](https://pub.dev/packages/_ardera_common_libc_bindings) 
depend on it without publishing to pub.dev. So I don't provide any support at all for any bugs, issues, feature requests, etc.

In case you still want to use it, you can look at the example.
The header files, structs, functions, globals etc to generate bindings for you need to specify in the `build.yaml`.

This package will download some linux sysroots which are used to generate the bindings to `C:\Users\hanne\AppData\Roaming\dart_libc_bindings_generator` or `$XDG_DATA_HOME/dart_libc_bindings_generator`.