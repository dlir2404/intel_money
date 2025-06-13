import 'package:flutter/material.dart';
import 'package:intel_money/core/services/wallet_service.dart';
import 'package:intel_money/core/state/wallet_state.dart';
import 'package:intel_money/shared/component/typos/currency_double_text.dart';
import 'package:provider/provider.dart';
import '../widgets/wallet_list.dart';

class WalletListTab extends StatelessWidget {
  const WalletListTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletState>(
      builder: (context, state, _) {
        final wallets = state.wallets;

        final totalBalance = wallets.fold<double>(
          0.0,
          (sum, wallet) => sum + (wallet.balance ?? 0.0),
        );

        return RefreshIndicator(
          onRefresh: () async {
            await WalletService().getWallets();
          },
          child: Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tổng số dư khả dụng:'),
                    CurrencyDoubleText(
                      value: totalBalance,
                      color: totalBalance > 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    )
                  ],
                ),
              ),
              Expanded(
                child: WalletList(
                  wallets: wallets,
                  showContextMenu: true,
                  onItemTap: (wallet) {
                    // Handle wallet item tap
                    //navigate to edit screen or show details
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
