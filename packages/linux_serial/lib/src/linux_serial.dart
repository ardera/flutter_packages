import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:computer/computer.dart';
import 'package:meta/meta.dart';
import 'package:collection/collection.dart';
import 'package:ffi/ffi.dart' as ffi show StringUtf8Pointer, malloc, calloc;
import 'package:path/path.dart';
import 'package:tuple/tuple.dart';
import 'package:async/async.dart';
import 'package:synchronized/synchronized.dart';
import 'package:_ardera_common_libc_bindings/_ardera_common_libc_bindings.dart';

@immutable
class Baudrate {
  const Baudrate._private(this.asLinuxValue, this.inBaudsPerSecond);

  final int asLinuxValue;
  final int inBaudsPerSecond;

  static const b0 = Baudrate._private(B0, 0);
  static const b50 = Baudrate._private(B50, 50);
  static const b75 = Baudrate._private(B75, 75);
  static const b110 = Baudrate._private(B110, 110);
  static const b134 = Baudrate._private(B134, 134);
  static const b150 = Baudrate._private(B150, 150);
  static const b200 = Baudrate._private(B200, 200);
  static const b300 = Baudrate._private(B300, 300);
  static const b600 = Baudrate._private(B600, 600);
  static const b1200 = Baudrate._private(B1200, 1200);
  static const b1800 = Baudrate._private(B1800, 1800);
  static const b2400 = Baudrate._private(B2400, 2400);
  static const b4800 = Baudrate._private(B4800, 4800);
  static const b9600 = Baudrate._private(B9600, 9600);
  static const b19200 = Baudrate._private(B19200, 19200);
  static const b38400 = Baudrate._private(B38400, 38400);
  static const b57600 = Baudrate._private(B57600, 57600);
  static const b115200 = Baudrate._private(B115200, 115200);
  static const b230400 = Baudrate._private(B230400, 230400);
  static const b460800 = Baudrate._private(B460800, 460800);
  static const b500000 = Baudrate._private(B500000, 500000);
  static const b576000 = Baudrate._private(B576000, 576000);
  static const b921600 = Baudrate._private(B921600, 921600);
  static const b1000000 = Baudrate._private(B1000000, 1000000);
  static const b1152000 = Baudrate._private(B1152000, 1152000);
  static const b1500000 = Baudrate._private(B1500000, 1500000);
  static const b2000000 = Baudrate._private(B2000000, 2000000);
  static const b2500000 = Baudrate._private(B2500000, 2500000);
  static const b3000000 = Baudrate._private(B3000000, 3000000);
  static const b3500000 = Baudrate._private(B3500000, 3500000);
  static const b4000000 = Baudrate._private(B4000000, 4000000);

  static const values = <Baudrate>{
    b0,
    b50,
    b75,
    b110,
    b134,
    b150,
    b200,
    b300,
    b600,
    b1200,
    b1800,
    b2400,
    b4800,
    b9600,
    b19200,
    b38400,
    b57600,
    b115200,
    b230400,
    b460800,
    b500000,
    b576000,
    b921600,
    b1000000,
    b1152000,
    b1500000,
    b2000000,
    b2500000,
    b3000000,
    b3500000,
    b4000000
  };
}

void epollerEntry(Tuple2<SendPort, int> arg) {
  final libc = LibC(ffi.DynamicLibrary.open("libc.so.6"));
  final sendPort = arg.item1;
  final epollFd = arg.item2;

  final nEpollEvents = 64;
  final epollEventsPtr = ffi.calloc.allocate<epoll_event>(nEpollEvents * ffi.sizeOf<epoll_event>());

  while (true) {
    final result = libc.epoll_wait(epollFd, epollEventsPtr, nEpollEvents, -1);
    if (result < 0) {
      throw OSError("Could not wait for epoll events. (epoll_wait)");
    } else if (result > 0) {
      final collected = <int>[];

      for (var i = 0; i < result; i++) {
        final epollEvent = epollEventsPtr.elementAt(i);
        collected.add(epollEvent.ref.data.u64);
      }

      sendPort.send(collected);
    }
  }
}

