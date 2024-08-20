import 'dart:ui' as ui show FlutterView;

import 'package:flutter/widgets.dart';
import 'package:multidisplay/src/display.dart';
import 'package:multidisplay/src/display_manager.dart';
import 'package:multidisplay/src/display_view_controller.dart';

/// Displays a widget on whatever display is connected to the specified
/// connector. If no display is connected to the specified connector, the
/// widget will not be displayed.

typedef DisplaySelector = Display? Function(Iterable<Display> displays);

abstract class DisplayView implements Widget {
  factory DisplayView.connector({
    Key? key,
    required String connector,
    required Widget child,
    DisplayManager? displayManager,
  }) = RawDisplayView.connector;

  factory DisplayView.selector({
    Key? key,
    required DisplaySelector selector,
    required Widget child,
    DisplayManager? displayManager,
  }) = RawDisplayView.selector;

  const factory DisplayView.controller({
    Key? key,
    required DisplayViewController controller,
    required Widget child,
  }) = RawDisplayControllerView;
}

class RawDisplayView extends StatefulWidget implements DisplayView {
  RawDisplayView.connector({
    super.key,
    required String connector,
    required this.child,
    DisplayManager? displayManager,
  })  : selector = ((displays) {
          return displays.firstWhere(
            (display) => display.connector.identifier == connector,
          );
        }),
        displayManager = displayManager ?? DisplayManager.instance;

  RawDisplayView.selector({
    super.key,
    required this.selector,
    required this.child,
    DisplayManager? displayManager,
  }) : displayManager = displayManager ?? DisplayManager.instance;

  final DisplaySelector selector;
  final Widget child;
  final DisplayManager displayManager;

  @override
  State<RawDisplayView> createState() => _RawDisplayViewState();
}

class _RawDisplayViewState extends State<RawDisplayView> {
  DisplayViewController? _controller;

  Future<void> onDisplaysChanged() async {
    final display = widget.selector(widget.displayManager.displays);
    if (display == null) {
      _controller?.dispose();
      setState(() {
        _controller = null;
      });
      return;
    }

    if (display != _controller?.display) {
      await _controller?.dispose();
      setState(() {
        _controller = null;
      });

      final controller = await widget.displayManager.createView(display.id);
      setState(() {
        _controller = controller;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.displayManager.addListener(onDisplaysChanged);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;

    widget.displayManager.removeListener(onDisplaysChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant RawDisplayView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.displayManager != oldWidget.displayManager) {
      widget.displayManager.removeListener(onDisplaysChanged);
      _controller?.dispose();
      setState(() {
        _controller = null;
      });

      widget.displayManager.addListener(onDisplaysChanged);
      onDisplaysChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewCollection(
      views: [
        if (_controller case DisplayViewController controller)
          RawDisplayControllerView(
            controller: controller,
            child: widget.child,
          ),
      ],
    );
  }
}

class RawDisplayControllerView extends StatefulWidget implements DisplayView {
  const RawDisplayControllerView({
    super.key,
    required this.controller,
    required this.child,
  });

  final DisplayViewController controller;
  final Widget child;

  @override
  State<RawDisplayControllerView> createState() =>
      _RawDisplayControllerViewState();
}

class _RawDisplayControllerViewState extends State<RawDisplayControllerView> {
  ui.FlutterView get view {
    if (widget.controller.view case ui.FlutterView view) {
      return view;
    }

    throw StateError(
        'DisplayViewController is not attached to a flutter view.');
  }

  @override
  Widget build(BuildContext context) {
    return View(view: view, child: widget.child);
  }
}
