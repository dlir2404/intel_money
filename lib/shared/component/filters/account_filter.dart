import 'package:flutter/material.dart';
import 'package:intel_money/core/models/wallet.dart';

import '../../../features/wallet/screens/filter_wallet_screen.dart';

class AccountFilter extends StatefulWidget {
  final List<Wallet>? selectedWallets;
  final Function(List<Wallet>?) onSelectionChanged;

  const AccountFilter({
    super.key,
    this.selectedWallets,
    required this.onSelectionChanged,
  });

  @override
  State<AccountFilter> createState() => _AccountFilterState();
}

class _AccountFilterState extends State<AccountFilter> {
  List<Wallet>? _selectedWallets;

  @override
  void initState() {
    super.initState();
    _selectedWallets = widget.selectedWallets;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final wallets = await Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => FilterWalletScreen(
                  selectedWallets:
                      _selectedWallets, // Pass null to use the default wallet state
                ),
          ),
        );

        widget.onSelectionChanged(wallets);
        setState(() {
          _selectedWallets = wallets;
        });
      },
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet, color: Colors.grey[400]),
            const SizedBox(width: 8),

            _selectedWallets == null
                ? Text('Tất cả ví', style: const TextStyle(fontSize: 16))
                : Text(
                  _selectedWallets!.isEmpty
                      ? 'Không chọn ví nào'
                      : _selectedWallets!.length > 2
                      ? '${_selectedWallets![0].name}, ${_selectedWallets![1].name}, +${_selectedWallets!.length - 2} more'
                      : _selectedWallets!
                          .map((wallet) => wallet.name)
                          .join(', '),
                  style: const TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
            const SizedBox(width: 8),
            Expanded(child: const SizedBox()),

            Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