class SynchronousComputer implements Computer {
  var _computer = Computer.create();
  bool _isRunning = false;
  Future<void>? _onTurnedOn;

  @override
  Future<R> compute<P, R>(Function fn, {P? param}) {
    final computer = this._computer;
    final onTurnedOn = this._onTurnedOn;

    if (_isRunning) {
      return computer.compute<P, R>(fn, param: param);
    } else if (onTurnedOn != null) {
      return onTurnedOn.then((_) {
        return computer.compute<P, R>(fn, param: param);
      });
    } else {
      throw StateError("compute called but Computer is not running and not turning on right now.");
    }
  }

  @override
  Future<void> turnOff() {
    final computer = this._computer;
    final onTurnedOn = this._onTurnedOn;

    if (_isRunning) {
      _computer = Computer.create();
      _isRunning = false;
      _onTurnedOn = null;

      return computer.turnOff();
    } else if (_onTurnedOn != null) {
      _computer = Computer.create();
      _isRunning = false;
      _onTurnedOn = null;

      return onTurnedOn!.then((value) => computer.turnOff());
    } else {
      throw StateError("turnOff called but Computer is not running and not turning on right now.");
    }
  }

  @override
  Future<void> turnOn({int workersCount = 2, bool verbose = false}) {
    if (_isRunning) {
      throw StateError("turnOn called but Computer is already running");
    } else if (_onTurnedOn != null) {
      throw StateError("turnOn called but Computer is currently turning on");
    } else {
      _onTurnedOn = _computer.turnOn(workersCount: workersCount, verbose: verbose).then((_) {
        _isRunning = true;
      }).whenComplete(() {
        _onTurnedOn = null;
      });

      return _onTurnedOn!;
    }
  }

  @override
  bool get isRunning => _isRunning;
}

int executeWrite(Tuple4<int, int, int, int> param) {
  final fd = param.item1;
  final writeFuncAddr = param.item2;
  final bufferAddr = param.item3;
  final length = param.item4;

  final write = ffi.Pointer.fromAddress(writeFuncAddr)
      .cast<ffi.NativeFunction<ffi.Int32 Function(ffi.Int32, ffi.Pointer<ffi.Void>, ffi.Uint32)>>()
      .asFunction<int Function(int, ffi.Pointer<ffi.Void>, int)>();

  final buffer = ffi.Pointer<ffi.Uint8>.fromAddress(bufferAddr);
  final result = write(fd, buffer.cast<ffi.Void>(), length);
  return result;
}

class PlatformInterface {
  PlatformInterface._construct(this.dylib, this.libc, this.epollFd, this.onFdReady);

  factory PlatformInterface._private() {
    final dylib = ffi.DynamicLibrary.open("libc.so.6");
    final libc = LibC(dylib);

    final result = libc.epoll_create1(EPOLL_CLOEXEC);
    if (result < 0) {
      throw OSError("Could not create epoll fd for polling serial ports");
    }

    final epollFd = result;
    final receivePort = ReceivePort();
    Isolate.spawn(epollerEntry, Tuple2(receivePort.sendPort, epollFd));
    final fdReadyStream = receivePort.cast<List>().map((list) => list.cast<int>()).asBroadcastStream();

    return PlatformInterface._construct(dylib, libc, epollFd, fdReadyStream);
  }

  final ffi.DynamicLibrary dylib;
  final LibC libc;
  final int epollFd;
  final Stream<List<int>> onFdReady;
  final Map<int, ffi.Pointer<epoll_event>?> _epollEventForFd = <int, ffi.Pointer<epoll_event>>{};
  final Map<int, Computer?> _computerForFd = <int, Computer>{};

  static PlatformInterface? _instance;

  static PlatformInterface get instance {
    _instance ??= PlatformInterface._private();
    return _instance!;
  }

