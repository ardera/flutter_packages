import 'dpms_stub.dart' if (dart.library.ffi) 'platform/flutterpi.dart' as platform;
import 'power_mode.dart';

/// Controls the power of the display selected by the embedder.
///
/// Currently implemented by flutter-pi for its selected KMS output.
abstract base class Dpms {
  /// The platform implementation, or `null` if DPMS is unavailable.
  ///
  /// Resolved lazily once per isolate. No support is assumed merely because
  /// the program runs on Linux: the embedder must provide the native ABI.
  static final Dpms? instance = platform.createInstance();

  /// Sets the display power mode.
  ///
  /// The operation is synchronous and may wait for a display modeset.
  /// Throws [DpmsException] when the embedder cannot apply the change.
  void setMode(PowerMode mode);

  /// Returns the last mode successfully requested through the embedder.
  ///
  /// This does not measure the monitor's own power button or external changes.
  /// Throws [DpmsException] if the embedder cannot report the mode.
  PowerMode getMode();
}

/// An error returned by the native DPMS implementation.
final class DpmsException implements Exception {
  const DpmsException(this.operation, this.errorCode);

  /// The failed operation, e.g. `setMode` or `getMode`.
  final String operation;

  /// The positive Linux errno value returned by the embedder.
  final int errorCode;

  @override
  String toString() => 'DpmsException: $operation failed (errno $errorCode)';
}
