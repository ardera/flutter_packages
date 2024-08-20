import 'package:meta/meta.dart';

import 'package:multidisplay/src/display.dart';

/// A slot that a display can be connected to.
///
/// Every display must have exactly one connector it's connected to, and
/// every connector can have at most one display connected to it.
abstract class Connector {
  /// A unique, predictable identifier for this connector.
  ///
  /// This identifier stays the same across reboots.
  /// Typical values are `HDMI-A-1`, `DP-1`, etc.
  String get identifier;

  /// The type of this connector.
  ConnectorType get type;

  /// Returns the display that is currently connected to this connector,
  /// or `null` if no display is connected.
  Display? display();

  @override
  String toString() {
    return 'Connector('
        'identifier: $identifier, '
        'type: $type'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Connector &&
        other.identifier == identifier &&
        other.type == type;
  }

  @override
  int get hashCode {
    return Object.hash(identifier.hashCode, type.hashCode);
  }
}

/// A type of connector.
///
/// For concrete connector types, see [PhysicalConnectorType].
abstract base class ConnectorType {
  const ConnectorType();

  String get name;

  @override
  String toString() {
    return name;
  }
}

/// A physical type of connector.
///
/// e.g. VGA, DVI, HDMI, etc.
final class PhysicalConnectorType extends ConnectorType {
  @protected
  const PhysicalConnectorType(this.name);

  final String name;

  static const VGA = PhysicalConnectorType('VGA');
  static const DVI = PhysicalConnectorType('DVI');
  static const lvds = PhysicalConnectorType('LVDS');
  static const displayPort = PhysicalConnectorType('DisplayPort');
  static const hdmi = PhysicalConnectorType('HDMI');
  static const TV = PhysicalConnectorType('TV');
  static const eDP = PhysicalConnectorType('eDP');
  static const DSI = PhysicalConnectorType('DSI');
  static const DPI = PhysicalConnectorType('DPI');

  static const values = [
    VGA,
    DVI,
    lvds,
    displayPort,
    hdmi,
    TV,
    eDP,
    DSI,
    DPI,
  ];
}
