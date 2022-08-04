import 'dart:ffi';

/// The C `size_t` type.
///
/// The [Size] type is a native type, and should not be constructed in
/// Dart code.
/// It occurs only in native type signatures and as annotation on [Struct] and
/// [Union] fields.
@AbiSpecificIntegerMapping({
  Abi.androidArm: Int32(),
  Abi.androidArm64: Int64(),
  Abi.androidIA32: Int32(),
  Abi.androidX64: Int64(),
  Abi.fuchsiaArm64: Int64(),
  Abi.fuchsiaX64: Int64(),
  Abi.iosArm: Int32(),
  Abi.iosArm64: Int64(),
  Abi.iosX64: Int64(),
  Abi.linuxArm: Int32(),
  Abi.linuxArm64: Int64(),
  Abi.linuxIA32: Int32(),
  Abi.linuxX64: Int64(),
  Abi.linuxRiscv32: Int32(),
  Abi.linuxRiscv64: Int64(),
  Abi.macosArm64: Int64(),
  Abi.macosX64: Int64(),
  Abi.windowsArm64: Int64(),
  Abi.windowsIA32: Int32(),
  Abi.windowsX64: Int64(),
})
class SSize extends AbiSpecificInteger {
  const SSize();
}
