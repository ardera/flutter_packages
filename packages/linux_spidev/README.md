# spidev

A dart package for SPI using the linux spidev interface. Uses FFI internally.
Has no dependencies on flutter whatsoever.

## Example

```dart
/// Create a [Spidev] instance from the spidev's bus and device number.
/// That spidev may not exist. ([Spidev] is actually just a data class)
final spidev = Spidev.fromBusDevNrs(0, 0);

/// Open the spidev, so you can use it.
final handle = spidev.open();

print("mode: ${handle.mode}");
print("bitsPerWord: ${handle.bitsPerWord}");
print("maxSpeed: ${handle.maxSpeed}");

final typedData = Uint8List(4)

spidev.transferSingleTypedData()

handle.close();
```