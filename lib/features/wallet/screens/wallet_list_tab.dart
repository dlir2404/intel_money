import 'package:flutter/material.dart';
import 'package:intel_money/core/services/wallet_service.dart';
import 'package:intel_money/core/state/app_state.dart';
import 'package:intel_money/core/models/wallet.dart';
import 'package:provider/provider.dart';

import '../../../shared/const/icons/wallet_icon.dart';
import '../widgets/wallet_list.dart';

class WalletListTab extends StatelessWidget {
  const WalletListTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final wallets = appState.wallets;

        return RefreshIndicator(
          onRefresh: () async {
            await WalletService().getWallets();
          },
          child: WalletList(
            wallets: wallets,
            showContextMenu: true,
            onItemTap: (wallet) {
              // Handle wallet item tap
              //navigate to edit screen or show details
            },
          ),
        );
      },
    );
  }
}
