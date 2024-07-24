import 'package:_ardera_common_libc_bindings/_ardera_common_libc_bindings.dart';

enum SpiMode {
  mode0(SPI_MODE_0),
  mode1(SPI_MODE_1),
  mode2(SPI_MODE_2),
  mode3(SPI_MODE_3);

  const SpiMode(this.value);

  factory SpiMode.fromValue(int value) {
    return switch (value) {
      SPI_MODE_0 => SpiMode.mode0,
      SPI_MODE_1 => SpiMode.mode1,
      SPI_MODE_2 => SpiMode.mode2,
      SPI_MODE_3 => SpiMode.mode3,
      _ => throw ArgumentError.value(value, 'value', 'Invalid SPI mode')
    };
  }

  final int value;
}

enum SpiFlag {
  csActiveHigh(SPI_CS_HIGH),
  lsbFirst(SPI_LSB_FIRST),
  threeWire(SPI_3WIRE),
  loopBack(SPI_LOOP),
  noCs(SPI_NO_CS),
  ready(SPI_READY),
  txDual(SPI_TX_DUAL),
  txQuad(SPI_TX_QUAD),
  txOctal(SPI_TX_OCTAL),
  rxDual(SPI_RX_DUAL),
  rxQuad(SPI_RX_QUAD),
  rxOctal(SPI_RX_OCTAL),
  toggleCsAfterEachWord(SPI_CS_WORD),
  threeWireHighImpedanceTurnaround(SPI_3WIRE_HIZ);

  const SpiFlag(this.value);

  final int value;
}

enum SpiTransferMode {
  single(1),
  dual(2),
  quad(4);

  const SpiTransferMode(this.bits);

  final int bits;
}

class SpiTransferProperties {
  /// Select a speed other than the device default for this transfer.
  /// If 0, the default of the SPI device is used.
  final int? speedHz;

  /// Delay after this transfer before
  /// (optionally) changing the chipselect status,
  /// then starting the next transfer or completing this [RawSpiTransfer].
  /// Measured in microseconds.
  final Duration delay;

  /// Select a bits_per_word other than the device default for this transfer.
  /// If 0 the default of the SPI device is used.
  final int? bitsPerWord;

  /// Affects chipselect after this transfer completes.
  final bool doToggleCS;

  /// Number of bits used for writing. If 0 the default (SPI_NBITS_SINGLE) is used.
  final SpiTransferMode? txTransferMode;

  /// number of bits used for reading. If 0 the default (SPI_NBITS_SINGLE) is used.
  final SpiTransferMode? rxTransferMode;

  /// Delay to be inserted between consecutive words of a transfer
  final Duration wordDelay;

  static final defaultProperties = SpiTransferProperties();

  SpiTransferProperties({
    this.speedHz,
    this.delay = const Duration(microseconds: 0),
    this.bitsPerWord,
    this.doToggleCS = false,
    this.txTransferMode,
    this.rxTransferMode,
    this.wordDelay = const Duration(microseconds: 0),
  })  : assert(speedHz == null || (speedHz >= 0 && speedHz <= 0xFFFFFFFF)),
        assert(delay.inMicroseconds >= 0 && delay.inMicroseconds <= 0xFFFF),
        assert(bitsPerWord == null || (bitsPerWord >= 0 && bitsPerWord <= 32)),
        assert(
            wordDelay.inMicroseconds >= 0 && wordDelay.inMicroseconds <= 0xFF);
}