  void makeRaw(int fd) {
    final ptr = ffi.calloc.allocate<termios>(ffi.sizeOf<termios>());

    libc.tcgetattr(fd, ptr);

    ptr.ref.c_iflag &= ~(IGNBRK | BRKINT | PARMRK | ISTRIP | INLCR | IGNCR | ICRNL | IXON);
    ptr.ref.c_oflag &= ~OPOST;
    ptr.ref.c_lflag &= ~(ECHO | ECHONL | ICANON | ISIG | IEXTEN);
    ptr.ref.c_cflag &= ~(CSIZE | PARENB);
    ptr.ref.c_cflag |= CS8;
    ptr.ref.c_cc[VMIN] = 0;
    ptr.ref.c_cc[VTIME] = 0;

    libc.tcsetattr(fd, TCSANOW, ptr);

    ffi.calloc.free(ptr);
  }

  void makeRawAndSetBaudrate(int fd, Baudrate baudrate) {
    final ptr = ffi.calloc.allocate<termios>(ffi.sizeOf<termios>());
    int result;

    result = libc.tcgetattr(fd, ptr);
    if (result < 0) {
      ffi.calloc.free(ptr);
      throw OSError("Could not get termios state for serial port. (tcgetattr)");
    }

    ptr.ref.c_iflag &= ~(IGNBRK | BRKINT | PARMRK | ISTRIP | INLCR | IGNCR | ICRNL | IXON);
    ptr.ref.c_oflag &= ~OPOST;
    ptr.ref.c_lflag &= ~(ECHO | ECHONL | ICANON | ISIG | IEXTEN);
    ptr.ref.c_cflag &= ~(CSIZE | PARENB);
    ptr.ref.c_cflag |= CS8;
    ptr.ref.c_cc[VMIN] = 1;
    ptr.ref.c_cc[VTIME] = 100;

    result = libc.cfsetispeed(ptr, baudrate.asLinuxValue);
    if (result < 0) {
      ffi.calloc.free(ptr);
      throw OSError("Could not set input speed for serial port. (cfsetispeed)");
    }

    result = libc.cfsetospeed(ptr, baudrate.asLinuxValue);
    if (result < 0) {
      ffi.calloc.free(ptr);
      throw OSError("Could not set output speed for serial port. (cfsetospeed)");
    }

    result = libc.tcsetattr(fd, TCSANOW, ptr);
    if (result < 0) {
      ffi.calloc.free(ptr);
      throw OSError("Could not set termios state for serial port. (tcsetattr)");
    }

    ffi.calloc.free(ptr);
  }

  int open(String path, {Baudrate? baudrate}) {
    final allocatedPath = path.toNativeUtf8();

    var result = libc.open(allocatedPath.cast(), O_RDWR | O_CLOEXEC | O_NONBLOCK);

    ffi.malloc.free(allocatedPath);

    if (result < 0) {
      throw OSError("Could not open serial port.");
    }

    final fd = result;

    try {
      if (baudrate != null) {
        PlatformInterface.instance.makeRawAndSetBaudrate(fd, baudrate);
      } else {
        PlatformInterface.instance.makeRaw(fd);
      }
    } on Object {
      libc.close(fd);
      rethrow;
    }

    final epollEvent = ffi.calloc.allocate<epoll_event>(ffi.sizeOf<epoll_event>());

    epollEvent.ref.events = EPOLL_EVENTS.EPOLLIN | EPOLL_EVENTS.EPOLLPRI | EPOLL_EVENTS.EPOLLONESHOT;
    epollEvent.ref.data.u64 = fd;

    result = libc.epoll_ctl(epollFd, EPOLL_CTL_ADD, fd, epollEvent);

    if (result < 0) {
      ffi.calloc.free(epollEvent);
      libc.close(fd);
      throw OSError("Could not add serial port fd to epoll instance");
    }

    _epollEventForFd[fd] = epollEvent;

    _computerForFd[fd] = SynchronousComputer()..turnOn(workersCount: 1);

    return fd;
  }

