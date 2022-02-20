import 'package:flutter_gpiod/flutter_gpiod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

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

void main() {
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
  });
}
