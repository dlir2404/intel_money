import 'package:flutter/material.dart';
import 'package:intel_money/core/services/wallet_service.dart';
import 'package:intel_money/core/state/app_state.dart';
import 'package:intel_money/core/types/wallet.dart';
import 'package:provider/provider.dart';

class WalletListTab extends StatelessWidget {
  const WalletListTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final wallets = appState.wallets;

        return RefreshIndicator(
          onRefresh: () async {
            final appState = Provider.of<AppState>(context, listen: false);
            final walletService = WalletService(appState: appState);
            await walletService.getWallets();
          },
          child: wallets.isEmpty
              ? _buildEmptyState(context)
              : _buildWalletList(context, wallets),
        );
      },
    );
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
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWalletList(BuildContext context, List<Wallet> wallets) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: wallets.length,
      itemBuilder: (context, index) {
        final wallet = wallets[index];
        return _buildWalletCard(context, wallet);
      },
    );
  }

  Widget _buildWalletCard(BuildContext context, Wallet wallet) {
    Color getWalletColor(String iconName) {
      switch (iconName) {
        case 'wallet': return Colors.blue;
        case 'savings': return Colors.amber;
        case 'card': return Colors.purple;
        case 'exchange': return Colors.green;
        case 'shopping': return Colors.pink;
        case 'money': return Colors.teal;
        default: return Theme.of(context).primaryColor;
      }
    }

    IconData getIconData(String iconName) {
      switch (iconName) {
        case 'wallet': return Icons.account_balance_wallet;
        case 'savings': return Icons.savings;
        case 'card': return Icons.credit_card;
        case 'exchange': return Icons.currency_exchange;
        case 'shopping': return Icons.shopping_bag;
        case 'money': return Icons.attach_money;
        default: return Icons.account_balance_wallet;
      }
    }

    final walletColor = getWalletColor(wallet.icon);
    final formattedBalance = '\$${wallet.balance.toStringAsFixed(2)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Navigate to wallet details
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: walletColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    getIconData(wallet.icon),
                    color: walletColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),

                // Name and description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wallet.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (wallet.description != null && wallet.description!.isNotEmpty)
                        Text(
                          wallet.description ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),

                // Balance
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formattedBalance,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: wallet.balance > 0 ? Colors.green[600] : Colors.red[600],
                        ),
                      ),
                      Text(
                        'Balance',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),

                // More menu
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
                  padding: EdgeInsets.zero,
                  offset: const Offset(0, 40),
                  constraints: const BoxConstraints(minWidth: 150, maxWidth: 180),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'transfer',
                      child: Row(
                        children: [
                          Icon(Icons.swap_horiz, size: 18, color: walletColor),
                          const SizedBox(width: 8),
                          const Text('Transfer'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18, color: walletColor),
                          const SizedBox(width: 8),
                          const Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18, color: Colors.red[400]),
                          const SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red[400])),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    final appState = Provider.of<AppState>(context, listen: false);
                    final walletService = WalletService(appState: appState);

                    switch (value) {
                      case 'transfer':
                      // Handle transfer
                        break;
                      case 'edit':
                      // Navigate to edit screen
                        break;
                      case 'delete':
                      // Show confirmation dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Wallet'),
                            content: Text('Are you sure you want to delete "${wallet.name}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('CANCEL'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  walletService.delete(wallet.id);
                                },
                                child: Text('DELETE', style: TextStyle(color: Colors.red[600])),
                              ),
                            ],
                          ),
                        );
                        break;
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}