  void setBaudrate(int fd, Baudrate baudrate) {
    final ptr = ffi.calloc.allocate<termios>(ffi.sizeOf<termios>());

    libc.tcgetattr(fd, ptr);

    libc.cfsetispeed(ptr, baudrate.asLinuxValue);
    libc.cfsetospeed(ptr, baudrate.asLinuxValue);

    libc.tcsetattr(fd, TCSANOW, ptr);

    ffi.calloc.free(ptr);
  }

  Baudrate getBaudrate(int fd) {
    final ptr = ffi.calloc.allocate<termios>(ffi.sizeOf<termios>());

    libc.tcgetattr(fd, ptr);

    final inputSpeedAsLinuxValue = libc.cfgetispeed(ptr);
    final outputSpeedAsLinuxValue = libc.cfgetospeed(ptr);

    ffi.calloc.free(ptr);

    final inputBaudrate = Baudrate.values.singleWhere((element) => element.asLinuxValue == inputSpeedAsLinuxValue);
    final outputBaudrate = Baudrate.values.singleWhere((element) => element.asLinuxValue == outputSpeedAsLinuxValue);

    if (inputBaudrate.inBaudsPerSecond < outputBaudrate.inBaudsPerSecond) {
      return inputBaudrate;
    } else {
      return outputBaudrate;
    }
  }

  void flushInput(int fd) {
    final result = libc.tcflush(fd, TCIFLUSH);
    if (result != 0) {
      throw OSError("Could not flush serial input");
    }
  }

  void arm(int fd) {
    final result = libc.epoll_ctl(epollFd, EPOLL_CTL_MOD, fd, _epollEventForFd[fd]!);
    if (result != 0) {
      throw OSError("Could not arm fd events. (epoll_ctl)");
    }
  }

  int read(int fd, ffi.Pointer buffer, int bufferSize) {
    assert(_epollEventForFd[fd] != null);

    final result = libc.read(fd, buffer.cast<ffi.Void>(), bufferSize);

    if (result < 0) {
      throw OSError("Could not read from serial port fd.");
    }

    return result;
  }

  Future<int> write(int fd, ffi.Pointer buffer, int bufferSize) {
    assert(_epollEventForFd[fd] != null);
    assert(_computerForFd[fd] != null);

    return _computerForFd[fd]!
        .compute<Tuple4<int, int, int, int>, int>(
      executeWrite,
      param: Tuple4<int, int, int, int>(
        fd,
        dylib.lookup("write").address,
        buffer.address,
        bufferSize,
      ),
    )
        .then((result) {
      if (result < 0) {
        throw OSError("Could not write to serial port. (write)");
      }
      return result;
    });
  }

  void close(int fd) {
    assert(_epollEventForFd[fd] != null);
    assert(_computerForFd[fd] != null);
    _computerForFd[fd]!.turnOff();
    _computerForFd[fd] = null;

    final result = libc.close(fd);
    if (result < 0) {
      throw OSError("Could not close serial port fd. (close)");
    }

    ffi.calloc.free(_epollEventForFd[fd]!);
    _epollEventForFd[fd] = null;
  }
}

/// Singleton for listing all the serial ports
/// available on the System, using the [ports] property.
@sealed
class SerialPorts {
  static const _pureSerialMajorNrs = <int>{
    19,
    22,
    24,
    32,
    46,
    48,
    54,
    57,
    71,
    75,
    88,
    105,
    112,
    117,
    148,
    154,
    156,
    164,
    166,
    172,
    174,
    188,
    204,
    208,
    210,
    216,
    224,
    256
  };

