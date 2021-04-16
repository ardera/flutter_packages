#!/bin/bash
pushd ../../tools/bindings_generator
./generate_bindings.sh
popd
cp ../../tools/bindings_generator/generated/*  ./lib/src/bindings/