import 'dart:isolate';
import 'dart:ffi' as ffi;

import 'package:_ardera_common_libc_bindings/_ardera_common_libc_bindings.dart';

sealed class ToExecutorMessage {}

sealed class FromExecutorMessage {}

final class StartTransferMessage implements ToExecutorMessage {
  StartTransferMessage({
    required this.id,
    required this.nTransfers,
    required ffi.Pointer<spi_ioc_transfer> pointer,
  }) : address = pointer.address;

  final int id;
  final int nTransfers;
  final int address;

  ffi.Pointer<spi_ioc_transfer> get pointer => ffi.Pointer.fromAddress(address);
}

final class TransferCompleteMessage implements FromExecutorMessage {
  TransferCompleteMessage.success({
    required this.id,
  })  : errorMessage = null,
        stackTrace = null;

  TransferCompleteMessage.error({
    required this.id,
    required Object exception,
    StackTrace? stackTrace,
  })  : errorMessage = exception.toString(),
        stackTrace = stackTrace?.toString();

  final int id;
  final String? errorMessage;
  final String? stackTrace;
}

final class SendPortMessage implements FromExecutorMessage {
  SendPortMessage(this.sendPort);

  final SendPort sendPort;
}

final class StopExecutorMessage implements ToExecutorMessage {}