  static const _descriptionForMajor = <int, String>{
    4: '8250/16450/16550 UART serial port',
    19: 'Cyclades serial card port',
    22: 'Digiboard serial card port',
    24: 'Stallion serial card port',
    32: 'Specialix serial card port',
    46: 'Comtrol Rocketport serial card port',
    48: 'SDL RISCom serial card port',
    54: 'Electrocardiognosis Holter serial card port',
    57: 'Hayes ESP serial card port',
    71: 'Computone IntelliPort II serial card port',
    75: 'Specialix IO8+ serial card port',
    88: 'COMX synchronous serial card port',
    105: 'Comtrol VS-1000 serial controller port',
    112: 'ISI serial card port',
    117: 'COSA/SRP synchronous serial card port',
    148: 'Technology Concepts serial card port',
    154: 'Specialix RIO serial card port',
    156: 'Specialix RIO serial card port',
    164: 'Chase Research AT/PCI-Fast serial card port',
    166: 'ACM USB modem',
    172: 'Moxa Intellio serial card port',
    174: 'SmartIO serial card port',
    188: 'USB serial converter',
    204: 'Low-density serial port',
    208: 'User space serial port',
    210: 'SBE, Inc. sync/async serial card port',
    216: 'Bluetooth RFCOMM TTY device',
    224: 'A2232 serial card port',
    256: 'Equinox SST multi-port serial board port'
  };

  static String? _getDescriptionForMagicNumbers(int major, int minor) {
    if (major == 204) {
      if (minor <= 3) {
        return 'LinkUp Systems L72xx UART port';
      } else if (minor == 4) {
        return 'Intel Footbridge (ARM)';
      } else if (minor <= 7) {
        return 'StrongARM builtin serial port';
      } else if (minor <= 11) {
        return 'SCI serial port (SuperH)';
      } else if (minor <= 12) {
        return 'Firmware console';
      } else if (minor <= 31) {
        return 'ARM \"AMBA\" serial port';
      } else if (minor <= 39) {
        return 'DataBooster serial port';
      } else if (minor == 40) {
        return 'SGI Altix console port';
      } else if (minor <= 43) {
        return 'Motorola i.MX serial port';
      } else if (minor <= 45) {
        return null;
      } else if (minor <= 47) {
        return 'PPC CPM (SCC or SMC) serial port';
      } else if (minor <= 81) {
        return 'Altix serial card port';
      } else if (minor == 82) {
        return 'NEC VR4100 series SIU';
      } else if (minor == 83) {
        return 'NEC VR4100 series DSIU';
      } else if (minor <= 115) {
        return 'Altix ioc4 serial card port';
      } else if (minor <= 147) {
        return 'Altix ioc3 serial card port';
      } else if (minor <= 153) {
        return 'PPC PSC serial port';
      } else if (minor <= 169) {
        return 'ATMEL serial port';
      } else if (minor <= 185) {
        return 'Hilscher netX serial port';
      } else if (minor == 186) {
        return 'JTAG1 DCC protocol based serial port emulation';
      } else if (minor <= 190) {
        return 'Xilinx uartlite port';
      } else if (minor == 191) {
        return 'Xen virtual console';
      } else if (minor <= 195) {
        return 'pmac_zilog serial port';
      } else if (minor <= 204) {
        return 'TX39/49 serial port';
      } else if (minor <= 208) {
        return 'SC26xx serial port';
      } else if (minor <= 212) {
        return 'MAX3100 serial port';
      } else {
        return null;
      }
    } else {
      return _descriptionForMajor[major];
    }
  }

  /// Creates a set of available [SerialPort]s on your system and
  /// returns it.
  static Set<SerialPort> get ports {
    if (!Platform.isLinux && !Platform.isAndroid) {
      throw StateError("This package only works on linux / android.");
    }

    return Directory(
      "/sys/dev/char",
    ).listSync(followLinks: false).map((element) {
      final match = RegExp("^([0-9]*):([0-9]*)\$").allMatches(basename(element.path)).single;
      final major = int.parse(match.group(1)!);
      final minor = int.parse(match.group(2)!);
      final name = basename(element.resolveSymbolicLinksSync());

      return Tuple3<String, int, int>(name, major, minor);
    }).where((tuple) {
      final major = tuple.item2;
      final minor = tuple.item3;

      if (major == 4 && minor >= 64) {
        return true;
      } else if (_pureSerialMajorNrs.contains(major)) {
        return true;
      } else {
        return false;
      }
    }).map((e) {
      final name = e.item1;
      final major = e.item2;
      final minor = e.item3;

      return SerialPort("/dev/$name", major, minor, _getDescriptionForMagicNumbers(major, minor) ?? "");
    }).toSet();
  }
}

