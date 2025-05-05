import 'package:flutter/cupertino.dart';

import '../models/wallet.dart';

class WalletState extends ChangeNotifier {
  static final WalletState _instance = WalletState._internal();
  factory WalletState() => _instance;
  WalletState._internal();


  List<Wallet> _wallets = [];

  List<Wallet> get wallets => _wallets;

  Wallet? get defaultWallet => _wallets.isNotEmpty ? _wallets.first : null;

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

  void decreateWalletBalance(int walletId, double amount) {
    final index = _wallets.indexWhere((element) => element.id == walletId);
    _wallets[index].balance -= amount;
    notifyListeners();
  }

  void increaseWalletBalance(int walletId, double amount) {
    final index = _wallets.indexWhere((element) => element.id == walletId);
    _wallets[index].balance += amount;
    notifyListeners();
  }

}