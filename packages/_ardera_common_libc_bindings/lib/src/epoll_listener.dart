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
    required this.callback,
    required this.callbackContext,
  });

  final int fd;
  final Set<EpollFlag> flags;
  final Capability listenerIdentity;
  final FdReadyCallback callback;
  final dynamic callbackContext;
}

class _ModCmd extends _Cmd {
  const _ModCmd({
    required super.seq,
    required this.listenerIdentity,
    this.flags,
    this.callback,
  });

  final Capability listenerIdentity;
  final Set<EpollFlag>? flags;
  final FdReadyCallback? callback;
}

class _DelCmd extends _Cmd {
  const _DelCmd({
    required super.seq,
    required this.listenerIdentity,
  });

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

class _InitializedEvent extends _Reply {
  const _InitializedEvent({required this.sendPort});

  final SendPort sendPort;
}

class _SuccessEvent<T> extends _Reply {
  const _SuccessEvent({
    required this.listenerIdentity,
    required this.event,
  });

  final Capability listenerIdentity;
  final T event;
}

class _ErrorEvent<T> extends _Reply {
  const _ErrorEvent({
    required this.listenerIdentity,
    required this.error,
    this.stackTrace,
  });

  final Capability listenerIdentity;
  final Object error;
  final StackTrace? stackTrace;
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

typedef FdReadyCallback = dynamic Function(EpollIsolate isolate, int fd, Set<EpollFlag> flags, dynamic context);

void _noop(EpollIsolate isolate, int fd, Set<EpollFlag> flags, void context) {}

class _Handler<C, V> {
  _Handler({
    required this.id,
    required this.fd,
    required this.flags,
    required this.callback,
    required this.callbackContext,
  });

  Capability id;
  int fd;
  Set<EpollFlag> flags;
  FdReadyCallback callback;
  dynamic callbackContext;
}

class EpollIsolate {
  EpollIsolate.fromIsolateArgs(Tuple3<SendPort, int, int> args)
      : _sendPort = args.item1,
        _epollFd = args.item2,
        _eventFd = args.item3 {
    _subscription = _receivePort.listen((message) {
      assert(message is _Cmd);
      _cmdQueue.add(message);
    });
  }

  final ReceivePort _receivePort = ReceivePort();
  final SendPort _sendPort;
  final int _epollFd;
  final int _eventFd;

  // There's no real reason to use [Capability] here, since we don't communicate this
  // across isolate boundaries, but we use Capability for all other fd handlers, so
  // let's use it here too.
  final _eventFdCap = Capability();

  final _capabilityMap = BiMap<int, Object>();
  final _handlerMap = <Object, _Handler>{};
  final _cmdQueue = Queue<_Cmd>();

  static const _maxEvents = 128;
  final _events = ffi.calloc<epoll_event>(_maxEvents);

  var _shouldRun = true;
  var _nextCapabilityMapIndex = 1;

  late final StreamSubscription<dynamic> _subscription;

  final libc = LibC(ffi.DynamicLibrary.open('libc.so.6'));

  void _epollCtl({
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
      final ok = libc.epoll_ctl(_epollFd, op, fd, event);
      if (ok < 0) {
        throw LinuxError('Could not add/modify/remove epoll entry.', 'epoll_ctl', libc.errno);
      }
    } finally {
      ffi.calloc.free(event);
    }
  }

  void _add({
    required Capability listenerId,
    required int fd,
    required Set<EpollFlag> flags,
    required FdReadyCallback callback,
    required dynamic callbackContext,
  }) {
    assert(!_capabilityMap.containsValue(listenerId));

    final index = _nextCapabilityMapIndex;
    final handler = _Handler(
      id: listenerId,
      fd: fd,
      flags: flags,
      callback: callback,
      callbackContext: callbackContext,
    );

    _epollCtl(
      op: EPOLL_CTL_ADD,
      fd: fd,
      flags: flags,
      userdata: index,
    );

    _capabilityMap[index] = listenerId;
    _handlerMap[listenerId] = handler;
    _nextCapabilityMapIndex++;
  }

