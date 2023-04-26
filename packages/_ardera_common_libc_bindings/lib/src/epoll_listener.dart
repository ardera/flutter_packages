import 'dart:async';
import 'dart:collection';
import 'dart:ffi' as ffi;
import 'dart:isolate';
import 'package:_ardera_common_libc_bindings/linux_error.dart';
import 'package:_ardera_common_libc_bindings/src/libc.dart';
import 'package:ffi/ffi.dart' as ffi;
import 'package:quiver/collection.dart';
import 'package:tuple/tuple.dart';

/// See:
///   https://man7.org/linux/man-pages/man2/epoll_ctl.2.html
enum EpollFlag {
  /// The associated file is available for read operations.
  inReady(EPOLLIN),

  /// The associated file is available for write operations.
  outReady(EPOLLOUT),

  /// Stream socket peer closed connection, or shut down writing
  /// half of connection.
  rdhup(EPOLLRDHUP),

  /// There is an exceptional condition on the file descriptor.
  pri(EPOLLPRI),

  /// Error condition happened on the associated file descriptor.
  ///
  /// This event is also reported for the write end of a pipe when
  /// the read end has been closed.
  ///
  /// [LibC.epoll_wait] will always report this event; it is not
  /// necessary to set it in events when calling [LibC.epoll_ctl].
  err(EPOLLERR),

  /// Hang up happened on the associated file descriptor.
  ///
  /// [LibC.epoll_wait] will always wait for this event; it is not
  /// necessary to set it in events when calling [LibC.epoll_ctl].
  ///
  /// Note that when reading from a channel such as a pipe or a
  /// stream socket, this event merely indicates that the peer
  /// closed its end of the channel.  Subsequent reads from the
  /// channel will return 0 (end of file) only after all
  /// outstanding data in the channel has been consumed.
  hup(EPOLLHUP),

  /// Requests edge-triggered notification for the associated
  /// file descriptor.  The default behavior for epoll is level-
  /// triggered.  See [1] for more detailed information
  /// about edge-triggered and level-triggered notification.
  ///
  /// This flag is an input flag for the event.events field when
  /// calling [LibC.epoll_ctl]; it is never returned by
  /// [LibC.epoll_wait].
  ///
  /// [1]: https://man7.org/linux/man-pages/man7/epoll.7.html
  edgeTriggered(EPOLLET),

  /// Requests one-shot notification for the associated file
  /// descriptor.
  ///
  /// This means that after an event notified for
  /// the file descriptor by [LibC.epoll_wait], the file descriptor
  /// is disabled in the interest list and no other events will
  /// be reported by the epoll interface.  The user must call
  /// [LibC.epoll_ctl] with [EPOLL_CTL_MOD] to rearm the file
  /// descriptor with a new event mask.
  ///
  /// This flag is an input flag for the event.events field when
  /// calling [LibC.epoll_ctl]; it is never returned by
  /// [LibC.epoll_wait].
  oneShot(EPOLLONESHOT),

  /// If [oneShot] and [edegeTriggered] are clear and the process has
  /// the CAP_BLOCK_SUSPEND capability, ensure that the system
  /// does not enter "suspend" or "hibernate" while this event
  /// is pending or being processed.
  ///
  /// The event is considered as being "processed" from the time
  /// when it is returned by a call to [LibC.epoll_wait] until the
  /// next call to [LibC.epoll_wait] on the same epoll file
  /// descriptor, the closure of that file descriptor, the removal
  /// of the event file descriptor with [EPOLL_CTL_DEL], or the
  /// clearing of [wakeUp] for the event file descriptor with
  /// [EPOLL_CTL_MOD].
  ///
  /// This flag is an input flag for the event.events field when
  /// calling [LibC.epoll_ctl]; it is never returned by
  /// [LibC.epoll_wait].
  wakeUp(EPOLLWAKEUP),

  /// Sets an exclusive wakeup mode for the epoll file descriptor that is being
  /// attached to the target file descriptor, fd.
  ///
  /// See:
  ///   https://man7.org/linux/man-pages/man2/epoll_ctl.2.html
  exclusive(EPOLLEXCLUSIVE);

  const EpollFlag(this._value);

  final int _value;
}

abstract class _Cmd {
  const _Cmd({
    required this.seq,
  });

  final Capability seq;
}

class _AddCmd extends _Cmd {
  const _AddCmd({
    required super.seq,
    required this.fd,
    required this.flags,
    required this.listenerIdentity,
  });

  final int fd;
  final Set<EpollFlag> flags;
  final Capability listenerIdentity;
}

