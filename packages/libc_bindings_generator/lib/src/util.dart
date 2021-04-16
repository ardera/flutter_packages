import 'dart:convert';
import 'dart:io';
import 'dart:ffi' as ffi;

import 'package:async/async.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:ffi/ffi.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as pathlib;
import 'package:build/build.dart';
import 'package:win32/win32.dart' as win32;
import 'package:ffi/ffi.dart' as ffi;
import 'package:xdg_directories/xdg_directories.dart' as xdg;

Stream<List<int>> httpGetByteStream(Uri uri) {
  final client = HttpClient();
  return StreamCompleter.fromFuture(client.getUrl(uri).then((value) => value.close()));
}

Future<String> httpGetString(Uri uri, {Encoding encoding = utf8, bool base64 = false}) async {
  final string = await encoding.decodeStream(httpGetByteStream(uri));

  if (base64) {
    return encoding.decode(base64Decode(string));
  } else {
    return string;
  }
}

extension ChildFileSystemEntities on Directory {
  File childFile(String name) {
    final file = File(pathlib.join(this.path, name));
    return file;
  }

  Directory childDir(String name) => Directory(pathlib.join(this.path, name));
}

Future<void> downloadFile({
  required Uri uri,
  required File dest,
  required Logger logger,
}) async {
  final writer = dest.openWrite();
  await writer.addStream(httpGetByteStream(uri));
  await writer.flush();
  await writer.close();
}

Future<bool> checkSha1({
  required File file,
  required String sha1sum,
  required Logger logger,
}) async {
  final digestSink = AccumulatorSink<Digest>();
  final byteSink = sha1.startChunkedConversion(digestSink);

  final reader = file.openRead();
  await reader.forEach(byteSink.add);
  byteSink.close();

  final digest = digestSink.events.single;
  logger.info("SHA1 for $file is: $digest");

  return digest.toString() == sha1sum;
}

Future<void> dartFormat({
  required FileSystemEntity target,
  required Logger logger,
}) async {
  final result = await Process.run('dart', ['format', '-l', '200', target.path]);
  if (result.exitCode == 0) {
    logger.fine(result.stdout);
    logger.fine(result.stderr);
  } else {
    logger.warning('Couldn\'t format bindings: ${result.stdout}, ${result.stderr}');
  }
}

Future<bool> invoke7Zip({
  required File src,
  required Directory dest,
  required Logger logger,
  String? sevenZipCommand,
}) async {
  sevenZipCommand ??= '7z.exe';

  final command = [sevenZipCommand, 'x', src.path, '-aoa', '-o${dest.path}'];

  final process = await Process.start(command.first, command.skip(1).toList());
  process.stdout.transform(systemEncoding.decoder).forEach(logger.fine);
  process.stderr.transform(systemEncoding.decoder).forEach(logger.warning);

  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    logger.severe('Couldn\'t extract file \"$src\" using 7zip. exit code: $exitCode');
    return false;
  }

  return true;
}

Future<bool> tryExtractUsingTar({
  required File tarball,
  required Directory dest,
  required Logger logger,
}) async {
  final command = ['tar', 'xf', tarball.path, '-C', dest.path];

  final process = await Process.start(command.first, command.skip(1).toList());
  process.stdout.transform(systemEncoding.decoder).forEach(logger.fine);
  process.stderr.transform(systemEncoding.decoder).forEach(logger.warning);

  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    logger.severe('Couldn\'t extract file \"$tarball\" using tar. exit code: $exitCode');
    return false;
  }

  return true;
}

class DartWriter implements StringSink {
  DartWriter([StringBuffer? buffer]) : this.buffer = buffer ?? StringBuffer();

  final StringBuffer buffer;

  String toString() => buffer.toString();

  @override
  void write(Object? object) => buffer.write(object);

  @override
  void writeAll(Iterable objects, [String separator = ""]) => buffer.writeAll(objects, separator);

  @override
  void writeCharCode(int charCode) => buffer.writeCharCode(charCode);

