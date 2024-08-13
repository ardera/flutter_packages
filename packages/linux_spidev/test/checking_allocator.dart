import 'dart:ffi' as ffi;

class MemoryLeakException implements Exception {
  MemoryLeakException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LeakCheckAllocator implements ffi.Allocator {
  LeakCheckAllocator(this._allocator);

  final ffi.Allocator _allocator;

  final _allocated = <ffi.Pointer, (int, StackTrace)>{};

  @override
  ffi.Pointer<T> allocate<T extends ffi.NativeType>(
    int byteCount, {
    int? alignment,
  }) {
    final pointer = _allocator.allocate<T>(byteCount, alignment: alignment);

    _allocated[pointer] = (byteCount, StackTrace.current);

    return pointer;
  }

  @override
  void free(ffi.Pointer<ffi.NativeType> pointer) {
    if (!_allocated.containsKey(pointer)) {
      throw StateError('Pointer $pointer was not allocated by this allocator.');
    }

    _allocator.free(pointer);

    _allocated.remove(pointer);
  }

  String pluralize(int number,
      {required String singular, required String plural}) {
    return number == 1 ? singular : plural;
  }

  void checkLeaks() {
    if (_allocated.isNotEmpty) {
      final buffer = StringBuffer();

      final leaks = _allocated.values.toList();
      leaks.sort((a, b) {
        return -a.$1.compareTo(b.$1);
      });

      buffer.writeln(
          '${leaks.length} ${pluralize(leaks.length, singular: 'Memory leak', plural: 'Memory leaks')} detected:\n');

      for (final (bytes, stackTrace) in leaks.take(3)) {
        buffer.writeln('');
        buffer.writeln('Leak of $bytes bytes allocated from:');
        buffer.writeln('$stackTrace');
      }

      if (leaks.length > 3) {
        buffer.writeln('');
        buffer.writeln('And ${leaks.length - 3} more...');
      }

      throw MemoryLeakException(buffer.toString());
    }
  }
}