class _ModCmd extends _Cmd {
  const _ModCmd({
    required super.seq,
    required this.fd,
    required this.flags,
    required this.listenerIdentity,
  });

  final int fd;
  final Set<EpollFlag> flags;
  final Capability listenerIdentity;
}

class _DelCmd extends _Cmd {
  const _DelCmd({
    required super.seq,
    required this.fd,
    required this.listenerIdentity,
  });

  final int fd;
  final Capability listenerIdentity;
}

class _StopCmd extends _Cmd {
  const _StopCmd({
    required super.seq,
  });
}

abstract class _Reply {
  const _Reply();
}

class _EventReply extends _Reply {
  const _EventReply({
    required this.listenerIdentity,
    required this.events,
  });

  final Capability listenerIdentity;
  final Set<EpollFlag> events;
}

abstract class _CmdReply extends _Reply {
  const _CmdReply({required this.seq});

  final Capability seq;
}

class _SuccessCmdReply extends _CmdReply {
  const _SuccessCmdReply({required super.seq});
}

class _ErrorCmdReply extends _CmdReply {
  const _ErrorCmdReply({
    required super.seq,
    required this.error,
    this.stackTrace,
  });

  final Object error;
  final StackTrace? stackTrace;
}

class _IsolateQuitMessage {}

void _epollMgrEntry(Tuple4<ReceivePort, SendPort, int, int> args) async {
  final receivePort = args.item1;
  final sendPort = args.item2;
  final epollFd = args.item3;
  final eventFd = args.item4;
  final eventFdCap = Capability();

  final capabilityMap = BiMap<int, Capability>();
  final cmdQueue = Queue<_Cmd>();

  const maxEvents = 128;
  final events = ffi.calloc<epoll_event>(maxEvents);

  var run = true;
  var nextCapabilityMapIndex = 1;

  final subscription = receivePort.listen((message) {
    assert(message is _Cmd);
    cmdQueue.add(message);
  });

  try {
    assert(epollFd > 0);
    assert(eventFd > 0);

    final libc = LibC(ffi.DynamicLibrary.open('libc.so.6'));

    void epollCtl({
      required int op,
      required int fd,
      required Set<EpollFlag> flags,
      required int userdata,
    }) {
      final event = ffi.calloc<epoll_event>();

      for (final flag in flags) {
        event.ref.events |= flag._value;
      }

      event.ref.data.u64 = userdata;

      try {
        final ok = libc.epoll_ctl(epollFd, op, fd, event);
        if (ok < 0) {
          throw LinuxError('Could not add/modify/remove epoll entry.', 'epoll_ctl', libc.errno);
        }
      } finally {
        ffi.calloc.free(event);
      }
    }

    void add({
      required int fd,
      required Set<EpollFlag> flags,
      required Capability userdata,
    }) {
      assert(!capabilityMap.containsValue(userdata));

      final index = nextCapabilityMapIndex;

      epollCtl(
        op: EPOLL_CTL_ADD,
        fd: fd,
        flags: flags,
        userdata: index,
      );

      capabilityMap[index] = userdata;
      nextCapabilityMapIndex++;
    }

    void mod({
      required int fd,
      required Set<EpollFlag> flags,
      required Capability userdata,
    }) {
      assert(capabilityMap.containsValue(userdata));

      epollCtl(
        op: EPOLL_CTL_MOD,
        fd: fd,
        flags: flags,
        userdata: capabilityMap.inverse[userdata]!,
      );
    }

    void del({
      required int fd,
      required Capability userdata,
    }) {
      assert(capabilityMap.containsValue(userdata));

      epollCtl(
        op: EPOLL_CTL_MOD,
        fd: fd,
        flags: const <EpollFlag>{},
        userdata: 0,
      );

      capabilityMap.inverse.remove(userdata);
    }

    void sendEvent({
      required Capability userdata,
      required Set<EpollFlag> events,
    }) {
      sendPort.send(_EventReply(
        listenerIdentity: userdata,
        events: events,
      ));
    }

    void replySuccess(
      _Cmd cmd,
    ) {
      sendPort.send(_SuccessCmdReply(seq: cmd.seq));
    }

    void replyError(_Cmd cmd, {required Object error, StackTrace? stackTrace}) {
      sendPort.send(_ErrorCmdReply(
        seq: cmd.seq,
        error: error,
        stackTrace: stackTrace,
      ));
    }

    Future<void> waitForEvents() async {
      await Future.delayed(Duration.zero);
    }

    /// Add the event fd to the epoll instance.
    /// so we get notified of new commands even when we're in
    /// epoll_wait right now.
    add(
      fd: eventFd,
      flags: {EpollFlag.inReady},
      userdata: eventFdCap,
    );

    while (run) {
      // let the microtask loop run so events the receivePort listener
      // is invoked and commands are added to the cmd queue
      await waitForEvents();

      // process cmd queue
      while (run && cmdQueue.isNotEmpty) {
        final cmd = cmdQueue.removeFirst();

        try {
          if (cmd is _AddCmd) {
            add(
              fd: cmd.fd,
              flags: cmd.flags,
              userdata: cmd.listenerIdentity,
            );
          } else if (cmd is _ModCmd) {
            mod(
              fd: cmd.fd,
              flags: cmd.flags,
              userdata: cmd.listenerIdentity,
            );
          } else if (cmd is _DelCmd) {
            del(
              fd: cmd.fd,
              userdata: cmd.listenerIdentity,
            );
          } else if (cmd is _StopCmd) {
            run = false;
          } else {
            assert(false);
          }

          replySuccess(cmd);
        } on Exception catch (e, stackTrace) {
          replyError(
            cmd,
            error: e,
            stackTrace: stackTrace,
          );
        }
      }

      if (!run) {
        break;
      }

      final ok = libc.epoll_wait(
        epollFd,
        events,
        maxEvents,
        // run indefinitely
        -1,
      );
      if (ok < 0) {
        throw LinuxError('Could not wait for epoll events.', 'epoll_wait', libc.errno);
      }

      if (ok > 0) {
        // process events
        for (var i = 0; i < ok; i++) {
          final event = events.elementAt(i);

          final capability = capabilityMap[event.ref.data.u64]!;

          final flags = <EpollFlag>{};
          for (final flag in EpollFlag.values) {
            if (event.ref.events & flag._value != 0) {
              flags.add(flag);
            }
          }

          if (capability == eventFdCap) {
            // do nothing
          } else {
            sendEvent(
              userdata: capability,
              events: flags,
            );
          }
        }
      }
    }
  } finally {
    subscription.cancel();
    ffi.calloc.free(events);
  }
}

