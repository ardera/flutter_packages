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

          // wait for all frames to be received
          await expectLater(
            receivedFramesFuture.timeout(const Duration(seconds: 30)),
            completes,
          );

          // check that they match the frames we sent
          expect(receivedFrames, containsAll(sentFrames));
        });
      });
    });

    group('Virtual CAN', () {
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
          tags: 'vcan',
        );
      }

      testWidgets('LinuxCan.instance.devices', (_) async {
        expect(devices, hasLength(1));

        // expect(devices[0].networkInterface.index, equals(3));
        expect(devices[0].networkInterface.name, equals('vcan0'));
      });

      group('CanDevice', () {
        late CanDevice vcan;

        setUp(() {
          vcan = devices.singleWhere((device) => device.networkInterface.name == 'vcan0');
        });

        testWidgets('queryAttributes', (_) async {
          final attributes = vcan.queryAttributes();

          expect(
            attributes.interfaceFlags,
            equals({
              NetInterfaceFlag.up,
              NetInterfaceFlag.running,
              NetInterfaceFlag.noArp,
              NetInterfaceFlag.lowerUp,
            }),
          );
          expect(attributes.txQueueLength, greaterThanOrEqualTo(1000));

          expect(attributes.operState, equals(NetInterfaceOperState.unknown));

          /// TODO: Implement stats
          expect(attributes.stats, anything);
          expect(attributes.numTxQueues, equals(1));
          expect(attributes.numRxQueues, equals(1));

          expect(attributes.bitTiming?.bitrate, isNull);
          expect(attributes.bitTimingLimits?.hardwareName, isNull);
          expect(attributes.bitTimingLimits?.timeSegment1Min, isNull);
          expect(attributes.bitTimingLimits?.timeSegment1Max, isNull);
          expect(attributes.bitTimingLimits?.timeSegment2Min, isNull);
          expect(attributes.bitTimingLimits?.timeSegment2Max, isNull);
          expect(attributes.bitTimingLimits?.bitRatePrescalerMin, isNull);
          expect(attributes.bitTimingLimits?.bitRatePrescalerMax, isNull);
          expect(attributes.bitTimingLimits?.bitRatePrescalerIncrement, isNull);

          expect(attributes.clockFrequency, isNull);
          expect(attributes.state, isNull);
          expect(attributes.restartDelay, isNull);
          expect(attributes.busErrorCounters, isNull);
          expect(attributes.dataBitTiming, isNull);
          expect(attributes.dataBitTimingLimits, isNull);
          expect(attributes.termination, isNull);
          expect(attributes.supportedTerminations, isNull);
          expect(attributes.supportedBitrates, isNull);
          expect(attributes.supportedDataBitrates, isNull);
          expect(attributes.maxBitrate, isNull);
        });
      });

      group('CanSocket', () {
        late CanSocket vcan0;
        late CanSocket vcan1;

        setUp(() {
          vcan0 = devices.singleWhere((device) => device.networkInterface.name == 'vcan0').open();
          vcan1 = devices.singleWhere((device) => device.networkInterface.name == 'vcan0').open();
        });

        tearDown(() {
          vcan1.close();
          vcan0.close();
        });

        testWidgets('send buf size', (_) async {
          expect(vcan0.sendBufSize, equals(26 * 4096));
          expect(vcan1.sendBufSize, equals(26 * 4096));
        });

        testWidgets('writing standard CAN frame', (_) async {
          expect(
            () => vcan0.send(CanFrame.standard(id: 0x123, data: [0x01, 0x02, 0x03, 0x04])),
            returnsNormally,
          );
        });

        group('sending and receiving on different socket', () {
          testWidgets(
            'empty SFF data frame',
            (_) async {
              final sentFrame = CanFrame.standard(id: 0x120, data: []);

              final frameFuture = vcan0.receiveSingle(emitErrors: true);

              vcan1.send(sentFrame);

              await expectLater(frameFuture, completion(equals(sentFrame)));
            },
            timeout: const Timeout(Duration(seconds: 10)),
          );

          testWidgets(
            'full-length SFF data frame',
            (_) async {
              final sentFrame = CanFrame.standard(id: 0x120, data: [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08]);

              final frameFuture = vcan1.receiveSingle(emitErrors: true);

              vcan0.send(sentFrame);

              await expectLater(frameFuture, completion(equals(sentFrame)));
            },
            timeout: const Timeout(Duration(seconds: 10)),
          );

          testWidgets(
            'SFF data frame',
            (_) async {
              late CanFrame frame;

              final future = vcan1.receiveSingle(emitErrors: true).then((received) => frame = received);

              vcan0.send(CanFrame.standard(id: 0x123, data: [0x01, 0x02, 0x03, 0x04]));

              await expectLater(future, completes);

              expect(frame, isNotNull);
              expect(frame, isA<CanStandardDataFrame>());

              final dataFrame = frame as CanStandardDataFrame;
              expect(dataFrame.id, equals(0x123));
              expect(dataFrame.data, hasLength(4));
              expect(dataFrame.data, equals([0x01, 0x02, 0x03, 0x04]));
            },
            timeout: const Timeout(Duration(seconds: 10)),
          );

          testWidgets(
            'SFF data frame 2',
            (_) async {
              late CanFrame frame;

              final future = vcan0.receiveSingle(emitErrors: true).then((received) => frame = received);

              vcan1.send(CanFrame.standard(id: 0x123, data: [0x01, 0x02, 0x03, 0x04]));

              await expectLater(future, completes);

              expect(frame, isNotNull);
              expect(frame, isA<CanStandardDataFrame>());

              final dataFrame = frame as CanStandardDataFrame;
              expect(dataFrame.id, equals(0x123));
              expect(dataFrame.data, hasLength(4));
              expect(dataFrame.data, equals([0x01, 0x02, 0x03, 0x04]));
            },
            timeout: const Timeout(Duration(seconds: 10)),
          );

          testWidgets(
            'SFF RTR frame',
            (_) async {
              late CanFrame frame;

              final future =
                  vcan0.receiveSingle(emitErrors: true, filter: CanFilter.any).then((received) => frame = received);

              vcan1.send(CanFrame.standardRemote(id: 0x123));

              await expectLater(future, completes);

              expect(frame, isNotNull);
              expect(frame, isA<CanStandardRemoteFrame>());

              final dataFrame = frame as CanStandardRemoteFrame;
              expect(dataFrame.id, equals(0x123));
            },
            timeout: const Timeout(Duration(seconds: 10)),
          );

          testWidgets(
            'EFF data frame',
            (_) async {
              late CanFrame frame;

              final future = vcan0.receiveSingle(emitErrors: true).then((received) => frame = received);

              vcan1.send(CanFrame.extended(id: 0x123, data: [0x01, 0x02, 0x03, 0x04]));

              await expectLater(future, completes);

              expect(frame, isNotNull);
              expect(frame, isA<CanExtendedDataFrame>());

              final dataFrame = frame as CanExtendedDataFrame;
              expect(dataFrame.id, equals(0x123));
              expect(dataFrame.data, hasLength(4));
              expect(dataFrame.data, equals([0x01, 0x02, 0x03, 0x04]));
            },
            timeout: const Timeout(Duration(seconds: 10)),
          );

          testWidgets(
            'EFF RTR frame',
            (_) async {
              late CanFrame frame;

              final future =
                  vcan0.receiveSingle(emitErrors: true, filter: CanFilter.any).then((received) => frame = received);

              vcan1.send(CanFrame.extendedRemote(id: 0x123));

              await expectLater(future, completes);

              expect(frame, isNotNull);
              expect(frame, isA<CanExtendedRemoteFrame>());

              final dataFrame = frame as CanExtendedRemoteFrame;
              expect(dataFrame.id, equals(0x123));
            },
            timeout: const Timeout(Duration(seconds: 10)),
          );

          testWidgets(
            'lots of frames',
            (_) async {
              final sentFrames = List.generate(
                1024,
                (i) {
                  return CanFrame.standard(id: 0x123, data: [i & 0xFF, i >> 8]);
                },
              );

              late List<CanFrame> receivedFrames;
              final receivedFramesFuture = vcan1.receive().take(1024).toList().then((frames) {
                receivedFrames = frames;
              });

              // write all frames to the bus.
              // requires a sufficiently big tx queue
              sentFrames.forEach(vcan0.send);

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

        group('kernel filters', () {
          testWidgets('filtering for single ID emits matching frames', (_) async {
            final frame1 = CanFrame.standard(id: 0x123, data: [0x01, 0x02, 0x03, 0x04]);
            final frame2 = CanFrame.standard(id: 0x124, data: [0x01, 0x02, 0x03, 0x04]);

            final framesFuture = vcan1.receiveSingle(filter: CanFilter.whitelist(const [0x123]));

            vcan0.send(frame1);
            vcan0.send(frame2);

            await expectLater(
              framesFuture.timeout(const Duration(seconds: 10)),
              completion(equals(frame1)),
            );
          });

          testWidgets('filtering for single ID does not emit non-matching frames', (_) async {
            final frame1 = CanFrame.standard(id: 0x123, data: [0x01, 0x02, 0x03, 0x04]);
            final frame2 = CanFrame.standard(id: 0x124, data: [0x01, 0x02, 0x03, 0x04]);

            final frameFuture = vcan1.receiveSingle(filter: CanFilter.whitelist(const [0x124]));

            vcan0.send(frame1);
            vcan0.send(frame2);

            await expectLater(
              frameFuture.timeout(const Duration(seconds: 10)),
              completion(equals(frame2)),
            );
          });

          testWidgets('filtering for multiple IDs emits matching frames', (_) async {
            final frames = [
              CanFrame.standard(id: 0x123, data: [0x01, 0x02, 0x03, 0x04]),
              CanFrame.standard(id: 0x124, data: [0x01, 0x02, 0x03, 0x04]),
              CanFrame.standard(id: 0x125, data: [0x01, 0x02, 0x03, 0x04]),
              CanFrame.standard(id: 0x126, data: [0x01, 0x02, 0x03, 0x04]),
            ];

            final frameFuture = vcan1
                .receive(
                  filter: CanFilter.whitelist(const [0x123, 0x124]),
                )
                .take(2)
                .toList();

            frames.forEach(vcan0.send);

            await expectLater(
              frameFuture.timeout(const Duration(seconds: 10)),
              completion(containsAll(frames.take(2))),
            );
          });

          testWidgets('filtering for multiple IDs does not emit non-matching frames', (_) async {
            final frames = [
              CanFrame.standard(id: 0x123, data: [0x01, 0x02, 0x03, 0x04]),
              CanFrame.standard(id: 0x124, data: [0x01, 0x02, 0x03, 0x04]),
              CanFrame.standard(id: 0x125, data: [0x01, 0x02, 0x03, 0x04]),
              CanFrame.standard(id: 0x126, data: [0x01, 0x02, 0x03, 0x04]),
            ];

            final frameFuture = vcan1.receive(filter: CanFilter.whitelist(const [0x125, 0x126])).take(2).toList();

            frames.forEach(vcan0.send);

            await expectLater(
              frameFuture.timeout(const Duration(seconds: 10)),
              completion(containsAll(frames.skip(2))),
            );
          });

          testWidgets('receiving two streams simulatenously emits same frames on both streams', (_) async {
            final frames = [
              CanFrame.standard(id: 0x126, data: [0x01, 0x02, 0x03, 0x04]),
            ];

            final frameFuture1 = vcan1.receiveSingle();

            final frameFuture2 = vcan1.receiveSingle();

            frames.forEach(vcan0.send);

            await expectLater(
              frameFuture1.timeout(const Duration(seconds: 10)),
              completion(anyOf(frames)),
            );
            await expectLater(
              frameFuture2.timeout(const Duration(seconds: 10)),
              completion(anyOf(frames)),
            );
          });

          testWidgets('receiving two streams simulatenously with different filters', (_) async {
            final frames = [
              CanFrame.standard(id: 0x11F, data: [0x01, 0x02, 0x03, 0x04]),
              CanFrame.standard(id: 0x120, data: [0x01, 0x02, 0x03, 0x04]),
              CanFrame.standard(id: 0x121, data: [0x01, 0x02, 0x03, 0x04]),
              CanFrame.standard(id: 0x122, data: [0x01, 0x02, 0x03, 0x04]),
              CanFrame.standard(id: 0x123, data: [0x01, 0x02, 0x03, 0x04]),
              CanFrame.standard(id: 0x124, data: [0x01, 0x02, 0x03, 0x04]),
              CanFrame.standard(id: 0x125, data: [0x01, 0x02, 0x03, 0x04]),
              CanFrame.standard(id: 0x126, data: [0x01, 0x02, 0x03, 0x04]),
              CanFrame.standard(id: 0x127, data: [0x01, 0x02, 0x03, 0x04]),
              CanFrame.standard(id: 0x128, data: [0x01, 0x02, 0x03, 0x04]),
              CanFrame.standard(id: 0x129, data: [0x01, 0x02, 0x03, 0x04]),
              CanFrame.standard(id: 0x12A, data: [0x01, 0x02, 0x03, 0x04]),
            ];

            final frameFuture1 = vcan1.receive(filter: CanFilter.whitelist([0x123, 0x124])).take(2).toList();

            final frameFuture2 = vcan1.receive(filter: CanFilter.whitelist([0x128, 0x129])).take(2).toList();

            frames.forEach(vcan0.send);

            await expectLater(
              frameFuture1.timeout(const Duration(seconds: 10)),
              completion(containsAll([
                predicate((f) => f is CanFrame && f.id == 0x123),
                predicate((f) => f is CanFrame && f.id == 0x124),
              ])),
            );

            await expectLater(
              frameFuture2.timeout(const Duration(seconds: 10)),
              completion(containsAll([
                predicate((f) => f is CanFrame && f.id == 0x128),
                predicate((f) => f is CanFrame && f.id == 0x129),
              ])),
            );
          });

          testWidgets(
            'blacklisting single ID works',
            (_) async {
              final frames = [
                CanFrame.standard(id: 0x123, data: [0x01, 0x02, 0x03, 0x04]),
                CanFrame.standard(id: 0x124, data: [0x01, 0x02, 0x03, 0x04]),
                CanFrame.standard(id: 0x125, data: [0x01, 0x02, 0x03, 0x04]),
              ];

              final framesFuture = vcan1
                  .receive(
                    emitErrors: true,
                    filter: CanFilter.blacklist(const [0x124]),
                  )
                  .take(2)
                  .toList();

              frames.forEach(vcan0.send);

              await expectLater(
                framesFuture.timeout(const Duration(seconds: 10)),
                completion(containsAll([frames[0], frames[2]])),
              );
            },
          );

          testWidgets(
            'in-kernel SFF filter matches emulated SFF filter',
            (_) async {
              final filter = CanFilter.or([
                CanFilter.or([
                  const CanFilter.idEquals(
                    0x101,
                    mask: 0x080,
                    formats: CanFrameFormat.both,
                  ),
                  const CanFilter.idEquals(
                    0x040,
                    mask: 0x030,
                    formats: {CanFrameFormat.base},
                    types: {CanFrameType.remote},
                  ),
                  const CanFilter.not(
                    CanFilter.idEquals(
                      0x123,
                      formats: {CanFrameFormat.base},
                    ),
                  ),
                  CanFilter.blacklist([0x124])
                ]),
              ]);

              final frames = Iterable.generate(2048 * 2, (index) {
                if (index < 2048) {
                  return CanFrame.standard(id: index, data: [0]);
                } else {
                  return CanFrame.standardRemote(id: index - 2048);
                }
              });

              final matchingEmulated = frames.where((frame) => filter.matches(frame));

              final received = vcan1.receive(emitErrors: true, filter: filter).take(matchingEmulated.length).toList();

              frames.forEach(vcan0.send);

              await expectLater(
                received.timeout(const Duration(seconds: 30)),
                completion(matchingEmulated),
              );
            },
          );

          testWidgets(
            'in-kernel EFF filter matches emulated EFF filter',
            (_) async {
              const filter = CanFilter.or([
                CanFilter.or([
                  CanFilter.idEquals(
                    0x101,
                    mask: 0x080,
                    formats: CanFrameFormat.both,
                  ),
                  CanFilter.idEquals(
                    0x04024,
                    mask: 0x03024,
                    formats: {CanFrameFormat.extended},
                    types: {CanFrameType.remote},
                  ),
                  CanFilter.not(
                    CanFilter.idEquals(
                      0x1,
                      mask: 0x1,
                      formats: {CanFrameFormat.extended},
                    ),
                  ),
                  CanFilter.notIdEquals(
                    0x2,
                    mask: 0x2,
                    formats: {CanFrameFormat.extended},
                  ),
                  CanFilter.notIdEquals(
                    0x4,
                    mask: 0x4,
                    formats: {CanFrameFormat.extended},
                  ),
                  CanFilter.notIdEquals(
                    0x8,
                    mask: 0x8,
                    formats: {CanFrameFormat.extended},
                  )
                ]),
              ]);

              final frames = Iterable.generate(pow(2, 20 + 1).toInt(), (index) {
                if (index & 1 == 0) {
                  return CanFrame.extended(id: index >> 1, data: [0]);
                } else {
                  return CanFrame.extendedRemote(id: index >> 1);
                }
              });

              final matchingEmulated = frames.where((frame) => filter.matches(frame));

              final received = vcan1.receive(emitErrors: true, filter: filter).take(matchingEmulated.length).toList();

              frames.forEach(vcan0.send);

              await expectLater(
                received.timeout(const Duration(seconds: 30)),
                completion(equals(matchingEmulated)),
              );
            },
          );
        });
      });
    });
  });
}
