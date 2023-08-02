import 'dart:async';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart' hide testWidgets;
import 'package:flutter_test/flutter_test.dart' as test show testWidgets;
import 'package:linux_can/linux_can.dart';

void main() {
  test.testWidgets('LinuxCan.instance.devices returns normally', (_) async {
    expect(
      () => LinuxCan.instance.devices,
      returnsNormally,
    );
  }, tags: 'pi3-can');

  group('', () {
    late List<CanDevice> devices;

    setUp(() {
      devices = LinuxCan.instance.devices;
    });

    group('Real CAN Hardware', () {
      void testWidgets(
        String description,
        Future<void> Function(WidgetTester) callback, {
        bool? skip,
        Timeout? timeout,
        bool semanticsEnabled = true,
        TestVariant<Object?> variant = const DefaultTestVariant(),
      }) {
        return test.testWidgets(
          description,
          callback,
          skip: skip,
          timeout: timeout,
          semanticsEnabled: semanticsEnabled,
          variant: variant,
          tags: 'pi3-can',
        );
      }

      testWidgets('LinuxCan.instance.devices', (_) async {
        expect(devices, hasLength(2));

        expect(devices[0].networkInterface.index, equals(3));
        expect(devices[0].networkInterface.name, equals('can0'));
        expect(devices[1].networkInterface.index, equals(4));
        expect(devices[1].networkInterface.name, equals('can1'));
      });

      group('CanDevice', () {
        late CanDevice can0;
        late CanDevice can1;

        setUp(() {
          can0 = devices.singleWhere((device) => device.networkInterface.name == 'can0');
          can1 = devices.singleWhere((device) => device.networkInterface.name == 'can1');
        });

        testWidgets('can0 queryAttributes', (_) async {
          final attributes = can0.queryAttributes();

          expect(
            attributes.interfaceFlags,
            equals({
              NetInterfaceFlag.up,
              NetInterfaceFlag.running,
              NetInterfaceFlag.noArp,
              NetInterfaceFlag.lowerUp,
              NetInterfaceFlag.echo
            }),
          );
          expect(attributes.txQueueLength, greaterThanOrEqualTo(1000));
          expect(attributes.operState, equals(NetInterfaceOperState.up));

          /// TODO: Implement stats
          expect(attributes.stats, anything);
          expect(attributes.numTxQueues, equals(1));
          expect(attributes.numRxQueues, equals(1));

          expect(attributes.bitTiming?.bitrate, equals(125000));
          expect(attributes.bitTimingLimits?.hardwareName, equals('mcp251x'));
          expect(attributes.bitTimingLimits?.timeSegment1Min, equals(3));
          expect(attributes.bitTimingLimits?.timeSegment1Max, equals(16));
          expect(attributes.bitTimingLimits?.timeSegment2Min, equals(2));
          expect(attributes.bitTimingLimits?.timeSegment2Max, equals(8));
          expect(attributes.bitTimingLimits?.bitRatePrescalerMin, equals(1));
          expect(attributes.bitTimingLimits?.bitRatePrescalerMax, equals(64));
          expect(attributes.bitTimingLimits?.bitRatePrescalerIncrement, equals(1));

          expect(attributes.clockFrequency, equals(8000000));
          expect(attributes.state, equals(CanState.active));
          expect(attributes.restartDelay, equals(Duration.zero));
          expect(attributes.busErrorCounters, isNull);
          expect(attributes.dataBitTiming, isNull);
          expect(attributes.dataBitTimingLimits, isNull);
          expect(attributes.termination, isNull);
          expect(attributes.supportedTerminations, isNull);
          expect(attributes.supportedBitrates, isNull);
          expect(attributes.supportedDataBitrates, isNull);
          expect(attributes.maxBitrate, equals(0));
        });

        testWidgets('can1 queryAttributes', (_) async {
          final attributes = can1.queryAttributes();

          expect(
            attributes.interfaceFlags,
            equals({
              NetInterfaceFlag.up,
              NetInterfaceFlag.running,
              NetInterfaceFlag.noArp,
              NetInterfaceFlag.lowerUp,
              NetInterfaceFlag.echo
            }),
          );
          expect(attributes.txQueueLength, greaterThanOrEqualTo(1000));
          expect(attributes.operState, equals(NetInterfaceOperState.up));

          /// TODO: Implement stats
          expect(attributes.stats, anything);
          expect(attributes.numTxQueues, equals(1));
          expect(attributes.numRxQueues, equals(1));

          expect(attributes.bitTiming?.bitrate, equals(125000));
          expect(attributes.bitTimingLimits?.hardwareName, equals('mcp251x'));
          expect(attributes.bitTimingLimits?.timeSegment1Min, equals(3));
          expect(attributes.bitTimingLimits?.timeSegment1Max, equals(16));
          expect(attributes.bitTimingLimits?.timeSegment2Min, equals(2));
          expect(attributes.bitTimingLimits?.timeSegment2Max, equals(8));
          expect(attributes.bitTimingLimits?.bitRatePrescalerMin, equals(1));
          expect(attributes.bitTimingLimits?.bitRatePrescalerMax, equals(64));
          expect(attributes.bitTimingLimits?.bitRatePrescalerIncrement, equals(1));

          expect(attributes.clockFrequency, equals(8000000));
          expect(attributes.state, equals(CanState.active));
          expect(attributes.restartDelay, equals(Duration.zero));
          expect(attributes.busErrorCounters, isNull);
          expect(attributes.dataBitTiming, isNull);
          expect(attributes.dataBitTimingLimits, isNull);
          expect(attributes.termination, isNull);
          expect(attributes.supportedTerminations, isNull);
          expect(attributes.supportedBitrates, isNull);
          expect(attributes.supportedDataBitrates, isNull);
          expect(attributes.maxBitrate, equals(0));
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
        });

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
        });
      });

      group('CanSocket', () {
        late CanSocket can0;
        late CanSocket can1;

        setUp(() {
          can0 = devices.singleWhere((device) => device.networkInterface.name == 'can0').open();
          can1 = devices.singleWhere((device) => device.networkInterface.name == 'can1').open();
        });

        tearDown(() {
          can0.close();
          can1.close();
        });

        testWidgets('can0 send buf size', (_) async {
          expect(can0.sendBufSize, equals(22 * 4096));
        });

        testWidgets('writing standard CAN frame to can0', (_) async {
          expect(
            () => can0.send(CanFrame.standard(id: 0x123, data: [0x01, 0x02, 0x03, 0x04])),
            returnsNormally,
          );
        });

        testWidgets('writing empty standard CAN frame to can0 and reading from can1', (_) async {
          final sentFrame = CanFrame.standard(id: 0x120, data: []);

          expectLater(can1.receiveSingle(), equals(sentFrame));

          can0.send(sentFrame);
        });

        testWidgets('writing full-length CAN frame to can0 and reading from can1', (_) async {
          final sentFrame = CanFrame.standard(id: 0x120, data: [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08]);

          expectLater(can1.receiveSingle(), equals(sentFrame));

          can0.send(sentFrame);
        });

        testWidgets('writing standard CAN frame to can0 and reading from can1', (_) async {
          late CanFrame frame;

          final future = can1.receiveSingle().then((received) => frame = received);

          can0.send(CanFrame.standard(id: 0x123, data: [0x01, 0x02, 0x03, 0x04]));

          await expectLater(future, completes);

          expect(frame, isNotNull);
          expect(frame, isA<CanStandardDataFrame>());

          final dataFrame = frame as CanStandardDataFrame;
          expect(dataFrame.id, equals(0x123));
          expect(dataFrame.data, hasLength(4));
          expect(dataFrame.data, equals([0x01, 0x02, 0x03, 0x04]));
        });

        testWidgets('writing standard CAN frame to can1 and reading from can0', (_) async {
          late CanFrame frame;

          final future = can0.receiveSingle().then((received) => frame = received);

          can1.send(CanFrame.standard(id: 0x123, data: [0x01, 0x02, 0x03, 0x04]));

          await expectLater(future, completes);

          expect(frame, isNotNull);
          expect(frame, isA<CanStandardDataFrame>());

          final dataFrame = frame as CanStandardDataFrame;
          expect(dataFrame.id, equals(0x123));
          expect(dataFrame.data, hasLength(4));
          expect(dataFrame.data, equals([0x01, 0x02, 0x03, 0x04]));
        });

        testWidgets('waiting for data frame on can1', (_) async {
          // FIXME: Maybe empty receive queues here

          final completer = Completer<CanFrame>();

          can1.receiveSingle().then(
                (frame) => completer.complete(frame),
                onError: (err, st) => completer.completeError(err, st),
              );

          await Future.delayed(const Duration(seconds: 2));

          expect(completer.isCompleted, isFalse);

          final frame = CanFrame.standard(id: 0x124, data: [0x01, 0x02, 0x03, 0x04]);

          can0.send(frame);

          await expectLater(completer.future.timeout(const Duration(seconds: 5)), completion(frame));
        });

        testWidgets('writing lots of frames to can0 and reading from can1', (_) async {
          final sentFrames = List.generate(
            1024,
            (i) {
              return CanFrame.standard(id: 0x123, data: [i & 0xFF, i >> 8]);
            },
          );

          late List<CanFrame> receivedFrames;
          final receivedFramesFuture = can1.receive().take(1024).toList().then((frames) {
            receivedFrames = frames;
          });

          // write all frames to the bus.
          // requires a sufficiently big tx queue
          sentFrames.forEach(can0.send);

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
            },
            timeout: const Timeout(Duration(seconds: 40)),
          );
        });
    });
  });
}
