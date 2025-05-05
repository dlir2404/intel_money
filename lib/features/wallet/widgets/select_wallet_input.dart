import 'package:flutter/material.dart';
import '../../../core/models/wallet.dart';
import '../../../core/state/app_state.dart';
import '../screens/select_wallet_screen.dart';

class SelectWalletInput extends StatefulWidget {
  final String placeholder;
  final Function(Wallet) onWalletSelected;

  const SelectWalletInput({
    super.key,
    required this.placeholder,
    required this.onWalletSelected,
  });

  @override
  State<SelectWalletInput> createState() => _SelectWalletInputState();
}

class _SelectWalletInputState extends State<SelectWalletInput> {
  Wallet _wallet = AppState().defaultWallet;

  void _navigateToSelectWallet() async {
    final selectedWallet = await Navigator.push<Wallet>(
      context,
      MaterialPageRoute(
        builder: (context) => SelectWalletScreen(selectedWallet: _wallet),
      ),
    );

    if (selectedWallet != null) {
      setState(() {
        _wallet = selectedWallet;
      });
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
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _wallet.icon.color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _wallet.icon.icon,
                color: _wallet.icon.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _wallet.name,
                style: TextStyle(
                  color: Colors.black,
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
