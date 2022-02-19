import 'package:flutter_gpiod/flutter_gpiod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'gpio_matcher.dart';

void main() {
  testWidgets(
    'match pi 4 gpio chips',
    (_) async {
      expect(FlutterGpiod.instance.supportsBias, isTrue);
      expect(FlutterGpiod.instance.supportsLineReconfiguration, isTrue);
      expect(FlutterGpiod.instance.chips, matchPi4GpioChips);
    },
    tags: ['pi4'],
  );

  testWidgets(
    'match odroid c4 gpio chips',
    (_) async {
      expect(FlutterGpiod.instance.supportsBias, isFalse);
      expect(FlutterGpiod.instance.supportsLineReconfiguration, isFalse);
      expect(FlutterGpiod.instance.chips, anything);
    },
    tags: ['odroidc4'],
  );
}
