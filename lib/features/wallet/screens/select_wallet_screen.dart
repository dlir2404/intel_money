import 'package:flutter/material.dart';
import 'package:intel_money/core/state/wallet_state.dart';
import 'package:provider/provider.dart';

import '../../../core/models/wallet.dart';
import '../../../core/services/wallet_service.dart';
import '../../../core/state/app_state.dart';
import '../controller/wallet_controller.dart';
import '../widgets/wallet_list.dart';

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
      body: Consumer<WalletState>(
        builder: (context, state, _) {
          final wallets = state.wallets;

          return RefreshIndicator(
            onRefresh: () async {
              await WalletService().getWallets();
            },
            child: WalletList(
              wallets: wallets,
              showContextMenu: false,
              onItemTap: (wallet) {
                Navigator.pop(context, wallet);
              },
              selectedWallet: selectedWallet,
            ),
          );
        },
      ),
    );
  }
}
