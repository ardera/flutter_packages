# dpms

Display power management for supported Linux embedders. Currently supports the
KMS output selected by **flutter-pi with the DPMS FFI bridge**. A desktop Flutter
Linux runner, an older flutter-pi build, a dummy display or an unsupported
platform returns `null` from `Dpms.instance`.

```dart
import 'package:dpms/dpms.dart';

Future<void> sleepDisplay() async {
  final dpms = Dpms.instance;
  if (dpms == null) return;

  try {
    dpms.setMode(PowerMode.off);
    await Future<void>.delayed(const Duration(seconds: 5));
  } finally {
    dpms.setMode(PowerMode.on);
  }
}
```

Only `PowerMode.on` and `PowerMode.off` are exposed. flutter-pi retains the
latest composition while off and presents it when the display is turned on.
`getMode()` returns the last successfully requested mode, initially `on`,
not the state of a monitor's own power button or changes by other processes.

`setMode` is synchronous and may wait for a display modeset. Operations can
throw `DpmsException`, whose `errorCode` is a positive Linux errno; for example,
a temporarily unavailable DRM master can make a request fail. Availability is
resolved lazily once per Dart isolate. A non-null instance indicates support,
not that every subsequent operation will succeed.

The package does not require Flutter itself. Other embedders can implement the
`Dpms` base class, with their own mechanism for obtaining an instance. On web,
including JavaScript and WebAssembly, the default implementation is absent and
`Dpms.instance` is `null`; it does not pretend to switch display power.

## Migration from the previous API

Replace constructing `Dpms()` and calling `isAvailable()` with a nullable
`Dpms.instance` check. The mode names remain `PowerMode.on/off`:

```dart
final dpms = Dpms.instance;
if (dpms == null) {
  // This embedder/output has no DPMS implementation.
  return;
}

try {
  dpms.setMode(PowerMode.off);
} on DpmsException catch (error) {
  print('Could not switch display power: ${error.errorCode}');
}
```

Update flutter-pi and this package together. The new ABI uses
`flutterpi_dpms_is_available`, `flutterpi_dpms_get`, and `flutterpi_dpms_set`;
old `dpms_isAvailable`/`dpms_getProperty`/`dpms_setProperty` symbols are not used.
Its native get result is signed (`0` off, `1` on, negative errno); the set result
is zero on success or a positive errno. The set argument is C `bool`.

See flutter-pi's `docs/DPMS.md` for native implementation details and a
Raspberry Pi 4/5 hardware verification checklist.

## Development

```sh
dart pub get
dart analyze --fatal-infos
dart test
dart compile js example/main.dart -o /tmp/dpms-example.js
dart compile wasm example/main.dart -o /tmp/dpms-example.wasm
```

Linux FFI tests compile a small C fixture with `cc` to check the actual native
calling convention and error values. The optional browser test can be run with
`dart test --platform chrome test/web_test.dart` when Chrome is installed.
These checks do not replace testing screen power on actual Raspberry Pi boards.
