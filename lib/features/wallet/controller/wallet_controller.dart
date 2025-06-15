import 'package:intel_money/core/state/app_state.dart';

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
  final AppState _appState = AppState();
  final WalletService _walletService = WalletService();

  Future<void> create(
    String name,
    String description,
    String icon,
    double baseBalance,
  ) async {
    final wallet = await _walletService.create(name, description, icon, baseBalance);
    _walletState.addWallet(wallet);

    if (baseBalance > 0) {
      _appState.increaseUserBalance(baseBalance);
    }
  }

  Future<void> removeWallet(Wallet wallet) async {
    await _walletService.delete(wallet.id);

    await _transactionController.removeTransactionsByWallet(wallet.id);

    if (wallet.baseBalance > 0) {
      _appState.decreaseUserBalance(wallet.baseBalance);
    }

    _walletState.removeWallet(wallet.id);
  }
}