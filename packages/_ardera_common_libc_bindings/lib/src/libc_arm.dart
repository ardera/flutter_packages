// ignore_for_file: constant_identifier_names, non_constant_identifier_names, camel_case_types, unnecessary_brace_in_string_interps, unused_element

import 'dart:ffi' as ffi;

export 'libc_arm.g.dart' hide epoll_event, epoll_data;

@ffi.Packed(1)
class epoll_data extends ffi.Union {
  external ffi.Pointer<ffi.Void> ptr;

  @ffi.Int32()
  external int fd;

  @ffi.Uint32()
  external int u32;

  @ffi.Uint64()
  external int u64;
}

@ffi.Packed(1)
class epoll_event extends ffi.Struct {
  @ffi.Uint32()
  external int events;

  external epoll_data data;
}
