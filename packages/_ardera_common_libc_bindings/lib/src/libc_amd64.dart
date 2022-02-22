// ignore_for_file: constant_identifier_names, non_constant_identifier_names, camel_case_types, unnecessary_brace_in_string_interps, unused_element

import 'dart:ffi' as ffi;

export 'libc_amd64.g.dart' hide epoll_data;

class epoll_data_real extends ffi.Union {
  external ffi.Pointer<ffi.Void> ptr;

  @ffi.Int32()
  external int fd;

  @ffi.Uint32()
  external int u32;

  @ffi.Uint64()
  external int u64;
}

class epoll_event_real extends ffi.Struct {
  @ffi.Uint32()
  external int events;

  external epoll_data_real data;
}
