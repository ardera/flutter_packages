import 'package:flutter_gpiod/flutter_gpiod.dart';
import 'package:flutter_test/flutter_test.dart';

class _GpioChipHasIndex extends CustomMatcher {
  _GpioChipHasIndex(matcher) : super('GpioChip with index that is', 'index', matcher);

  @override
  Object? featureValueOf(actual) => (actual as GpioChip).index;
}

class _GpioChipHasName extends CustomMatcher {
  _GpioChipHasName(matcher) : super('GpioChip with name that is', 'name', matcher);

  @override
  Object? featureValueOf(actual) => (actual as GpioChip).name;
}

class _GpioChipHasLabel extends CustomMatcher {
  _GpioChipHasLabel(matcher) : super('GpioChip with label that is', 'label', matcher);

  @override
  Object? featureValueOf(actual) => (actual as GpioChip).label;
}

class _GpioChipHasLines extends CustomMatcher {
  _GpioChipHasLines(matcher) : super('GpioChip with lines that is', 'lines', matcher);

  @override
  Object? featureValueOf(actual) => (actual as GpioChip).lines;
}

class _GpioLineHasInfo extends CustomMatcher {
  _GpioLineHasInfo(matcher) : super('GpioLine with info that is', 'info', matcher);

  @override
  Object? featureValueOf(actual) => (actual as GpioLine).info;
}

class _LineInfoHasName extends CustomMatcher {
  _LineInfoHasName(matcher) : super("LineInfo with name that is", "name", matcher);

  @override
  featureValueOf(actual) => (actual as LineInfo).name;
}

class _LineInfoHasConsumer extends CustomMatcher {
  _LineInfoHasConsumer(matcher) : super('LineInfo with consumer that is', 'consumer', matcher);

  @override
  featureValueOf(actual) => (actual as LineInfo).consumer;
}

class _LineInfoHasIsUsed extends CustomMatcher {
  _LineInfoHasIsUsed(matcher) : super('LineInfo with isUsed that is', 'isUsed', matcher);

  @override
  featureValueOf(actual) => (actual as LineInfo).isUsed;
}

class _LineInfoHasIsRequested extends CustomMatcher {
  _LineInfoHasIsRequested(matcher) : super('LineInfo with isRequested that is', 'isRequested', matcher);

  @override
  featureValueOf(actual) => (actual as LineInfo).isRequested;
}

class _LineInfoHasIsFree extends CustomMatcher {
  _LineInfoHasIsFree(matcher) : super('LineInfo with isFree that is', 'isFree', matcher);

  @override
  featureValueOf(actual) => (actual as LineInfo).isFree;
}

class _LineInfoHasDirection extends CustomMatcher {
  _LineInfoHasDirection(matcher) : super('LineInfo with direction that is', 'direction', matcher);

  @override
  featureValueOf(actual) => (actual as LineInfo).direction;
}

class _LineInfoHasOutputMode extends CustomMatcher {
  _LineInfoHasOutputMode(matcher) : super('LineInfo with outputMode that is', 'outputMode', matcher);

  @override
  featureValueOf(actual) => (actual as LineInfo).outputMode;
}

class _LineInfoHasBias extends CustomMatcher {
  _LineInfoHasBias(matcher) : super('LineInfo with bias that is', 'bias', matcher);

  @override
  featureValueOf(actual) => (actual as LineInfo).bias;
}

class _LineInfoHasActiveState extends CustomMatcher {
  _LineInfoHasActiveState(matcher) : super('LineInfo with activeState that is', 'activeState', matcher);

  @override
  featureValueOf(actual) => (actual as LineInfo).activeState;
}

Matcher matchLineInfo(
  Object? name,
  Object? consumer,
  Object? isUsed,
  Object? isRequested,
  Object? isFree,
  Object? direction,
  Object? outputMode,
  Object? bias,
  Object? activeState,
) {
  return allOf([
    _LineInfoHasName(name),
    _LineInfoHasConsumer(consumer),
    _LineInfoHasIsUsed(isUsed),
    _LineInfoHasIsRequested(isRequested),
    _LineInfoHasIsFree(isFree),
    _LineInfoHasDirection(direction),
    _LineInfoHasOutputMode(outputMode),
    _LineInfoHasBias(bias),
    _LineInfoHasActiveState(activeState),
  ]);
}

Matcher matchGpioLine(Object? info) {
  return _GpioLineHasInfo(info);
}

Matcher matchGpioLineInfo(
  Object? name,
  Object? consumer,
  Object? isUsed,
  Object? isRequested,
  Object? isFree,
  Object? direction,
  Object? outputMode,
  Object? bias,
  Object? activeState,
) {
  return matchGpioLine(matchLineInfo(
    name,
    consumer,
    isUsed,
    isRequested,
    isFree,
    direction,
    outputMode,
    bias,
    activeState,
  ));
}

