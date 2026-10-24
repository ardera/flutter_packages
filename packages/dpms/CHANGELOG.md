## Unreleased

- Use nullable `Dpms.instance` and a common base class with a flutter-pi backend.
- Bind the signed `flutterpi_dpms_*` ABI and report native errors as `DpmsException`.
- Correctly return `PowerMode.off` from `getMode()`.
- Return no implementation on unsupported platforms, including JavaScript/Wasm.
- Add usage/migration documentation, tests and an example.