/// A single linux serial port.
@immutable
class SerialPort {
  SerialPort(this.path, this.major, this.minor, this.description);

  /// The path of the serial port inside of `/dev`
  final String path;

  /// The major number of the device
  final int major;

  /// The minor number of the device
  final int minor;

  /// A description of this serial port, determined by the
  /// major and minor numbers.
  final String description;

  /// Creates a [File] from [path] and returns it
  File get file => File(path);

  /// The name of the device file of the serial port,
  /// for example `ttyUSB0` for a USB serial port.
  String get name => basename(path);

  /// Opens the serial port for reading and writing and
  /// returns a handle to it.
  SerialPortHandle open({Baudrate? baudrate}) {
    final fd = PlatformInterface.instance.open(path, baudrate: baudrate);

    return SerialPortHandle._private(fd);
  }

  @override
  String toString() {
    return "SerialPort(file: $file, name: $name)";
  }
}

abstract class StringReader {
  factory StringReader(Stream<int> source, {Encoding encoding = utf8}) {
    return _StringReaderImpl(source, encoding: encoding);
  }

  @protected
  StringReader.construct({required this.encoding});

  Encoding encoding;

  Future<List<int>> readBytes(int numBytes);

  /// Reads a string that has [length] number of characters.
  /// Read [numBytes] bytes and convert it into a string.
  Future<String> read({int? length, int? numBytes});

  Future<String> readln([String lineBreak = '\n']);

  Future<void> close({bool immediate = false});
}

class _StringReaderImpl extends StringReader {
  _StringReaderImpl(this.source, {required Encoding encoding})
      : queue = StreamQueue(source),
        super.construct(encoding: encoding);

  final Stream<int> source;
  final StreamQueue<int> queue;

  Future<List<int>> readBytes(int numBytes) async {
    assert(numBytes >= 0);

    final result = <int>[];

    while (result.length <= numBytes) {
      result.add(await queue.next);
    }

    return result;
  }

  Future<String> read({int? numBytes, int? length}) async {
    if ((numBytes != null) == (length != null)) {
      throw ArgumentError("Exactly one of `numBytes` or `length` must be given.");
    }

    final encoding = this.encoding;
    if (isEncodingStatic(encoding)) {
      numBytes = getBytesPerChar(encoding);
    }

    if (numBytes != null) {
      return readBytes(numBytes).then((value) => encoding.decode(value));
    } else {
      final buffer = StringBuffer();
      final stringSink = StringConversionSink.fromStringSink(buffer);
      final byteSink = encoding.decoder.startChunkedConversion(stringSink);

      while (buffer.length < length!) {
        byteSink.add([await queue.next]);
      }

      return buffer.toString();
    }
  }

  Future<String> readln([String lineBreak = '\n']) async {
    final encoding = this.encoding;

    final buffer = StringBuffer();
    final stringSink = StringConversionSink.fromStringSink(buffer);
    final byteSink = encoding.decoder.startChunkedConversion(stringSink);

    while (true) {
      byteSink.add([await queue.next]);

      var string = buffer.toString();

      final matches = lineBreak.allMatches(string);
      if (matches.isNotEmpty) {
        string = string.substring(0, matches.first.start);
        return string;
      }
    }
  }

  Future<void> close({bool immediate = false}) {
    return queue.cancel(immediate: false) ?? Future.value();
  }
}

bool isEncodingStatic(Encoding encoding) {
  return (encoding is AsciiCodec) || (encoding is Latin1Codec);
}

int getBytesPerChar(Encoding encoding) {
  if (encoding is AsciiCodec) {
    return 1;
  } else if (encoding is Latin1Codec) {
    return 1;
  } else {
    throw ArgumentError.value(encoding, "Encoding doesn't have a static number of bytes per character.");
  }
}

