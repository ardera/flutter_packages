# linux_can_test_app

A flutter test app with an integration test for the linux_can package.

See `integration_test/can_test.dart` for the actual test.

To run, first setup a raspberry pi 3 with the hardware setup documented in `dart_test.yaml` and flutter-pi.
Then, add that raspberry pi 3 as a custom device. (https://github.com/flutter/flutter/wiki/Using-custom-embedders-with-the-Flutter-CLI)

To run the tests, run:
```
$ flutter run -d my-pi3-device-name -t pi3-can integration_test/can_test.dart
```

