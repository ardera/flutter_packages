import 'dart:ffi' as ffi;
import 'package:linux_dpms/src/dpms_power_state.dart';

/*
uint32_t dpms_isAvailable();
void dpms_setProperty(uint64_t value);
uint64_t dpms_getProperty();
*/

typedef DpmsGetPropertyFuncType = ffi.Uint64 Function();
typedef DpmsGetPropertyType = int Function();

typedef DpmsSetPropertyFuncType = ffi.Void Function(ffi.Uint64 value);
typedef DpmsSetPropertyType = void Function(int value);

typedef DpmsIsAvailableFuncType = ffi.Uint32 Function();
typedef DpmsIsAvailableType = int Function();

class DpmsLinux {
  final _DpmsLinux _service = _DpmsLinux.instance;
  bool isAvailable() {
    if (_service.dpmsIsAvailable == null || _service.dpmsSetProperty == null) {
      return false;
    }
    return true;
  }

  void setPowerState(DpmsPowerState state) {
    if (_service.dpmsSetProperty != null) {
      _service.dpmsSetProperty!(state.value);
    }
    return;
  }

  DpmsPowerState getPowerState() {
    if (_service.dpmsGetProperty != null) {
      final value = _service.dpmsGetProperty!();
      return DpmsPowerState.values.firstWhere((item) => item.value == value);
    }
    return DpmsPowerState.on;
  }
}

class _DpmsLinux {
  final DpmsIsAvailableType? dpmsIsAvailable;
  final DpmsGetPropertyType? dpmsGetProperty;
  final DpmsSetPropertyType? dpmsSetProperty;

  _DpmsLinux._constructor({
    required this.dpmsIsAvailable,
    required this.dpmsGetProperty,
    required this.dpmsSetProperty,
  });

  factory _DpmsLinux._() {
    final lib = ffi.DynamicLibrary.process();

    try {
      final dpmsIsAvailable = lib.lookupFunction<DpmsIsAvailableFuncType, DpmsIsAvailableType>("dpms_isAvailable");
      final dpmsGetProperty = lib.lookupFunction<DpmsGetPropertyFuncType, DpmsGetPropertyType>("dpms_getProperty");
      final dpmsSetProperty = lib.lookupFunction<DpmsSetPropertyFuncType, DpmsSetPropertyType>("dpms_setProperty");

      return _DpmsLinux._constructor(
        dpmsIsAvailable: dpmsIsAvailable,
        dpmsGetProperty: dpmsGetProperty,
        dpmsSetProperty: dpmsSetProperty,
      );
    } on ArgumentError {
      return _DpmsLinux._constructor(
        dpmsIsAvailable: null,
        dpmsGetProperty: null,
        dpmsSetProperty: null,
      );
    }
  }

  static _DpmsLinux? _instance;

  static _DpmsLinux get instance {
    _instance ??= _DpmsLinux._();
    return _instance!;
  }
}
