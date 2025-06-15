import 'package:flutter/material.dart';
import 'package:intel_money/shared/component/typos/currency_double_text.dart';

import '../../../core/models/wallet.dart';
import '../../../shared/helper/toast.dart';
import '../controller/wallet_controller.dart';
import '../screens/edit_wallet_screen.dart';

class WalletItem extends StatelessWidget {
  final Wallet wallet;
  final void Function(Wallet) onTap;
  final bool showContextMenu;
  final Widget? trailing;

  WalletItem({
    super.key,
    required this.wallet,
    required this.onTap,
    this.showContextMenu = false,
    this.trailing,
  });

  final WalletController _walletController = WalletController();

  PopupMenuButton _buildContextMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
      padding: EdgeInsets.zero,
      offset: const Offset(0, 40),
      constraints: const BoxConstraints(minWidth: 150, maxWidth: 180),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder:
          (context) => [
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
          case 'edit':
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditWalletScreen(wallet: wallet),
              ),
            );
            break;
          case 'delete':
            _deleteWallet(context);
            break;
        }
      },
    );
  }

  void _deleteWallet(BuildContext context) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text(
            'Bạn có chắc muốn xóa ví này? Tất cả các giao dịch liên quan đều sẽ bị xóa. Hành động này không thể hoàn tác.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await _walletController.removeWallet(wallet);
        AppToast.showSuccess(context, "Đã xóa.");
      } catch (e) {
        AppToast.showError(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    color: wallet.icon.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    wallet.icon.icon,
                    color: wallet.icon.color,
                    size: 24,
                  ),
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
                      CurrencyDoubleText(
                        value: wallet.balance,
                        color:
                            wallet.balance >= 0
                                ? Colors.green[600]
                                : Colors.red[600],
                        fontSize: 16,
                      ),
                    ],
                  ),
                ),

                if (showContextMenu) _buildContextMenu(context),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
