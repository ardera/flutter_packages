# linux_serial

Dart package for accessing serial ports on Linux using dart:ffi.

## Example usage

```dart
/// get the list of available serial ports
final ports = SerialPorts.ports;
print(ports);

/// find the serial port with the name `ttyS0`
final port = ports.singleWhere((p) => p.name == 'ttyS0');

/// open the port, so we can read and write things to it
final handle = port.open(baudrate: Baudrate.b9600);

/// set the encoding used for converting written strings to bytes and vice-versa
handle.encoding = AsciiCodec();

/// get a new serial port reader.
/// this sequential reader will buffer all incoming until we read from it.
/// We can also get another sequential reader if we want to, in that case the
/// two constructed sequential readers may emit the same strings.
final reader = handle.getNewSequentialReader();

/// write ATWS followed by a carriage return to the serial port.
/// This is an example communication with a ELM327. ATWS basically
/// reboots the ELM.
await handle.write('ATWS\r');

/// The the command (in this case, the reboot) is complete when
/// we read a carriage return and a '>' from the ELM.
/// The response we read does NOT include the '\r>'.
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
```
