import 'dart:io';

import 'package:_ardera_common_libc_bindings/_ardera_common_libc_bindings.dart';
import 'package:file/memory.dart';
import 'package:linux_spidev/linux_spidev.dart';
import 'package:linux_spidev/src/native.dart';
import 'package:test/test.dart';

import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart' as ffi;

import 'checking_allocator.dart';
import 'fake_libc.dart';

final throwsOsError = throwsA(isA<OSError>());

void main() {
  group('NativeSpidevPlatformInterface', () {
    late FakeLibC libc;
    late MemoryFileSystem fs;
    late LeakCheckAllocator allocator;
    late SpidevPlatformInterface platformInterface;

    setUp(() {
      libc = FakeLibC();

      allocator = LeakCheckAllocator(ffi.malloc);

      fs = MemoryFileSystem();

      platformInterface =
          SpidevPlatformInterface.test(libc, allocator: allocator, fs: fs);
    });

    test('ioctl works', () {
      final fd = 123;
      final request = 456;
      final argp = ffi.Pointer.fromAddress(789);

      var ioctlPtrWasCalled = false;

      libc.ioctlPtrFn = (fd, request, argp) {
        expect(fd, equals(123));
        expect(request, equals(456));
        expect(argp.address, equals(789));

        ioctlPtrWasCalled = true;

        return 123;
      };

      final result = platformInterface.ioctl(fd, request, argp);

      expect(result, equals(123));
      expect(ioctlPtrWasCalled, isTrue);

      allocator.checkLeaks();
    });

    test('ioctl is retried indefinitely on EINTR', () {
      final fd = 123;
      final request = 456;
      final argp = ffi.Pointer.fromAddress(789);

      var ioctlPtrWasCalled = false;

      var count = 5;
      libc.ioctlPtrFn = (fd, request, argp) {
        expect(fd, equals(123));
        expect(request, equals(456));
        expect(argp.address, equals(789));

        ioctlPtrWasCalled = true;

        return count-- > 0 ? -1 : 123;
      };

      libc.errnoFn = () => 4;

      final result = platformInterface.ioctl(fd, request, argp);

      expect(result, equals(123));
      expect(ioctlPtrWasCalled, isTrue);

      allocator.checkLeaks();
    });

    test('ioctl throws OSError on negative return value', () {
      final fd = 123;
      final request = 456;
      final argp = ffi.Pointer.fromAddress(789);

      var ioctlPtrWasCalled = false;

      libc.ioctlPtrFn = (fd, request, argp) {
        expect(fd, equals(123));
        expect(request, equals(456));
        expect(argp.address, equals(789));

        ioctlPtrWasCalled = true;

        return -1;
      };

      libc.errnoFn = () => 1;

      expect(() => platformInterface.ioctl(fd, request, argp), throwsOsError);

      expect(ioctlPtrWasCalled, isTrue);

      allocator.checkLeaks();
    });

    test('open works', () {
      var openWasCalled = false;

      libc.openFn = (path, flags) {
        expect(
          path.cast<ffi.Utf8>().toDartString(),
          equals('/dev/spidev123.456'),
        );

        expect(flags, equals(2 /* O_RDWR */ | 524288 /* O_CLOEXEC */));

        openWasCalled = true;

        return 123;
      };

      final result = platformInterface.open('/dev/spidev123.456');

      expect(result, equals(123));
      expect(openWasCalled, isTrue);

      allocator.checkLeaks();
    });

    test('open throws OSError on negative return value and frees memory', () {
      var openWasCalled = false;

      libc.openFn = (path, flags) {
        expect(
          path.cast<ffi.Utf8>().toDartString(),
          equals('/dev/spidev123.456'),
        );

        expect(flags, equals(2 /* O_RDWR */ | 524288 /* O_CLOEXEC */));

        openWasCalled = true;

        return -1;
      };

      expect(() => platformInterface.open('/dev/spidev123.456'), throwsOsError);
      expect(openWasCalled, isTrue);

      allocator.checkLeaks();
    });

    test('close works', () {
      var closeWasCalled = false;

      libc.closeFn = (fd) {
        expect(fd, equals(123));

        closeWasCalled = true;

        return 0;
      };

      platformInterface.close(123);

      expect(closeWasCalled, isTrue);

      allocator.checkLeaks();
    });

    test('close throws OS error on negative return value', () {
      var closeWasCalled = false;

      libc.closeFn = (fd) {
        expect(fd, equals(123));

        closeWasCalled = true;

        return -1;
      };

      expect(() => platformInterface.close(123), throwsOsError);

      expect(closeWasCalled, isTrue);

      allocator.checkLeaks();
    });

    test('exists returns true if file exists', () {
      fs.file('/dev/spidev123.456').createSync(recursive: true);

      expect(platformInterface.exists('/dev/spidev123.456'), isTrue);
    });

    test('exists returns false if file doesn\'t extist', () {
      expect(platformInterface.exists('/dev/spidev123.456'), isFalse);
    });

    test('setModeAndFlags works', () {
      var ioctlWasCalled = false;

      libc.ioctlPtrFn = (fd, request, argp) {
        expect(fd, equals(123));
        expect(request, equals(1074031365 /* SPI_IOC_WR_MODE32 */));

        const expected = 3 |
            4 |
            8 |
            16 |
            32 |
            64 |
            128 |
            256 |
            512 |
            1024 |
            2048 |
            4096 |
            8192 |
            16384 |
            32768;

        expect(argp.cast<ffi.Uint32>().value, equals(expected));

        ioctlWasCalled = true;

        return 0;
      };

      platformInterface.setModeAndFlags(123, SpiMode.mode3, {
        SpiFlag.csActiveHigh,
        SpiFlag.lsbFirst,
        SpiFlag.threeWire,
        SpiFlag.loopBack,
        SpiFlag.noCs,
        SpiFlag.ready,
        SpiFlag.txDual,
        SpiFlag.txQuad,
        SpiFlag.txOctal,
        SpiFlag.rxDual,
        SpiFlag.rxQuad,
        SpiFlag.rxOctal,
        SpiFlag.toggleCsAfterEachWord,
        SpiFlag.threeWireHighImpedanceTurnaround,
      });

      expect(ioctlWasCalled, isTrue);

      allocator.checkLeaks();
    });

    test('setModeAndFlags does not leak on error', () {
      var ioctlWasCalled = false;

      libc.ioctlPtrFn = (fd, request, argp) {
        ioctlWasCalled = true;
        return -1;
      };

      libc.errnoFn = () => 1;

      expect(
        () => platformInterface.setModeAndFlags(
            123, SpiMode.mode3, SpiFlag.values.toSet()),
        throwsOsError,
      );

      expect(ioctlWasCalled, isTrue);

      allocator.checkLeaks();
    });

    test('getModeAndFlags works', () {
      var ioctlWasCalled = false;

      libc.ioctlPtrFn = (fd, request, argp) {
        expect(fd, equals(123));
        expect(request, equals(2147773189 /* SPI_IOC_RD_MODE32 */));

        argp.cast<ffi.Uint32>().value = 1 |
            0 |
            8 |
            0 |
            32 |
            0 |
            128 |
            0 |
            512 |
            0 |
            2048 |
            0 |
            8192 |
            0 |
            32768;

        ioctlWasCalled = true;

        return 0;
      };

      final (mode, flags) = platformInterface.getModeAndFlags(123);

      expect(mode, equals(SpiMode.mode1));
      expect(
        flags,
        unorderedEquals({
          SpiFlag.lsbFirst,
          SpiFlag.loopBack,
          SpiFlag.ready,
          SpiFlag.txQuad,
          SpiFlag.rxQuad,
          SpiFlag.txOctal,
          SpiFlag.threeWireHighImpedanceTurnaround,
        }),
      );

      expect(ioctlWasCalled, isTrue);

      allocator.checkLeaks();
    });

    test('getModeAndFlags does not leak on error', () {
      var ioctlWasCalled = false;

      libc.ioctlPtrFn = (fd, request, argp) {
        ioctlWasCalled = true;
        return -1;
      };

      libc.errnoFn = () => 1;

      expect(
        () => platformInterface.getModeAndFlags(123),
        throwsOsError,
      );

      expect(ioctlWasCalled, isTrue);

      allocator.checkLeaks();
    });

    test('setMaxSpeed works', () {
      var ioctlWasCalled = false;

      libc.ioctlPtrFn = (fd, request, argp) {
        expect(fd, equals(123));

        expect(request, equals(1074031364 /* SPI_IOC_WR_MAX_SPEED_HZ */));

        expect(argp.cast<ffi.Uint32>().value, equals(123456));

        ioctlWasCalled = true;

        return 0;
      };

      platformInterface.setMaxSpeed(123, 123456);

      expect(ioctlWasCalled, isTrue);

      allocator.checkLeaks();
    });

    test('setMaxSpeed does not leak on error', () {
      var ioctlWasCalled = false;

      libc.ioctlPtrFn = (fd, request, argp) {
        ioctlWasCalled = true;
        return -1;
      };

      libc.errnoFn = () => 1;

      expect(
        () => platformInterface.setMaxSpeed(123, 123456),
        throwsOsError,
      );

      expect(ioctlWasCalled, isTrue);

      allocator.checkLeaks();
    });

    test('getMaxSpeed works', () {
      var ioctlWasCalled = false;

      libc.ioctlPtrFn = (fd, request, argp) {
        expect(fd, equals(123));

        expect(request, equals(2147773188 /* SPI_IOC_RD_MAX_SPEED_HZ */));

        argp.cast<ffi.Uint32>().value = 123456;

        ioctlWasCalled = true;

        return 0;
      };

      final result = platformInterface.getMaxSpeed(123);

      expect(result, equals(123456));

      expect(ioctlWasCalled, isTrue);

      allocator.checkLeaks();
    });

    test('getMaxSpeed does not leak on error', () {
      var ioctlWasCalled = false;

      libc.ioctlPtrFn = (fd, request, argp) {
        ioctlWasCalled = true;
        return -1;
      };

      libc.errnoFn = () => 1;

      expect(
        () => platformInterface.getMaxSpeed(123),
        throwsOsError,
      );

      expect(ioctlWasCalled, isTrue);

      allocator.checkLeaks();
    });

    test('setWordSize works', () {
      var ioctlWasCalled = false;

      libc.ioctlPtrFn = (fd, request, argp) {
        expect(fd, equals(123));

        expect(request, equals(1073834755 /* SPI_IOC_WR_BITS_PER_WORD */));

        expect(argp.cast<ffi.Uint8>().value, equals(8));

        ioctlWasCalled = true;

        return 0;
      };

      platformInterface.setWordSize(123, 8);

      expect(ioctlWasCalled, isTrue);

      allocator.checkLeaks();
    });

    test('setWordSize does not leak on error', () {
      var ioctlWasCalled = false;

      libc.ioctlPtrFn = (fd, request, argp) {
        ioctlWasCalled = true;
        return -1;
      };

      libc.errnoFn = () => 1;

      expect(
        () => platformInterface.setWordSize(123, 8),
        throwsOsError,
      );

      expect(ioctlWasCalled, isTrue);

      allocator.checkLeaks();
    });

    test('getWordSize works', () {
      var ioctlWasCalled = false;

      libc.ioctlPtrFn = (fd, request, argp) {
        expect(fd, equals(123));

        expect(request, equals(2147576579 /* SPI_IOC_RD_BITS_PER_WORD */));

        argp.cast<ffi.Uint8>().value = 20;

        ioctlWasCalled = true;

        return 0;
      };

      final result = platformInterface.getWordSize(123);

      expect(result, equals(20));

      expect(ioctlWasCalled, isTrue);

      allocator.checkLeaks();
    });

    test('getWordSize does not leak on error', () {
      var ioctlWasCalled = false;

      libc.ioctlPtrFn = (fd, request, argp) {
        ioctlWasCalled = true;
        return -1;
      };

      libc.errnoFn = () => 1;

      expect(
        () => platformInterface.getWordSize(123),
        throwsOsError,
      );

      expect(ioctlWasCalled, isTrue);

      allocator.checkLeaks();
    });
  });
}
