import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter_gpiod/flutter_gpiod.dart';

void main() async {
  /// Retrieve the list of GPIO chips.
  final chips = FlutterGpiod.instance.chips;

  /// Print out all GPIO chips and all lines
  /// for all GPIO chips.
  for (var chip in chips) {
    print("$chip");

    for (var line in chip.lines) {
      print("  $line");
    }
  }

  /// Retrieve the line with index 23 of the first chip.
  /// This is BCM pin 23 for the Raspberry Pi.
  ///
  /// I recommend finding the chip you want
  /// based on the chip label, as is done here.
  ///
  /// In this example, we search for the main Raspberry Pi GPIO chip and then
  /// retrieve the line with index 23 of it. So [line] is GPIO pin BCM 23.
  ///
  /// The main GPIO chip is called `pinctrl-bcm2711` on Pi 4 and `pinctrl-bcm2835`
  /// on older Raspberry Pis and it was also called that way on Pi 4 with older
  /// kernel versions.
  final chip = chips.singleWhere(
    (chip) => chip.label == 'pinctrl-bcm2711',
    orElse: () => chips.singleWhere((chip) => chip.label == 'pinctrl-bcm2835'),
  );

  final line1 = chip.lines[23];
  final line2 = chip.lines[24];

  /// Request BCM 23 as output.
  line1.requestOutput(consumer: "flutter_gpiod test", initialValue: false);

  /// Pulse the line 2 times.
  line1.setValue(true);
  await Future.delayed(Duration(milliseconds: 500));
  line1.setValue(false);
  await Future.delayed(Duration(milliseconds: 500));
  line1.setValue(true);
  await Future.delayed(Duration(milliseconds: 500));
  // setValue(false) is not needed since we're releasing it anyway
  line1.release();

  /// Now we're listening for falling and rising edge events
  /// on BCM 23 and BCM 24.
  line1.requestInput(
      consumer: "test 1", triggers: {SignalEdge.falling, SignalEdge.rising});

  line2.requestInput(
      consumer: "test 2", triggers: {SignalEdge.falling, SignalEdge.rising});

  print("line value: ${line1.getValue()}");

  /// Print all received line events for
  /// line 1 and 2.
  final mergedEvents = StreamGroup.mergeBroadcast([
    line1.onEvent.map((event) => "(pin 23) $event"),
    line2.onEvent.map((event) => "(pin 24) $event"),
  ]);

  var countEvents = 0;
  await for (final event in mergedEvents) {
    print("GPIO event: $event");

    countEvents++;
    if (countEvents > 100) {
      break;
    }
  }

  /// If you depend on a certain line event being triggered,
  /// for example, if you listen on an interrupt line and
  /// you block until you receive an interrupt (= a signal event)
  /// in your code, be careful to NOT write code such as the following:
  ///
  /// ```dart
  /// final interruptLine = ...;
  ///
  /// // do something that triggers an interrupt here
  ///
  /// // wait for an interrupt
  /// await for (final _ in interruptLine.onEvent) break;
  ///
  /// // continue here
  /// ```
  ///
  /// [GpioLine.onEvent] is a broadcast stream. If an event is
  /// added to a broadcast stream, but no listener is present,
  /// that event will simply be discarded. So if your chip
  /// triggers the interrupt faster than the dart code reaches
  /// the `await for`, the signal event will be discarded and
  /// the dart code will block there indefinitely, waiting for
  /// a signal event.
  ///
  /// Instead, do something like this:

  /// Get a single-subscription (buffering stream).
  /// The stream will start buffering the events immediately.
  /// If you use `listen` to subscribe to this Stream (or mapped / filtered / etc variants of it),
  /// it's important to cancel your subscription afterwards, otherwise
  /// memory will fill up with buffered signal events.

  /// `SingleSubscriptionTransformer` is contained in the `async` package btw.
  final bufferingStream = line1.onEvent
      .transform(SingleSubscriptionTransformer<SignalEvent, SignalEvent>());

  // Let's say, if we pulse line 2 (BCM 24) some device connected
  // to it will pulse line 1 (BCM 23) as an interrupt.
  line2.release();
  line2.requestOutput(
      consumer: 'some device that has interrupts', initialValue: false);
  line2.setValue(true);
  await Future.delayed(Duration(milliseconds: 500));
  line2.setValue(false);
  line2.release();

  print("waiting for interrupt...");

  /// `await for` just uses a [StreamSubscription] internally too and
  /// will cancel the stream subscription when the `await for` loop
  /// finishes, so no memory leak.
  await for (final _ in bufferingStream) break;

  print("got interrupt!");

  /// you also can't listen to / use `await for` with `bufferingStream`
  /// at this point anymore, since single subscription streams are not reusable
  /// after they were canceled.

  line1.release();
}