Matcher matchGpioChip(
  Object? index,
  Object? name,
  Object? label,
  Object? lines,
) {
  return allOf(
    _GpioChipHasIndex(index),
    _GpioChipHasName(name),
    _GpioChipHasLabel(label),
    _GpioChipHasLines(lines),
  );
}

late final Matcher mainPi4GpioChip = matchGpioChip(
  0,
  'gpiochip0',
  anything,
  [
    matchGpioLineInfo('ID_SDA', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('ID_SCL', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('SDA1', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('SCL1', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('GPIO_GCLK', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('GPIO5', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('GPIO6', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('SPI_CE1_N', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('SPI_CE0_N', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('SPI_MISO', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('SPI_MOSI', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('SPI_SCLK', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('GPIO12', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('GPIO13', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('TXD1', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('RXD1', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('GPIO16', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('GPIO17', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('GPIO18', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('GPIO19', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('GPIO20', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('GPIO21', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('GPIO22', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('GPIO23', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('GPIO24', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('GPIO25', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('GPIO26', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('GPIO27', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('RGMII_MDIO', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('RGMIO_MDC', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('CTS0', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('RTS0', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('TXD0', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('RXD0', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('SD1_CLK', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('SD1_CMD', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('SD1_DATA0', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('SD1_DATA1', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('SD1_DATA2', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('SD1_DATA3', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('PWM0_MISO', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('PWM1_MOSI', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('STATUS_LED_G_CLK', 'led0', true, false, false, LineDirection.output, OutputMode.pushPull,
        anything, ActiveState.high),
    matchGpioLineInfo('SPIFLASH_CE_N', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('SDA0', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('SCL0', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('RGMII_RXCLK', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('RGMII_RXCTL', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('RGMII_RXD0', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('RGMII_RXD1', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('RGMII_RXD2', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('RGMII_RXD3', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('RGMII_TXCLK', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('RGMII_TXCTL', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('RGMII_TXD0', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('RGMII_TXD1', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('RGMII_TXD2', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
    matchGpioLineInfo('RGMII_TXD3', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
  ],
);

late final Matcher secPi4GpioChip = matchGpioChip(
  1,
  'gpiochip1',
  anything,
  [
    matchGpioLineInfo(
      'BT_ON',
      null,
      false,
      false,
      true,
      LineDirection.output,
      OutputMode.pushPull,
      anything,
      ActiveState.high,
    ),
    matchGpioLineInfo(
      'WL_ON',
      null,
      false,
      false,
      true,
      LineDirection.output,
      OutputMode.pushPull,
      anything,
      ActiveState.high,
    ),
    matchGpioLineInfo(
      'PWR_LED_OFF',
      'led1',
      true,
      false,
      false,
      LineDirection.output,
      OutputMode.pushPull,
      anything,
      ActiveState.low,
    ),
    matchGpioLineInfo(
      'GLOBAL_RESET',
      null,
      false,
      false,
      true,
      LineDirection.output,
      OutputMode.pushPull,
      anything,
      ActiveState.high,
    ),
    matchGpioLineInfo(
      'VDD_SD_IO_SEL',
      'vdd-sd-io',
      true,
      false,
      false,
      LineDirection.output,
      OutputMode.pushPull,
      anything,
      ActiveState.high,
    ),
    matchGpioLineInfo(
      'CAM_GPIO',
      null,
      false,
      false,
      true,
      LineDirection.output,
      OutputMode.pushPull,
      anything,
      ActiveState.high,
    ),
    matchGpioLineInfo(
      'SD_PWR_ON',
      'sd_vcc_reg',
      true,
      false,
      false,
      LineDirection.output,
      OutputMode.pushPull,
      anything,
      ActiveState.high,
    ),
    matchGpioLineInfo('SD_OC_N', null, false, false, true, LineDirection.input, null, anything, ActiveState.high),
  ],
);

late final Matcher thirdPi4GpioChip = matchGpioChip(
  2,
  'gpiochip2',
  anything,
  [
    matchGpioLineInfo(null, '2.reg_bridge', true, false, false, LineDirection.output, OutputMode.pushPull, anything,
        ActiveState.high),
    matchGpioLineInfo(
        null, 'reset', true, false, false, LineDirection.output, OutputMode.pushPull, anything, ActiveState.low),
  ],
);

late final Matcher matchPi4GpioChips = equals([mainPi4GpioChip, secPi4GpioChip, thirdPi4GpioChip]);
