import 'package:flutter/material.dart';
import 'package:intel_money/features/wallet/controller/wallet_controller.dart';

import '../../../core/models/wallet.dart';
import '../screens/select_wallet_screen.dart';

class SelectWalletInput extends StatefulWidget {
  final String placeholder;
  final Wallet? wallet;
  final Function(Wallet?) onWalletSelected;

  const SelectWalletInput({
    super.key,
    required this.placeholder,
    this.wallet,
    required this.onWalletSelected,
  });

  @override
  State<SelectWalletInput> createState() => _SelectWalletInputState();
}

class _SelectWalletInputState extends State<SelectWalletInput> {
  void _navigateToSelectWallet() async {
    final selectedCategory = await Navigator.push<Wallet>(
      context,
      MaterialPageRoute(
        builder:
            (context) => SelectWalletScreen(
          selectedWallet: widget.wallet,
        ),
      ),
    );

    if (selectedCategory != null) {
      widget.onWalletSelected(selectedCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _navigateToSelectWallet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: WalletController.getIconColor(
                  widget.wallet?.icon ?? '',
                ).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                WalletController.getWalletIcon(widget.wallet?.icon ?? ''),
                color: WalletController.getIconColor(widget.wallet?.icon ?? ''),
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.wallet?.name ?? widget.placeholder,
                style: TextStyle(
                  color: widget.wallet == null ? Colors.grey : Colors.black,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
          ],
        ),
      ),
    );;
  }
}
