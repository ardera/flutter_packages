import 'dart:convert';

import 'package:linux_serial/linux_serial.dart';

void main() async {
  print("ports: ${SerialPorts.ports}");

  final port = SerialPorts.ports.singleWhere((element) => element.name == "ttyS0");

  final handle = port.open(baudrate: Baudrate.b9600);

  handle.encoding = AsciiCodec();

  (() async {
    final reader = handle.getNewSequentialReader();
    while (true) {
      try {
        final char = await reader.read(numBytes: 1);
        final rune = char.runes.single;
        if (rune >= 0x1f && rune != 0x7F) {
          print('$char');
        } else {
          print('0x${rune.toRadixString(16).toUpperCase()}');
        }
      } on StateError {
        reader.close();
        break;
      }
    }
  })();

  final reader = handle.getNewSequentialReader();

  await handle.write('ATWS\r');
  var response = await reader.readln('\r>');

  await handle.write('ATE0\r');
  response = await reader.readln('\r>');

  await handle.write('ATL0\r');
  response = await reader.readln('\r>');

  await handle.write("ATS0");
  response = await reader.readln('\r>');

  await handle.write('ATI\r');
  response = await reader.readln('\r>');
  response = response.replaceAll('\r', '');
  print('ATI: $response');

  await handle.write('01001');
  response = await reader.readln('\r>');
  response = response.replaceAll('\r', '');
  print('01001: $response');

  await reader.close();
  await handle.close();
  print("finished");
}
