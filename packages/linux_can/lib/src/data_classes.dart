// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:_ardera_common_libc_bindings/_ardera_common_libc_bindings.dart';
import 'package:collection/collection.dart';
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

  @override
  String toString() {
    return 'CanBitTiming(bitrate: $bitrate, samplePoint: $samplePoint, tq: $tq, propagationSegment: $propagationSegment, phaseSegment1: $phaseSegment1, phaseSegment2: $phaseSegment2, syncJumpWidth: $syncJumpWidth, bitratePrescaler: $bitratePrescaler)';
  }
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

  @override
  String toString() {
    return 'CanBitTimingLimits(hardwareName: $hardwareName, timeSegment1Min: $timeSegment1Min, timeSegment1Max: $timeSegment1Max, timeSegment2Min: $timeSegment2Min, timeSegment2Max: $timeSegment2Max, synchronisationJumpWidth: $synchronisationJumpWidth, bitRatePrescalerMin: $bitRatePrescalerMin, bitRatePrescalerMax: $bitRatePrescalerMax, bitRatePrescalerIncrement: $bitRatePrescalerIncrement)';
  }
}

/// CAN operation and error states
///
/// ref:
///   https://elixir.bootlin.com/linux/latest/source/include/uapi/linux/can/netlink.h#L66
enum CanState {
  /// RX/TX error count < 96
  active(0),

  /// RX/TX error count < 128
  warning(1),

  /// RX/TX error count < 256
  passive(2),

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

  @override
  String toString() => 'CanBusErrorCounters(txErrors: $txErrors, rxErrors: $rxErrors)';
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

  @override
  String toString() {
    return 'CanDeviceStats(busError: $busError, errorWarning: $errorWarning, errorPassive: $errorPassive, busOff: $busOff, arbitrationLost: $arbitrationLost, restarts: $restarts)';
  }
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

sealed class CanDataFrame extends CanFrame {
  const CanDataFrame({required this.id, required this.data}) : assert(0 <= data.length && data.length <= 8);

  /// CAN ID of the frame.
  final int id;

  final List<int> data;
}

final class CanStandardDataFrame extends CanDataFrame {
  const CanStandardDataFrame({required super.id, required super.data}) : assert(id & ~CAN_SFF_MASK == 0);

  @override
  operator ==(Object other) {
    return other is CanStandardDataFrame && other.id == id && listsEqual(other.data, data);
  }

  @override
  int get hashCode => Object.hash(id.hashCode, data.hashCode);
}

final class CanExtendedDataFrame extends CanDataFrame {
  const CanExtendedDataFrame({required super.id, required super.data}) : assert(id & ~CAN_EFF_MASK == 0);

  @override
  operator ==(Object other) {
    return other is CanExtendedDataFrame && other.id == id && listsEqual(other.data, data);
  }

  @override
  int get hashCode => Object.hash(id.hashCode, data.hashCode);
}

sealed class CanRemoteFrame extends CanFrame {
  const CanRemoteFrame({required this.id});

  /// CAN ID of the frame.
  final int id;
}

final class CanStandardRemoteFrame extends CanRemoteFrame {
  const CanStandardRemoteFrame({required super.id}) : assert(id & ~CAN_SFF_MASK == 0);

