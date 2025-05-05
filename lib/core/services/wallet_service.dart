import 'package:flutter/cupertino.dart';
import 'package:intel_money/core/network/api_client.dart';
import 'package:intel_money/core/models/wallet.dart';
import 'package:intel_money/shared/const/icons/wallet_icon.dart';

import '../state/wallet_state.dart';

class WalletService {
  final WalletState _walletState = WalletState();
  final ApiClient _apiClient = ApiClient.instance;

  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  Future<void> create(
    String name,
    String description,
    String icon,
    double balance,
  ) async {
    final response = await _apiClient.post('/wallet', {
      'name': name,
      'description': description,
      'icon': icon,
      'balance': balance,
    });

    debugPrint(response.toString());

    final wallet = Wallet.fromJson(response);
    _walletState.addWallet(wallet);
  }

  Future<void> getWallets() async {
    final response = await _apiClient.get('/wallet');

    final List<dynamic> walletsData = response['wallets'];
    final wallets =
        walletsData.map((wallet) => Wallet.fromJson(wallet)).toList();
    _walletState.setWallets(wallets);
  }

  Future<void> update(
    int id,
    String name,
    String description,
    String icon,
    double balance,
  ) async {
    await _apiClient.put('/wallet/$id', {
      'name': name,
      'description': description,
      'icon': icon,
      'balance': balance,
    });

    final wallet = Wallet(
      id: id,
      name: name,
      icon: WalletIcon.getIcon(icon),
      balance: balance,
      description: description,
    );
    _walletState.updateWallet(wallet);
  }

  Future<void> delete(int id) async {
    await _apiClient.delete('/wallet/$id');
    _walletState.removeWallet(id);
  }
}
