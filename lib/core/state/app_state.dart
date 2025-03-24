import 'package:flutter/cupertino.dart';
import 'package:intel_money/core/models/user.dart';
import 'package:intel_money/core/types/wallet.dart';

class AppState extends ChangeNotifier {
  User? _user;
  List<Wallet> _wallets = [];

  User? get user => _user;
  List<Wallet> get wallets => _wallets;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void setWallets(List<Wallet> wallets) {
    _wallets = wallets;
    notifyListeners();
  }

  void addWallet(Wallet wallet) {
    _wallets.add(wallet);
    notifyListeners();
  }

  void updateWallet(Wallet wallet) {
    final index = _wallets.indexWhere((element) => element.id == wallet.id);
    _wallets[index] = wallet;
    notifyListeners();
  }

  void removeWallet(int id) {
    _wallets.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  void clear() {
    _user = null;
    _wallets = [];
    notifyListeners();
  }
}