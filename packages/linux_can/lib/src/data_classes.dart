import 'package:_ardera_common_libc_bindings/_ardera_common_libc_bindings.dart';
import 'package:quiver/collection.dart';

/// A linux network interface.
///
/// Combination of an interface index and interface name.
///
/// For example, `can0`, 5.
class NetworkInterface {
  NetworkInterface({required this.index, required this.name});

  final int index;
  final String name;
}

/// Defines CAN bit-timing values.
///
/// For further reference, see: http://esd.cs.ucr.edu/webres/can20.pdf
class CanBitTiming {
  const CanBitTiming({
    required this.bitrate,
    required this.samplePoint,
    required this.tq,
    required this.propagationSegment,
    required this.phaseSegment1,
    required this.phaseSegment2,
    required this.syncJumpWidth,
    required this.bitratePrescaler,
  })  : assert(0 < bitrate),
        assert(0 <= samplePoint && samplePoint <= 1000),
        assert(0 < tq),
        assert(0 < propagationSegment),
        assert(0 < phaseSegment1),
        assert(0 < phaseSegment2),
        assert(0 < syncJumpWidth),
        assert(0 < bitratePrescaler);

  const CanBitTiming.bitrateOnly({required this.bitrate})
      : samplePoint = 0,
        tq = 0,
        propagationSegment = 0,
        phaseSegment1 = 0,
        phaseSegment2 = 0,
        syncJumpWidth = 0,
        bitratePrescaler = 0;

  /// Bit-rate in bits/second, in absence of resynchronization,
  /// by an ideal transmitter.
  final int bitrate;

  /// Sample point in one-tenth of a percent.
  final int samplePoint;

  /// Time quanta (TQ) in nanoseconds.
  ///
  /// Other timings values in the struct are expressed as
  /// multiples of this value.
  final int tq;

  /// Propagation Segment in TQs.
  ///
  /// CAN 2.0 specification writes:
  ///   This part of the bit time is used to compensate for physical delay times
  ///   within the network.
  ///   It is twice the sum of the signal's propagation time on the bus line, the
  ///   input comparator delay, and the output driver delay.
  final int propagationSegment;

  /// Phase buffer segment 1 in TQs.
  ///
  /// CAN 2.0 specification writes:
  ///   These Phase-Buffer-Segments are used to compensate for edge phase errors.
  ///   These segments can be lengthened or shortened by resynchronization.
  final int phaseSegment1;

  /// Phase buffer segment 2 in TQs.
  ///
  /// CAN 2.0 specification writes:
  ///   These Phase-Buffer-Segments are used to compensate for edge phase errors.
  ///   These segments can be lengthened or shortened by resynchronization.
  final int phaseSegment2;

  /// Synchronisation jump width in TQs.
  final int syncJumpWidth;

  /// Bit-rate prescaler.
  final int bitratePrescaler;
}

/// CAN controller mode
///
/// ref
///   https://elixir.bootlin.com/linux/v6.3/source/include/uapi/linux/can/netlink.h#L95
///   https://elixir.bootlin.com/linux/v6.3/source/drivers/net/can/dev/netlink.c#L240
enum CanModeFlag {
  /// Loopback mode.
  ///
  /// ref:
  ///   https://elixir.bootlin.com/linux/v6.3/source/include/uapi/linux/can/netlink.h#L95
  loopback(CAN_CTRLMODE_LOOPBACK),

  /// Listen-only mode.
  ///
  /// ref:
  ///   https://elixir.bootlin.com/linux/v6.3/source/include/uapi/linux/can/netlink.h#L96
  listenOnly(CAN_CTRLMODE_LISTENONLY),

  /// Triple sampling mode.
  ///
  /// ref:
  ///   https://elixir.bootlin.com/linux/v6.3/source/include/uapi/linux/can/netlink.h#L97
  tripleSample(CAN_CTRLMODE_3_SAMPLES),

