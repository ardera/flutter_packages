@TestOn('vm')
library;

import 'package:dpms/dpms.dart';
import 'package:dpms/src/platform/flutterpi.dart';
import 'package:test/test.dart';

void main() {
  test('a regular Dart process has no DPMS implementation', () {
    expect(Dpms.instance, isNull);
  });

  test('both power modes round trip, including off', () {
    var nativeMode = 1;
    final dpms = FlutterpiDpms(() => nativeMode, (enabled) {
      nativeMode = enabled ? 1 : 0;
      return 0;
    });
    expect(dpms.getMode(), PowerMode.on);
    dpms.setMode(PowerMode.off);
    expect(dpms.getMode(), PowerMode.off);
    dpms.setMode(PowerMode.on);
    expect(dpms.getMode(), PowerMode.on);
  });

  test('read errors remain errors instead of being interpreted as on', () {
    final dpms = FlutterpiDpms(() => -19, (_) => 0);
    expect(dpms.getMode, throwsA(isA<DpmsException>().having((e) => e.errorCode, 'errno', 19)));
  });

  test('failed mode changes propagate the native errno', () {
    final dpms = FlutterpiDpms(() => 1, (_) => 16);
    expect(() => dpms.setMode(PowerMode.off), throwsA(isA<DpmsException>().having((e) => e.errorCode, 'errno', 16)));
  });

  test('unexpected native mode is rejected', () {
    final dpms = FlutterpiDpms(() => 3, (_) => 0);
    expect(dpms.getMode, throwsStateError);
  });
}
