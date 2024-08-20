import 'dart:ui' as ui show Display;

import 'package:multidisplay/src/connector.dart';

/// A variant of the [ui.Display] class that is used to represent a
/// display connected to a [Connector] on this devie.
abstract class Display implements ui.Display {
  Connector get connector;

  @override
  String toString() {
    return 'Display('
        'id: $id, '
        'connector: $connector, '
        'size: $size, '
        'devicePixelRatio: $devicePixelRatio, '
        'refreshRate: $refreshRate'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Display &&
        other.id == id &&
        other.connector == connector &&
        other.size == size &&
        other.devicePixelRatio == devicePixelRatio &&
        other.refreshRate == refreshRate;
  }

  @override
  int get hashCode {
    return Object.hash(
      id.hashCode,
      connector.hashCode,
      size.hashCode,
      devicePixelRatio.hashCode,
      refreshRate.hashCode,
    );
  }
}
