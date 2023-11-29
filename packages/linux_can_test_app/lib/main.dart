import 'package:flutter/material.dart';
import 'package:linux_can/linux_can.dart';

void main() async {
  final can0 = LinuxCan.instance.devices.singleWhere((device) => device.networkInterface.name == 'can0');
  final can1 = LinuxCan.instance.devices.singleWhere((device) => device.networkInterface.name == 'can1');

  await Future.delayed(const Duration(seconds: 3));

  can0.queryAttributes();

  final can1Attributes = can1.queryAttributes();
  debugPrint('can1 attributes: $can1Attributes');

  debugPrint('can1 hardwareName: ${can1.hardwareName}');

  debugPrint('can1 xstats: ${can1.xstats}');

  debugPrint('can1 txqlen: ${can1.txQueueLength}');

  for (var i = 0; i < 50; i++) {
    can1.hardwareName;
  }
}
