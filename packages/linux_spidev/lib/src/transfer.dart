import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:ffi/ffi.dart' as ffi;
import 'package:linux_spidev/src/data.dart';

typedef NativeSpiData = (ffi.Pointer tx, ffi.Pointer rx, int length);

abstract class SpiTransfer {
  SpiTransferProperties get properties;

  (ffi.Pointer tx, ffi.Pointer rx, int length) startTransfer();

  void postTransfer(ffi.Pointer tx, ffi.Pointer rx, int length);
}

class NativeSpiTransfer extends SpiTransfer {
  NativeSpiTransfer({
    required this.tx,
    required this.rx,
    required this.length,
    SpiTransferProperties? properties,
  })  : assert(tx != ffi.nullptr || rx != ffi.nullptr),
        properties = properties ?? SpiTransferProperties.defaultProperties;

  final ffi.Pointer tx;
  final ffi.Pointer rx;
  final int length;

  @override
  final SpiTransferProperties properties;

  @override
  void postTransfer(
    ffi.Pointer<ffi.NativeType> tx,
    ffi.Pointer<ffi.NativeType> rx,
    int length,
  ) {}

  @override
  NativeSpiData startTransfer() {
    return (tx, rx, length);
  }
}

class TypedDataSpiTransfer extends SpiTransfer {
  TypedDataSpiTransfer({
    this.tx,
    this.rx,
    SpiTransferProperties? properties,
    ffi.Allocator allocator = ffi.malloc,
  })  : assert(tx != null || rx != null,
            'At least one of tx or rx must be given.'),
        assert((tx == null || rx == null) || (tx.length == rx.length),
            'Transmit and receive buffers must have the same length if both are given.'),
        assert((tx == null) || (rx == null) || !_overlaps(tx, rx),
            'Overlapping transmit and receive buffers are not supported.'),
        _allocator = allocator,
        properties = properties ?? SpiTransferProperties.defaultProperties,
        length = tx?.length ?? rx!.length;

  static bool _overlaps(Uint8List a, Uint8List b) {
    return (a.buffer == b.buffer) &&
        (((a.offsetInBytes >= b.offsetInBytes) &&
                (a.offsetInBytes <= b.offsetInBytes + b.lengthInBytes)) ||
            ((b.offsetInBytes >= a.offsetInBytes) &&
                (b.offsetInBytes <= a.offsetInBytes + a.lengthInBytes)));
  }

  /// data to be written. can be [null]
  final Uint8List? tx;

  /// data to be read. can be [null]
  final Uint8List? rx;

  final int length;

  final ffi.Allocator _allocator;

  final SpiTransferProperties properties;

  @override
  NativeSpiData startTransfer() {
    final ffi.Pointer<ffi.Uint8> txPointer;
    if (tx case Uint8List tx) {
      txPointer = _allocator<ffi.Uint8>(length);

      final txPointerAsBuf = txPointer.asTypedList(length);
      for (var i = 0; i < txPointerAsBuf.length; i++) {
        txPointerAsBuf[i] = tx[i];
      }
    } else {
      txPointer = ffi.nullptr;
    }

    final rxPointer = rx != null ? _allocator<ffi.Uint8>(length) : ffi.nullptr;

    return (txPointer, rxPointer, length);
  }

  @override
  void postTransfer(
    ffi.Pointer<ffi.NativeType> tx,
    ffi.Pointer<ffi.NativeType> rx,
    int length,
  ) {
    try {
      if (this.rx case Uint8List rxList) {
        final rxPtrAsBuf = rx.cast<ffi.Uint8>().asTypedList(length);
        List.copyRange(rxList, 0, rxPtrAsBuf);
      }
    } finally {
      if (rx != ffi.nullptr) {
        _allocator.free(rx);
      }

      if (tx != ffi.nullptr) {
        _allocator.free(tx);
      }
    }
  }
}

class ByteListSpiTransfer extends SpiTransfer {
  ByteListSpiTransfer({
    this.tx,
    this.rx,
    SpiTransferProperties? properties,
    ffi.Allocator allocator = ffi.malloc,
  })  : assert(tx != null || rx != null),
        assert((tx == null || rx == null) || (tx.length == rx.length)),
        length = tx?.length ?? rx!.length,
        properties = properties ?? SpiTransferProperties.defaultProperties,
        _allocator = allocator;

  /// data to be written. can be [null]
  final List<int>? tx;

  /// data to be read. can be [null]
  final List<int>? rx;

  final int length;

  /// Special properties for only this transfer.
  ///
  /// If not specified, the default properties are used.
  final SpiTransferProperties properties;

  final ffi.Allocator _allocator;

  @override
  NativeSpiData startTransfer() {
    final txPointer = switch (tx) {
      null => ffi.nullptr,
      List<int> tx => _allocator<ffi.Uint8>(length)
        ..asTypedList(length).setAll(0, tx),
    };

    final rxPointer = switch (rx) {
      null => ffi.nullptr,
      List<int> _ => _allocator<ffi.Uint8>(length),
    };

    return (txPointer, rxPointer, length);
  }

  @override
  void postTransfer(
    ffi.Pointer<ffi.NativeType> tx,
    ffi.Pointer<ffi.NativeType> rx,
    int length,
  ) {
    try {
      if (this.rx case List<int> rxList) {
        List.copyRange(rxList, 0, rx.cast<ffi.Uint8>().asTypedList(length));
      }
    } finally {
      if (tx != ffi.nullptr) {
        _allocator.free(tx);
      }
      if (rx != ffi.nullptr) {
        _allocator.free(rx);
      }
    }
  }
}
