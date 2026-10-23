@TestOn('vm')
library;

import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:dpms/dpms.dart';
import 'package:dpms/src/platform/flutterpi.dart';
import 'package:test/test.dart';

typedef _ConfigureNative = ffi.Void Function(ffi.Int32, ffi.Int32, ffi.Int32);

void main() {
  group('flutter-pi FFI ABI', () {
    late Directory temporary;
    late ffi.DynamicLibrary library;
    late ffi.DynamicLibrary missingSymbols;
    late void Function(int, int, int) configure;

    setUpAll(() async {
      temporary = await Directory.systemTemp.createTemp('dpms-ffi-test-');
      for (final missing in [false, true]) {
        final output = '${temporary.path}/${missing ? 'missing' : 'dpms'}.so';
        final result = await Process.run('cc', [
          '-shared',
          '-fPIC',
          if (missing) '-DDPMS_TEST_MISSING_SYMBOLS',
          'test/fixtures/dpms.c',
          '-o',
          output,
        ]);
        if (result.exitCode != 0) {
          fail('Could not build native DPMS fixture: ${result.stderr}');
        }
        final loaded = ffi.DynamicLibrary.open(output);
        if (missing) {
          missingSymbols = loaded;
        } else {
          library = loaded;
        }
      }
      configure = library.lookupFunction<_ConfigureNative, void Function(int, int, int)>('dpms_test_configure');
    });

    tearDownAll(() async {
      await temporary.delete(recursive: true);
    });

    setUp(() => configure(1, 0, 0));

    test('C bool and signed int32 bindings round trip both modes', () {
      final dpms = FlutterpiDpms.fromLibrary(library);
      dpms.setMode(PowerMode.off);
      expect(dpms.getMode(), PowerMode.off);
      dpms.setMode(PowerMode.on);
      expect(dpms.getMode(), PowerMode.on);
    });

    test('negative native read errno crosses FFI intact', () {
      final dpms = FlutterpiDpms.fromLibrary(library);
      configure(1, 19, 0);
      expect(dpms.getMode, throwsA(isA<DpmsException>().having((e) => e.errorCode, 'errno', 19)));
    });

    test('failed native write crosses FFI intact', () {
      final dpms = FlutterpiDpms.fromLibrary(library);
      dpms.setMode(PowerMode.on);
      configure(1, 0, 16);
      expect(() => dpms.setMode(PowerMode.off), throwsA(isA<DpmsException>().having((e) => e.errorCode, 'errno', 16)));
      expect(dpms.getMode(), PowerMode.on);
    });

    test('symbols alone do not imply support for the selected output', () {
      configure(0, 0, 0);
      expect(() => FlutterpiDpms.fromLibrary(library), throwsUnsupportedError);
    });

    test('an embedder without the ABI is unsupported', () {
      expect(() => FlutterpiDpms.fromLibrary(missingSymbols), throwsUnsupportedError);
    });
  }, skip: !Platform.isLinux ? 'Native fixture targets Linux.' : false);
}
