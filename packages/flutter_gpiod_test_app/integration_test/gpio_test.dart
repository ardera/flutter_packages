import 'dart:async';
import 'dart:ui';

import 'package:flutter_gpiod/flutter_gpiod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'gpio_matcher.dart';

Matcher isFreeInputLine(Object? name, [ActiveState? activeState]) {
  return matchGpioLineInfo(
    name,
    noConsumer,
    false,
    false,
    true,
    LineDirection.input,
    anything,
    Bias.disable,
    activeState ?? ActiveState.high,
  );
}

Matcher isFreeOutputLine(Object? name, {Object? outputMode, Object? bias, Object? activeState}) {
  return matchGpioLineInfo(
    name,
    noConsumer,
    false,
    false,
    true,
    LineDirection.output,
    outputMode ?? OutputMode.pushPull,
    bias ?? Bias.disable,
    activeState ?? ActiveState.high,
  );
}

Matcher isKernelInputLine(Object? name, Object? consumer, {Object? outputMode, Object? bias, Object? activeState}) {
  return matchGpioLineInfo(
    name,
    consumer,
    true,
    false,
    false,
    LineDirection.input,
    outputMode ?? OutputMode.pushPull,
    bias ?? Bias.disable,
    activeState ?? ActiveState.high,
  );
}

Matcher isKernelOutputLine(Object? name, Object? consumer, {Object? outputMode, Object? bias, Object? activeState}) {
  return matchGpioLineInfo(
    name,
    consumer,
    true,
    false,
    false,
    LineDirection.output,
    outputMode ?? OutputMode.pushPull,
    bias ?? Bias.disable,
    activeState ?? ActiveState.high,
  );
}

Matcher isOwnedInputLine(Object? name, Object? consumer, {Object? bias, Object? activeState}) {
  return matchGpioLineInfo(
    name,
    consumer,
    true,
    true,
    false,
    LineDirection.input,
    anything,
    bias ?? Bias.disable,
    activeState ?? ActiveState.high,
  );
}

