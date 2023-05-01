import 'package:linux_can/src/can_device.dart';
import 'package:linux_can/src/platform_interface.dart';

class LinuxCan {
  LinuxCan._();

  final PlatformInterface _interface = PlatformInterface();

  static final LinuxCan instance = LinuxCan._();

  List<CanDevice> get devices {
    return _interface.getCanDevices();
  }
}
