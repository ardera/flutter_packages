import 'dart:io';

import 'package:flutter_gpiod/flutter_gpiod.dart';
import 'package:linux_spidev/linux_spidev.dart';
import 'package:linux_spidev_test_app/st7735.dart';

void main() async {
  final lines = Map.fromIterable(
    FlutterGpiod.instance.chips.expand((chip) => chip.lines),
    key: (line) => line.info.name,
    value: (line) => line,
  );

  final st7735 = ST7735(
    spidev: Spidev.fromBusDevNrs(0, 0),
    dc: lines['GPIO25'],
    reset: lines['GPIO24'],
    width: 128,
    heigth: 160,
  );

  final handle = st7735.open();

  await handle.powerOn();

  await handle.hardReset();

  print('Done.');

  exit(0);
}
