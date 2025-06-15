import 'package:intel_money/core/state/app_state.dart';
import 'package:intel_money/core/state/transaction_state.dart';

import '../../../core/models/wallet.dart';
import '../../../core/services/wallet_service.dart';
import '../../../core/state/statistic_state.dart';
import '../../../core/state/wallet_state.dart';
import '../../../shared/const/icons/wallet_icon.dart';
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
    final wallet = await _walletService.create(
      name,
      description,
      icon,
      baseBalance,
    );
    _walletState.addWallet(wallet);

    if (baseBalance > 0) {
      _appState.increaseUserBalance(baseBalance);
    }
  }

  Future<void> updateWallet(
    Wallet oldWallet,
    String name,
    String description,
    String icon,
    double baseBalance,
  ) async {
    await _walletService.update(
      oldWallet.id,
      name,
      description,
      icon,
      baseBalance,
    );

    final newWallet = oldWallet.copyWith();
    newWallet.name = name;
    newWallet.description = description;
    newWallet.icon = WalletIcon.getIcon(icon);
    newWallet.baseBalance = baseBalance;

    if (oldWallet.baseBalance == baseBalance) {
      _walletState.updateWallet(newWallet);
    } else {
      final differ = baseBalance - oldWallet.baseBalance;

      final firstModifyBalanceTransaction = TransactionController().getFirstModifyBalanceTransaction(oldWallet.id);
      if (firstModifyBalanceTransaction != null) {
        //ex: base: 0, mod +100 => new base: 20 => only mod + 80
        //ex2: base: 20, mode +80 => new base: 0 => differ is -20 => mode +100

        final newTransaction = firstModifyBalanceTransaction.copyWith();
        newTransaction.amount -= differ;
        TransactionState().updateTransaction(newTransaction);
        _walletState.updateWallet(newWallet);
        StatisticState().recalculateStatisticData();
      } else {
        if (differ > 0) {
          _appState.increaseUserBalance(differ);
          newWallet.balance += differ;
        } else {
          _appState.decreaseUserBalance(-differ);
          newWallet.balance += differ; // differ is negative, so this decreases the balance
        }
        _walletState.updateWallet(newWallet);
      }
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
