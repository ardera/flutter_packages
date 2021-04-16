#!/bin/bash -i

pushd ./bindings_generator
./generate_bindings.sh
popd

pushd ./example
flutter build bundle --target=lib/main.dart
rsync -a ./build/flutter_assets/ pi@hpi4:/home/pi/devel/flutter_serial_assets
popd