  void _mod<C, V>({
    required Object listenerId,
    Set<EpollFlag>? flags,
    FdReadyCallback? callback,
    dynamic callbackContext,
    bool forceSetContext = false,
    bool force = false,
  }) {
    assert(_capabilityMap.containsValue(listenerId));
    assert(_handlerMap.containsKey(listenerId));

    final handler = _handlerMap[listenerId]! as _Handler<C, V>;

    if (flags != null || force) {
      _epollCtl(
        op: EPOLL_CTL_MOD,
        fd: handler.fd,
        flags: flags ?? handler.flags,
        userdata: _capabilityMap.inverse[listenerId]!,
      );
    }

    // only apply the new values when we know epoll_ctl succeeded
    handler.flags = flags ?? handler.flags;
    handler.callback = callback ?? handler.callback;
    handler.callbackContext = forceSetContext ? callbackContext as C : (callbackContext ?? handler.callbackContext);
  }

  void rearm({required Object handlerId}) {
    _mod(listenerId: handlerId, force: true);
  }

  void _del({
    required Object listenerId,
  }) {
    assert(_capabilityMap.containsValue(listenerId));
    assert(_handlerMap.containsKey(listenerId));

    final handler = _handlerMap[listenerId]!;

    _epollCtl(
      op: EPOLL_CTL_DEL,
      fd: handler.fd,
      flags: const <EpollFlag>{},
      userdata: 0,
    );

    _capabilityMap.inverse.remove(listenerId);
    _handlerMap.remove(listenerId);
  }

  void _sendEvent<T>({
    required Capability handlerId,
    required T event,
  }) {
    _sendPort.send(_SuccessEvent<T>(
      listenerIdentity: handlerId,
      event: event,
    ));
  }

  void _sendError<T>({
    required Capability handlerId,
    required Object error,
    StackTrace? stackTrace,
  }) {
    _sendPort.send(_ErrorEvent<T>(
      listenerIdentity: handlerId,
      error: error,
      stackTrace: stackTrace,
    ));
  }

  void _replySuccess(
    _Cmd cmd,
  ) {
    _sendPort.send(_SuccessCmdReply(seq: cmd.seq));
  }

  void _replyError(
    _Cmd cmd, {
    required Object error,
    StackTrace? stackTrace,
  }) {
    _sendPort.send(_ErrorCmdReply(
      seq: cmd.seq,
      error: error,
      stackTrace: stackTrace,
    ));
  }

  Future<void> _waitForEvents() async {
    await Future.delayed(Duration.zero);
  }

  void processCommands() {
    // process cmd queue
    while (_shouldRun && _cmdQueue.isNotEmpty) {
      final cmd = _cmdQueue.removeFirst();

      try {
        if (cmd is _AddCmd) {
          _add(
            listenerId: cmd.listenerIdentity,
            fd: cmd.fd,
            flags: cmd.flags,
            callback: cmd.callback,
            callbackContext: cmd.callbackContext,
          );
        } else if (cmd is _ModCmd) {
          _mod(
            listenerId: cmd.listenerIdentity,
            flags: cmd.flags,
            callback: cmd.callback,
          );
        } else if (cmd is _DelCmd) {
          _del(
            listenerId: cmd.listenerIdentity,
          );
        } else if (cmd is _StopCmd) {
          _shouldRun = false;
        } else {
          assert(false);
        }

        _replySuccess(cmd);
      } on Exception catch (e, stackTrace) {
        _replyError(
          cmd,
          error: e,
          stackTrace: stackTrace,
        );
      }
    }
  }

  void dispose() {
    _subscription.cancel();
    ffi.calloc.free(_events);
  }

  int _retry(int Function() syscall, {Set<int> retryErrorCodes = const {EINTR}}) {
    late int result;
    do {
      result = syscall();
    } while ((result < 0) && retryErrorCodes.contains(libc.errno));

    return result;
  }

