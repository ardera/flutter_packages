import 'dart:collection';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:multidisplay/multidisplay.dart';

class _ConnectorImpl implements Connector {
  const _ConnectorImpl({
    required this.identifier,
    required this.type,
    required MethodChannelDisplayManager manager,
  }) : _manager = manager;

  final String identifier;
  final ConnectorType type;

  final MethodChannelDisplayManager _manager;

  Display? display() {
    return _manager.display(connectorId: identifier);
  }
}

class _DisplayImpl implements Display {
  const _DisplayImpl({
    required this.connector,
    required this.devicePixelRatio,
    required this.id,
    required this.refreshRate,
    required this.size,
  });

  final Connector connector;

  @override
  final double devicePixelRatio;

  @override
  final int id;

  @override
  final double refreshRate;

  @override
  final Size size;
}

final class _GenericConnectorType extends ConnectorType {
  const _GenericConnectorType(this.name);

  final String name;
}

class _DisplayViewControllerImpl implements DisplayViewController {
  static const _channel = MethodChannel('multidisplay/view_controller');

  _DisplayViewControllerImpl(
    this.viewId,
    this.display, {
    ui.PlatformDispatcher? platformDispatcher,
  }) : _platformDispatcher =
            platformDispatcher ?? ui.PlatformDispatcher.instance;

  final ui.PlatformDispatcher _platformDispatcher;

  @override
  final int viewId;

  @override
  ui.FlutterView? get view => _platformDispatcher.view(id: display.id);

  @override
  final Display display;

  var _disposed = false;

  void _checkNotDisposed() {
    if (_disposed) {
      throw StateError('DisplayViewController is already closed.');
    }
  }

  Future<void> dispose() async {
    _checkNotDisposed();

    _disposed = true;
    await _channel.invokeMethod('closeView', [viewId]);
  }
}

class MethodChannelDisplayManager
    with ChangeNotifier
    implements DisplayManager {
  static const eventChannel = EventChannel('multidisplay/events');
  static const methodChannel = MethodChannel('multidisplay/display_manager');

  final platformDispatcher = ui.PlatformDispatcher.instance;

  var _connectors = <Connector>[];
  var _displays = <Display>[];

  late final Iterable<Connector> _connectorsView =
      UnmodifiableListView(_connectors);

  late final Iterable<Display> _displaysView = UnmodifiableListView(_displays);

  var _listening = false;
  void _onEvent(dynamic event) {
    final connectors = [
      for (final conn in event['connectors'])
        _ConnectorImpl(
          identifier: conn['identifier'],
          type: _GenericConnectorType(conn['type']),
          manager: this,
        )
    ];

    final displays = <Display>[
      for (final disp in event['displays'])
        _DisplayImpl(
          connector: connectors.firstWhere(
            (c) => c.identifier == disp['connector'],
          ),
          devicePixelRatio: disp['devicePixelRatio'],
          id: disp['id'] as int,
          refreshRate: (disp['refreshRate'] as num).toDouble(),
          size: Size(
            (disp['width'] as num).toDouble(),
            (disp['height'] as num).toDouble(),
          ),
        )
    ];

    _connectors = connectors;
    _displays = displays;
    notifyListeners();
  }

  void _ensureListening() {
    if (_listening) return;

    eventChannel.receiveBroadcastStream().listen(_onEvent);
    _listening = true;
  }

  @override
  Iterable<Connector> get connectors {
    _ensureListening();
    return _connectorsView;
  }

  @override
  Iterable<Display> get displays {
    _ensureListening();
    return _displaysView;
  }

  @override
  Connector? connector({required String id}) {
    return connectors.cast<Connector?>().firstWhere(
          (c) => c?.identifier == id,
          orElse: () => null,
        );
  }

  @override
  Display? display({String? connectorId, int? id}) {
    if ((connectorId != null) == (id != null)) {
      throw ArgumentError(
          'Exactly one of `connectorId` or `id` must be provided.');
    }

    return displays.cast<Display?>().firstWhere(
          (d) => d?.id == id || d?.connector.identifier == connectorId,
          orElse: () => null,
        );
  }

  @override
  Future<DisplayViewController> createView(int displayId) async {
    final display = this.display(id: displayId);
    if (display == null) {
      throw ArgumentError.value(
        displayId,
        'displayId',
        'No display with id $displayId.',
      );
    }

    final id = await methodChannel.invokeMethod<int>(
      'createDisplayView',
      [displayId],
    );
    if (id == null) {
      throw StateError('Failed to create view.');
    }

    assert(
      platformDispatcher.view(id: id) != null,
      'Created view was not found in PlatformDispatcher.',
    );

    return _DisplayViewControllerImpl(
      id,
      display,
      platformDispatcher: platformDispatcher,
    );
  }
}
