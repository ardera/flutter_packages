# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## 2023-10-11

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`linux_serial` - `v0.2.3+6`](#linux_serial---v0236)

---

#### `linux_serial` - `v0.2.3+6`

 - **REFACTOR**(linux_serial): remove duplicate code. ([ab7b09d0](https://github.com/ardera/flutter_packages/commit/ab7b09d02d72aa07a906ded7743b2110f3cbed3e))
 - **FIX**(linux_serial): fix incorrect list cast. ([9d130049](https://github.com/ardera/flutter_packages/commit/9d130049eae614ecc62aabae95fcdfdd4266c7c3))


## 2023-08-22

### Changes

---

Packages with breaking changes:

 - [`linux_can` - `v0.2.0`](#linux_can---v020)

Packages with other changes:

 - [`_ardera_common_libc_bindings` - `v0.3.2`](#_ardera_common_libc_bindings---v032)
 - [`flutterpi_gstreamer_video_player` - `v0.1.1+1`](#flutterpi_gstreamer_video_player---v0111)
 - [`linux_serial` - `v0.2.3+5`](#linux_serial---v0235)
 - [`linux_spidev` - `v0.2.1+5`](#linux_spidev---v0215)
 - [`flutter_gpiod` - `v0.5.1+5`](#flutter_gpiod---v0515)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `linux_serial` - `v0.2.3+5`
 - `linux_spidev` - `v0.2.1+5`
 - `flutter_gpiod` - `v0.5.1+5`

---

#### `linux_can` - `v0.2.0`

 - **REFACTOR**(linux_can): reuse memory internally. ([6a976d78](https://github.com/ardera/flutter_packages/commit/6a976d7898c4d0a065bb8e22e551de9870c392ed))
 - **REFACTOR**(linux_can): Use `CAN_ERR_*` constants from bindings. ([0c4080eb](https://github.com/ardera/flutter_packages/commit/0c4080eb127e335b0a4d4f9b58110046eb83409a))
 - **FEAT**(linux_can): Implement filters. ([520e658d](https://github.com/ardera/flutter_packages/commit/520e658dc731176438337eb70e33cd202f85a81a))
 - **FEAT**(linux_can): Initial work on filter support. ([76335093](https://github.com/ardera/flutter_packages/commit/76335093ba113778630bbd6e96a50247dfd64433))
 - **BREAKING** **FEAT**(linux_can): Implement CAN frame filtering. ([a2afcaa1](https://github.com/ardera/flutter_packages/commit/a2afcaa14e95ad7c73ff0c7ffe507ffd40051d2f))

#### `_ardera_common_libc_bindings` - `v0.3.2`

 - **FIX**(bindings): fix can bindings sizeOf test. ([ca53d245](https://github.com/ardera/flutter_packages/commit/ca53d245e465a8efb699c38a6c09577d629244ef))
 - **FIX**(bindings): retry epoll_wait on EINTR. ([813b9944](https://github.com/ardera/flutter_packages/commit/813b9944f8309d484e6edb407abb88fd58e9e189))
 - **FEAT**(bindingsgen): Add `linux/can/{raw,error}.h` bindings. ([24d027ac](https://github.com/ardera/flutter_packages/commit/24d027ac68c704ff697b8934e6c2e778de24fd40))
 - **FEAT**(bindings): export can_filter struct. ([5f1fcb21](https://github.com/ardera/flutter_packages/commit/5f1fcb210150dc862bfc012b7770f622b1ad6d68))

#### `flutterpi_gstreamer_video_player` - `v0.1.1+1`

 - **FIX**(flutterpi_gstreamer_video_player): fix deprecations. ([74b8cb56](https://github.com/ardera/flutter_packages/commit/74b8cb562f0d60714580fd787f81f782d7a2e679))


## 2023-07-18

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`_ardera_common_libc_bindings` - `v0.3.1`](#_ardera_common_libc_bindings---v031)
 - [`flutterpi_gstreamer_video_player` - `v0.1.1`](#flutterpi_gstreamer_video_player---v011)
 - [`linux_can` - `v0.1.0+1`](#linux_can---v0101)
 - [`linux_serial` - `v0.2.3+4`](#linux_serial---v0234)
 - [`linux_spidev` - `v0.2.1+4`](#linux_spidev---v0214)
 - [`flutter_gpiod` - `v0.5.1+4`](#flutter_gpiod---v0514)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `linux_serial` - `v0.2.3+4`
 - `linux_spidev` - `v0.2.1+4`
 - `flutter_gpiod` - `v0.5.1+4`

---

#### `_ardera_common_libc_bindings` - `v0.3.1`

 - **FEAT**(bindings): add `ARPHRD_...` bindings. ([b123003f](https://github.com/ardera/flutter_packages/commit/b123003f7e08b6b3da220d5a95391735a1cefef7))

#### `flutterpi_gstreamer_video_player` - `v0.1.1`

 - **FEAT**(flutterpi_gstreamer_video_player_example): add exit button. ([7d4f37c6](https://github.com/ardera/flutter_packages/commit/7d4f37c678bea11d92975e3185f01f85b380e1b5))

#### `linux_can` - `v0.1.0+1`

 - **REFACTOR**(linux_can): Use binding instead of magic nr. ([e5975413](https://github.com/ardera/flutter_packages/commit/e597541357b5809ed834e52e26d319bfeba5483c))
 - **REFACTOR**(linux_can): use rtnetlink fd for querying MTU. ([78a933ed](https://github.com/ardera/flutter_packages/commit/78a933edc96acac75fd91ac6992904d933141c98))
 - **FIX**(linux_can): More robust checking for CAN device. ([78e2f805](https://github.com/ardera/flutter_packages/commit/78e2f805871035422800de0b27c8241d36fe8f9a))


## 2023-07-03

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`_ardera_common_libc_bindings` - `v0.3.0+2`](#_ardera_common_libc_bindings---v0302)
 - [`flutter_gpiod` - `v0.5.1+3`](#flutter_gpiod---v0513)
 - [`linux_can` - `v0.1.0+2`](#linux_can---v0102)
 - [`linux_serial` - `v0.2.3+3`](#linux_serial---v0233)
 - [`linux_spidev` - `v0.2.1+3`](#linux_spidev---v0213)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `linux_can` - `v0.1.0+2`
 - `linux_serial` - `v0.2.3+3`
 - `linux_spidev` - `v0.2.1+3`

---

#### `_ardera_common_libc_bindings` - `v0.3.0+2`

 - **FIX**: ioctlPtr. ([c3994b74](https://github.com/ardera/flutter_packages/commit/c3994b741933f8440ae83f4182113b21f15e06ed))
 - **FIX**: mark some functions non-leaf as workaround. ([9bfa7a6d](https://github.com/ardera/flutter_packages/commit/9bfa7a6d3e03f888308a627f3b0a491c03f5e8da))

#### `flutter_gpiod` - `v0.5.1+3`

 - **FIX**: don't block infinitely waiting for gpio events. ([81123cfe](https://github.com/ardera/flutter_packages/commit/81123cfe0acc75a0512f43cb7131abc3fb4cecb4))


## 2023-06-21

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`_ardera_common_libc_bindings` - `v0.3.0+1`](#_ardera_common_libc_bindings---v0301)
 - [`linux_can` - `v0.1.0+1`](#linux_can---v0101)
 - [`linux_serial` - `v0.2.3+2`](#linux_serial---v0232)
 - [`linux_spidev` - `v0.2.1+2`](#linux_spidev---v0212)
 - [`flutter_gpiod` - `v0.5.1+2`](#flutter_gpiod---v0512)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `linux_can` - `v0.1.0+1`
 - `linux_serial` - `v0.2.3+2`
 - `linux_spidev` - `v0.2.1+2`
 - `flutter_gpiod` - `v0.5.1+2`

---

#### `_ardera_common_libc_bindings` - `v0.3.0+1`

 - **REFACTOR**: de-assemble bindingsgen helper package. ([f5e6255c](https://github.com/ardera/flutter_packages/commit/f5e6255cd90957507f2c0e81a5bae21244860d6f))


## 2023-06-20

### Changes

---

Packages with breaking changes:

 - [`_ardera_common_libc_bindings` - `v0.3.0`](#_ardera_common_libc_bindings---v030)
 - [`linux_can` - `v0.1.0`](#linux_can---v010)

Packages with other changes:

 - [`_ardera_libc_bindings_generator` - `v0.1.1+1`](#_ardera_libc_bindings_generator---v0111)
 - [`flutter_gpiod` - `v0.5.1+1`](#flutter_gpiod---v0511)
 - [`linux_spidev` - `v0.2.1+1`](#linux_spidev---v0211)
 - [`linux_serial` - `v0.2.3+1`](#linux_serial---v0231)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `linux_serial` - `v0.2.3+1`

---

#### `_ardera_common_libc_bindings` - `v0.3.0`

 - **FEAT**: bindingsgen: add `getsockopt` binding. ([fed350e6](https://github.com/ardera/flutter_packages/commit/fed350e646b128d29468a165d78bcaee84859737))
 - **FEAT**: CAN event listening. ([48913713](https://github.com/ardera/flutter_packages/commit/48913713f48ce5665dfd8c73ab0e5e7653634f73))
 - **FEAT**: more & restructured bindings, epoll event loop, linux_can CAN TDC dataclasses. ([088922bc](https://github.com/ardera/flutter_packages/commit/088922bc66ed415f9bbd6a39bf624db09f92ba18))
 - **FEAT**: add more rtnetlink communication. ([f73e08bb](https://github.com/ardera/flutter_packages/commit/f73e08bb135ccc67222d8e1cfb210fd0f550d8c1))
 - **FEAT**: regenerate libc bindings using bindingsgenerator tool. ([79fc3e4a](https://github.com/ardera/flutter_packages/commit/79fc3e4a5cb5e84fd6df24f1ba1bdbbc81ff8e60))
 - **FEAT**: add packages/_ardera_common_libc_bindings/tool/bindingsgenerator. ([0df03227](https://github.com/ardera/flutter_packages/commit/0df03227620d4762f812b8be2feaebe1e383783d))
 - **BREAKING** **FIX**: make EpollListener work. ([6b7b215b](https://github.com/ardera/flutter_packages/commit/6b7b215bc65c079490ef147521e62385238aa22d))

#### `linux_can` - `v0.1.0`

 - **REFACTOR**: use dart 3 pattern matching. ([7f4a1d9c](https://github.com/ardera/flutter_packages/commit/7f4a1d9cf3b99bacfa4e4196326a06e7e504c81a))
 - **FIX**: linux_can: depend on package collection. ([6bd56f02](https://github.com/ardera/flutter_packages/commit/6bd56f028959b0da3c260baa0d17fb2cee022db8))
 - **FEAT**: refactors, improvements for linux_can. ([7b44800a](https://github.com/ardera/flutter_packages/commit/7b44800affb76e29f1c11088bb73b17bd69280ca))
 - **FEAT**: CAN event listening. ([48913713](https://github.com/ardera/flutter_packages/commit/48913713f48ce5665dfd8c73ab0e5e7653634f73))
 - **FEAT**: more & restructured bindings, epoll event loop, linux_can CAN TDC dataclasses. ([088922bc](https://github.com/ardera/flutter_packages/commit/088922bc66ed415f9bbd6a39bf624db09f92ba18))
 - **FEAT**: add more rtnetlink communication. ([f73e08bb](https://github.com/ardera/flutter_packages/commit/f73e08bb135ccc67222d8e1cfb210fd0f550d8c1))
 - **FEAT**: add linux_can package. ([26bd3258](https://github.com/ardera/flutter_packages/commit/26bd3258b44eab3b943c972a5fc1bcd8569edeb1))
 - **BREAKING** **FIX**: Make some linux_can fields private, Add asserts. ([ecb1f885](https://github.com/ardera/flutter_packages/commit/ecb1f8856e55cdeb637f2c848503ea02db411277))
 - **BREAKING** **FEAT**: implement querying CAN interface attributes. ([51d1923f](https://github.com/ardera/flutter_packages/commit/51d1923f3e3423813feebf08a371d432dc020065))

#### `_ardera_libc_bindings_generator` - `v0.1.1+1`

 - **FIX**: depend on dart 2.17 for abi specific integer types. ([037b78cc](https://github.com/ardera/flutter_packages/commit/037b78cc2e11ce75719c12b6a71b9388d8803cb4))

#### `flutter_gpiod` - `v0.5.1+1`

 - **FIX**: use dart 2.17 for `dart:ffi` abi-specific integer types. ([79e410a2](https://github.com/ardera/flutter_packages/commit/79e410a2c08e114c4afee8312aefb9ba493048d7))
 - **FIX**: invoke libc.errno_location as a function. ([896af01e](https://github.com/ardera/flutter_packages/commit/896af01e5323e2a959df454e71671d126a8c6f20))

#### `linux_spidev` - `v0.2.1+1`

 - **FIX**: use dart 2.17 for `dart:ffi` abi-specific integer types. ([79e410a2](https://github.com/ardera/flutter_packages/commit/79e410a2c08e114c4afee8312aefb9ba493048d7))


## 2023-04-04

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`linux_serial` - `v0.2.3`](#linux_serial---v023)

---

#### `linux_serial` - `v0.2.3`

 - **FIX**: remove logging, increase dart SDK min to 2.16. ([7e4a0058](https://github.com/ardera/flutter_packages/commit/7e4a0058ba8e58b2715d54a6cf62179467a7b4e0))


## 2023-02-27

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`linux_serial` - `v0.2.2`](#linux_serial---v022)

---

#### `linux_serial` - `v0.2.2`

 - **REFACTOR**: fix analyzer warnings. ([9e652157](https://github.com/ardera/flutter_packages/commit/9e652157b62b64c080f492715fda83e9b63533bd))
 - **FEAT**: make linux_serial work with new libc bindings. ([b5074fbd](https://github.com/ardera/flutter_packages/commit/b5074fbd24e7e04f408a1c13b7c8e5cba7735ec7))


## 2023-02-27

### Changes

---

Packages with breaking changes:

 - [`_ardera_common_libc_bindings` - `v0.2.0`](#_ardera_common_libc_bindings---v020)

Packages with other changes:

 - [`flutter_gpiod` - `v0.5.1`](#flutter_gpiod---v051)
 - [`flutterpi_gstreamer_video_player` - `v0.1.0+1`](#flutterpi_gstreamer_video_player---v0101)
 - [`linux_spidev` - `v0.2.1`](#linux_spidev---v021)
 - [`linux_serial` - `v0.2.1+1`](#linux_serial---v0211)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `linux_serial` - `v0.2.1+1`

---

#### `_ardera_common_libc_bindings` - `v0.2.0`

 - **BREAKING** **FEAT**: migrate to cross-ABI bindings. ([9dcd4507](https://github.com/ardera/flutter_packages/commit/9dcd450738c418be34aa8bb9f2aac3794b256469))

#### `flutter_gpiod` - `v0.5.1`

 - **FEAT**: use newly generated libc bindings in dependants. ([14972b55](https://github.com/ardera/flutter_packages/commit/14972b5560d1e6e0cfd748cb47936e6696577c0e))

#### `flutterpi_gstreamer_video_player` - `v0.1.0+1`

 - **FIX**: formatting in video player example. ([19e2a8a9](https://github.com/ardera/flutter_packages/commit/19e2a8a908b5d37f5c632482bceca1cc876ae41a))

#### `linux_spidev` - `v0.2.1`

 - **FEAT**: use newly generated libc bindings in dependants. ([14972b55](https://github.com/ardera/flutter_packages/commit/14972b5560d1e6e0cfd748cb47936e6696577c0e))


## 2023-02-26

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`omxplayer_video_player` - `v2.1.1`](#omxplayer_video_player---v211)

---

#### `omxplayer_video_player` - `v2.1.1`

 - **REFACTOR**: fix analyzer warnings. ([9e652157](https://github.com/ardera/flutter_packages/commit/9e652157b62b64c080f492715fda83e9b63533bd))


## 2023-02-26

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`_ardera_libc_bindings_generator` - `v0.1.1`](#_ardera_libc_bindings_generator---v011)

---

#### `_ardera_libc_bindings_generator` - `v0.1.1`

 - **REFACTOR**: fix analyzer warnings. ([9e652157](https://github.com/ardera/flutter_packages/commit/9e652157b62b64c080f492715fda83e9b63533bd))


## 2023-02-26

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`linux_serial` - `v0.2.1`](#linux_serial---v021)

---

#### `linux_serial` - `v0.2.1`

 - **REFACTOR**: fix analyzer warnings. ([9e652157](https://github.com/ardera/flutter_packages/commit/9e652157b62b64c080f492715fda83e9b63533bd))


## 2022-08-07

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`omxplayer_video_player` - `v2.1.0`](#omxplayer_video_player---v210)

---

#### `omxplayer_video_player` - `v2.1.0`

 - upgrade deps


## 2022-08-07

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`linux_spidev` - `v0.2.0`](#linux_spidev---v020)

---

#### `linux_spidev` - `v0.2.0`

 - upgrade deps (ffi to 2.0.0)


## 2022-08-07

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`linux_serial` - `v0.2.0`](#linux_serial---v020)

---

#### `linux_serial` - `v0.2.0`

 - upgrade deps (ffi to 2.0.0)


## 2022-08-07

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`flutter_gpiod` - `v0.5.0`](#flutter_gpiod---v050)

---

#### `flutter_gpiod` - `v0.5.0`

 - upgrade ffi to 2.0.0


## 2022-08-07

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`_ardera_libc_bindings_generator` - `v0.1.0`](#_ardera_libc_bindings_generator---v010)

---

#### `_ardera_libc_bindings_generator` - `v0.1.0`

 - upgrade ffigen, use portable dart:ffi types


## 2022-08-07

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`_ardera_common_libc_bindings` - `v0.1.0`](#_ardera_common_libc_bindings---v010)
 - [`linux_serial` - `v0.1.0+1`](#linux_serial---v0101)
 - [`linux_spidev` - `v0.1.0+1`](#linux_spidev---v0101)
 - [`flutter_gpiod` - `v0.4.0+1`](#flutter_gpiod---v0401)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `linux_serial` - `v0.1.0+1`
 - `linux_spidev` - `v0.1.0+1`
 - `flutter_gpiod` - `v0.4.0+1`

---

#### `_ardera_common_libc_bindings` - `v0.1.0`

 - Regenerate bindings with latest bindings generator, use portable dart:ffi types

