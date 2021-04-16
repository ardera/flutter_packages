#!/bin/bash -i

pushd ./bindings_generator
./generate_bindings.sh
popd

pushd ./example
cmd.exe /C flutter build bundle --target=lib/main.dart
rsync -a ./build/flutter_assets/ hpi4:/home/pi/devel/flutter_spidev_assets
popd