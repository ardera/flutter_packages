## 0.5.1+5

 - Update a dependency to the latest release.

## 0.5.1+4

 - Update a dependency to the latest release.

## 0.5.1+3

 - **FIX**: don't block infinitely waiting for gpio events. ([81123cfe](https://github.com/ardera/flutter_packages/commit/81123cfe0acc75a0512f43cb7131abc3fb4cecb4))

## 0.5.1+2

 - Update a dependency to the latest release.

## 0.5.1+1

 - **FIX**: use dart 2.17 for `dart:ffi` abi-specific integer types. ([79e410a2](https://github.com/ardera/flutter_packages/commit/79e410a2c08e114c4afee8312aefb9ba493048d7))
 - **FIX**: invoke libc.errno_location as a function. ([896af01e](https://github.com/ardera/flutter_packages/commit/896af01e5323e2a959df454e71671d126a8c6f20))

## 0.5.1

 - **FEAT**: use newly generated libc bindings in dependants. ([14972b55](https://github.com/ardera/flutter_packages/commit/14972b5560d1e6e0cfd748cb47936e6696577c0e))

## 0.5.0

 - upgrade ffi to 2.0.0

## [0.4.0]

* fix some smaller issues
* test on pi 4 and odroid c4 using a seperate test app
* migrate to common bindings

## [0.4.0-nullsafety]

* migrate to null-safety
* migrate to FFI 1.0
* use new bindings generator
* try finding `pinctrl-bcm2711` and fallback to `pinctrl-bcm2835` if not present in the examples
* add `timestamp` and `timestampNanos` properties in `SignalEvent` since the kernel no-longer provides realtime timestamps for signal events by default.
* use `DateTime.now` in event listener isolate for measuring the wall-clock time of a signal event.
* change documentation inside `SignalEvent`

## [0.3.1]

* fix docs for `GpioChip.label`

## [0.3.0]

* `GpioLine.onEvent` is now a broadcast (not single subscription) stream
* example was updated to include some gotchas with this single subscription stream
* fix a bug with closing event lines

## [0.2.0]

* switch to using FFI
* libgpiod is no longer required, the interface accesses the GPIO character devices directly using ioctls
* a lot of stuff has been made synchronous
* add a sub-project for generating the FFI bindings ("bindings_generator")
* update the examples for the new API
* fix some documentation
* tested on ARM32, should work on other 32-bit and 64-bit linux platforms as well (untested though)

## [0.1.0+3]

* Removed link in `pubspec.yaml` because it wasn't working.

## [0.1.0+2]

* Format sources
* Better description in `pubspec.yaml`

## [0.1.0+1]

* Fix `README.md`

## [0.1.0]

* Initial release.