void main() {
  // In some cases when running on ODROID C4, the display doesn't initialize correctly
  // and the window.physicalSize is zero.
  //
  // That'll cause this error later on:
  //  ══╡ EXCEPTION CAUGHT BY SCHEDULER LIBRARY ╞═════════════════════════════════════════════════════════
  //  The following assertion was thrown during a scheduler callback:
  //  Matrix4 entries must be finite.
  //  'dart:ui/painting.dart':
  //  Failed assertion: line 46 pos 10: '<optimized out>'
  //
  //  Either the assertion indicates an error in the framework itself, or we should provide substantially
  //  more information in this error message to help you determine and fix the underlying cause.
  //  In either case, please report this assertion by filing a bug on GitHub:
  //    https://github.com/flutter/flutter/issues/new?template=2_bug.md
  //
  //  When the exception was thrown, this was the stack:
  //  #2      _matrix4IsValid (dart:ui/painting.dart:46:10)
  //  #3      SceneBuilder.pushTransform (dart:ui/compositing.dart:326:12)
  //  #4      TransformLayer.addToScene (package:flutter/src/rendering/layer.dart:1909:27)
  //  #5      ContainerLayer.buildScene (package:flutter/src/rendering/layer.dart:1094:5)
  //  #6      RenderView.compositeFrame (package:flutter/src/rendering/view.dart:236:37)
  //  #7      RendererBinding.drawFrame (package:flutter/src/rendering/binding.dart:520:18)
  //  #8      WidgetsBinding.drawFrame (package:flutter/src/widgets/binding.dart:865:13)
  //  #9      RendererBinding._handlePersistentFrameCallback (package:flutter/src/rendering/binding.dart:381:5)
  //  #10     SchedulerBinding._invokeFrameCallback (package:flutter/src/scheduler/binding.dart:1289:15)
  //  #11     SchedulerBinding.handleDrawFrame (package:flutter/src/scheduler/binding.dart:1218:9)
  //  #12     LiveTestWidgetsFlutterBinding.handleDrawFrame (package:flutter_test/src/binding.dart:1710:13)
  //  #13     SchedulerBinding.scheduleWarmUpFrame.<anonymous closure> (package:flutter/src/scheduler/binding.dart:942:7)
  //  #28     _RawReceivePort._handleMessage (dart:isolate-patch/isolate_patch.dart:192:26)
  //  (elided 16 frames from class _AssertionError, class _Timer, dart:async, dart:async-patch, and package:stack_trace)
  //  ════════════════════════════════════════════════════════════════════════════════════════════════════
  //
  // We can't override the widgets binding so we can't really do anything about it. Maybe we can fix it
  // in the android subproject.
  // assert here so we at least fail early.
  assert(PlatformDispatcher.instance.implicitView!.physicalSize != Size.zero);

  group('test gpio on pi 4', () {
    testWidgets('test pi 4 general gpio', (_) async {
      final gpio = FlutterGpiod.instance;

      expect(gpio.supportsBias, isTrue);
      expect(gpio.supportsLineReconfiguration, isTrue);

      final chips = gpio.chips;
      expect(chips, hasLength(3));
    }, tags: ['pi4']);

    testWidgets('test pi 4 main gpio chip', (_) async {
      final chip = FlutterGpiod.instance.chips[0];
      expect(chip.index, 0);
      expect(chip.name, 'gpiochip0');
      expect(chip.label, 'pinctrl-bcm2711');

      final lines = chip.lines;
      expect(lines, hasLength(58));
      expect(lines[0], isFreeInputLine('ID_SDA'));
      expect(lines[1], isFreeInputLine('ID_SCL'));
      expect(lines[2], isFreeInputLine('SDA1'));
      expect(lines[3], isFreeInputLine('SCL1'));
      expect(lines[4], isFreeInputLine('GPIO_GCLK'));
      expect(lines[5], isFreeInputLine('GPIO5'));
      expect(lines[6], isFreeInputLine('GPIO6'));
      expect(lines[7], isFreeInputLine('SPI_CE1_N'));
      expect(lines[8], isFreeInputLine('SPI_CE0_N'));
      expect(lines[9], isFreeInputLine('SPI_MISO'));
      expect(lines[10], isFreeInputLine('SPI_MOSI'));
      expect(lines[11], isFreeInputLine('SPI_SCLK'));
      expect(lines[12], isFreeInputLine('GPIO12'));
      expect(lines[13], isFreeInputLine('GPIO13'));
      expect(lines[14], isFreeInputLine('TXD1'));
      expect(lines[15], isFreeInputLine('RXD1'));
      expect(lines[16], isFreeInputLine('GPIO16'));
      expect(lines[17], isFreeInputLine('GPIO17'));
      expect(lines[18], isFreeInputLine('GPIO18'));
      expect(lines[19], isFreeInputLine('GPIO19'));
      expect(lines[20], isFreeInputLine('GPIO20'));
      expect(lines[21], isFreeInputLine('GPIO21'));
      expect(lines[22], isFreeInputLine('GPIO22'));
      expect(lines[23], isFreeInputLine('GPIO23'));
      expect(lines[24], isFreeInputLine('GPIO24'));
      expect(lines[25], isFreeInputLine('GPIO25'));
      expect(lines[26], isFreeInputLine('GPIO26'));
      expect(lines[27], isFreeInputLine('GPIO27'));
      expect(lines[28], isFreeInputLine('RGMII_MDIO'));
      expect(lines[29], isFreeInputLine('RGMIO_MDC'));
      expect(lines[30], isFreeInputLine('CTS0'));
      expect(lines[31], isFreeInputLine('RTS0'));
      expect(lines[32], isFreeInputLine('TXD0'));
      expect(lines[33], isFreeInputLine('RXD0'));
      expect(lines[34], isFreeInputLine('SD1_CLK'));
      expect(lines[35], isFreeInputLine('SD1_CMD'));
      expect(lines[36], isFreeInputLine('SD1_DATA0'));
      expect(lines[37], isFreeInputLine('SD1_DATA1'));
      expect(lines[38], isFreeInputLine('SD1_DATA2'));
      expect(lines[39], isFreeInputLine('SD1_DATA3'));
      expect(lines[40], isFreeInputLine('PWM0_MISO'));
      expect(lines[41], isFreeInputLine('PWM1_MOSI'));
      expect(lines[42], isKernelOutputLine('STATUS_LED_G_CLK', 'led0'));
      expect(lines[43], isFreeInputLine('SPIFLASH_CE_N'));
      expect(lines[44], isFreeInputLine('SDA0'));
      expect(lines[45], isFreeInputLine('SCL0'));
      expect(lines[46], isFreeInputLine('RGMII_RXCLK'));
      expect(lines[47], isFreeInputLine('RGMII_RXCTL'));
      expect(lines[48], isFreeInputLine('RGMII_RXD0'));
      expect(lines[49], isFreeInputLine('RGMII_RXD1'));
      expect(lines[50], isFreeInputLine('RGMII_RXD2'));
      expect(lines[51], isFreeInputLine('RGMII_RXD3'));
      expect(lines[52], isFreeInputLine('RGMII_TXCLK'));
      expect(lines[53], isFreeInputLine('RGMII_TXCTL'));
      expect(lines[54], isFreeInputLine('RGMII_TXD0'));
      expect(lines[55], isFreeInputLine('RGMII_TXD1'));
      expect(lines[56], isFreeInputLine('RGMII_TXD2'));
      expect(lines[57], isFreeInputLine('RGMII_TXD3'));
    }, tags: ['pi4']);

    testWidgets('test pi 4 secondary gpio chip', (_) async {
      final chip = FlutterGpiod.instance.chips[1];
      expect(chip.index, 1);
      expect(chip.name, 'gpiochip1');
      expect(chip.label, 'raspberrypi-exp-gpio');

      final lines = chip.lines;
      expect(lines, hasLength(8));
      expect(lines[0], isFreeOutputLine('BT_ON'));
      expect(lines[1], isFreeOutputLine('WL_ON'));
      expect(lines[2], isKernelOutputLine('PWR_LED_OFF', 'led1', activeState: ActiveState.low));
      expect(lines[3], isFreeOutputLine('GLOBAL_RESET'));
      expect(lines[4], isKernelOutputLine('VDD_SD_IO_SEL', 'vdd-sd-io'));
      expect(lines[5], isFreeOutputLine('CAM_GPIO'));
      expect(lines[6], isKernelOutputLine('SD_PWR_ON', 'sd_vcc_reg'));
      expect(lines[7], isFreeInputLine('SD_OC_N'));
    }, tags: ['pi4']);

    testWidgets('test pi 4 third gpio chip', (_) async {
      final chip = FlutterGpiod.instance.chips[2];
      expect(chip.index, 2);
      expect(chip.name, 'gpiochip2');
      expect(chip.label, '7inch-touchscreen-p');

      final lines = chip.lines;
      expect(lines, hasLength(2));
      expect(lines[0], isKernelOutputLine(unnamed, '2.reg_bridge'));
      expect(lines[1], isKernelOutputLine(unnamed, 'reset', activeState: ActiveState.low));
    }, tags: ['pi4']);
  });

  group('test gpio on odroid c4', () {
    testWidgets(
      'test odroid c4 general gpio',
      (_) async {
        final gpio = FlutterGpiod.instance;

        expect(gpio.supportsBias, isFalse);
        expect(gpio.supportsLineReconfiguration, isFalse);

        final chips = gpio.chips;
        expect(chips, hasLength(2));
      },
      tags: ['odroidc4'],
    );

    testWidgets('test odroid c4 first gpio chip', (_) async {
      final chip = FlutterGpiod.instance.chips[0];
      expect(chip.index, 0);
      expect(chip.name, 'gpiochip0');
      expect(chip.label, 'aobus-banks');

      final lines = chip.lines;
      expect(lines, hasLength(16));
      expect(lines[0], isFreeInputLine(unnamed));
      expect(lines[1], isFreeInputLine(unnamed));
      expect(lines[2], isKernelOutputLine(unnamed, 'ffe09080.usb3phy'));
      expect(lines[3], isFreeInputLine(unnamed));
      expect(lines[4], isFreeInputLine(unnamed));
      expect(lines[5], isFreeInputLine(unnamed));
      expect(lines[6], isKernelOutputLine(unnamed, 'amlsd'));
      expect(lines[7], isFreeInputLine(unnamed));
      expect(lines[8], isFreeInputLine(unnamed));
      expect(lines[9], isFreeInputLine(unnamed));
      expect(lines[10], isFreeInputLine(unnamed));
      expect(lines[11], isKernelOutputLine(unnamed, '?'));
      expect(lines[12], isFreeInputLine(unnamed));
      expect(lines[13], isFreeInputLine(unnamed));
      expect(lines[14], isFreeInputLine(unnamed));
      expect(lines[15], isFreeInputLine(unnamed));
    }, tags: ['odroidc4']);

    testWidgets('test odroid c4 second gpio chip', (_) async {
      final chip = FlutterGpiod.instance.chips[1];
      expect(chip.index, 1);
      expect(chip.name, 'gpiochip1');
      expect(chip.label, 'periphs-banks');

      final lines = chip.lines;
      expect(lines, hasLength(86));
      expect(lines[0], isFreeInputLine(unnamed));
      expect(lines[1], isFreeInputLine(unnamed));
      expect(lines[2], isFreeInputLine(unnamed));
      expect(lines[3], isFreeInputLine(unnamed));
      expect(lines[4], isFreeInputLine(unnamed));
      expect(lines[5], isFreeInputLine(unnamed));
      expect(lines[6], isFreeInputLine(unnamed));
      expect(lines[7], isFreeInputLine(unnamed));
      expect(lines[8], isFreeInputLine(unnamed));
      expect(lines[9], isFreeInputLine(unnamed));
      expect(lines[10], isFreeInputLine(unnamed));
      expect(lines[11], isFreeInputLine(unnamed));
      expect(lines[12], isFreeInputLine(unnamed));
      expect(lines[13], isFreeInputLine(unnamed));
      expect(lines[14], isFreeInputLine(unnamed));
      expect(lines[15], isFreeInputLine(unnamed));
      expect(lines[16], isFreeInputLine(unnamed));
      expect(lines[17], isFreeInputLine(unnamed));
      expect(lines[18], isFreeInputLine(unnamed));
      expect(lines[19], isFreeInputLine(unnamed));
      expect(lines[20], isFreeInputLine(unnamed));
      expect(lines[21], isKernelOutputLine(unnamed, 'usb_hub'));
      expect(lines[22], isFreeInputLine(unnamed));
      expect(lines[23], isFreeInputLine(unnamed));
      expect(lines[24], isFreeInputLine(unnamed));
      expect(lines[25], isFreeInputLine(unnamed));
      expect(lines[26], isFreeInputLine(unnamed));
      expect(lines[27], isFreeInputLine(unnamed));
      expect(lines[28], isFreeInputLine(unnamed));
      expect(lines[29], isFreeOutputLine(unnamed));
      expect(lines[30], isFreeInputLine(unnamed));
      expect(lines[31], isFreeInputLine(unnamed));
      expect(lines[32], isFreeInputLine(unnamed));
      expect(lines[33], isFreeInputLine(unnamed));
      expect(lines[34], isFreeInputLine(unnamed));
      expect(lines[35], isFreeInputLine(unnamed));
      expect(lines[36], isFreeInputLine(unnamed));
      expect(lines[37], isFreeInputLine(unnamed));
      expect(lines[38], isKernelOutputLine(unnamed, 'amlsd'));
      expect(lines[39], isFreeInputLine(unnamed));
      expect(lines[40], isFreeInputLine(unnamed));
      expect(lines[41], isFreeInputLine(unnamed));
      expect(lines[42], isFreeInputLine(unnamed));
      expect(lines[43], isFreeInputLine(unnamed));
      expect(lines[44], isFreeInputLine(unnamed));
      expect(lines[45], isFreeInputLine(unnamed));
      expect(lines[46], isFreeInputLine(unnamed));
      expect(lines[47], isFreeInputLine(unnamed));
      expect(lines[48], isKernelInputLine(unnamed, 'amlsd'));
      expect(lines[49], isFreeInputLine(unnamed));
      expect(lines[50], isFreeInputLine(unnamed));
      expect(lines[51], isFreeInputLine(unnamed));
      expect(lines[52], isFreeInputLine(unnamed));
      expect(lines[53], isFreeInputLine(unnamed));
      expect(lines[54], isFreeInputLine(unnamed));
      expect(lines[55], isFreeInputLine(unnamed));
      expect(lines[56], isFreeInputLine(unnamed));
      expect(lines[57], isFreeInputLine(unnamed));
      expect(lines[58], isFreeInputLine(unnamed));
      expect(lines[59], isFreeInputLine(unnamed));
      expect(lines[60], isFreeInputLine(unnamed));
      expect(lines[61], isFreeInputLine(unnamed));
      expect(lines[62], isFreeInputLine(unnamed));
      expect(lines[63], isFreeInputLine(unnamed));
      expect(lines[64], isFreeInputLine(unnamed));
      expect(lines[65], isFreeInputLine(unnamed));
      expect(
        lines[66],
        matchGpioLineInfo(
          unnamed,
          noConsumer,
          false,
          false,
          true,
          anyOf(LineDirection.input, LineDirection.output),
          anything,
          Bias.disable,
          ActiveState.high,
        ),
      );
      expect(lines[67], isFreeInputLine(unnamed));
      expect(lines[68], isFreeInputLine(unnamed));
      expect(lines[69], isFreeInputLine(unnamed));
      expect(lines[70], isFreeInputLine(unnamed));
      expect(lines[71], isFreeInputLine(unnamed));
      expect(lines[72], isFreeInputLine(unnamed));
      expect(lines[73], isFreeInputLine(unnamed));
      expect(lines[74], isFreeInputLine(unnamed));
      expect(lines[75], isFreeInputLine(unnamed));
      expect(lines[76], isKernelOutputLine(unnamed, 'spi0.0'));
      expect(lines[77], isFreeInputLine(unnamed));
      expect(lines[78], isFreeInputLine(unnamed));
      expect(lines[79], isFreeInputLine(unnamed));
      expect(lines[80], isFreeInputLine(unnamed));
      expect(lines[81], isFreeInputLine(unnamed));
      expect(lines[82], isFreeInputLine(unnamed));
      expect(lines[83], isFreeInputLine(unnamed));
      expect(lines[84], isFreeInputLine(unnamed));
      expect(lines[85], isFreeInputLine(unnamed));
    }, tags: ['odroidc4']);

    group('request gpio lines', () {
      late List<GpioLine> requestedLines;
      late bool rerequestGpiox0AsInput;

      void requestInput(
        GpioLine line, {
        String consumer = '',
        Bias? bias,
        ActiveState activeState = ActiveState.high,
        Set<SignalEdge> triggers = const {},
      }) {
        line.requestInput(
          consumer: consumer,
          bias: bias,
          activeState: activeState,
          triggers: triggers,
        );

        requestedLines.add(line);
      }

      void requestOutput(
        GpioLine line, {
        String consumer = '',
        OutputMode outputMode = OutputMode.pushPull,
        Bias? bias,
        ActiveState activeState = ActiveState.high,
        required bool initialValue,
      }) {
        line.requestOutput(
          consumer: consumer,
          outputMode: outputMode,
          bias: bias,
          activeState: activeState,
          initialValue: initialValue,
        );

        requestedLines.add(line);
      }

      void release(GpioLine line) {
        line.release();
        requestedLines.remove(line);
      }

      setUp(() {
        requestedLines = <GpioLine>[];
        rerequestGpiox0AsInput = false;
      });

      tearDown(() {
        dynamic err;

        for (final l in List.of(requestedLines)) {
          try {
            release(l);
          } catch (e) {
            // catch the error so we can report it after,
            // but keep trying to release the other lines
            err ??= e;
          }
        }

        if (rerequestGpiox0AsInput) {
          final gpiox0 = FlutterGpiod.instance.chips[1].lines[476 - 410];
          requestInput(gpiox0);
          release(gpiox0);
        }

        if (err != null) {
          throw err;
        }
      });

      testWidgets('test odroid c4 first gpio chip requesting lines', (_) async {
        final lines = FlutterGpiod.instance.chips[0].lines;

        // request all the lines
        expect(() => requestInput(lines[0], consumer: 'test0'), returnsNormally);
        expect(() => requestInput(lines[1], consumer: 'test1'), returnsNormally);
        // already consumed by 'ffe09080.usb3phy'
        // expect(() => requestInput(lines[2], consumer: 'test2'), returnsNormally);
        expect(() => requestInput(lines[3], consumer: 'test3'), returnsNormally);
        // expect(() => requestInput(lines[4], consumer: 'test4'), returnsNormally);
        // expect(() => requestInput(lines[5], consumer: 'test5'), returnsNormally);
        // already consumed by 'amlsd'
        // expect(() => requestInput(lines[6], consumer: 'test'), returnsNormally);
        // expect(() => requestInput(lines[7], consumer: 'test7'), returnsNormally);
        // expect(() => requestInput(lines[8], consumer: 'test8'), returnsNormally);
        // expect(() => requestInput(lines[9], consumer: 'test9'), returnsNormally);
        // expect(() => requestInput(lines[10], consumer: 'test10'), returnsNormally);
        // already consumed by '?'
        // expect(() => requestInput(lines[11], consumer: 'test11'), returnsNormally);
        expect(() => requestInput(lines[12], consumer: 'test12'), returnsNormally);
        // expect(() => requestInput(lines[13], consumer: 'test13'), returnsNormally);
        expect(() => requestInput(lines[14], consumer: 'test14'), returnsNormally);
        expect(() => requestInput(lines[15], consumer: 'test15'), returnsNormally);

        // check the listing matches what we expect
        expect(lines[0], isOwnedInputLine(unnamed, 'test0'));
        expect(lines[1], isOwnedInputLine(unnamed, 'test1'));
        expect(lines[3], isOwnedInputLine(unnamed, 'test3'));
        expect(lines[12], isOwnedInputLine(unnamed, 'test12'));
        expect(lines[14], isOwnedInputLine(unnamed, 'test14'));
        expect(lines[15], isOwnedInputLine(unnamed, 'test15'));

        // release all the lines
        expect(() => release(lines[0]), returnsNormally);
        expect(() => release(lines[1]), returnsNormally);
        expect(() => release(lines[3]), returnsNormally);
        expect(() => release(lines[12]), returnsNormally);
        expect(() => release(lines[14]), returnsNormally);
        expect(() => release(lines[15]), returnsNormally);
      }, tags: ['odroidc4']);

      testWidgets('test odroid c4 second gpio chip requesting lines', (_) async {
        final lines = FlutterGpiod.instance.chips[1].lines;

        // request all the lines
        expect(() => requestInput(lines[0], consumer: 'test0'), returnsNormally);
        // expect(() => requestInput(lines[1], consumer: 'test1'), returnsNormally);
        // expect(() => requestInput(lines[2], consumer: 'test2'), returnsNormally);
        // expect(() => requestInput(lines[3], consumer: 'test3'), returnsNormally);
        // expect(() => requestInput(lines[4], consumer: 'test4'), returnsNormally);
        // expect(() => requestInput(lines[5], consumer: 'test5'), returnsNormally);
        // expect(() => requestInput(lines[6], consumer: 'test6'), returnsNormally);
        // expect(() => requestInput(lines[7], consumer: 'test7'), returnsNormally);
        // expect(() => requestInput(lines[8], consumer: 'test8'), returnsNormally);
        // expect(() => requestInput(lines[9], consumer: 'test9'), returnsNormally);
        // expect(() => requestInput(lines[10], consumer: 'test10'), returnsNormally);
        // expect(() => requestInput(lines[11], consumer: 'test11'), returnsNormally);
        // expect(() => requestInput(lines[12], consumer: 'test12'), returnsNormally);
        // expect(() => requestInput(lines[13], consumer: 'test13'), returnsNormally);
        // expect(() => requestInput(lines[14], consumer: 'test14'), returnsNormally);
        expect(() => requestInput(lines[15], consumer: 'test15'), returnsNormally);
        expect(() => requestInput(lines[16], consumer: 'test16'), returnsNormally);
        // expect(() => requestInput(lines[17], consumer: 'test17'), returnsNormally);
        // expect(() => requestInput(lines[18], consumer: 'test18'), returnsNormally);
        // expect(() => requestInput(lines[19], consumer: 'test19'), returnsNormally);
        // expect(() => requestInput(lines[20], consumer: 'test20'), returnsNormally);
        // already consumed by 'usb_hub'
        // expect(() => requestInput(lines[21], consumer: 'test'), returnsNormally);
        expect(() => requestInput(lines[22], consumer: 'test22'), returnsNormally);
        expect(() => requestInput(lines[23], consumer: 'test23'), returnsNormally);
        expect(() => requestInput(lines[24], consumer: 'test24'), returnsNormally);
        expect(() => requestInput(lines[25], consumer: 'test25'), returnsNormally);
        // expect(() => requestInput(lines[26], consumer: 'test26'), returnsNormally);
        // expect(() => requestInput(lines[27], consumer: 'test27'), returnsNormally);
        // expect(() => requestInput(lines[28], consumer: 'test28'), returnsNormally);
        // output line
        // expect(() => requestInput(lines[29], consumer: 'test29'), returnsNormally);
        // expect(() => requestInput(lines[30], consumer: 'test30'), returnsNormally);
        // expect(() => requestInput(lines[31], consumer: 'test31'), returnsNormally);
        // expect(() => requestInput(lines[32], consumer: 'test32'), returnsNormally);
        // expect(() => requestInput(lines[33], consumer: 'test33'), returnsNormally);
        // expect(() => requestInput(lines[34], consumer: 'test34'), returnsNormally);
        expect(() => requestInput(lines[35], consumer: 'test35'), returnsNormally);
        // expect(() => requestInput(lines[36], consumer: 'test36'), returnsNormally);
        expect(() => requestInput(lines[37], consumer: 'test37'), returnsNormally);
        // already consumed by 'amlsd'
        // expect(() => requestInput(lines[38], consumer: 'test38'), returnsNormally);
        // expect(() => requestInput(lines[39], consumer: 'test39'), returnsNormally);
        expect(() => requestInput(lines[40], consumer: 'test40'), returnsNormally);
        expect(() => requestInput(lines[41], consumer: 'test41'), returnsNormally);
        expect(() => requestInput(lines[42], consumer: 'test42'), returnsNormally);
        expect(() => requestInput(lines[43], consumer: 'test43'), returnsNormally);
        expect(() => requestInput(lines[44], consumer: 'test44'), returnsNormally);
        expect(() => requestInput(lines[45], consumer: 'test45'), returnsNormally);
        expect(() => requestInput(lines[46], consumer: 'test46'), returnsNormally);
        expect(() => requestInput(lines[47], consumer: 'test47'), returnsNormally);
        // already consumed by 'amlsd'
        // expect(() => requestInput(lines[48], consumer: 'test'), returnsNormally);
        expect(() => requestInput(lines[49], consumer: 'test49'), returnsNormally);
        expect(() => requestInput(lines[50], consumer: 'test50'), returnsNormally);
        expect(() => requestInput(lines[51], consumer: 'test51'), returnsNormally);
        expect(() => requestInput(lines[52], consumer: 'test52'), returnsNormally);
        expect(() => requestInput(lines[53], consumer: 'test53'), returnsNormally);
        expect(() => requestInput(lines[54], consumer: 'test54'), returnsNormally);
        expect(() => requestInput(lines[55], consumer: 'test55'), returnsNormally);
        expect(() => requestInput(lines[56], consumer: 'test56'), returnsNormally);
        expect(() => requestInput(lines[57], consumer: 'test57'), returnsNormally);
        expect(() => requestInput(lines[58], consumer: 'test58'), returnsNormally);
        expect(() => requestInput(lines[59], consumer: 'test59'), returnsNormally);
        expect(() => requestInput(lines[60], consumer: 'test60'), returnsNormally);
        expect(() => requestInput(lines[61], consumer: 'test61'), returnsNormally);
        expect(() => requestInput(lines[62], consumer: 'test62'), returnsNormally);
        expect(() => requestInput(lines[63], consumer: 'test63'), returnsNormally);
        // expect(() => requestInput(lines[64], consumer: 'test64'), returnsNormally);
        // expect(() => requestInput(lines[65], consumer: 'test65'), returnsNormally);
        expect(() => requestInput(lines[66], consumer: 'test66'), returnsNormally);
        expect(() => requestInput(lines[67], consumer: 'test67'), returnsNormally);
        expect(() => requestInput(lines[68], consumer: 'test68'), returnsNormally);
        expect(() => requestInput(lines[69], consumer: 'test69'), returnsNormally);
        expect(() => requestInput(lines[70], consumer: 'test70'), returnsNormally);
        expect(() => requestInput(lines[71], consumer: 'test71'), returnsNormally);
        expect(() => requestInput(lines[72], consumer: 'test72'), returnsNormally);
        // expect(() => requestInput(lines[73], consumer: 'test73'), returnsNormally);
        // expect(() => requestInput(lines[74], consumer: 'test74'), returnsNormally);
        // expect(() => requestInput(lines[75], consumer: 'test75'), returnsNormally);
        // already consumed by 'spi0.0'
        // expect(() => requestInput(lines[76], consumer: 'test'), returnsNormally);
        // expect(() => requestInput(lines[77], consumer: 'test77'), returnsNormally);
        // expect(() => requestInput(lines[78], consumer: 'test78'), returnsNormally);
        // expect(() => requestInput(lines[79], consumer: 'test79'), returnsNormally);
        expect(() => requestInput(lines[80], consumer: 'test80'), returnsNormally);
        expect(() => requestInput(lines[81], consumer: 'test81'), returnsNormally);
        // expect(() => requestInput(lines[82], consumer: 'test82'), returnsNormally);
        // expect(() => requestInput(lines[83], consumer: 'test83'), returnsNormally);
        // expect(() => requestInput(lines[84], consumer: 'test84'), returnsNormally);
        expect(() => requestInput(lines[85], consumer: 'test85'), returnsNormally);

        // check the listing matches what we expect
        expect(lines[0], isOwnedInputLine(unnamed, 'test0'));
        expect(lines[15], isOwnedInputLine(unnamed, 'test15'));
        expect(lines[16], isOwnedInputLine(unnamed, 'test16'));
        expect(lines[22], isOwnedInputLine(unnamed, 'test22'));
        expect(lines[23], isOwnedInputLine(unnamed, 'test23'));
        expect(lines[24], isOwnedInputLine(unnamed, 'test24'));
        expect(lines[25], isOwnedInputLine(unnamed, 'test25'));
        expect(lines[35], isOwnedInputLine(unnamed, 'test35'));
        expect(lines[37], isOwnedInputLine(unnamed, 'test37'));
        expect(lines[40], isOwnedInputLine(unnamed, 'test40'));
        expect(lines[41], isOwnedInputLine(unnamed, 'test41'));
        expect(lines[42], isOwnedInputLine(unnamed, 'test42'));
        expect(lines[43], isOwnedInputLine(unnamed, 'test43'));
        expect(lines[44], isOwnedInputLine(unnamed, 'test44'));
        expect(lines[45], isOwnedInputLine(unnamed, 'test45'));
        expect(lines[46], isOwnedInputLine(unnamed, 'test46'));
        expect(lines[47], isOwnedInputLine(unnamed, 'test47'));
        expect(lines[49], isOwnedInputLine(unnamed, 'test49'));
        expect(lines[50], isOwnedInputLine(unnamed, 'test50'));
        expect(lines[51], isOwnedInputLine(unnamed, 'test51'));
        expect(lines[52], isOwnedInputLine(unnamed, 'test52'));
        expect(lines[53], isOwnedInputLine(unnamed, 'test53'));
        expect(lines[54], isOwnedInputLine(unnamed, 'test54'));
        expect(lines[55], isOwnedInputLine(unnamed, 'test55'));
        expect(lines[56], isOwnedInputLine(unnamed, 'test56'));
        expect(lines[57], isOwnedInputLine(unnamed, 'test57'));
        expect(lines[58], isOwnedInputLine(unnamed, 'test58'));
        expect(lines[59], isOwnedInputLine(unnamed, 'test59'));
        expect(lines[60], isOwnedInputLine(unnamed, 'test60'));
        expect(lines[61], isOwnedInputLine(unnamed, 'test61'));
        expect(lines[62], isOwnedInputLine(unnamed, 'test62'));
        expect(lines[63], isOwnedInputLine(unnamed, 'test63'));
        expect(lines[66], isOwnedInputLine(unnamed, 'test66'));
        expect(lines[67], isOwnedInputLine(unnamed, 'test67'));
        expect(lines[68], isOwnedInputLine(unnamed, 'test68'));
        expect(lines[69], isOwnedInputLine(unnamed, 'test69'));
        expect(lines[70], isOwnedInputLine(unnamed, 'test70'));
        expect(lines[71], isOwnedInputLine(unnamed, 'test71'));
        expect(lines[72], isOwnedInputLine(unnamed, 'test72'));
        expect(lines[80], isOwnedInputLine(unnamed, 'test80'));
        expect(lines[81], isOwnedInputLine(unnamed, 'test81'));
        expect(lines[85], isOwnedInputLine(unnamed, 'test85'));

        // release all the lines
        expect(() => release(lines[0]), returnsNormally);
        expect(() => release(lines[15]), returnsNormally);
        expect(() => release(lines[16]), returnsNormally);
        expect(() => release(lines[22]), returnsNormally);
        expect(() => release(lines[23]), returnsNormally);
        expect(() => release(lines[24]), returnsNormally);
        expect(() => release(lines[25]), returnsNormally);
        expect(() => release(lines[35]), returnsNormally);
        expect(() => release(lines[37]), returnsNormally);
        expect(() => release(lines[40]), returnsNormally);
        expect(() => release(lines[41]), returnsNormally);
        expect(() => release(lines[42]), returnsNormally);
        expect(() => release(lines[43]), returnsNormally);
        expect(() => release(lines[44]), returnsNormally);
        expect(() => release(lines[45]), returnsNormally);
        expect(() => release(lines[46]), returnsNormally);
        expect(() => release(lines[47]), returnsNormally);
        expect(() => release(lines[49]), returnsNormally);
        expect(() => release(lines[50]), returnsNormally);
        expect(() => release(lines[51]), returnsNormally);
        expect(() => release(lines[52]), returnsNormally);
        expect(() => release(lines[53]), returnsNormally);
        expect(() => release(lines[54]), returnsNormally);
        expect(() => release(lines[55]), returnsNormally);
        expect(() => release(lines[56]), returnsNormally);
        expect(() => release(lines[57]), returnsNormally);
        expect(() => release(lines[58]), returnsNormally);
        expect(() => release(lines[59]), returnsNormally);
        expect(() => release(lines[60]), returnsNormally);
        expect(() => release(lines[61]), returnsNormally);
        expect(() => release(lines[62]), returnsNormally);
        expect(() => release(lines[63]), returnsNormally);
        expect(() => release(lines[66]), returnsNormally);
        expect(() => release(lines[67]), returnsNormally);
        expect(() => release(lines[68]), returnsNormally);
        expect(() => release(lines[69]), returnsNormally);
        expect(() => release(lines[70]), returnsNormally);
        expect(() => release(lines[71]), returnsNormally);
        expect(() => release(lines[72]), returnsNormally);
        expect(() => release(lines[80]), returnsNormally);
        expect(() => release(lines[81]), returnsNormally);
        expect(() => release(lines[85]), returnsNormally);
      }, tags: ['odroidc4']);

      testWidgets('test edge events', (tester) async {
        // This test assumes there's an electrical connection between pins
        // GPIOX.4 and GPIOX.0.

        // Take this sheet as reference: https://wiki.odroid.com/odroid-c4/hardware/expansion_connectors
        // periphs-banks has export numbers 410-495.
        // aobus-banks has export numbers 496-511.

        // This is GPIOX.4 (export number 480)
        final gpiox4 = FlutterGpiod.instance.chips[1].lines[480 - 410];

        // This is GPIOX.0 (export number 476)
        final gpiox0 = FlutterGpiod.instance.chips[1].lines[476 - 410];

        // Now request GPIOX.4 as input and GPIOX.0 as output
        requestInput(gpiox4, consumer: 'test', triggers: const {SignalEdge.rising});
        requestOutput(gpiox0, consumer: 'test', initialValue: false);
        rerequestGpiox0AsInput = true;

        final completer = Completer<SignalEvent>();
        gpiox4.onEvent.first.then(
          (e) {
            if (!completer.isCompleted) {
              completer.complete(e);
            }
          },
          onError: (err, stackTrace) {
            if (!completer.isCompleted) {
              completer.completeError(err, stackTrace);
            }
          },
        );

        // Set the output pin to high, this should trigger an edge event
        gpiox0.setValue(true);
        gpiox0.setValue(false);

        // wait for some time so the edge event arrives

        //await tester.pump(const Duration(seconds: 5));
        TestWidgetsFlutterBinding.ensureInitialized().delayed(const Duration(seconds: 5)).then((value) {
          if (!completer.isCompleted) {
            completer.completeError(TimeoutException('Waiting for signal edge timed out.', const Duration(seconds: 5)));
          }
        });

        late SignalEvent event;
        await expectLater(completer.future.then((e) => event = e), completes);

        final now = DateTime.now();
        const oneDay = Duration(days: 1);
        expect(event.time.isAfter(now.subtract(oneDay)), isTrue);
        expect(event.time.isBefore(now.add(oneDay)), isTrue);
        expect(event.edge, SignalEdge.rising);

        release(gpiox0);
        release(gpiox4);

        // request as input and release again because for some reason,
        // otherwise after release it'll still be an output line
        // (which will make some test above fail)
        requestInput(gpiox0);
        rerequestGpiox0AsInput = false;
        release(gpiox0);
      }, tags: ['odroidc4']);
    });
  });

  group('test gpio on lattepanda', () {
    // $ uname -a
    // Linux panda 5.15.0-69-generic #76~20.04.1-Ubuntu SMP Mon Mar 20 15:54:19 UTC 2023 x86_64 x86_64 x86_64 GNU/Linux

    testWidgets(
      'test lattepanda general gpio',
      (_) async {
        final gpio = FlutterGpiod.instance;

        expect(gpio.supportsBias, isFalse);
        expect(gpio.supportsLineReconfiguration, isFalse);

        final chips = gpio.chips;
        expect(chips, hasLength(5));
      },
      tags: ['panda'],
    );

    testWidgets('test lattepanda first gpio chip', (_) async {
      final chip = FlutterGpiod.instance.chips[0];
      expect(chip.index, 0);
      expect(chip.name, 'gpiochip0');
      expect(chip.label, 'aobus-banks');

      final lines = chip.lines;
      expect(lines, hasLength(98));

      expect(lines.getRange(0, 78), everyElement(isFreeInputLine(unnamed)));
      expect(lines[78], isKernelInputLine(unnamed, 'volume_up'));
      expect(lines[79], isFreeInputLine(unnamed));
      expect(lines[80], isKernelInputLine(unnamed, 'volume_down'));
      expect(lines.getRange(81, 98), everyElement(isFreeInputLine(unnamed)));
    }, tags: ['panda']);

    testWidgets('test lattepanda second gpio chip', (_) async {
      final chip = FlutterGpiod.instance.chips[1];
      expect(chip.index, 1);
      expect(chip.name, 'gpiochip1');
      expect(chip.label, 'aobus-banks');

      final lines = chip.lines;
      expect(lines, hasLength(73));

      expect(lines[0], isFreeOutputLine(unnamed));
      expect(lines[1], isFreeInputLine(unnamed));
      expect(lines[2], isFreeOutputLine(unnamed));
      expect(lines[3], isKernelInputLine(unnamed, 'id'));
      expect(lines[4], isFreeOutputLine(unnamed));
      expect(lines[5], isFreeInputLine(unnamed));
      expect(lines[6], isFreeOutputLine(unnamed));
      expect(lines.getRange(7, 15), everyElement(isFreeInputLine(unnamed)));
      expect(lines[15], isKernelInputLine(unnamed, 'interrupt'));
      expect(lines.getRange(16, 24), everyElement(isFreeInputLine(unnamed)));
      expect(lines[24], isFreeOutputLine(unnamed));
      expect(lines[25], isFreeOutputLine(unnamed));
      expect(lines.getRange(26, 47), everyElement(isFreeInputLine(unnamed)));
      expect(lines[47], isFreeOutputLine(unnamed));
      expect(lines.getRange(48, 55), everyElement(isFreeInputLine(unnamed)));
      expect(lines[55], isFreeOutputLine(unnamed));
      expect(lines.getRange(56, 60), everyElement(isFreeInputLine(unnamed)));
      expect(lines[60], isFreeOutputLine(unnamed));
      expect(lines[61], isFreeInputLine(unnamed));
      expect(lines[62], isFreeInputLine(unnamed));
      expect(lines[63], isFreeOutputLine(unnamed));
      expect(lines[64], isFreeInputLine(unnamed));
      expect(lines[65], isFreeOutputLine(unnamed));
      expect(lines[66], isFreeOutputLine(unnamed));
      expect(lines[67], isFreeInputLine(unnamed));
      expect(lines[68], isFreeInputLine(unnamed));
      expect(lines[69], isFreeOutputLine(unnamed));
      expect(lines[70], isFreeOutputLine(unnamed));
      expect(lines[71], isFreeInputLine(unnamed));
      expect(lines[72], isFreeOutputLine(unnamed));
    }, tags: ['panda']);

    testWidgets('test lattepanda third gpio chip', (_) async {
      final chip = FlutterGpiod.instance.chips[2];
      expect(chip.index, 2);
      expect(chip.name, 'gpiochip2');
      expect(chip.label, 'aobus-banks');

      final lines = chip.lines;
      expect(lines, hasLength(27));

      expect(lines.getRange(0, 8), everyElement(isFreeInputLine(unnamed)));
      expect(lines[8], isKernelInputLine(unnamed, 'power', activeState: ActiveState.low));
      expect(lines.getRange(9, 16), everyElement(isFreeInputLine(unnamed)));
      expect(lines[16], isKernelOutputLine(unnamed, 'ACPI:OpRegion'));
      expect(lines.getRange(17, 24), everyElement(isFreeInputLine(unnamed)));
      expect(lines[24], isFreeOutputLine(unnamed));
      expect(lines[25], isFreeInputLine(unnamed));
      expect(lines[26], isFreeInputLine(unnamed));
    }, tags: ['panda']);

    testWidgets('test lattepanda fourth gpio chip', (_) async {
      final chip = FlutterGpiod.instance.chips[3];
      expect(chip.index, 3);
      expect(chip.name, 'gpiochip3');
      expect(chip.label, 'aobus-banks');

      final lines = chip.lines;
      expect(lines, hasLength(86));

      expect(lines.getRange(0, 46), everyElement(isFreeInputLine(unnamed)));
      expect(lines[46], isKernelOutputLine(unnamed, 'vbus'));
      expect(lines.getRange(47, 78), everyElement(isFreeInputLine(unnamed)));
      expect(lines[78], isFreeOutputLine(unnamed));
      expect(lines[79], isKernelInputLine(unnamed, 'interrupt'));
      expect(lines[80], isFreeInputLine(unnamed));
      expect(lines[81], isKernelInputLine(unnamed, '80860F14:01', activeState: ActiveState.low));
      expect(lines[82], isFreeInputLine(unnamed));
      expect(lines[83], isFreeInputLine(unnamed));
      expect(lines[84], isFreeInputLine(unnamed));
      expect(lines[85], isFreeOutputLine(unnamed));
    }, tags: ['panda']);

    testWidgets('test lattepanda fifth gpio chip', (_) async {
      final chip = FlutterGpiod.instance.chips[4];
      expect(chip.index, 4);
      expect(chip.name, 'gpiochip4');
      expect(chip.label, 'aobus-banks');

      final lines = chip.lines;
      expect(lines, hasLength(3));

      expect(lines[0], isFreeInputLine(unnamed));
      expect(lines[1], isFreeInputLine(unnamed));
      expect(lines[2], isKernelInputLine(unnamed, 'ACPI:Event'));
    }, tags: ['panda']);
  });
}
