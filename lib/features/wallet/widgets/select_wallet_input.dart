import 'package:flutter/material.dart';
import 'package:intel_money/core/state/wallet_state.dart';
import '../../../core/models/wallet.dart';
import '../screens/select_wallet_screen.dart';
import '../../../shared/const/icons/wallet_icon.dart';

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
  Wallet? _wallet;
  final WalletState _walletState = WalletState();

  @override
  void initState() {
    super.initState();
    _wallet = _walletState.defaultWallet;
    _walletState.addListener(_onWalletStateChanged);
  }

  @override
  void dispose() {
    _walletState.removeListener(_onWalletStateChanged);
    super.dispose();
  }

  void _onWalletStateChanged() {
    if (mounted) {
      setState(() {
        // Only update if we're using the default wallet (not a custom selection)
        if (_wallet == null || _wallet == _walletState.defaultWallet) {
          _wallet = _walletState.defaultWallet;
        }
      });
    }
  }

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
                color:
                    _wallet?.icon.color.withOpacity(0.15) ??
                    Colors.grey.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _wallet?.icon.icon ?? WalletIcon.defaultIcon().icon,
                color: _wallet?.icon.color ?? Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _wallet?.name ?? widget.placeholder,
                style: TextStyle(
                  color: _wallet == null ? Colors.grey : Colors.black,
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
