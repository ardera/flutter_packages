import 'package:linux_dpms/src/dpms_power_state.dart';

class DpmsLinux {
  bool isAvailable() {
    return false;
  }

  void setPowerState(DpmsPowerState state) {}

  DpmsPowerState getPowerState() {
    return DpmsPowerState.on;
  }
}
