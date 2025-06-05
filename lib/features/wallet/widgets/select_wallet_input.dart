import 'package:flutter/material.dart';
import '../../../core/models/wallet.dart';
import '../../../shared/const/icons/wallet_icon.dart';
import '../screens/select_wallet_screen.dart';

class SelectWalletInput extends StatefulWidget {
  final String placeholder;
  final Wallet? wallet;
  final Function(Wallet) onWalletSelected;

  const SelectWalletInput({
    super.key,
    required this.placeholder,
    required this.onWalletSelected,
    this.wallet,
  });

  @override
  State<SelectWalletInput> createState() => _SelectWalletInputState();
}

class _SelectWalletInputState extends State<SelectWalletInput> {
  void _navigateToSelectWallet() async {
    final selectedWallet = await Navigator.push<Wallet>(
      context,
      MaterialPageRoute(
        builder: (context) => SelectWalletScreen(selectedWallet: widget.wallet),
      ),
    );

    if (selectedWallet != null) {
      widget.onWalletSelected(selectedWallet);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _navigateToSelectWallet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                    widget.wallet?.icon.color.withOpacity(0.15) ??
                    Colors.grey.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.wallet?.icon.icon ?? WalletIcon.defaultIcon().icon,
                color: widget.wallet?.icon.color ?? Colors.grey,
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
    );
  }
}