  /// One-Shot mode.
  ///
  /// ref:
  ///   https://elixir.bootlin.com/linux/v6.3/source/include/uapi/linux/can/netlink.h#L98
  oneShot(CAN_CTRLMODE_ONE_SHOT),

  /// Bus-error reporting.
  ///
  /// ref:
  ///   https://elixir.bootlin.com/linux/v6.3/source/include/uapi/linux/can/netlink.h#L99
  busErrorReporting(CAN_CTRLMODE_BERR_REPORTING),

  /// CAN Flexible Datarate (FD) mode.
  ///
  /// ref:
  ///   https://elixir.bootlin.com/linux/v6.3/source/include/uapi/linux/can/netlink.h#L100
  flexibleDatarate(CAN_CTRLMODE_FD),

  /// Ignore missing CAN ACKs
  ///
  /// ref:
  ///   https://elixir.bootlin.com/linux/v6.3/source/include/uapi/linux/can/netlink.h#L101
  presumeAck(CAN_CTRLMODE_PRESUME_ACK),

  /// CAN Flexible Datarate (FD) in non-ISO mode.
  ///
  /// ref:
  ///   https://elixir.bootlin.com/linux/v6.3/source/include/uapi/linux/can/netlink.h#L102
  flexibleDatarateNonIso(CAN_CTRLMODE_FD_NON_ISO),

  /// Classic CAN data-length-code (DLC) option.
  ///
  /// ref:
  ///   https://elixir.bootlin.com/linux/v6.3/source/include/uapi/linux/can/netlink.h#L103
  classicCanDlc(CAN_CTRLMODE_CC_LEN8_DLC),

  /// CAN transceiver automatically calculates TDCV
  ///
  /// (TDC = CAN FD Transmission Delay Compensation)
  ///
  /// ref:
  ///   https://elixir.bootlin.com/linux/v6.3/source/include/uapi/linux/can/netlink.h#L104
  tdcAuto(CAN_CTRLMODE_TDC_AUTO),

  /// TDCV is manually set up by user
  ///
  /// (TDC = CAN FD Transmission Delay Compensation)
  ///
  /// ref:
  ///   https://elixir.bootlin.com/linux/v6.3/source/include/uapi/linux/can/netlink.h#L105
  tdcManual(CAN_CTRLMODE_TDC_MANUAL);

  const CanModeFlag(this.value);

  final int value;
}

class CanBitTimingLimits {
  const CanBitTimingLimits({
    required this.hardwareName,
    required this.timeSegment1Min,
    required this.timeSegment1Max,
    required this.timeSegment2Min,
    required this.timeSegment2Max,
    required this.synchronisationJumpWidth,
    required this.bitRatePrescalerMin,
    required this.bitRatePrescalerMax,
    required this.bitRatePrescalerIncrement,
  });

  final String hardwareName;
  final int timeSegment1Min;
  final int timeSegment1Max;
  final int timeSegment2Min;
  final int timeSegment2Max;
  final int synchronisationJumpWidth;
  final int bitRatePrescalerMin;
  final int bitRatePrescalerMax;
  final int bitRatePrescalerIncrement;
}

/// CAN operation and error states
///
/// ref:
///   https://elixir.bootlin.com/linux/latest/source/include/uapi/linux/can/netlink.h#L66
enum CanState {
  /// RX/TX error count < 96
  errorActive(0),

  /// RX/TX error count < 128
  errorWarning(1),

  /// RX/TX error count < 256
  errorPassive(2),

  /// RX/TX error count >= 256
  busOff(3),

  /// Device is stopped
  stopped(4),

  /// Device is sleeping
  sleeping(5);

  const CanState(this.value);

  final int value;
}

/// CAN bus error counters
///
/// ref:
///   https://elixir.bootlin.com/linux/latest/source/include/uapi/linux/can/netlink.h#L79
class CanBusErrorCounters {
  const CanBusErrorCounters({
    required this.txErrors,
    required this.rxErrors,
  })  : assert(txErrors >= 0),
        assert(rxErrors >= 0);