  Future<void> run() async {
    assert(_epollFd > 0);
    assert(_eventFd > 0);

    _sendPort.send(_InitializedEvent(sendPort: _receivePort.sendPort));

    /// Add the event fd to the epoll instance.
    /// so we get notified of new commands even when we're in
    /// epoll_wait right now.
    _add(
      fd: _eventFd,
      flags: {EpollFlag.inReady},
      listenerId: _eventFdCap,
      callback: _noop,
      callbackContext: null,
    );

    while (_shouldRun) {
      // let the microtask loop run so events the receivePort listener
      // is invoked and commands are added to the cmd queue
      await _waitForEvents();

      processCommands();

      // It could be we received a stop command.
      // In that case, finish early here.
      if (!_shouldRun) {
        break;
      }

      final ok = _retry(() => libc.epoll_wait(
            _epollFd,
            _events,
            _maxEvents,
            -1, // wait indefinitely
          ));
      if (ok < 0) {
        throw LinuxError('Could not wait for epoll events.', 'epoll_wait', libc.errno);
      }

      if (ok > 0) {
        // process any epoll events
        for (var i = 0; i < ok; i++) {
          final event = _events.elementAt(i);

          final capability = _capabilityMap[event.ref.data.u64]!;

          final flags = <EpollFlag>{};
          for (final flag in EpollFlag.values) {
            if (event.ref.events & flag._value != 0) {
              flags.add(flag);
            }
          }

          if (capability == _eventFdCap) {
            // do nothing
          } else {
            assert(capability is Capability);

            // Find and invoke the handler.
            final handler = _handlerMap[capability]!;

            try {
              final value = handler.callback(this, handler.fd, flags, handler.callbackContext);

              _sendEvent(
                handlerId: handler.id,
                event: value,
              );
            } on Exception catch (err, st) {
              _sendError(
                handlerId: handler.id,
                error: err,
                stackTrace: st,
              );
            }
          }
        }
      }
    }
  }

  static void entry(Tuple3<SendPort, int, int> args) async {
    final isolate = EpollIsolate.fromIsolateArgs(args);

    try {
      await isolate.run();
    } finally {
      isolate.dispose();
    }
  }
}

typedef ValueCallback<T> = void Function(T value);

typedef ErrorCallback = void Function(Object error, StackTrace? stackTrace);

abstract class FdHandler<T> {
  Capability get _id;
  int get fd;
  ValueCallback<T> get callback;
  ErrorCallback get errorCallback;
}

class _FdHandlerImpl<T> implements FdHandler<T> {
  _FdHandlerImpl({
    required this.fd,
    required this.callback,
    required this.errorCallback,
  });

  @override
  final _id = Capability();

  @override
  final int fd;

  @override
  ValueCallback<T> callback;

  @override
  ErrorCallback errorCallback;
}

class EpollEventLoop {
  EpollEventLoop._construct({
    required LibC libc,
    required int epollFd,
    required int eventFd,
    required ReceivePort receivePort,
    required Future<Isolate> isolateFuture,
  })  : _libc = libc,
        _epollFd = epollFd,
        _eventFd = eventFd,
        _receivePort = receivePort,
        _isolateFuture = isolateFuture,
        _notifyBuffer = ffi.calloc<ffi.Uint8>(8) {
    _isolateFuture.then(
      (isolate) {
        _isolate = isolate;

        isolate.addOnExitListener(
          _receivePort.sendPort,
          response: 'isolate-quit',
        );

        isolate.addErrorListener(_receivePort.sendPort);
      },
      onError: (err, stackTrace) {
        _isolateError = err.toString();
        _isolateErrorStackTrace = stackTrace.toString();
      },
    );

    _notifyBuffer.elementAt(0).value = 0x01;

    _receivePortSubscription = _receivePort.listen(_onReceivePortMessage);

    _sendPort = _sendPortCompleter.future;
  }

  factory EpollEventLoop(LibC libc) {
    final epollFd = libc.epoll_create1(EPOLL_CLOEXEC);
    if (epollFd < 0) {
      throw LinuxError('Could not create epoll fd.', 'epoll_create1', libc.errno);
    }

    try {
      final eventFd = libc.eventfd(0, EFD_CLOEXEC | EFD_NONBLOCK);
      if (eventFd < 0) {
        throw LinuxError('Could not create event fd.', 'eventfd', libc.errno);
      }

      try {
        final myReceivePort = ReceivePort();
        final otherSendPort = myReceivePort.sendPort;

        final isolateFuture = Isolate.spawn(
          EpollIsolate.entry,
          Tuple3(otherSendPort, epollFd, eventFd),
        );

        return EpollEventLoop._construct(
          libc: libc,
          epollFd: epollFd,
          eventFd: eventFd,
          receivePort: myReceivePort,
          isolateFuture: isolateFuture,
        );
      } on Object {
        libc.close(eventFd);
        rethrow;
      }
    } on Object {
      libc.close(epollFd);
      rethrow;
    }
  }

