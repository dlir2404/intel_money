import 'package:flutter/material.dart';
import 'package:intel_money/core/state/wallet_state.dart';
import 'package:intel_money/shared/component/filters/list_item_filter.dart';
import 'package:provider/provider.dart';

import '../../../core/models/wallet.dart';
import '../../../shared/component/typos/currency_double_text.dart';

class FilterWalletScreen extends StatefulWidget {
  final List<Wallet>? selectedWallets;
  const FilterWalletScreen({super.key, required this.selectedWallets});

  @override
  State<FilterWalletScreen> createState() => _FilterWalletScreenState();
}

class _FilterWalletScreenState extends State<FilterWalletScreen> {
  List<Wallet>? _selectedWallets;

  @override
  void initState() {
    super.initState();
    _selectedWallets = widget.selectedWallets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn ví'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.of(context).pop(_selectedWallets);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<WalletState>(
              builder: (context, state, _) {
                final allWallets = state.wallets;

                return ListItemFilter(
                  items: allWallets,
                  selectedItems: widget.selectedWallets,
                  getItemName: (item) => item.name,
                  onSelectionChanged: (selectedItems) {
                    setState(() {
                      _selectedWallets = selectedItems;
                    });
                  },
                  itemBuilder: (context, item, isSelected) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical:  8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Icon
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: item.icon.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(item.icon.icon, color: item.icon.color, size: 24),
                          ),
                          const SizedBox(width: 16),

                          // Wallet Name
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                CurrencyDoubleText(
                                  value: item.balance,
                                  color: item.balance >= 0 ? Colors.green[600] : Colors.red[600],
                                  fontSize: 16,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(_selectedWallets);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Xác nhận'),
            ),
          ),
        ],
      ),
    );
  }
}
