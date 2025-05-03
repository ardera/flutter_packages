/*
https://github.com/torvalds/linux/blob/master/include/uapi/drm/drm_mode.h#L143
/* bit compatible with the xorg definitions. */
#define DRM_MODE_DPMS_ON	0
#define DRM_MODE_DPMS_STANDBY	1
#define DRM_MODE_DPMS_SUSPEND	2
#define DRM_MODE_DPMS_OFF	3
*/
enum DpmsPowerState {
  on(0),
  standby(1),
  suspend(2),
  off(3);

  final int value;
  const DpmsPowerState(this.value);
}