class FdListener {
  FdListener(this._fd, this._callback);

  final _identity = Capability();
  final int _fd;
  final void Function(Set<EpollFlag> events) _callback;
}

class EpollEventLoop {
  EpollEventLoop._construct({
    required LibC libc,
    required int epollFd,
    required int eventFd,
    required ReceivePort receivePort,
    required SendPort sendPort,
    required Future<Isolate> isolateFuture,
  })  : _libc = libc,
        _epollFd = epollFd,
        _eventFd = eventFd,
        _receivePort = receivePort,
        _sendPort = sendPort,
        _isolateFuture = isolateFuture,
        _notifyBuffer = ffi.calloc<ffi.Uint8>(8) {
    _isolateFuture.then(
      (isolate) {
        _isolate = isolate;

        isolate.addOnExitListener(
          _receivePort.sendPort,
          response: _IsolateQuitMessage(),
        );

        isolate.addErrorListener(_receivePort.sendPort);
      },
      onError: (err, stackTrace) {
        _isolateError = err.toString();
        _isolateErrorStackTrace = stackTrace.toString();
      },
    );

    _receivePortSubscription = _receivePort.listen(_onReceivePortMessage);
  }

  factory EpollEventLoop(LibC libc) {
    final epollFd = libc.epoll_create1(EPOLL_CLOEXEC);
    if (epollFd < 0) {
      throw LinuxError('Could not create epoll fd.', 'epoll_create1', libc.errno);
    }

    final eventFd = 0;

    final myReceivePort = ReceivePort();
    final otherSendPort = myReceivePort.sendPort;

    final otherReceivePort = ReceivePort();
    final mySendPort = otherReceivePort.sendPort;

    final isolateFuture = Isolate.spawn(
      _epollMgrEntry,
      Tuple4(otherReceivePort, otherSendPort, epollFd, eventFd),
    );

    return EpollEventLoop._construct(
      libc: libc,
      epollFd: epollFd,
      eventFd: eventFd,
      receivePort: myReceivePort,
      sendPort: mySendPort,
      isolateFuture: isolateFuture,
    );
  }

  final LibC _libc;
  final int _epollFd;
  final int _eventFd;
  final ReceivePort _receivePort;
  final SendPort _sendPort;
  final Future<Isolate> _isolateFuture;

  late final StreamSubscription _receivePortSubscription;
  final ffi.Pointer<ffi.Uint8> _notifyBuffer;

  var _alive = true;

