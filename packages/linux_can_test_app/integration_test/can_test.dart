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

      expect(devices[0].networkInterface.index, equals(0));
      expect(devices[0].networkInterface.name, equals('can0'));
      expect(devices[1].networkInterface.index, equals(1));
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
      });

      testWidgets('writing standard CAN frame to can0', (_) async {
        expect(
          () => can0.write(CanFrame.standard(id: 0x123, data: [0x01, 0x02, 0x03, 0x04])),
          returnsNormally,
        );
      }, tags: 'pi3-can');

      testWidgets('writing standard CAN frame to can0 and reading from can1', (_) async {
        can0.write(CanFrame.standard(id: 0x123, data: [0x01, 0x02, 0x03, 0x04]));

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

        late CanFrame? frame;
        expect(() => frame = can0.read(), returnsNormally);
        expect(frame, isNotNull);
        expect(frame, isA<CanStandardDataFrame>());

        final dataFrame = frame as CanStandardDataFrame;
        expect(dataFrame.id, equals(0x123));
        expect(dataFrame.data, hasLength(4));
        expect(dataFrame.data, equals([0x01, 0x02, 0x03, 0x04]));
      }, tags: 'pi3-can');
    });
  });
}