  @override
  void writeln([Object? object]) => buffer.writeln(object);

  void writeComment(String text, {bool doc = false}) {
    LineSplitter().convert(text).map((l) => '//${doc ? '/' : ''} $l').forEach(writeln);
  }

  void writeImport(AssetId assetId, {String? importPrefix}) {
    write('import \'package:${assetId.package}/${assetId.path}\'');

    if (importPrefix != null) {
      write(' as $importPrefix');
    }

    writeln(';');
  }

  void startWritingClass(String className) {
    writeln('class $className {');
  }

  void stopWritingClass() {
    writeln('}');
  }
}

extension IterableFutureToFutureIterable<T> on Iterable<Future<T>> {
  Future<List<T>> wait() {
    return Future.wait(this);
  }
}

Directory getApplicationSupportDirectory(String applicationIdentifier) {
  if (Platform.isWindows) {
    final folderId = win32.FOLDERID_RoamingAppData;

    final pathPtrPtr = calloc<ffi.Pointer<ffi.Utf16>>();
    final knownFolderId = calloc<win32.GUID>()..ref.setGUID(folderId);

    try {
      final hr = win32.SHGetKnownFolderPath(
        knownFolderId,
        win32.KF_FLAG_DEFAULT,
        win32.NULL,
        pathPtrPtr,
      );

      if (win32.FAILED(hr)) {
        if (hr == win32.E_INVALIDARG || hr == win32.E_FAIL) {
          throw win32.WindowsException(hr);
        }
      }

      var sanitized =
          applicationIdentifier.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').trimRight().replaceAll(RegExp(r'[.]+$'), '');

      const int kMaxComponentLength = 255;
      if (sanitized.length > kMaxComponentLength) {
        sanitized = sanitized.substring(0, kMaxComponentLength);
      }

      return Directory(pathPtrPtr.value.toDartString()).childDir(sanitized);
    } finally {
      calloc.free(pathPtrPtr);
      calloc.free(knownFolderId);
    }
  } else if (Platform.isLinux) {
    return xdg.dataHome.childDir(applicationIdentifier);
  } else {
    throw UnsupportedError('Platform ${Platform.operatingSystem} is not supported.');
  }
}

Future<bool> tryExtractUsing7Zip({
  required File tarball,
  required Directory dest,
  required Logger logger,
  String? sevenZipCommand,
}) async {
  final temp = await Directory.systemTemp.createTemp();

  bool success = await invoke7Zip(
    src: tarball,
    dest: temp,
    sevenZipCommand: sevenZipCommand,
    logger: logger,
  );
  if (success == false) {
    await temp.delete(recursive: true);
    return false;
  }

  final extractedTarFile = temp.childFile(pathlib.basenameWithoutExtension(tarball.path));
  if (extractedTarFile.existsSync()) {
    success = await invoke7Zip(
      src: extractedTarFile,
      dest: dest,
      sevenZipCommand: sevenZipCommand,
      logger: logger,
    );
  }

  await temp.delete(recursive: true);

  return success;
}

Future<void> extractTarball({
  required File tarball,
  required Directory dest,
  required Logger logger,
  String? sevenZipCommand,
  bool deleteBeforeExtracting = true,
}) async {
  dest = dest.absolute;
  tarball = tarball.absolute;

  if (deleteBeforeExtracting) {
    if (await dest.exists()) {
      await dest.delete(recursive: true);
    }
  }

  if (!await dest.exists()) {
    await dest.create();
  }

  logger.info('Trying to extract using 7zip...');
  bool success =
      await tryExtractUsing7Zip(tarball: tarball, dest: dest, sevenZipCommand: sevenZipCommand, logger: logger);

  if (success == false) {
    logger.info('Trying to extract using tar...');
    success = await tryExtractUsingTar(tarball: tarball, dest: dest, logger: logger);
  }

  if (success == false) {
    throw Exception('Couldn\'t extract tarball.');
  }
}
