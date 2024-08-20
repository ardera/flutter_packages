import 'package:flutter/foundation.dart';

import 'package:multidisplay/src/connector.dart';
import 'package:multidisplay/src/display.dart';
import 'package:multidisplay/src/display_view_controller.dart';

abstract interface class DisplayManager with ChangeNotifier {
  static late final DisplayManager instance;

  Iterable<Connector> get connectors;

  Iterable<Display> get displays;

  Connector? connector({required String id});

  Display? display({int? id, String? connectorId});

  Future<DisplayViewController> createView(int displayId);
}
