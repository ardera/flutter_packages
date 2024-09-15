import 'package:linux_can/linux_can.dart';

Future<void> main() async {
  final linuxcan = LinuxCan.instance;

  // Find the CAN interface with name `can0`.
  final device = linuxcan.devices.singleWhere((device) => device.networkInterface.name == 'can0');

  // We need the interface to be up and running for most purposes.
  // If it is not up, you can bring it up using: (replace 125000 with the bitrate of the bus)
  //   sudo ip link set can0 type can bitrate 125000
  //   sudo ip link set can0 up
  if (!device.isUp) {
    throw StateError('CAN interface is not up.');
  }

  // Query the attributes of this interface.
  final attributes = device.queryAttributes();

  print('CAN device attributes: $attributes');
  print('CAN device hardware name: ${device.hardwareName}');

  // Actually open the device, so we can send/receive frames.
  final socket = device.open();

  if (socket.isFlexibleDataRate) {
    socket.send(CanFrame.standardFd(
        id: 0x123,
        data: [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x10, 0x11, 0x12],
        switchBitRate: true));
  } else {
    // Send some example CAN frame.
    socket.send(CanFrame.standard(id: 0x123, data: [0x01, 0x02, 0x03, 0x04]));
  }

  // Read a CAN frame. This is blocking, i.e. it will wait for a frame to arrive.
  //
  // There's no internal queueing. receiveSingle() will only actually start listening
  // for a new frame inside this method.
  // If a frame arrived on the socket before we get to receiveSingle(), we won't receive it.
  final frame = await socket.receiveSingle();

  // We received a frame.
  switch (frame) {
    case CanDataFrame(:final id, :final data):
      print('received data frame with id $id and data $data');
    case CanRemoteFrame _:
      print('received remote frame $frame');
  }

  // Listen on a Stream of CAN frames
  await for (final frame in socket.receive()) {
    print('received frame $frame');
    break;
  }

  // Close the socket to release all resources.
  await socket.close();
}
