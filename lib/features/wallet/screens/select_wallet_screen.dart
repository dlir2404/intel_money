import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/wallet.dart';
import '../../../core/state/app_state.dart';
import '../controller/wallet_controller.dart';

class SelectWalletScreen extends StatelessWidget {
  final Wallet? selectedWallet;
  const SelectWalletScreen({super.key, this.selectedWallet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Wallet'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AppState>(
        builder: (context, appState, _) {
          final wallets = appState.wallets;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            itemCount: wallets.length,
            itemBuilder: (context, index) {
              final wallet = wallets[index];

              return ListTile(
                title: Text(wallet.name),
                leading: Icon(
                  WalletController.getWalletIcon(wallet.icon),
                  color: WalletController.getIconColor(wallet.icon),
                ),
                onTap: () {
                  Navigator.pop(context, wallet);
                },
              );
            },
          );
        },
      ),
    );
  }
}