  final LibC _libc;
  final int _epollFd;
  final int _eventFd;
  final ReceivePort _receivePort;
  late FutureOr<SendPort> _sendPort;
  final _sendPortCompleter = Completer<SendPort>();
  final Future<Isolate> _isolateFuture;

  late final StreamSubscription _receivePortSubscription;
  final ffi.Pointer<ffi.Uint8> _notifyBuffer;

  var _alive = true;

  Isolate? _isolate;
  String? _isolateError;
  String? _isolateErrorStackTrace;
  final _isolateExitCompleter = Completer.sync();

  final _handlers = <Capability, _FdHandlerImpl>{};
  final _pendingCommands = <Capability, Completer>{};

  void _onReceivePortMessage(dynamic msg) {
    assert(msg is _Reply || msg is List || msg is String);

    if (msg is _InitializedEvent) {
      assert(_sendPort is Future);
      _sendPort = msg.sendPort;
      _sendPortCompleter.complete(msg.sendPort);
    } else if (msg is _SuccessEvent) {
      _onEvent(msg);
    } else if (msg is _CmdReply) {
      _onCmdReply(msg);
    } else if (msg == 'isolate-quit') {
      _isolateExitCompleter.complete();
    } else if (msg is List) {
      assert(msg[0] is String);
      assert(msg[1] is String?);

      _isolateError = msg[0];
      _isolateErrorStackTrace = msg[1];

      throw RemoteError(_isolateError!, _isolateErrorStackTrace!);
    } else {
      assert(false);
    }
  }

  void _onEvent(_SuccessEvent event) {
    if (!_handlers.containsKey(event.listenerIdentity)) {
      throw StateError('No event listener registered for capability ${event.listenerIdentity}.');
    }

    _handlers[event.listenerIdentity]!.callback(event.event);
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
    if (_sendPort is SendPort) {
      (_sendPort as SendPort).send(cmd);
    } else if (_sendPort is Future<SendPort>) {
      (await _sendPort).send(cmd);
    }

    _pendingCommands[seq] = completer;

    // notify the isolate of the new command
    // (it might be in the middle of a epoll_wait)
    if (notify) {
      _notifyIsolate();
    }

    // wait for the ACK here
    return await completer.future;
  }

  Future<FdHandler> add({
    required int fd,
    required Set<EpollFlag> events,
    required FdReadyCallback isolateCallback,
    required dynamic isolateCallbackContext,
    required ValueCallback onValue,
    required ErrorCallback onError,
  }) async {
    assert(_alive);

    final seq = Capability();
    final handler = _FdHandlerImpl(
      fd: fd,
      callback: onValue,
      errorCallback: onError,
    );

    await _sendCmd(_AddCmd(
      seq: seq,
      listenerIdentity: handler._id,
      fd: fd,
      flags: events,
      callback: isolateCallback,
      callbackContext: isolateCallbackContext,
    ));

    _handlers[handler._id] = handler;

    return handler;
  }

  Future<void> modify({
    required FdHandler listener,
    Set<EpollFlag>? events,
    FdReadyCallback? isolateCallback,
    ValueCallback? callback,
  }) async {
    assert(_alive);
    assert(_handlers.containsKey(listener));

    final seq = Capability();

    await _sendCmd(_ModCmd(
      seq: seq,
      listenerIdentity: listener._id,
      flags: events,
      callback: isolateCallback,
    ));

    (listener as _FdHandlerImpl).callback = callback ?? listener.callback;
  }

  Future<void> _delete({required FdHandler listener, bool notify = true}) async {
    assert(_alive);

    final seq = Capability();

    try {
      await _sendCmd(
        _DelCmd(
          seq: seq,
          listenerIdentity: listener._id,
        ),
        notify: notify,
      );
    } finally {
      _handlers.remove(listener._id);
    }
  }

  Future<void> delete({required FdHandler listener}) {
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
      for (final listener in _handlers.values)
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
