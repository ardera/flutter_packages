@TestOn('browser')
library;

import 'package:dpms/dpms.dart';
import 'package:test/test.dart';

void main() {
  test('DPMS is unavailable on web', () {
    expect(Dpms.instance, isNull);
  });
}
