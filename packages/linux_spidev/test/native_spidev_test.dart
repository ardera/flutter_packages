import 'dart:ffi' as ffi;

import 'package:linux_spidev/src/data.dart';
import 'package:linux_spidev/src/native.dart';
import 'package:linux_spidev/src/transfer.dart';
import 'package:test/test.dart';

import 'fake_platform_interface.dart';
import 'fake_spi_transfer_executor.dart';

void main() {
  test('parse path', () {
    expect(
      NativeSpidev.parsePath('/dev/spidev123.456'),
      equals(('spidev123.456', 123, 456)),
    );

    expect(
      NativeSpidev.parsePath('/dev/spidev123.c'),
      equals(('spidev123.c', null, null)),
    );

    expect(
      NativeSpidev.parsePath('/sys/xyz/spi0.0'),
      equals(('spi0.0', null, null)),
    );

    expect(
      NativeSpidev.parsePath('adwa0i213ind'),
      equals(('adwa0i213ind', null, null)),
    );
  });

  test('NativeSpidev.fromBusDevNrs', () {
    var existsWasCalled = false;

    SpidevPlatformInterface.debugOverrideInstance = FakePlatformInterface()
      ..existsFn = (path) {
        expect(path, '/dev/spidev123.456');
        existsWasCalled = true;
        return false;
      };

    final dev = NativeSpidev.fromBusDevNrs(123, 456);

    expect(dev.busNr, equals(123));
    expect(dev.devNr, equals(456));
    expect(dev.name, equals('spidev123.456'));
    expect(dev.path, equals('/dev/spidev123.456'));
    expect(dev.exists, isFalse);
    expect(existsWasCalled, isTrue);
  });

  test('NativeSpidev.open', () {
    var openWasCalled = false;
    var existsWasCalled = false;

    SpidevPlatformInterface.debugOverrideInstance = FakePlatformInterface(
      openFn: (path) {
        expect(path, '/dev/spidev123.456');
        openWasCalled = true;
        return 123;
      },
      existsFn: (path) {
        expect(path, '/dev/spidev123.456');
        existsWasCalled = true;
        return true;
      },
    );

    final dev = NativeSpidev.fromBusDevNrs(123, 456);

    final handle = dev.open(caching: false);

    expect(handle.spidev, equals(dev));
    expect(openWasCalled, isTrue);
    expect(existsWasCalled, isTrue);
  });

  group('NativeSpidevHandle', () {
    late FakePlatformInterface platformInterface;
    late NativeSpidev device;
    late NativeSpidevHandle handle;
    late FakeSpiTransferExecutor transferExecutor;

    setUp(() {
      platformInterface = FakePlatformInterface();

      device = NativeSpidev.test(
        platformInterface,
        'spidev123.456',
        '/dev/spidev123.456',
        123,
        456,
      );

      transferExecutor = FakeSpiTransferExecutor();

      handle = NativeSpidevHandle.test(
        platformInterface,
        device,
        123,
        executor: transferExecutor,
      );
    });

    test('get bitsPerWord', () {
      platformInterface.getWordSizeFn = (fd, {allocator}) => 10;

      expect(handle.bitsPerWord, 10);
    });

    test('set bitsPerWord', () {
      var setWordSizeWasCalled = false;
      platformInterface.setWordSizeFn = (fd, value, {allocator}) {
        expect(value, 10);
        setWordSizeWasCalled = true;
      };

      handle.bitsPerWord = 10;

      expect(setWordSizeWasCalled, isTrue);
    });

    test('get mode and flags', () {
      platformInterface.getModeAndFlagsFn = (fd, {allocator}) => (
            SpiMode.mode3,
            SpiFlag.values.toSet(),
          );

      expect(handle.flags, unorderedEquals(SpiFlag.values));
      expect(handle.mode, SpiMode.mode3);
    });

    test('set flags', () {
      var getModeAndFlagsWasCalled = false;
      var setModeAndFlagsWasCalled = false;

      platformInterface.getModeAndFlagsFn = (fd, {allocator}) {
        getModeAndFlagsWasCalled = true;
        return (SpiMode.mode0, <SpiFlag>{});
      };

      platformInterface.setModeAndFlagsFn = (fd, mode, flags, {allocator}) {
        expect(mode, SpiMode.mode0);
        expect(flags, unorderedEquals(SpiFlag.values));

        setModeAndFlagsWasCalled = true;
      };

      handle.flags = SpiFlag.values.toSet();

      expect(getModeAndFlagsWasCalled, isTrue);
      expect(setModeAndFlagsWasCalled, isTrue);
    });

    test('set mode', () {
      var getModeAndFlagsWasCalled = false;
      var setModeAndFlagsWasCalled = false;

      platformInterface.getModeAndFlagsFn = (fd, {allocator}) {
        getModeAndFlagsWasCalled = true;
        return (SpiMode.mode0, <SpiFlag>{});
      };

      platformInterface.setModeAndFlagsFn = (fd, mode, flags, {allocator}) {
        expect(mode, SpiMode.mode3);
        expect(flags, isEmpty);

        setModeAndFlagsWasCalled = true;
      };

      handle.mode = SpiMode.mode3;

      expect(getModeAndFlagsWasCalled, isTrue);
      expect(setModeAndFlagsWasCalled, isTrue);
    });

    test('get max speed', () {
      platformInterface.getMaxSpeedFn = (fd, {allocator}) {
        expect(fd, 123);
        return 123456;
      };

      expect(handle.maxSpeed, 123456);
    });

    test('set max speed', () {
      var setMaxSpeedWasCalled = false;

      platformInterface.setMaxSpeedFn = (fd, speed, {allocator}) {
        expect(fd, 123);
        expect(speed, 123456);
        setMaxSpeedWasCalled = true;
      };

      handle.maxSpeed = 123456;

      expect(setMaxSpeedWasCalled, isTrue);
    });

    test('close', () {
      var closeWasCalled = false;
      var transferExecutorCloseWasCalled = false;

      transferExecutor.closeFn = () async {
        transferExecutorCloseWasCalled = true;
      };

      platformInterface.closeFn = (fd) {
        expect(fd, 123);
        closeWasCalled = true;
      };

      handle.close();

      expect(closeWasCalled, isTrue);
      expect(transferExecutorCloseWasCalled, isTrue);
    });

    test('transferSingle', () {
      transferExecutor.transferFn = (transfers) async {
        expect(transfers, hasLength(1));

        final transfer = transfers.single;
        expect(transfer, isA<ByteListSpiTransfer>());

        final byteListTransfer = transfer as ByteListSpiTransfer;

        expect(byteListTransfer.tx, equals([1, 2, 3]));
        expect(byteListTransfer.rx, equals([4, 5, 6]));
        expect(byteListTransfer.properties, isNotNull);

        final props = byteListTransfer.properties;

        expect(props.speedHz, 123456);
        expect(props.delay, equals(Duration(microseconds: 789)));
        expect(props.bitsPerWord, 10);
        expect(props.doToggleCS, isTrue);
        expect(props.txTransferMode, SpiTransferMode.dual);
        expect(props.rxTransferMode, SpiTransferMode.quad);
        expect(props.wordDelay, equals(Duration(microseconds: 123)));
      };

      handle.transferSingle(
        tx: [1, 2, 3],
        rx: [4, 5, 6],
        transferProperties: SpiTransferProperties(
          speedHz: 123456,
          delay: Duration(microseconds: 789),
          bitsPerWord: 10,
          doToggleCS: true,
          txTransferMode: SpiTransferMode.dual,
          rxTransferMode: SpiTransferMode.quad,
          wordDelay: Duration(microseconds: 123),
        ),
      );
    });

    test('transferSingleNative', () {
      transferExecutor.transferFn = (transfers) async {
        expect(transfers, hasLength(1));

        final transfer = transfers.single;
        expect(transfer, isA<NativeSpiTransfer>());

        final nativeTransfer = transfer as NativeSpiTransfer;

        expect(nativeTransfer.tx, equals(ffi.Pointer.fromAddress(123)));
        expect(nativeTransfer.rx, equals(ffi.Pointer.fromAddress(456)));
        expect(nativeTransfer.properties, isNotNull);

        final props = nativeTransfer.properties;

        expect(props.speedHz, 123456);
        expect(props.delay, equals(Duration(microseconds: 789)));
        expect(props.bitsPerWord, 10);
        expect(props.doToggleCS, isTrue);
        expect(props.txTransferMode, SpiTransferMode.dual);
        expect(props.rxTransferMode, SpiTransferMode.quad);
        expect(props.wordDelay, equals(Duration(microseconds: 123)));
      };

      handle.transferSingleNative(
        tx: ffi.Pointer.fromAddress(123),
        rx: ffi.Pointer.fromAddress(456),
        length: 7,
        transferProperties: SpiTransferProperties(
          speedHz: 123456,
          delay: Duration(microseconds: 789),
          bitsPerWord: 10,
          doToggleCS: true,
          txTransferMode: SpiTransferMode.dual,
          rxTransferMode: SpiTransferMode.quad,
          wordDelay: Duration(microseconds: 123),
        ),
      );
    });
  });
}