  Isolate? _isolate;
  String? _isolateError;
  String? _isolateErrorStackTrace;
  final _isolateExitCompleter = Completer.sync();

  final _eventHandlers = <Capability, FdListener>{};
  final _pendingCommands = <Capability, Completer>{};

  void _onReceivePortMessage(dynamic msg) {
    assert(msg is _Reply || msg is _IsolateQuitMessage || msg is List);

    if (msg is _EventReply) {
      _onEvent(msg);
    } else if (msg is _CmdReply) {
      _onCmdReply(msg);
    } else if (msg is _IsolateQuitMessage) {
      _isolateExitCompleter.complete();
    } else if (msg is List) {
      assert(msg[0] is String);
      assert(msg[1] is String?);

      _isolateError = msg[0];
      _isolateErrorStackTrace = msg[1];
    } else {
      assert(false);
    }
  }

  void _onEvent(_EventReply event) {
    if (!_eventHandlers.containsKey(event.listenerIdentity)) {
      throw StateError('No event listener registered for capability ${event.listenerIdentity}.');
    }

    _eventHandlers[event.listenerIdentity]!._callback(event.events);
  }

  void _onCmdReply(_CmdReply reply) {
    final completer = _pendingCommands.remove(reply.seq);

    if (completer == null) {
      throw StateError('Command with seqno ${reply.seq} has no registered completer, and has already been replied to.');
    }

    if (reply is _SuccessCmdReply) {
      completer.complete();
    } else if (reply is _ErrorCmdReply) {
      completer.completeError(reply.error, reply.stackTrace);
    }
  }

  void _notifyIsolate() {
    final ok = _libc.write(_eventFd, _notifyBuffer.cast<ffi.Void>(), 8);
    if (ok < 0) {
      throw LinuxError('Could not wakeup epoll isolate.', 'write', _libc.errno);
    }
  }

  Future<void> _sendCmd(_Cmd cmd, {bool notify = true}) async {
    assert(_alive);

    if (_isolate == null) {
      if (_isolateError != null) {
        throw RemoteError(_isolateError!, _isolateErrorStackTrace ?? '');
      }

      await _isolateFuture;

      if (_isolateError != null) {
        throw RemoteError(_isolateError!, _isolateErrorStackTrace ?? '');
      }
    }

    final seq = cmd.seq;

    final completer = Completer.sync();

    // send the commands through
    _sendPort.send(cmd);

    _pendingCommands[seq] = completer;

    // notify the isolate of the new command
    // (it might be in the middle of a epoll_wait)
    if (notify) {
      _notifyIsolate();
    }

    // wait for the ACK here
    return await completer.future;
  }

  Future<FdListener> add({
    required int fd,
    required Set<EpollFlag> events,
    required void Function(Set<EpollFlag> events) callback,
  }) async {
    assert(_alive);

    final seq = Capability();
    final listener = FdListener(fd, callback);

    await _sendCmd(_AddCmd(
      seq: seq,
      fd: fd,
      flags: events,
      listenerIdentity: listener._identity,
    ));

    return listener;
  }

  Future<void> modify({
    required FdListener listener,
    required Set<EpollFlag> events,
  }) async {
    assert(_alive);

    final seq = Capability();

    await _sendCmd(_ModCmd(
      seq: seq,
      fd: listener._fd,
      flags: events,
      listenerIdentity: listener._identity,
    ));
  }

  Future<void> _delete({required FdListener listener, bool notify = true}) async {
    assert(_alive);

    final seq = Capability();

    try {
      await _sendCmd(
        _DelCmd(
          seq: seq,
          fd: listener._fd,
          listenerIdentity: listener._identity,
        ),
        notify: notify,
      );
    } finally {
      _eventHandlers.remove(listener._identity);
    }
  }

  Future<void> delete({required FdListener listener}) {
    return _delete(listener: listener);
  }

  Future<void> dispose() async {
    assert(_alive);

    // first, delete all listeners.
    // then, send the stop command.
    //
    // don't set notify so we don't signal the
    // eventfd 10000 times.
    final futures = [
      for (final listener in _eventHandlers.values)
        _delete(
          listener: listener,
          notify: false,
        ),
      _sendCmd(_StopCmd(seq: Capability()))
    ];

    // signal the event fd once.
    _notifyIsolate();

    // wait for all commands to complete.
    await Future.wait(futures);

    assert(_isolate != null);
    await _isolateExitCompleter.future;

    ffi.calloc.free(_notifyBuffer);
    _receivePortSubscription.cancel();
    _libc.close(_epollFd);
    _libc.close(_eventFd);

    _alive = false;
  }
}