/// A handle for an opened serial port.
class SerialPortHandle implements StringSink, StringReader {
  factory SerialPortHandle._private(int fd) {
    var readBuffer = ffi.malloc.allocate<ffi.Uint8>(_bufferSize);

    StreamSubscription<List<int>>? fdReadySubscription;
    late StreamController<List<int>> inputController;

    inputController = StreamController.broadcast(
        onListen: () {
          PlatformInterface.instance.flushInput(fd);

          fdReadySubscription = PlatformInterface.instance.onFdReady.listen((fds) {
            if (fds.contains(fd)) {
              final actuallyRead = PlatformInterface.instance.read(fd, readBuffer, _bufferSize);

              PlatformInterface.instance.arm(fd);

              if (actuallyRead > 0) {
                final copiedBytes = List<int>.unmodifiable(Uint8List.fromList(readBuffer.asTypedList(actuallyRead)));
                inputController.add(copiedBytes);
              }
            }
          });

          PlatformInterface.instance.arm(fd);
        },
        onCancel: () {
          fdReadySubscription!.cancel();
          fdReadySubscription = null;
        },
        sync: true);

    return SerialPortHandle._construct(fd, inputController, ffi.malloc.allocate<ffi.Uint8>(_bufferSize));
  }

  SerialPortHandle._construct(this._fd, this._inputController, this._writeBuffer)
      : stream = _inputController.stream,
        byteStream = _inputController.stream.expand((element) => element),
        _writeBufferAsTypedList = _writeBuffer.asTypedList(_bufferSize);

  static const _bufferSize = 2048;
  ffi.Pointer<ffi.Uint8> _writeBuffer;
  final Uint8List _writeBufferAsTypedList;
  final _writeLock = Lock();

  final int _fd;
  final StreamController<List<int>> _inputController;

  /// The stream of byte lists being received from the port,
  /// as a broadcast stream.
  final Stream<List<int>> stream;

  /// [stream], but in bytes rather than byte lists.
  final Stream<int> byteStream;

  /// The encoding used for converting strings into bytes and
  /// vice-versa. Used in [write], [writeAll], [writeCharCode], [writeln],
  /// [read], [readStringWithNumBytes], [readln]
  /// and [getNewSequentialReader].
  Encoding encoding = utf8;
  bool _isOpen = true;

  /// The currently configured baudrate (speed) of the serial port.
  Baudrate get baudrate {
    assert(_isOpen);
    return PlatformInterface.instance.getBaudrate(_fd);
  }

  /// The currently configured baudrate (speed) of the serial port.
  set baudrate(Baudrate value) {
    assert(_isOpen);
    return PlatformInterface.instance.setBaudrate(_fd, value);
  }

  /// Close the serial port. This synchronously closes the handle.
  /// The returned future completes after the complete cleanup is done.
  @override
  Future<void> close({bool immediate = false}) {
    assert(_isOpen);
    _isOpen = false;

    PlatformInterface.instance.close(_fd);
    final result = _inputController.close();

    _writeLock.synchronized(() {
      ffi.malloc.free(_writeBuffer);
    });

    return result.then<void>((value) => null);
  }

  Future<void> writeBytes(Iterable<int> bytes) {
    assert(_isOpen);

    if (bytes.isEmpty) {
      return _writeLock.synchronized(() {});
    }

    return _writeLock.synchronized(() async {
      if (!_isOpen) return;

      for (final slice in bytes.slices(_bufferSize)) {
        _writeBufferAsTypedList.setAll(0, slice);
        await PlatformInterface.instance.write(_fd, _writeBuffer, slice.length);
      }
    });
  }

  @override
  Future<void> write(Object? obj) {
    assert(_isOpen);

    final bytes = encoding.encode('$obj');
    return writeBytes(bytes);
  }

