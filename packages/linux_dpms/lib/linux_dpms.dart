export 'src/linux_dpms_stub.dart'
    if (dart.library.io) 'src/linux_dpms.dart'
    if (dart.library.js) 'src/linux_dpms_web.dart';
export 'src/dpms_power_state.dart';
