import 'dart:convert';

import 'dart:ffi' as ffi;

import 'bindings/libc.dart';

List<T> listFromArrayHelper<T>(int length, T getElement(int index)) {
  return List.generate(length, getElement, growable: false);
}

String stringFromInlineArray(int maxLength, int getElement(int index), {Encoding codec = utf8}) {
  final list = listFromArrayHelper(maxLength, getElement);
  final indexOfZero = list.indexOf(0);
  final length = indexOfZero == -1 ? maxLength : indexOfZero;

  return codec.decode(list.sublist(0, length));
}

void writeStringToArrayHelper(String str, int length, void setElement(int index, int value), {Encoding codec = utf8}) {
  final untruncatedBytes = List.of(codec.encode(str))..addAll(List.filled(length, 0));

  untruncatedBytes.take(length).toList().asMap().forEach(setElement);
}

typedef _dart_errno_location = ffi.Pointer<ffi.Int32> Function();

extension Errno on LibC {
  ffi.Pointer<ffi.Int32> errnoLocation() {
    try {
      return this.errno_location();
    } on ArgumentError {}

    try {
      return this.lookup<ffi.NativeFunction<_dart_errno_location>>('__errno').asFunction<_dart_errno_location>().call();
    } on ArgumentError {}

    try {
      return this.lookup<ffi.NativeFunction<_dart_errno_location>>('errno').asFunction<_dart_errno_location>().call();
    } on ArgumentError {}

    try {
      return this
          .lookup<ffi.NativeFunction<_dart_errno_location>>('_dl_errno')
          .asFunction<_dart_errno_location>()
          .call();
    } on ArgumentError {}

    try {
      return this
          .lookup<ffi.NativeFunction<_dart_errno_location>>('__libc_errno')
          .asFunction<_dart_errno_location>()
          .call();
    } on ArgumentError {}

    throw UnsupportedError('Couldn\'t get the errno.');
  }

  int get errno {
    return errnoLocation().value;
  }
}

extension IoctlPointer on LibC {}
