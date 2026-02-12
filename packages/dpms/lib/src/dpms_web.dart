import 'package:dpms/src/power_mode.dart';

class Dpms {
  bool isAvailable() {
    return false;
  }

  void setMode(PowerMode mode) {}

  PowerMode getMode() {
    return PowerMode.on;
  }
}
