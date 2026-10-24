import 'dart:ffi' as ffi;
import 'dart:io';

import '../dpms.dart';
import '../power_mode.dart';

typedef _NativeGet = ffi.Int32 Function();
typedef _NativeSet = ffi.Int32 Function(ffi.Bool);

Dpms? createInstance() {
  if (!Platform.isLinux) return null;
  try {
    return FlutterpiDpms.fromLocalProcess();
  } on UnsupportedError {
    return null;
  }
}

/// flutter-pi's signed, errno-based FFI implementation.
final class FlutterpiDpms extends Dpms {
  FlutterpiDpms(this._getMode, this._setMode);

  factory FlutterpiDpms.fromLocalProcess() => FlutterpiDpms.fromLibrary(ffi.DynamicLibrary.process());

  /// Binds the same ABI from a library, also useful for native integration tests.
  factory FlutterpiDpms.fromLibrary(ffi.DynamicLibrary library) {
    try {
      final isAvailable = library.lookupFunction<_NativeGet, int Function()>('flutterpi_dpms_is_available');
      final getMode = library.lookupFunction<_NativeGet, int Function()>('flutterpi_dpms_get');
      final setMode = library.lookupFunction<_NativeSet, int Function(bool)>('flutterpi_dpms_set');
      if (isAvailable() != 1) {
        throw UnsupportedError('The selected flutter-pi output does not support DPMS.');
      }
      return FlutterpiDpms(getMode, setMode);
    } on ArgumentError {
      throw UnsupportedError('The embedder does not provide the flutter-pi DPMS ABI.');
    }
  }

  final int Function() _getMode;
  final int Function(bool) _setMode;

  @override
  void setMode(PowerMode mode) {
    final result = _setMode(mode == PowerMode.on);
    if (result != 0) throw DpmsException('setMode', result.abs());
  }

  @override
  PowerMode getMode() {
    final result = _getMode();
    if (result < 0) throw DpmsException('getMode', -result);
    return switch (result) {
      0 => PowerMode.off,
      1 => PowerMode.on,
      _ => throw StateError('Invalid flutter-pi DPMS mode: $result'),
    };
  }
}
