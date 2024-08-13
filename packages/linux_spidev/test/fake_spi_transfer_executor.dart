import 'package:linux_spidev/src/executor/executor.dart';
import 'package:linux_spidev/src/transfer.dart';

class FakeSpiTransferExecutor implements SpiTransferExecutor {
  @override
  Future<void> close() {
    if (closeFn != null) {
      return closeFn!();
    } else {
      throw UnimplementedError();
    }
  }

  Future<void> Function()? closeFn;

  @override
  Future<void> transfer(Iterable<SpiTransfer> transfers) {
    if (transferFn != null) {
      return transferFn!(transfers);
    } else {
      throw UnimplementedError();
    }
  }

  Future<void> Function(Iterable<SpiTransfer>)? transferFn;
}