  final int txErrors;
  final int rxErrors;
}

/// CAN device statistics
class CanDeviceStats {
  const CanDeviceStats({
    required this.busError,
    required this.errorWarning,
    required this.errorPassive,
    required this.busOff,
    required this.arbitrationLost,
    required this.restarts,
  });

  /// Bus errors
  final int busError;

  /// Changes to error warning state
  final int errorWarning;

  /// Changes to error passive state
  final int errorPassive;

  /// Changes to bus off state
  final int busOff;

  /// Arbitration lost errors
  final int arbitrationLost;

  /// CAN controller re-starts
  final int restarts;
}

/// CAN FD Transmission Delay Compensation parameters
///
/// At high bit rates, the propagation delay from the TX pin to the RX
/// pin of the transceiver causes measurement errors: the sample point
/// on the RX pin might occur on the previous bit.
///
/// To solve this issue, ISO 11898-1 introduces in section 11.3.3
/// "Transmitter delay compensation" a SSP (Secondary Sample Point)
/// equal to the distance from the start of the bit time on the TX pin
/// to the actual measurement on the RX pin.
///
/// This structure contains the parameters to calculate that SSP.
///
/// -+----------- one bit ----------+-- TX pin
///  |<--- Sample Point --->|
///
///                         --+----------- one bit ----------+-- RX pin
///  |<-------- TDCV -------->|
///                           |<------- TDCO ------->|
///  |<----------- Secondary Sample Point ---------->|
///
/// To increase precision, contrary to the other bittiming parameters
/// which are measured in time quanta, the TDC parameters are measured
/// in clock periods (also referred as "minimum time quantum" in ISO
/// 11898-1).
///
/// See:
///   https://elixir.bootlin.com/linux/v6.3/source/include/linux/can/bittiming.h#L20
class CanTransmissionDelayCompensation {
  const CanTransmissionDelayCompensation({
    required this.value,
    required this.offset,
    required this.window,
  });

  /// Transmission Delay Compensation Value.
  ///
  /// The time needed for the signal to propagate, i.e. the distance,
  /// in clock periods, from the start of the bit on the TX pin to
  /// when it is received on the RX pin.
  ///
  /// [value] depends on the controller mode:
  ///   - If [CanModeFlag.tdcAuto] is set:
  ///     The transceiver dynamically measures [value] for each
  ///     transmitteed CAN FD frame and the value provided here
  ///     should be ignored.
  ///
  ///   - If [CanModeFlag.tdcManual] is set:
  ///     Use the fixed provided value.
  final int value;

  /// Transmission Delay Compensation Offset.
  ///
  /// Offset value, in clock periods, defining the distance between
  /// the start of the bit reception on the RX pin of the transceiver
  /// and the SSP position such that SSP = @tdcv + @tdco.
  final int offset;

  /// Transmission Delay Compensation Filter window.
  ///
  /// Defines the minimum value for the SSP position in clock periods.
  ///
  /// If the SSP position is less than [window], then no delay
  /// compensations occur and the normal sampling point is used instead.
  ///
  /// The features is enabled if and only if [value] is set to zero
  /// (automatic mode) and [window] is configured to a value
  /// greater than [offset].
  final int window;
}

/// CAN hardware-dependent constants for Transmission Delay Compensation.
///
/// See:
///   https://elixir.bootlin.com/linux/v6.3/source/include/linux/can/bittiming.h#L84
class CanTransmissionDelayCompensationLimits {
  CanTransmissionDelayCompensationLimits({
    required this.valueMin,
    required this.valueMax,
    required this.offsetMin,
    required this.offsetMax,
    required this.windowMin,
    required this.windowMax,
  });

  /// [CanTransmissionDelayCompensation.value] minimum value.
  ///
  /// If the controller does not support manual mode ([CanModeFlag.tdcManual]),
  /// then this value is ignored.
  final int valueMin;

