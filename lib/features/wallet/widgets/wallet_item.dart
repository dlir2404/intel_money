import 'package:flutter/material.dart';

import '../../../core/models/wallet.dart';
import '../../../shared/const/icons/wallet_icon.dart';

class WalletItem extends StatelessWidget {
  final Wallet wallet;
  final void Function(Wallet) onTap;
  final bool showContextMenu;
  final Widget? trailing;

  const WalletItem({
    super.key,
    required this.wallet,
    required this.onTap,
    this.showContextMenu = false,
    this.trailing,
  });

  PopupMenuButton _buildContextMenu() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
      padding: EdgeInsets.zero,
      offset: const Offset(0, 40),
      constraints: const BoxConstraints(minWidth: 150, maxWidth: 180),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder:
          (context) => [
            PopupMenuItem<String>(
              value: 'transfer',
              child: Row(
                children: [
                  Icon(Icons.swap_horiz, size: 18),
                  const SizedBox(width: 8),
                  const Text('Transfer'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 18),
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
        // Handle context menu actions here
        switch (value) {
          case 'transfer':
            // Handle transfer action
            break;
          case 'edit':
            // Handle edit action
            break;
          case 'delete':
            // Handle delete action
            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final icon = WalletIcon.getIcon(wallet.icon);

    return Container(
      margin: EdgeInsets.only(bottom: 10),
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
            onTap(wallet);
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
                    color: icon.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon.icon, color: icon.color, size: 24),
                ),
                const SizedBox(width: 16),

                // Wallet Name
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
                      Text(
                        wallet.balance.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              wallet.balance >= 0
                                  ? Colors.green[600]
                                  : Colors.red[600],
                        ),
                      ),
                    ],
                  ),
                ),

                if (showContextMenu) _buildContextMenu(),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
