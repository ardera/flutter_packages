import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:linux_can/linux_can.dart';

void main() {
  testWidgets('querying CAN devices', (_) async {
    expect(
      () => LinuxCan.instance.devices,
      returnsNormally,
    );
  }, tags: 'pi3-can');

  group('general CAN', () {
    late List<CanDevice> devices;

    setUp(() {
      devices = LinuxCan.instance.devices;
    });

    testWidgets('CAN device list details', (_) async {
      expect(devices, hasLength(2));

      expect(devices[0].networkInterface.index, equals(3));
      expect(devices[0].networkInterface.name, equals('can0'));
      expect(devices[1].networkInterface.index, equals(4));
      expect(devices[1].networkInterface.name, equals('can1'));
    }, tags: 'pi3-can');

    group('control can0 and can1', () {
      late CanDevice can0;
      late CanDevice can1;

      setUp(() {
        can0 = devices.singleWhere((device) => device.networkInterface.name == 'can0');
        can1 = devices.singleWhere((device) => device.networkInterface.name == 'can1');
      });

      testWidgets('opening & closing can0 device', (_) async {
        late CanSocket socket;
        expect(
          () => socket = can0.open(),
          returnsNormally,
        );
        expect(
          () => socket.close(),
          returnsNormally,
        );
      }, tags: 'pi3-can');

      testWidgets('opening & closing can1 device', (_) async {
        late CanSocket socket;
        expect(
          () => socket = can1.open(),
          returnsNormally,
        );
        expect(
          () => socket.close(),
          returnsNormally,
        );
      }, tags: 'pi3-can');
    });

    group('use can0 and can1', () {
      late CanSocket can0;
      late CanSocket can1;

      setUp(() {
        can0 = devices.singleWhere((device) => device.networkInterface.name == 'can0').open();
        can1 = devices.singleWhere((device) => device.networkInterface.name == 'can1').open();

        // empty the receive queues
        while (can0.read() != null) {}
        while (can1.read() != null) {}
      });

      tearDown(() {
        can0.close();
        can1.close();
      });

      testWidgets('writing standard CAN frame to can0', (_) async {
        expect(
          () => can0.write(CanFrame.standard(id: 0x123, data: [0x01, 0x02, 0x03, 0x04])),
          returnsNormally,
        );
      }, tags: 'pi3-can');

      testWidgets('writing empty standard CAN frame to can0 and reading from can1', (_) async {
        final sentFrame = CanFrame.standard(id: 0x120, data: []);
        can0.write(sentFrame);

        await Future.delayed(const Duration(seconds: 2));

        late CanFrame? receivedFrame;
        expect(() => receivedFrame = can1.read(), returnsNormally);
        expect(receivedFrame, equals(sentFrame));
      }, tags: 'pi3-can');

      testWidgets('writing full-length CAN frame to can0 and reading from can1', (_) async {
        final sentFrame = CanFrame.standard(id: 0x120, data: [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08]);
        can0.write(sentFrame);

        await Future.delayed(const Duration(seconds: 2));

        late CanFrame? receivedFrame;
        expect(() => receivedFrame = can1.read(), returnsNormally);
        expect(receivedFrame, equals(sentFrame));
      }, tags: 'pi3-can');

      testWidgets('writing standard CAN frame to can0 and reading from can1', (_) async {
        can0.write(CanFrame.standard(id: 0x123, data: [0x01, 0x02, 0x03, 0x04]));

        await Future.delayed(const Duration(seconds: 2));

        late CanFrame? frame;
        expect(() => frame = can1.read(), returnsNormally);
        expect(frame, isNotNull);
        expect(frame, isA<CanStandardDataFrame>());

        final dataFrame = frame as CanStandardDataFrame;
        expect(dataFrame.id, equals(0x123));
        expect(dataFrame.data, hasLength(4));
        expect(dataFrame.data, equals([0x01, 0x02, 0x03, 0x04]));
      }, tags: 'pi3-can');

      testWidgets('writing standard CAN frame to can1 and reading from can0', (_) async {
        can1.write(CanFrame.standard(id: 0x123, data: [0x01, 0x02, 0x03, 0x04]));

        await Future.delayed(const Duration(seconds: 2));

        late CanFrame? frame;
        expect(() => frame = can0.read(), returnsNormally);
        expect(frame, isNotNull);
        expect(frame, isA<CanStandardDataFrame>());

        final dataFrame = frame as CanStandardDataFrame;
        expect(dataFrame.id, equals(0x123));
        expect(dataFrame.data, hasLength(4));
        expect(dataFrame.data, equals([0x01, 0x02, 0x03, 0x04]));
      }, tags: 'pi3-can');

      testWidgets('waiting for data frame on can1', (_) async {
        while (can1.read() != null) {}

        final completer = Completer<CanFrame>();

        can1.frames.first.then(
          (frame) => completer.complete(frame),
          onError: (err, st) => completer.completeError(err, st),
        );

        await Future.delayed(const Duration(seconds: 2));

        expect(completer.isCompleted, isFalse);

        final frame = CanFrame.standard(id: 0x124, data: [0x01, 0x02, 0x03, 0x04]);

        can0.write(frame);

        await expectLater(completer.future.timeout(const Duration(seconds: 5)), completion(frame));
      }, tags: 'pi3-can');

      testWidgets('writing lots of frames to can0 and reading from can1', (_) async {
        final sentFrames = List.generate(
          1024,
          (i) {
            return CanFrame.standard(id: 0x123, data: [i & 0xFF, i >> 8]);
          },
        );

        late List<CanFrame> receivedFrames;
        final receivedFramesFuture = can1.frames.take(1024).toList().then((frames) {
          receivedFrames = frames;
        });

        // write all frames to the bus.
        // requires a sufficiently big tx queue
        sentFrames.forEach(can0.write);

        // wait for all frames to be received
        await expectLater(
          receivedFramesFuture.timeout(const Duration(seconds: 30)),
          completes,
        );

        // check that they match the frames we sent
        expect(receivedFrames, containsAll(sentFrames));
      }, tags: 'pi3-can');
    });
  });
}
