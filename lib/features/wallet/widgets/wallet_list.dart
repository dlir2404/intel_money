import 'package:flutter/material.dart';
import 'package:intel_money/features/wallet/widgets/wallet_item.dart';
import 'package:intel_money/shared/component/icons/icon_selected.dart';

import '../../../core/config/routes.dart';
import '../../../core/models/wallet.dart';

class WalletList extends StatelessWidget {
  final List<Wallet> wallets;
  final void Function(Wallet)? onItemTap;
  final bool showContextMenu;
  final Wallet? selectedWallet;

  const WalletList({
    super.key,
    required this.wallets,
    this.onItemTap,
    required this.showContextMenu, this.selectedWallet,
  });

  void _navigateToCreateWallet(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.createWallet);
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'No wallets yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the + button to create your first wallet',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),

              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add Wallet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () => _navigateToCreateWallet(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (wallets.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: wallets.length,
      itemBuilder: (context, index) {
        final wallet = wallets[index];
        return WalletItem(
          wallet: wallet,
          onTap: (wallet) {
            if (onItemTap != null) {
              onItemTap!(wallet);
            }
          },
          showContextMenu: showContextMenu,
          trailing: selectedWallet == wallet ? IconSelected() : null,
        );
      },
    );
  }
}
