import '../../../core/models/wallet.dart';
import '../../../core/services/wallet_service.dart';
import '../../../core/state/wallet_state.dart';
import '../../transaction/controller/transaction_controller.dart';

class WalletController {
  static final WalletController _instance = WalletController._internal();
  factory WalletController() => _instance;
  WalletController._internal();

  final TransactionController _transactionController = TransactionController();
  final WalletState _walletState = WalletState();
  final WalletService _walletService = WalletService();

  Future<void> removeWallet(Wallet wallet) async {
    await _walletService.delete(wallet.id);

    await _transactionController.removeTransactionsByWallet(wallet.id);
    _walletState.removeWallet(wallet.id);
  }
}