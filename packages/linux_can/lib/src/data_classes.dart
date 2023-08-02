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
sealed class CanFrame {
  const CanFrame();

  /// CAN ID of the frame.
  int get id;

  /// Frame format. (Base: 11bit id, Extended: 29bit id)
  CanFrameFormat get format;

  /// Frame type. (Data or Remote Transmission Request)
  CanFrameType get type;

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

  @override
  int get hashCode;

  @override
  bool operator ==(Object other);
}

sealed class CanBaseFrame extends CanFrame {
  /// 11-bit CAN ID (base frame format) of this frame.
  @override
  int get id;
}

sealed class CanExtendedFrame extends CanFrame {
  /// 29-bit CAN ID (extended frame format) of this frame.
  @override
  int get id;
}

sealed class CanDataFrame extends CanFrame {
  /// 0 to 8 byte CAN frame payload.
  List<int> get data;
}

sealed class CanRemoteFrame extends CanFrame {}

class CanStandardDataFrame extends CanFrame implements CanBaseFrame, CanDataFrame {
  const CanStandardDataFrame({required this.id, required this.data}) : assert(0 <= data.length && data.length <= 8);

  @override
  final int id;

  @override
  final List<int> data;

  @override
  final CanFrameFormat format = CanFrameFormat.base;

  @override
  final CanFrameType type = CanFrameType.data;

  @override
  int get hashCode => Object.hash(id, data);

  @override
  bool operator ==(Object other) {
    return other is CanStandardDataFrame && id == other.id && listsEqual(data, other.data);
  }

  @override
  String toString() => 'CanStandardDataFrame(id: $id, data: $data)';
}

class CanExtendedDataFrame extends CanFrame implements CanExtendedFrame, CanDataFrame {
  const CanExtendedDataFrame({required this.id, required this.data}) : assert(id & ~CAN_EFF_MASK == 0);

  @override
  final int id;

  @override
  final List<int> data;

  @override
  final CanFrameFormat format = CanFrameFormat.extended;

  @override
  final CanFrameType type = CanFrameType.data;

  @override
  int get hashCode => Object.hash(id, data);

  @override
  bool operator ==(Object other) {
    return other is CanExtendedDataFrame && id == other.id && listsEqual(data, other.data);
  }

  @override
  String toString() => 'CanExtendedDataFrame(id: $id, data: $data)';
}

class CanStandardRemoteFrame extends CanFrame implements CanBaseFrame, CanRemoteFrame {
  const CanStandardRemoteFrame({required this.id}) : assert(id & ~CAN_SFF_MASK == 0);

  @override
  final int id;

  @override
  final CanFrameFormat format = CanFrameFormat.base;

  @override
  final CanFrameType type = CanFrameType.remote;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    return other is CanStandardRemoteFrame && id == other.id;
  }

  @override
  String toString() => 'CanStandardRemoteFrame(id: $id)';
}

class CanExtendedRemoteFrame extends CanFrame implements CanExtendedFrame, CanRemoteFrame {
  const CanExtendedRemoteFrame({required this.id}) : assert(id & ~CAN_EFF_MASK == 0);

  @override
  final int id;

  @override
  final CanFrameFormat format = CanFrameFormat.extended;

  @override
  final CanFrameType type = CanFrameType.remote;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    return other is CanExtendedRemoteFrame && id == other.id;
  }

  @override
  String toString() => 'CanExtendedRemoteFrame(id: $id)';
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

base class CanError implements Exception {
  const CanError(this.kindNative, this.description);

  static const txTimeout = CanError(CAN_ERR_TX_TIMEOUT, 'driver transmit timeout');
  static const noAck = CanError(CAN_ERR_ACK, 'received no ACK on transmission');
  static const busOff = CanError(CAN_ERR_BUSOFF, 'bus off');
  static const busError = CanError(CAN_ERR_BUSERROR, 'bus error');
  static const restarted = CanError(CAN_ERR_RESTARTED, 'controller restarted');

  final int kindNative;
  final String description;

  @override
  String toString() {
    return 'CAN error: $description';
  }
}

final class CanArbitrationLostError extends CanError {
  const CanArbitrationLostError(this.bit)
      : assert(bit != 0),
        super(
          CAN_ERR_LOSTARB,
          'Lost arbitration in ${bit != null ? 'bit $bit' : 'unspecified bit'}',
        );

