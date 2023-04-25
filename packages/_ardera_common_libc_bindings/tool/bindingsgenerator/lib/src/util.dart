import 'dart:io';
import 'package:path/path.dart' as pathlib;

extension ChildFileSystemEntities on Directory {
  File childFile(String name) {
    final file = File(pathlib.join(path, name));
    return file;
  }

  Directory childDir(String name) => Directory(pathlib.join(path, name));
}
