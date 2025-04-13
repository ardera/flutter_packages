# 📰 NEWS
- migrated to null-safety
- `SignalEvent`'s `time` property is no-longer that accurate, but instead two new properties, `timestampNanos` and `timestamp` are now provided which are super accurate. (This is because of changes in the kernel) 
- Raspberry Pi's main GPIO chip is no longer called `pinctrl-bcm2835` on Pi 4's with latest kernel version. Instead its called `pinctrl-bcm2711`.
- Raspberry Pi's kernel changed so that its GPIO indexes are no longer a perfect sequence. 
  Two different device files may now refer to the same GPIO chip.
  Therefore, a map represents this relationship instead of a list going forward.

# flutter_gpiod

A dart package for GPIO access on linux / Android (*root required*) using the linux GPIO character-device interface. Tested & working on ARM32 but should work on other 32-bit and 64-bit linux platforms as well.

## Getting Started

Then, you can retrieve the map of GPIO chips attached to
your system using [FlutterGpiod.chips]. Each chip has a name,
label, and a number of GPIO lines associated with it.
```dart
final chips = FlutterGpiod.instance.chips;

for (final chip in chips.values) {
  print("chip name: ${chip.name}, chip label: ${chip.label}");

  for (final line in chip.lines) {
    print("  line: $line");
  }
}
```

Each line also has some information associated with it that can be
retrieved using [GpioLine.info].
The information can change at any time if the line is not owned/requested by you.
```dart
// Get the main Raspberry Pi GPIO chip.
// On Raspberry Pi 4 the main GPIO chip is called `pinctrl-bcm2711` and
// on older Pi's or a Pi 4 with older kernel version it's called `pinctrl-bcm2835`.
// On newer kernel version the chips may appear twice, so using `singleWhere` would fail.
final chip = FlutterGpiod.instance.chips.values.firstWhere(
  (chip) => chip.label == 'pinctrl-bcm2711',
  orElse: () => FlutterGpiod.instance.chips.values.firstWhere((chip) => chip.label == 'pinctrl-bcm2835'),
);

// Get line 22 of the GPIO chip.
// This is the BCM 22 pin of the Raspberry Pi.
final line = chip.lines[22];

print("line info: ${line.info}")
```

To control a line (to read or write values or to listen for edges),
you need to request it using [GpioLine.requestInput] or [GpioLine.requestOutput].
```dart
final chip = FlutterGpiod.instance.chips.values.firstWhere((chip) => chip.label == 'pinctrl-bcm2835');
final line = chip.lines[22];

// request it as input.
line.requestInput();
print("line value: ${line.getValue()}");
line.release();

// now we're requesting it as output.
line.requestOutput(initialValue: true);
line.setValue(false);
line.release();

// request it as input again, but this time we're also listening
// for edges; both in this case.
line.requestInput(triggers: {SignalEdge.falling, SignalEdge.rising});

print("line value: ${line.getValue()}");

// line.onEvent will not emit any events if no triggers
// are requested for the line.
// this will run forever
await for (final event in line.onEvent) {
  print("got GPIO line signal event: $event");
}

line.release();
```
