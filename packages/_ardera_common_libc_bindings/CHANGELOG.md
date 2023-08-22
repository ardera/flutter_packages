## 0.3.2

 - **FIX**(bindings): fix can bindings sizeOf test. ([ca53d245](https://github.com/ardera/flutter_packages/commit/ca53d245e465a8efb699c38a6c09577d629244ef))
 - **FIX**(bindings): retry epoll_wait on EINTR. ([813b9944](https://github.com/ardera/flutter_packages/commit/813b9944f8309d484e6edb407abb88fd58e9e189))
 - **FEAT**(bindingsgen): Add `linux/can/{raw,error}.h` bindings. ([24d027ac](https://github.com/ardera/flutter_packages/commit/24d027ac68c704ff697b8934e6c2e778de24fd40))
 - **FEAT**(bindings): export can_filter struct. ([5f1fcb21](https://github.com/ardera/flutter_packages/commit/5f1fcb210150dc862bfc012b7770f622b1ad6d68))

## 0.3.1

 - **FEAT**(bindings): add `ARPHRD_...` bindings. ([b123003f](https://github.com/ardera/flutter_packages/commit/b123003f7e08b6b3da220d5a95391735a1cefef7))

## 0.3.0+2

 - **FIX**: ioctlPtr. ([c3994b74](https://github.com/ardera/flutter_packages/commit/c3994b741933f8440ae83f4182113b21f15e06ed))
 - **FIX**: mark some functions non-leaf as workaround. ([9bfa7a6d](https://github.com/ardera/flutter_packages/commit/9bfa7a6d3e03f888308a627f3b0a491c03f5e8da))

## 0.3.0+1

 - **REFACTOR**: de-assemble bindingsgen helper package. ([f5e6255c](https://github.com/ardera/flutter_packages/commit/f5e6255cd90957507f2c0e81a5bae21244860d6f))

## 0.3.0

> Note: This release has breaking changes.

 - **FEAT**: bindingsgen: add `getsockopt` binding. ([fed350e6](https://github.com/ardera/flutter_packages/commit/fed350e646b128d29468a165d78bcaee84859737))
 - **FEAT**: CAN event listening. ([48913713](https://github.com/ardera/flutter_packages/commit/48913713f48ce5665dfd8c73ab0e5e7653634f73))
 - **FEAT**: more & restructured bindings, epoll event loop, linux_can CAN TDC dataclasses. ([088922bc](https://github.com/ardera/flutter_packages/commit/088922bc66ed415f9bbd6a39bf624db09f92ba18))
 - **FEAT**: add more rtnetlink communication. ([f73e08bb](https://github.com/ardera/flutter_packages/commit/f73e08bb135ccc67222d8e1cfb210fd0f550d8c1))
 - **FEAT**: regenerate libc bindings using bindingsgenerator tool. ([79fc3e4a](https://github.com/ardera/flutter_packages/commit/79fc3e4a5cb5e84fd6df24f1ba1bdbbc81ff8e60))
 - **FEAT**: add packages/_ardera_common_libc_bindings/tool/bindingsgenerator. ([0df03227](https://github.com/ardera/flutter_packages/commit/0df03227620d4762f812b8be2feaebe1e383783d))
 - **BREAKING** **FIX**: make EpollListener work. ([6b7b215b](https://github.com/ardera/flutter_packages/commit/6b7b215bc65c079490ef147521e62385238aa22d))

## 0.2.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**: migrate to cross-ABI bindings. ([9dcd4507](https://github.com/ardera/flutter_packages/commit/9dcd450738c418be34aa8bb9f2aac3794b256469))

## 0.1.1

- fix naming of ssize_t type

## 0.1.0

- Regenerate bindings with latest bindings generator, use portable dart:ffi types

## 0.0.1

- Initial version.