  @override
  operator ==(Object other) {
    return other is CanStandardRemoteFrame && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

final class CanExtendedRemoteFrame extends CanRemoteFrame {
  const CanExtendedRemoteFrame({required super.id}) : assert(id & ~CAN_EFF_MASK == 0);

  @override
  operator ==(Object other) {
    return other is CanExtendedRemoteFrame && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

final class CanErrorFrame extends CanFrame {
  const CanErrorFrame();
}

/// The RFC2863 state of the network interface.
///
/// See: https://docs.kernel.org/networking/operstates.html
enum NetInterfaceOperState {
  /// Interface is in unknown state, neither driver nor userspace has set operational state.
  ///
  /// Interface must be considered for user data as setting operational state has not been implemented in every driver.
  unknown(0),

  /// Unused in current kernel (notpresent interfaces normally disappear), just a numerical placeholder.
  notPresent(1),

  /// Interface is unable to transfer data on L1, f.e. ethernet is not plugged or interface is ADMIN down.
  down(2),

  /// Interfaces stacked on an interface that is down show this state (f.e. VLAN).
  lowerLayerDown(3),

  /// Interface is in testing mode, for example executing driver self-tests or media (cable) test.
  ///
  /// It can't be used for normal traffic until tests complete.
  testing(4),

  /// Interface is L1 up, but waiting for an external event, f.e. for a protocol to establish. (802.1X)
  dormant(5),

  /// Interface is operational up and can be used.
  up(6);

  const NetInterfaceOperState(this.value);

  final int value;
}

class NetInterfaceStats {}

/// Flags describing the state of a network interface.
///
/// What these flags actually mean depends on the driver, because it's up to the driver
/// to signal these.
///
/// Note: The iproute2 `ip link` command will sometimes report NO-CARRIER, but that's not actually a real flag
/// reported by the kernel. Instead, `ip link` will never report (IFF_)RUNNING if it's reported by the kernel, but
/// instead will report NO-CARRIER if UP is reported but not RUNNING:
///   https://github.com/shemminger/iproute2/blob/v6.3.0/bridge/link.c#L37-L40
///
/// Reference:
///   https://github.com/torvalds/linux/blob/v6.3/include/uapi/linux/if.h#L42-L81
enum NetInterfaceFlag {
  /// Interface is up.
  up(IFF_UP),

  /// Broadcast address valid.
  broadcast(IFF_BROADCAST),

  /// Turn on debugging.
  debug(IFF_DEBUG),

  /// Is a loopback net.
  loopback(IFF_LOOPBACK),

  /// Interface has p-p link.
  pointToPoint(IFF_POINTOPOINT),

  /// Avoid use of trailers.
  noTrailers(IFF_NOTRAILERS),

  /// Interface RFC2863 OPER_UP. Volatile.
  running(IFF_RUNNING),

  /// No ARP protocol.
  noArp(IFF_NOARP),

  /// Receive all packets.
  promiscuous(IFF_PROMISC),

  /// Receive all multicast packets.
  allMulti(IFF_ALLMULTI),

  /// Master of a load balancer.
  master(IFF_MASTER),

  /// Slave of a load balancer.
  slave(IFF_SLAVE),

  /// Supports multicast.
  multicast(IFF_MULTICAST),

  /// Can set media type.
  portsel(IFF_PORTSEL),

  /// Auto media select active.
  audioMedia(IFF_AUTOMEDIA),

  /// Dialup device with changing addresses.
  dynamic(IFF_DYNAMIC),

  /// Driver signals L1 up.
  lowerUp(1 << 16),

  /// Driver signals dormant.
  dormant(1 << 17),

  /// Echo sent packets.
  echo(1 << 18);

  const NetInterfaceFlag(this.nativeValue);

  final int nativeValue;
}

class CanInterfaceAttributes {
  final Set<NetInterfaceFlag>? interfaceFlags;

  final int? txQueueLength;
  final NetInterfaceOperState? operState;
  final NetInterfaceStats? stats;
  final int? numTxQueues;
  final int? numRxQueues;

  final CanDeviceStats? xstats;

  final CanBitTiming? bitTiming;
  final CanBitTimingLimits? bitTimingLimits;
  final int? clockFrequency;
  final CanState? state;
  final Set<CanModeFlag>? controllerMode;
  final Duration? restartDelay;
  final CanBusErrorCounters? busErrorCounters;
  final CanBitTiming? dataBitTiming;
  final CanBitTimingLimits? dataBitTimingLimits;
  final int? termination;
  final List<int>? supportedTerminations;
  final List<int>? supportedBitrates;
  final List<int>? supportedDataBitrates;
  final int? maxBitrate;
  final Set<CanModeFlag>? supportedControllerModes;

  /// TODO: Implement tdc and tdcLimits
  // final CanTransmissionDelayCompensation? tdc;
  // final CanTransmissionDelayCompensationLimits? tdcLimits;

  CanInterfaceAttributes({
    this.interfaceFlags,
    this.txQueueLength,
    this.operState,
    this.stats,
    this.numTxQueues,
    this.numRxQueues,
    this.xstats,
    this.bitTiming,
    this.bitTimingLimits,
    this.clockFrequency,
    this.state,
    this.controllerMode,
    this.restartDelay,
    this.busErrorCounters,
    this.dataBitTiming,
    this.dataBitTimingLimits,
    this.termination,
    this.supportedTerminations,
    this.supportedBitrates,
    this.supportedDataBitrates,
    this.maxBitrate,
    this.supportedControllerModes,
  });

  @override
  bool operator ==(covariant CanInterfaceAttributes other) {
    if (identical(this, other)) return true;
    final setEquals = const DeepCollectionEquality().equals;

    return setEquals(other.interfaceFlags, interfaceFlags) &&
        other.txQueueLength == txQueueLength &&
        other.operState == operState &&
        other.stats == stats &&
        other.numTxQueues == numTxQueues &&
        other.numRxQueues == numRxQueues &&
        other.xstats == xstats &&
        other.bitTiming == bitTiming &&
        other.bitTimingLimits == bitTimingLimits &&
        other.clockFrequency == clockFrequency &&
        other.state == state &&
        setEquals(other.controllerMode, controllerMode) &&
        other.restartDelay == restartDelay &&
        other.busErrorCounters == busErrorCounters &&
        other.dataBitTiming == dataBitTiming &&
        other.dataBitTimingLimits == dataBitTimingLimits &&
        other.termination == termination &&
        other.supportedTerminations == supportedTerminations &&
        other.supportedBitrates == supportedBitrates &&
        other.supportedDataBitrates == supportedDataBitrates &&
        other.maxBitrate == maxBitrate &&
        setEquals(other.supportedControllerModes, supportedControllerModes);
  }

  @override
  int get hashCode {
    return interfaceFlags.hashCode ^
        txQueueLength.hashCode ^
        operState.hashCode ^
        stats.hashCode ^
        numTxQueues.hashCode ^
        numRxQueues.hashCode ^
        xstats.hashCode ^
        bitTiming.hashCode ^
        bitTimingLimits.hashCode ^
        clockFrequency.hashCode ^
        state.hashCode ^
        controllerMode.hashCode ^
        restartDelay.hashCode ^
        busErrorCounters.hashCode ^
        dataBitTiming.hashCode ^
        dataBitTimingLimits.hashCode ^
        termination.hashCode ^
        supportedTerminations.hashCode ^
        supportedBitrates.hashCode ^
        supportedDataBitrates.hashCode ^
        maxBitrate.hashCode ^
        supportedControllerModes.hashCode;
  }

  @override
  String toString() {
    return 'CanInterfaceAttributes(interfaceFlags: $interfaceFlags, txQueueLength: $txQueueLength, operState: $operState, stats: $stats, numTxQueues: $numTxQueues, numRxQueues: $numRxQueues, xstats: $xstats, bitTiming: $bitTiming, bitTimingLimits: $bitTimingLimits, clockFrequency: $clockFrequency, state: $state, controllerMode: $controllerMode, restartDelay: $restartDelay, busErrorCounters: $busErrorCounters, dataBitTiming: $dataBitTiming, dataBitTimingLimits: $dataBitTimingLimits, termination: $termination, supportedTerminations: $supportedTerminations, supportedBitrates: $supportedBitrates, supportedDataBitrates: $supportedDataBitrates, maxBitrate: $maxBitrate, supportedControllerModes: $supportedControllerModes)';
  }
}
