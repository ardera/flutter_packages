import 'package:linux_spidev/linux_spidev.dart';

void main() {
  final spidev = Spidev.fromBusDevNrs(0, 0);

  final handle = spidev.open();

  print("mode: ${handle.mode}");
  print("bitsPerWord: ${handle.bitsPerWord}");
  print("maxSpeed: ${handle.maxSpeed}");

  handle.close();
}