  final int? bit;

  @override
  int get hashCode => bit.hashCode;

  @override
  bool operator ==(Object other) {
    return other is CanArbitrationLostError && other.bit == bit;
  }
}

final class CanProtocolError extends CanError {
  const CanProtocolError(this.protocolErrorNative, String description) : super(CAN_ERR_PROT, description);

  static const unspecified = CanProtocolError(CAN_ERR_PROT_UNSPEC, 'Unspecified protocol error');
  static const bit = CanProtocolError(CAN_ERR_PROT_BIT, 'Single bit protocol violation');
  static const format = CanProtocolError(CAN_ERR_PROT_FORM, 'Frame format protocol violation');
  static const stuffing = CanProtocolError(CAN_ERR_PROT_STUFF, 'Bit stuffing protocol violation');
  static const dominantBit = CanProtocolError(CAN_ERR_PROT_BIT0, 'Unable to send dominant bit');
  static const recessiveBit = CanProtocolError(CAN_ERR_PROT_BIT1, 'Unable to send recessive bit');
  static const overload = CanProtocolError(CAN_ERR_PROT_OVERLOAD, 'Bus overload');
  static const tx = CanProtocolError(CAN_ERR_PROT_TX, 'Protocol error ocurred on transmission');

  static const values = [unspecified, bit, format, stuffing, dominantBit, recessiveBit, overload, tx];

  final int protocolErrorNative;
}

final class CanControllerError extends CanError {
  const CanControllerError(this.controllerErrorNative, String description) : super(CAN_ERR_CRTL, description);

  static const unspecified = CanControllerError(CAN_ERR_CRTL_UNSPEC, 'Unspecified controller error');
  static const rxOverflow = CanControllerError(CAN_ERR_CRTL_RX_OVERFLOW, 'RX buffer overflow');
  static const txOverflow = CanControllerError(CAN_ERR_CRTL_TX_OVERFLOW, 'TX buffer overflow');
  static const rxWarning = CanControllerError(CAN_ERR_CRTL_RX_WARNING, 'reached warning level for RX errors');
  static const txWarning = CanControllerError(CAN_ERR_CRTL_TX_WARNING, 'reached warning level for TX errors');
  static const rxPassive = CanControllerError(CAN_ERR_CRTL_RX_PASSIVE, 'reached error passive status for RX');
  static const txPassive = CanControllerError(CAN_ERR_CRTL_TX_PASSIVE, 'reached error passive status for TX');

  static const values = [
    unspecified,
    rxOverflow,
    txOverflow,
    rxWarning,
    txWarning,
    rxPassive,
    txPassive,
  ];

  final int controllerErrorNative;
}

enum CanWireStatus {
  /// CAN H or CAN L is not connected.
  /// This is the only wire status actually supported by any upstream kernel
  /// driver at the moment. (By the ETAS ES58x driver)
  notConnected(CAN_ERR_TRX_CANL_NO_WIRE, 'Not connected'),

  /// CAN H or CAN L is shorted to BAT.
  /// Not implemented by any upstream kernel drivers at the moment.
  shortToBattery(CAN_ERR_TRX_CANL_SHORT_TO_BAT, 'Shorted to BAT'),

  /// CAN H or CAN L is shorted to VCC.
  /// Not implemented by any upstream kernel drivers at the moment.
  shortToVCC(CAN_ERR_TRX_CANL_SHORT_TO_VCC, 'Shorted to VCC'),

  /// CAN H or CAN L is shorted to GND.
  /// Not implemented by any upstream kernel drivers at the moment.
  shortToGND(CAN_ERR_TRX_CANL_SHORT_TO_GND, 'Shorted to GND');

  const CanWireStatus(this.native, this.description);

  final int native;
  final String description;
}

final class CanWiringError extends CanError {
  const CanWiringError(this.canHigh, this.canLow, this.canHighShortedToCanLow) : super(CAN_ERR_TRX, '');

  final CanWireStatus? canHigh;
  final CanWireStatus? canLow;

  /// True if CAN H and CAN L are shorted to each other.
  /// Not implemented by any upstream kernel drivers at the moment.
  final bool canHighShortedToCanLow;

  /// Unspecified wiring error.
  /// Not implemented by any upstream kernel drivers at the moment.
  static const unspecified = CanWiringError(null, null, false);

