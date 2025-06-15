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
    _wallets[index].name = wallet.name;
    _wallets[index].description = wallet.description;
    _wallets[index].icon = wallet.icon;
    _wallets[index].baseBalance = wallet.baseBalance;
    _wallets[index].balance = wallet.balance;
    notifyListeners();
  }

  void removeWallet(int id) {
    _wallets.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  void decreaseWalletBalance(int walletId, double amount) {
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