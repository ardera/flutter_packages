part of 'omxplayer_video_player.dart';

class UniqueRegistry implements ValueListenable<_EnsureUniqueState?> {
  UniqueRegistry._();

  static UniqueRegistry? _instance;

  static final _registry = <Key, List<_EnsureUniqueState>>{};

  final _notifier = ValueNotifier<_EnsureUniqueState?>(null);

  static UniqueRegistry get instance {
    if (_instance == null) {
      _instance = UniqueRegistry._();
    }

    return _instance!;
  }

  void _callDeferred(void fn()) {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) => fn());
  }

  @override
  void addListener(listener) => _notifier.addListener(listener);

  @override
  void removeListener(listener) => _notifier.removeListener(listener);

  @override
  _EnsureUniqueState? get value => _notifier.value;

  bool isRegistered(Key key, State state) => _registry.containsKey(key) && _registry[key]!.contains(state);

  void register(Key key, State state) {
    _registry.putIfAbsent(key, () => <_EnsureUniqueState>[]).insert(0, state as _EnsureUniqueState);

    // don't call this synchronously, since we're probably building widgets right now.
    _callDeferred(() => _notifier.value = _registry[key]!.first);
  }

  void unregister(Key key, State state) {
    _registry[key]!.remove(state);

    if (_registry[key]!.length == 0) {
      _registry.remove(key);
      _callDeferred(() => _notifier.value = null);
    } else {
      _callDeferred(() => _notifier.value = _registry[key]!.first);
    }
  }
}

class _EnsureUniqueKey extends GlobalObjectKey {
  _EnsureUniqueKey(Object value) : super(value);
}

class EnsureUnique extends StatefulWidget {
  EnsureUnique({this.strict = false, required this.identity, required this.child});

  final bool strict;
  final Key identity;
  final Widget child;

  @override
  createState() => _EnsureUniqueState();
}

class _EnsureUniqueState extends State<EnsureUnique> {
  Element? _lastParent;

  Element? get _parent {
    Element? e;

    context.visitAncestorElements((element) {
      e = element;
      return false;
    });

    return e;
  }

  @override
  void didUpdateWidget(EnsureUnique oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.identity != widget.identity) {
      UniqueRegistry.instance.unregister(oldWidget.identity, this);
      UniqueRegistry.instance.register(widget.identity, this);
    }
  }

  @override
  void deactivate() {
    super.deactivate();
    UniqueRegistry.instance.unregister(widget.identity, this);
  }

  @override
  Widget build(BuildContext context) {
    if (_lastParent != _parent) {
      if (_lastParent != null && UniqueRegistry.instance.isRegistered(widget.identity, this)) {
        UniqueRegistry.instance.unregister(widget.identity, this);
      }

      if (_parent != null) {
        UniqueRegistry.instance.register(widget.identity, this);
      }

      _lastParent = _parent;
    }

    if (widget.strict == true) {
      return KeyedSubtree(
        key: _EnsureUniqueKey(widget.identity),
        child: widget.child,
      );
    } else {
      return ValueListenableBuilder(
        valueListenable: UniqueRegistry.instance,
        builder: (context, dynamic state, childWidget) {
          if (state == this) {
            return widget.child;
          } else {
            return childWidget!;
          }
        },
        child: Container(),
      );
    }
  }
}
