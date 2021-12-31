import 'dart:convert';

List<T> listFromArrayHelper<T>(int length, T getElement(int index)) {
  return List.generate(length, getElement, growable: false);
}

String stringFromInlineArray(int maxLength, int getElement(int index),
    {Encoding codec = utf8}) {
  final list = listFromArrayHelper(maxLength, getElement);
  final indexOfZero = list.indexOf(0);
  final length = indexOfZero == -1 ? maxLength : indexOfZero;

  return codec.decode(list.sublist(0, length));
}

void writeStringToArrayHelper(
    String str, int length, void setElement(int index, int value),
    {Encoding codec = utf8}) {
  final untruncatedBytes = List.of(codec.encode(str))
    ..addAll(List.filled(length, 0));

  untruncatedBytes.take(length).toList().asMap().forEach(setElement);
}