  /// [CanTransmissionDelayCompensation.value] maximum value.
  ///
  /// If the controller does not support manual mode ([CanModeFlag.tdcManual]),
  /// then this value is ignored.
  final int valueMax;

  /// [CanTransmissionDelayCompensation.offset] minimum value.
  final int offsetMin;

  /// [CanTransmissionDelayCompensation.offset] maximum value.
  ///
  /// Should not be zero.
  final int offsetMax;

  /// [CanTransmissionDelayCompensation.window] minimum value.
  ///
  /// If [windowMax] is zero, this value should be ignored.
  final int windowMin;

  /// [CanTransmissionDelayCompensation.window] maximum value.
  ///
  /// Should be set to zero if the controller does not support this feature.
  final int windowMax;
}

/// Classical CAN frame structure (aka CAN 2.0B)
abstract class CanFrame {
  const CanFrame();

  /// Data frame,
  /// CAN 2.0B Standard Frame Format
  factory CanFrame.standard({required int id, required List<int> data}) {
    return CanStandardDataFrame(id: id, data: data);
  }

  /// Data frame,
  /// CAN 2.0B Extended Frame Format
  factory CanFrame.extended({required int id, required List<int> data}) {
    return CanExtendedDataFrame(id: id, data: data);
  }

  /// Remote Frame / Remote Transmission Request,
  /// CAN 2.0B Standard Frame Format
  factory CanFrame.standardRemote({required int id}) {
    return CanStandardRemoteFrame(id: id);
  }

  /// Remote Frame / Remote Transmission Request,
  /// CAN 2.0B Extended Frame Format
  factory CanFrame.extendedRemote({required int id}) {
    return CanExtendedRemoteFrame(id: id);
  }

  /// Error Frame
  factory CanFrame.error() {
    return CanErrorFrame();
  }
}

abstract class CanDataFrame extends CanFrame {
  const CanDataFrame({required this.id, required this.data}) : assert(0 <= data.length && data.length <= 8);

  /// CAN ID of the frame.
  final int id;

  final List<int> data;
}

class CanStandardDataFrame extends CanDataFrame {
  const CanStandardDataFrame({required super.id, required super.data}) : assert(id & ~CAN_SFF_MASK == 0);

  @override
  operator ==(Object other) {
    return other is CanStandardDataFrame && other.id == id && listsEqual(other.data, data);
  }

  @override
  int get hashCode => Object.hash(id.hashCode, data.hashCode);
}

class CanExtendedDataFrame extends CanDataFrame {
  const CanExtendedDataFrame({required super.id, required super.data}) : assert(id & ~CAN_EFF_MASK == 0);

  @override
  operator ==(Object other) {
    return other is CanExtendedDataFrame && other.id == id && listsEqual(other.data, data);
  }

  @override
  int get hashCode => Object.hash(id.hashCode, data.hashCode);
}

abstract class CanRemoteFrame extends CanFrame {
  const CanRemoteFrame({required this.id});

  /// CAN ID of the frame.
  final int id;
}

class CanStandardRemoteFrame extends CanRemoteFrame {
  const CanStandardRemoteFrame({required super.id}) : assert(id & ~CAN_SFF_MASK == 0);

  @override
  operator ==(Object other) {
    return other is CanStandardRemoteFrame && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class CanExtendedRemoteFrame extends CanRemoteFrame {
  const CanExtendedRemoteFrame({required super.id}) : assert(id & ~CAN_EFF_MASK == 0);

  @override
  operator ==(Object other) {
    return other is CanExtendedRemoteFrame && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class CanErrorFrame extends CanFrame {
  /// The fact that we only have one instance of this means we don't need to implement
  /// operator ==() and hashCode().
  const CanErrorFrame._();

  factory CanErrorFrame() {
    return const CanErrorFrame._();
  }
}
