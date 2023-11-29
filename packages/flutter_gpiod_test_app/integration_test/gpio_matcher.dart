import 'package:flutter_gpiod/flutter_gpiod.dart';
import 'package:flutter_test/flutter_test.dart';

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

final Matcher noConsumer = anyOf(isNull, equals(''));

final Matcher unnamed = anyOf(isNull, equals(''));

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
