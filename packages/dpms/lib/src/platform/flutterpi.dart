import 'dart:ffi' as ffi;

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

class FlutterpiDPMS {
  final DpmsIsAvailableType? dpmsIsAvailable;
  final DpmsGetPropertyType? dpmsGetProperty;
  final DpmsSetPropertyType? dpmsSetProperty;

  FlutterpiDPMS._constructor({
    required this.dpmsIsAvailable,
    required this.dpmsGetProperty,
    required this.dpmsSetProperty,
  });

  factory FlutterpiDPMS._() {
    final lib = ffi.DynamicLibrary.process();

    try {
      final dpmsIsAvailable = lib.lookupFunction<DpmsIsAvailableFuncType, DpmsIsAvailableType>("dpms_isAvailable");
      final dpmsGetProperty = lib.lookupFunction<DpmsGetPropertyFuncType, DpmsGetPropertyType>("dpms_getProperty");
      final dpmsSetProperty = lib.lookupFunction<DpmsSetPropertyFuncType, DpmsSetPropertyType>("dpms_setProperty");

      return FlutterpiDPMS._constructor(
        dpmsIsAvailable: dpmsIsAvailable,
        dpmsGetProperty: dpmsGetProperty,
        dpmsSetProperty: dpmsSetProperty,
      );
    } on ArgumentError {
      return FlutterpiDPMS._constructor(
        dpmsIsAvailable: null,
        dpmsGetProperty: null,
        dpmsSetProperty: null,
      );
    }
  }

  static FlutterpiDPMS? _instance;

  static FlutterpiDPMS get instance {
    _instance ??= FlutterpiDPMS._();
    return _instance!;
  }
}