  @override
  String get description {
    final description = [
      if (canHighShortedToCanLow) 'CAN H shorted to CAN L',
      if (canHigh != null) 'CAN H: $canHigh',
      if (canLow != null) 'CAN L: $canLow',
      if (canHigh == null && canLow == null) 'Unspecified wiring error',
    ].join(', ');

    return description;
  }
}

enum CanRuleCombinator { or, and }

class CanFilterRule {
  const CanFilterRule({
    required this.id,
    required this.mask,
    this.formats = const {CanFrameFormat.base, CanFrameFormat.extended},
    this.types = const {CanFrameType.data},
    this.invert = false,
  })  : assert(0 <= id && id <= CAN_EFF_MASK),
        assert(0 <= mask && mask <= CAN_EFF_MASK);

  static const empty = CanFilterRule(id: 1, mask: 0, formats: {}, types: {}, invert: false);

  final int id;
  final int mask;
  final Set<CanFrameFormat> formats;
  final Set<CanFrameType> types;
  final bool invert;

  CanFilterRule copyWith({
    int? id,
    int? mask,
    Set<CanFrameFormat>? formats,
    Set<CanFrameType>? types,
    bool? invert,
  }) {
    return CanFilterRule(
      id: id ?? this.id,
      mask: mask ?? this.mask,
      formats: formats ?? this.formats,
      types: types ?? this.types,
      invert: invert ?? this.invert,
    );
  }

  bool disjoint(CanFilterRule other) {
    if (invert || other.invert) {
      throw UnimplementedError();
    }

    if (id & other.mask != other.id & mask) {
      // disjoint.
      return true;
    }

    // There are ids that match both rules.
    // If the format sets are disjoint, the rules are still disjoint.
    if (formats.intersection(other.formats).isNotEmpty) {
      return false;
    }

    // If the frame types are disjoint, the rules are still disjoint.
    if (types.intersection(other.types).isNotEmpty) {
      return false;
    }

    return true;
  }

  bool intersecting(CanFilterRule other) => !disjoint(other);

  @override
  int get hashCode => Object.hash(id, mask, formats, types, invert);

  @override
  bool operator ==(Object other) {
    return other is CanFilterRule &&
        id == other.id &&
        mask == other.mask &&
        formats.asConst() == other.formats.asConst() &&
        types.asConst() == other.types.asConst() &&
        invert == other.invert;
  }
}

enum CanFrameFormat {
  base,
  extended;

  const CanFrameFormat();

  static const both = {base, extended};

  Set<CanFrameFormat> toSet() {
    return switch (this) {
      CanFrameFormat.base => const {CanFrameFormat.base},
      CanFrameFormat.extended => const {CanFrameFormat.extended},
    };
  }
}

extension CanFrameFormatAsConstSet on Set<CanFrameFormat> {
  static const _noneSet = <CanFrameFormat>{};
  static const _baseOnlySet = {CanFrameFormat.base};
  static const _extendedOnlySet = {CanFrameFormat.extended};
  static const _bothSet = {CanFrameFormat.base, CanFrameFormat.extended};

  Set<CanFrameFormat> asConst() {
    switch (this) {
      case _noneSet:
      case _baseOnlySet:
      case _extendedOnlySet:
      case _bothSet:
        return this;
      default:
        if (isEmpty) {
          return _noneSet;
        } else if (contains(CanFrameFormat.base)) {
          if (contains(CanFrameFormat.extended)) {
            return _bothSet;
          } else {
            return _baseOnlySet;
          }
        } else {
          return _extendedOnlySet;
        }
    }
  }
}

enum CanFrameType { data, remote }

extension CanFrameTypeAsConstSet on Set<CanFrameType> {
  static const _noneSet = <CanFrameType>{};
  static const _dataOnlySet = {CanFrameType.data};
  static const _remoteOnlySet = {CanFrameType.remote};
  static const _bothSet = {CanFrameType.data, CanFrameType.remote};

  Set<CanFrameType> asConst() {
    switch (this) {
      case _noneSet:
      case _dataOnlySet:
      case _remoteOnlySet:
      case _bothSet:
        return this;
      default:
        if (isEmpty) {
          return _noneSet;
        } else if (contains(CanFrameType.data)) {
          if (contains(CanFrameType.remote)) {
            return _bothSet;
          } else {
            return _dataOnlySet;
          }
        } else {
          return _remoteOnlySet;
        }
    }
  }
}