  @override
  Future<void> writeAll(Iterable objects, [String separator = ""]) {
    Future<void> future;

    Iterator iterator = objects.iterator;
    if (!iterator.moveNext()) _writeLock.synchronized(() {});

    if (separator.isEmpty) {
      future = write(iterator.current);
      while (iterator.moveNext()) {
        final current = iterator.current;
        future = future.then((_) => write(current));
      }
      ;
    } else {
      future = write(iterator.current);
      while (iterator.moveNext()) {
        future = future.then((_) => write(separator));

        final current = iterator.current;
        future = future.then((_) => write(current));
      }
    }

    return future;
  }

  @override
  Future<void> writeCharCode(int charCode) {
    return write(String.fromCharCode(charCode));
  }

  @override
  Future<void> writeln([Object? obj = "", String linebreak = "\n"]) {
    if (linebreak.isNotEmpty) {
      return write(obj).then((_) => write(linebreak));
    } else {
      return write(obj);
    }
  }

  @override
  Future<List<int>> readBytes(int numBytes) {
    assert(numBytes >= 0);

    if (numBytes == 0) {
      return Future.value(<int>[]);
    }

    late StreamSubscription<List<int>> sub;
    final result = <int>[];
    final completer = Completer<List<int>>();

    sub = stream.listen((bytes) {
      final toTake = min(bytes.length, numBytes - result.length);
      result.addAll(bytes.take(toTake));

      if (result.length == numBytes) {
        completer.complete(result);
        sub.cancel();
      }
    }, onError: (err, stackTrace) {
      completer.completeError(err, stackTrace);
    }, onDone: () {
      completer.completeError(StateError("Serial input stream closed prematurely."), StackTrace.current);
    }, cancelOnError: true);

    return completer.future;
  }

  @override
  Future<String> read({int? length, int? numBytes}) {
    if ((numBytes != null) == (length != null)) {
      throw ArgumentError("Exactly one of `numBytes` or `length` must be given.");
    }

    final encoding = this.encoding;
    if (isEncodingStatic(encoding)) {
      numBytes = getBytesPerChar(encoding);
    }

    if (numBytes != null) {
      return readBytes(numBytes).then((bytes) => encoding.decode(bytes));
    } else {
      final completer = Completer<String>();
      final buffer = StringBuffer();
      final stringSink = StringConversionSink.fromStringSink(buffer);
      final byteSink = encoding.decoder.startChunkedConversion(stringSink);

      late StreamSubscription<List<int>> sub;
      sub = stream.listen((bytes) {
        byteSink.add(bytes);

        if (buffer.length >= length!) {
          final result = buffer.toString().substring(0, length);
          sub.cancel();
          byteSink.close();
          stringSink.close();
          completer.complete(result);
        }
      }, onError: (error, stackTrace) {
        byteSink.close();
        stringSink.close();
        completer.completeError(error, stackTrace);
      }, onDone: () {
        byteSink.close();
        stringSink.close();
        completer.completeError(StateError("Serial input stream closed prematurely."), StackTrace.current);
      });

      return completer.future;
    }
  }

  @override
  Future<String> readln([String linebreak = '\n']) {
    final encoding = this.encoding;
    final completer = Completer<String>();
    final buffer = StringBuffer();
    final stringSink = StringConversionSink.fromStringSink(buffer);
    final byteSink = encoding.decoder.startChunkedConversion(stringSink);

    late StreamSubscription<List<int>> sub;
    sub = stream.listen((bytes) {
      byteSink.add(bytes);

      var string = buffer.toString();

      final matches = linebreak.allMatches(string);
      if (matches.isNotEmpty) {
        string = string.substring(0, matches.first.start);
        sub.cancel();
        byteSink.close();
        stringSink.close();
        completer.complete(string);
      }
    }, onError: (error, stackTrace) {
      sub.cancel();
      byteSink.close();
      stringSink.close();
      completer.completeError(error, stackTrace);
    }, onDone: () {
      sub.cancel();
      byteSink.close();
      stringSink.close();
      completer.completeError(StateError("Serial input stream closed prematurely."), StackTrace.current);
    });

    return completer.future;
  }

  StringReader getNewSequentialReader() {
    return StringReader(stream.expand((element) => element), encoding: encoding);
  }
}
