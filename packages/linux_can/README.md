# linux_can

A dart package for using CAN (Controller Area Network) on Linux.
Tested & working on ARM32 but should work on other 32-bit and 64-bit linux platforms as well.

This package uses ffi to interface the kernel SocketCAN APIs directly. It does not contain any
native code and has no platform dependencies apart from libc.

## Features

- sending and receiving CAN frames, synchronously and asynchronously (Stream)
  - CAN 2.0 standard and extended frames are supported.

- querying CAN interface attributes
  - general attributes (operational state, flags, tx/rx queues)
  - bitrate & supported bitrates, bit timing & bit timing limits, clock frequency, bus error counters,
    termination & supported terminations, controller modes, ...

## Usage

```dart
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

// Send some example CAN frame.
socket.send(CanFrame.standard(id: 0x123, data: [0x01, 0x02, 0x03, 0x04]));

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
```