class CanFilterNotRepresentableException implements Exception {
  const CanFilterNotRepresentableException(this.message);

  final String? message;

  @override
  String toString() {
    return 'CAN filter not representable as native SocketCAN filter rule list: $message';
  }
}

abstract base class CanFilter {
  const CanFilter();

  factory CanFilter.whitelist(
    Iterable<int> ids, {
    Set<CanFrameFormat> formats = const {CanFrameFormat.base, CanFrameFormat.extended},
    Set<CanFrameType> types = const {CanFrameType.data},
  }) {
    return CanFilter.or([
      for (final id in ids)
        CanFilter.idEquals(
          id,
          formats: formats,
          types: types,
        ),
    ]);
  }

  factory CanFilter.blacklist(
    Iterable<int> ids, {
    Set<CanFrameFormat> formats = const {CanFrameFormat.base, CanFrameFormat.extended},
    Set<CanFrameType> types = const {CanFrameType.data, CanFrameType.remote},
  }) {
    return CanFilter.and([
      for (final id in ids)
        CanFilter.notIdEquals(
          id,
          formats: formats,
          types: types,
        ),
    ]);
  }

  const factory CanFilter.idEquals(
    int id, {
    int? mask,
    Set<CanFrameFormat> formats,
    Set<CanFrameType> types,
  }) = CanFilterIdEquals;

  const factory CanFilter.notIdEquals(
    int id, {
    int? mask,
    Set<CanFrameFormat> formats,
    Set<CanFrameType> types,
  }) = CanFilterIdEquals.not;

  const factory CanFilter.not(CanFilter operand) = CanFilterNot;

  const factory CanFilter.or(Iterable<CanFilter> operands) = CanFilterOr.fromIterable;

  const factory CanFilter.and(Iterable<CanFilter> operands) = CanFilterAnd.fromIterable;

  /// Matches any CAN data or RTR frame with any id and any frame format (base or extended).
  static const any = CanFilter.idEquals(
    0,
    mask: 0,
    formats: {CanFrameFormat.base, CanFrameFormat.extended},
    types: {CanFrameType.data, CanFrameType.remote},
  );

  /// Matches any CAN data frame with any id and any frame format (base or extended).
  static const anyData = CanFilter.idEquals(
    0,
    mask: 0,
    formats: {CanFrameFormat.base, CanFrameFormat.extended},
    types: {CanFrameType.data},
  );

  /// Matches no frames at all.
  static const none = CanFilter.or([]);

  (Iterable<CanFilterRule>, CanRuleCombinator?) get rules;

  bool matches(CanFrame frame);
}

final class CanFilterIdEquals extends CanFilter {
  const CanFilterIdEquals(
    this.id, {
    this.mask,
    this.formats = CanFrameFormat.both,
    this.types = const {CanFrameType.data},
  })  : assert(0 <= id && id <= CAN_EFF_MASK),
        assert(mask == null || 0 <= mask && mask <= CAN_EFF_MASK),
        invert = false;

  const CanFilterIdEquals.not(
    this.id, {
    this.mask,
    this.formats = CanFrameFormat.both,
    this.types = const {CanFrameType.data, CanFrameType.remote},
  })  : assert(0 <= id && id <= CAN_EFF_MASK),
        assert(mask == null || 0 <= mask && mask <= CAN_EFF_MASK),
        invert = true;

  final int id;
  final int? mask;
  final Set<CanFrameFormat> formats;
  final Set<CanFrameType> types;
  final bool invert;

  CanFilterRule _getUniversal() {
    final mask = this.mask ?? CAN_EFF_MASK;

    return CanFilterRule(
      id: id,
      mask: mask,
      formats: formats,
      types: types,
      invert: invert,
    );
  }

  static int _fullMaskForFormat(CanFrameFormat format) {
    return switch (format) {
      CanFrameFormat.base => CAN_SFF_MASK,
      CanFrameFormat.extended => CAN_EFF_MASK,
    };
  }

  int _maskForFormat(CanFrameFormat format) {
    final mask = this.mask;

    return switch (format) {
      CanFrameFormat.base => mask != null ? mask & CAN_SFF_MASK : CAN_SFF_MASK,
      CanFrameFormat.extended => mask != null ? mask & CAN_EFF_MASK : CAN_EFF_MASK
    };
  }

