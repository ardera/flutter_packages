# spidev

A dart package for SPI using the linux spidev interface. Uses dart:ffi internally.
Has no dependencies on flutter whatsoever.

This package is currently in early early alpha.

## Example

```dart
/// Create a [Spidev] instance from the spidev's bus and device number.
/// That spidev may not exist. ([Spidev] is actually just a data class)
final spidev = Spidev.fromBusDevNrs(0, 0);

/// Open the spidev, so you can use it and read/write data from/to it.
final handle = spidev.open();

print("mode: ${handle.mode}");
print("bitsPerWord: ${handle.bitsPerWord}");
print("maxSpeed: ${handle.maxSpeed}");

/// for transferring data from and to a SPI device, normal dart typed data
/// can be used. However this will internally result in the data being copied
/// to a real (malloced) memory buffer and then copied back again after receive.
/// If you're transmitting larger amounts of data, you can also use malloced
/// buffers directly using [spidev.transferSingleNativeMem].
final typedData = Uint8List(4);

/// This will only execute this single SPI transfer. If you want to execute
/// multiple transfers consecutively, for example write a four-byte command and
/// and then read 512 bytes directly after, you need to use [spidev.transfer] or
/// [spidev.transferNativeMem] which take list of [SpiTransfer]s as arguments
/// and pass those lists of SPI transfers to the kernel all at once.
await spidev.transferSingleTypedData(txBuf: typedData, rxBuf: typedData);

/// This is a more low-level example for using malloced memory directly.
final command = ffi.malloc.allocate<ffi.Uint8>(4);
final response = ffi.malloc.allocate<ffi.Uint8>(512);

command[0] = 0x12;
command[1] = 0x34;
command[2] = 0x56;
command[3] = 0x78;

await spidev.transfer([
  SpiTransfer(
    data: SpiTransferData.fromNativeMem(txBuf: command, length: 4),
  ),
  SpiTransfer(
    data: SpiTransferData.fromNativeMem(rxBuf: response, length: 512),
  ),
])

final responseAsList = response.asTypedList(512);
print(responseAsList);

ffi.malloc.free(command);
ffi.malloc.free(response);

handle.close();

/// This can also be used for transferring files for example.
/// In this case, allocate a large file buffer (maybe 2048 bytes,
/// some linux SPI drivers have a max byte limit size per transaction
/// (a transaction being 1 or more consecutive SPI transfers) but unfortunately
/// you can't query that limit)
/// Then, get a typed list of the buffer (using asTypedList(length)) and then
/// read the file or parts of the file directly into that list.
```