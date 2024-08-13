// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_gpiod/flutter_gpiod.dart';
import 'package:linux_spidev/linux_spidev.dart';

const BG_SPI_CS_BACK = 0;
const BG_SPI_CS_FRONT = 1;

const SPI_CLOCK_HZ = 16000000;

// Constants for interacting with display registers.
const ST7735_TFTWIDTH = 80;
const ST7735_TFTHEIGHT = 160;

const ST7735_COLS = 132;
const ST7735_ROWS = 162;

const ST7735_NOP = 0x00;
const ST7735_SWRESET = 0x01;
const ST7735_RDDID = 0x04;
const ST7735_RDDST = 0x09;

const ST7735_SLPIN = 0x10;
const ST7735_SLPOUT = 0x11;
const ST7735_PTLON = 0x12;
const ST7735_NORON = 0x13;

const ST7735_INVOFF = 0x20;
const ST7735_INVON = 0x21;
const ST7735_DISPOFF = 0x28;
const ST7735_DISPON = 0x29;

const ST7735_CASET = 0x2A;
const ST7735_RASET = 0x2B;
const ST7735_RAMWR = 0x2C;
const ST7735_RAMRD = 0x2E;

const ST7735_PTLAR = 0x30;
const ST7735_MADCTL = 0x36;
const ST7735_COLMOD = 0x3A;

const ST7735_FRMCTR1 = 0xB1;
const ST7735_FRMCTR2 = 0xB2;
const ST7735_FRMCTR3 = 0xB3;
const ST7735_INVCTR = 0xB4;
const ST7735_DISSET5 = 0xB6;

const ST7735_PWCTR1 = 0xC0;
const ST7735_PWCTR2 = 0xC1;
const ST7735_PWCTR3 = 0xC2;
const ST7735_PWCTR4 = 0xC3;
const ST7735_PWCTR5 = 0xC4;
const ST7735_VMCTR1 = 0xC5;

const ST7735_RDID1 = 0xDA;
const ST7735_RDID2 = 0xDB;
const ST7735_RDID3 = 0xDC;
const ST7735_RDID4 = 0xDD;

const ST7735_GMCTRP1 = 0xE0;
const ST7735_GMCTRN1 = 0xE1;

const ST7735_PWCTR6 = 0xFC;

class ST7735Handle {
  @visibleForTesting
  ST7735Handle.test({
    required SpidevHandle handle,
    required GpioLine dc,
    required this.width,
    required this.height,
    GpioLine? backlight,
    GpioLine? reset,
  })  : _handle = handle,
        _backlight = backlight,
        _dc = dc,
        _reset = reset;

  final SpidevHandle _handle;
  final GpioLine _dc;
  final GpioLine? _backlight;
  final GpioLine? _reset;

  final int width, height;

  var _isClosed = false;

  void _checkNotClosed() {
    if (_isClosed) {
      throw StateError('ST7735Handle is closed');
    }
  }

  static ST7735Handle open({
    required int width,
    required int height,
    required Spidev handle,
    required GpioLine dc,
    GpioLine? backlight,
    GpioLine? reset,
  }) {
    final spiHandle = handle.open();

    try {
      dc.requestOutput(consumer: 'ST7735 DC', initialValue: false);

      try {
        backlight?.requestOutput(consumer: 'ST7735 BL', initialValue: true);

        try {
          reset?.requestOutput(consumer: 'ST7735 RST', initialValue: false);

          return ST7735Handle.test(
            handle: spiHandle,
            width: width,
            height: height,
            dc: dc,
            backlight: backlight,
            reset: reset,
          );
        } catch (_) {
          backlight?.release();
          rethrow;
        }
      } catch (_) {
        dc.release();
        rethrow;
      }
    } catch (_) {
      spiHandle.close();
      rethrow;
    }
  }

  bool get supportsHardReset => _reset != null;

  Future<void> _transfer(Iterable<int> bytes, {required bool dc}) async {
    _checkNotClosed();

    _dc.setValue(dc);
    await _handle.transferSingle(tx: bytes);
  }

  Future<void> _transferData(Iterable<int> bytes) async {
    _checkNotClosed();
    return await _transfer(bytes, dc: false);
  }

  Future<void> _transferCommand(Iterable<int> bytes) async {
    _checkNotClosed();
    return await _transfer(bytes, dc: true);
  }

  Future<void> _command(
    int command, {
    Iterable<int> data = const [],
    Duration? delay,
  }) async {
    _checkNotClosed();

    await _transferCommand([command]);

    if (data.isNotEmpty) {
      await _transferData(data);
    }

    if (delay != null) {
      await Future.delayed(delay);
    }
  }

  Future<void> hardReset() async {
    _checkNotClosed();

    if (_reset case GpioLine reset) {
      reset.setValue(true);
      await Future.delayed(const Duration(milliseconds: 500));
      reset.setValue(false);
      await Future.delayed(const Duration(milliseconds: 500));
      reset.setValue(true);
      await Future.delayed(const Duration(milliseconds: 500));
    } else {
      throw UnsupportedError('Reset is not supported');
    }
  }

  Future<void> softReset() async {
    _checkNotClosed();

    await _command(ST7735_SWRESET, delay: const Duration(milliseconds: 150));
  }

  Future<void> wake() async {
    _checkNotClosed();

    await _command(ST7735_SLPOUT, delay: const Duration(milliseconds: 500));
  }

  Future<void> powerOn() async {
    await _command(ST7735_SWRESET, delay: const Duration(milliseconds: 150));

    await _command(ST7735_SLPOUT, delay: const Duration(milliseconds: 500));

    await _command(ST7735_FRMCTR1, data: [0x01, 0x2C, 0x2D]);
    await _command(ST7735_FRMCTR2, data: [0x01, 0x2C, 0x2D]);
    await _command(ST7735_FRMCTR3, data: [0x01, 0x2C, 0x2D, 0x01, 0x2C, 0x2D]);

    await _command(ST7735_INVCTR, data: [0x07]);

    await _command(ST7735_PWCTR1, data: [0xA2, 0x02, 0x84]);
    await _command(ST7735_PWCTR2, data: [0x0A, 0x00]);
    await _command(ST7735_PWCTR4, data: [0x8A, 0x2A]);
    await _command(ST7735_PWCTR5, data: [0x8A, 0xEE]);

    await _command(ST7735_VMCTR1, data: [0x0E]);

    await _command(ST7735_MADCTL, data: [0xC0]);
  }

  void close() {
    _checkNotClosed();
    _isClosed = true;

    _reset?.release();
    _backlight?.release();
    _dc.release();
    _handle.close();
  }
}

class ST7735 {
  ST7735({
    required this.spidev,
    required this.dc,
    this.backlight,
    this.reset,
    required this.heigth,
    required this.width,
  });

  final Spidev spidev;
  final GpioLine dc;
  final GpioLine? backlight;
  final GpioLine? reset;
  final int width;
  final int heigth;

  ST7735Handle open() {
    return ST7735Handle.open(
      handle: spidev,
      dc: dc,
      backlight: backlight,
      reset: reset,
      width: width,
      height: heigth,
    );
  }
}
