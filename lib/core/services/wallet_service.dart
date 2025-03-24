import 'package:flutter/cupertino.dart';
import 'package:intel_money/core/network/api_client.dart';
import 'package:intel_money/core/state/app_state.dart';
import 'package:intel_money/core/types/wallet.dart';

class WalletService {
  final AppState _appState;
  final ApiClient _apiClient;

  WalletService({required AppState appState, ApiClient? apiClient})
    : _appState = appState,
      _apiClient = apiClient ?? ApiClient.instance;

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
    _appState.addWallet(wallet);
  }

  Future<void> getWallets() async {
    final response = await _apiClient.get('/wallet');

    final List<dynamic> walletsData = response['wallets'];
    final wallets =
        walletsData.map((wallet) => Wallet.fromJson(wallet)).toList();
    _appState.setWallets(wallets);
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
      icon: icon,
      balance: balance,
      description: description,
    );
    _appState.updateWallet(wallet);
  }

  Future<void> delete(int id) async {
    await _apiClient.delete('/wallet/$id');
    _appState.removeWallet(id);
  }
}
