import 'package:dpms/dpms.dart';

Future<void> main() async {
  final dpms = Dpms.instance;
  if (dpms == null) {
    print('DPMS is unavailable in this embedder.');
    return;
  }

  try {
    print('Current mode: ${dpms.getMode()}');
    dpms.setMode(PowerMode.off);
    await Future<void>.delayed(const Duration(seconds: 5));
  } finally {
    dpms.setMode(PowerMode.on);
  }
}
