# flutter_gpiod_test_app

A flutter app for testing flutter_gpiod.

This app has an integration test defined that'll test GPIO functionality on 2 devices:
- a Raspberry Pi 4 Model B+ with the official 7 inch touchscreen
- an ODROID C4 with Android 9 installed, and pins GPIOX.4 and GPIOX.0 electrically connected with a wire

The tests that will run are the following:
- for each GPIO chip, it'll check they match what's expected (index, name, label, number of GPIO lines)
- for each GPIO line, it'll check if the line info matches what's expected (name, consumer, direction, output mode, bias, active state)
- try to request every line as input, check if the line info matches what's expected for the now-owned line, and release them all again
    - This is currently only done on ODROID.
    - Also on ODROID, there are a lot of lines that are listed as "free", but requesting them throws an error. These are excluded from testing.
- Trigger testing (ODROID only too)
    - request two lines that are electrically connected.
    - one as input with edge triggers (this is currently GPIOX.4)
    - one as output (GPIOX.0)
    - toggle the output line, check if we get an edge event for GPIOX.4 in a reasonable timeframe
    - do some basic sanity checks with the received signal edge event

To run e.g. on ODROID:
- connect ODROID to your host machine
- cd into the `flutter_gpiod_test_app` directory
- run `flutter test -d odroid -t odroidc4 integration_test/gpio_test.dart`

To run on Pi 4:
- add the pi as a [custom device](https://github.com/flutter/flutter/wiki/Using-custom-embedders-with-the-Flutter-CLI)
- cd into the `flutter_gpiod_test_app` directory
- run `flutter test -d pi -t pi4 integration_test/gpio_test.dart` (assuming `pi` is the name of the custom device you configured)

The tests that run are selected based on the `-t` parameter. `odroidc4` will make the odroid tests run, `pi4` the pi 4 tests. We don't want to run the wrong tests because they do pretty paranoid matching of the GPIO chips / lines, so we'll get test failures if we accidentally run them on the wrong device. 