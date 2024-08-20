import 'dart:ui' as ui show FlutterView;

import 'package:multidisplay/src/display.dart';

/// A controller for a display that is opened for rendering.
///
/// The controller represents full control over the display, including
/// the ability to render content to the display, blanking/unblanking,
/// and closing the display.
abstract interface class DisplayViewController {
  /// The view id of the associated [ui.FlutterView].
  int get viewId;

  /// The associated [ui.FlutterView].
  ui.FlutterView? get view;

  /// The display that this view is associated with.
  Display get display;

  /// Disposes the view controller, releasing the display.
  Future<void> dispose();
}