  (Iterable<CanFilterRule>, CanRuleCombinator?) get optimizedRules {
    // We short-circuit here if we can't fully optimize the filter rules.
    // The kernel keeps special, optimized filter lists for rules that:
    //   - only match a single id
    //   - don't have the RTR or INV flag set
    //
    // The kernel will check the optimized filter lists last. I.e. it does not make sense
    // to register a universal rule and additional specialized (optimized) subset of the rule,
    // since the universal rule will be matched first.
    //
    // Hence we return early here when we can't fully replace this filter with optimized,
    // single-id non-RTR non-INV rules.
    if (types.asConst() != const {CanFrameType.data}) {
      return rules;
    }

    if (formats.any((f) => _maskForFormat(f) != _fullMaskForFormat(f))) {
      return rules;
    }

    if (invert) {
      return rules;
    }

    final optimized = [
      for (final format in formats)
        CanFilterRule(
          id: id,
          mask: _maskForFormat(format),
          formats: format.toSet(),
          types: const {CanFrameType.data},
          invert: false,
        ),
    ];

    return (
      optimized,
      optimized.length > 1 ? CanRuleCombinator.or : null,
    );
  }

  @override
  bool matches(CanFrame frame) {
    var result = false;

    if (formats.contains(frame.format) && types.contains(frame.type)) {
      final mask = _maskForFormat(frame.format);
      if (frame.id & mask == id) {
        result = true;
      }
    }

    if (invert) {
      result = !result;
    }

    return result;
  }

  @override
  (Iterable<CanFilterRule>, CanRuleCombinator?) get rules {
    return ([_getUniversal()], null);
  }
}

final class CanFilterNot extends CanFilter {
  const CanFilterNot(this.operand);

  final CanFilter operand;

  @override
  bool matches(CanFrame frame) {
    return !operand.matches(frame);
  }

  @override
  (Iterable<CanFilterRule>, CanRuleCombinator?) get rules {
    final (rules, combinator) = operand.rules;

    return (
      rules.map(
        (r) => r.copyWith(invert: !r.invert),
      ),
      switch (combinator) {
        null => null,
        CanRuleCombinator.and => CanRuleCombinator.or,
        CanRuleCombinator.or => CanRuleCombinator.and,
      }
    );
  }
}

abstract base class CanFilterCombine extends CanFilter {
  const CanFilterCombine.fromIterable(this.operands);

  final Iterable<CanFilter> operands;
}

final class CanFilterOr extends CanFilterCombine {
  const CanFilterOr.fromIterable(super.operands) : super.fromIterable();

  @override
  bool matches(CanFrame frame) {
    return operands.any((operand) => operand.matches(frame));
  }

  @override
  (Iterable<CanFilterRule>, CanRuleCombinator?) get rules {
    if (operands.any((op) => op.rules.$2 == CanRuleCombinator.and)) {
      /// TODO: Can we support this somehow?
      throw CanFilterNotRepresentableException(
        'AND filters inside an OR filter are representable.',
      );
    }

    return (
      operands.expand(
        (filter) {
          return switch (filter) {
            CanFilterIdEquals _ => filter.optimizedRules.$1,
            CanFilter _ => filter.rules.$1,
          };
        },
      ).toSet(),
      CanRuleCombinator.or,
    );
  }
}

final class CanFilterAnd extends CanFilterCombine {
  const CanFilterAnd.fromIterable(super.operands) : super.fromIterable();

  static Set<T> intersection<T>(Set<T> a, Set<T> b) {
    return a.intersection(b);
  }

  @override
  bool matches(CanFrame frame) {
    return operands.every((operand) => operand.matches(frame));
  }

  @override
  (Iterable<CanFilterRule>, CanRuleCombinator?) get rules {
    if (operands.length > 1 &&
        operands.map((op) => op.rules.$2).any((combinator) => combinator == CanRuleCombinator.or)) {
      /// TODO: Can we support this somehow?
      throw CanFilterNotRepresentableException(
        'OR filters inside an AND filter are not representable.',
      );
    }

    final combinator = switch (operands) {
      List(isEmpty: true) => null,
      List(length: 1) => operands.single.rules.$2,
      _ => CanRuleCombinator.and,
    };

    return (
      operands.expand((filter) => filter.rules.$1).toSet(),
      combinator,
    );
  }
}
