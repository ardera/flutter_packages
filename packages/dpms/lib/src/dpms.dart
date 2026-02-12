import 'package:dpms/src/platform/flutterpi.dart';
import 'package:dpms/src/power_mode.dart';

class Dpms {
  final FlutterpiDPMS _service = FlutterpiDPMS.instance;
  /*
https://github.com/torvalds/linux/blob/master/include/uapi/drm/drm_mode.h#L143
/* bit compatible with the xorg definitions. */
#define DRM_MODE_DPMS_ON	0
#define DRM_MODE_DPMS_STANDBY	1
#define DRM_MODE_DPMS_SUSPEND	2
#define DRM_MODE_DPMS_OFF	3
*/
  // ignore: constant_identifier_names
  static const DRM_MODE_DPMS_ON = 0;
  // ignore: constant_identifier_names
  static const DRM_MODE_DPMS_OFF = 3;
  bool isAvailable() {
    if (_service.dpmsIsAvailable == null || _service.dpmsSetProperty == null) {
      return false;
    }
    return true;
  }

  void setMode(PowerMode state) {
    if (_service.dpmsSetProperty != null) {
      _service.dpmsSetProperty!(state == PowerMode.on ? DRM_MODE_DPMS_ON : DRM_MODE_DPMS_OFF);
    }
    return;
  }

  PowerMode getMode() {
    if (_service.dpmsGetProperty != null) {
      final value = _service.dpmsGetProperty!();
      if (value == DRM_MODE_DPMS_ON) {
        return PowerMode.on;
      }
      PowerMode.off;
    }
    return PowerMode.on;
  }
}
