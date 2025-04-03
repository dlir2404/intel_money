import 'package:flutter/material.dart';
import 'package:intel_money/core/services/wallet_service.dart';
import 'package:intel_money/core/state/app_state.dart';
import 'package:intel_money/shared/component/input/main_input.dart';
import 'package:intel_money/shared/helper/toast.dart';
import 'package:provider/provider.dart';

import '../../../core/services/ad_service.dart';

class CreateWalletScreen extends StatefulWidget {
  const CreateWalletScreen({Key? key}) : super(key: key);

  @override
  State<CreateWalletScreen> createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends State<CreateWalletScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedIcon = "wallet"; // Default icon
  late final WalletService _walletService;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _walletService = WalletService(appState: appState);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Wallet'),
          elevation: 0,
        ),
        body: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Create New Wallet',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Set up your wallet details below',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),

                // Icon selection
                _buildIconSelector(),
                const SizedBox(height: 25),

                // Wallet name
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Wallet Name',
                    hintText: 'Enter wallet name',
                    prefixIcon: const Icon(Icons.account_balance_wallet),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),

                const SizedBox(height: 20),

                // Initial amount
                MainInput(
                  label: 'Initial Amount',
                  hint: 'Enter initial amount',
                  controller: _amountController,
                  currency: '\$',
                  onChanged: (value) {
                    // Handle amount changes if needed
                  },
                ),

                const SizedBox(height: 20),

                // Description
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'Add some notes about this wallet',
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  maxLines: 3,
                ),

                const SizedBox(height: 40),

                // Create button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _createWallet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Create Wallet',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconSelector() {
    final icons = [
      {'icon': Icons.account_balance_wallet, 'name': 'wallet'},
      {'icon': Icons.savings, 'name': 'savings'},
      {'icon': Icons.credit_card, 'name': 'card'},
      {'icon': Icons.currency_exchange, 'name': 'exchange'},
      {'icon': Icons.shopping_bag, 'name': 'shopping'},
      {'icon': Icons.attach_money, 'name': 'money'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Icon',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 70,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: icons.map((iconData) {
              final bool isSelected = _selectedIcon == iconData['name'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIcon = iconData['name'] as String;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 15),
                  width: 60,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor.withOpacity(0.2)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    iconData['icon'] as IconData,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[600],
                    size: 28,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _createWallet() {
    // Validate inputs
    if (_nameController.text.isEmpty) {
      AppToast.showError(context, 'Please enter a wallet name');
      return;
    }

    if (_amountController.text.isEmpty) {
      AppToast.showError(context, 'Please enter an initial amount');
      return;
    }

    // Parse initial amount
    double initialAmount = double.tryParse(_amountController.text) ?? 0;

    _walletService.create(
      _nameController.text,
      _descriptionController.text,
      _selectedIcon, // Use the selected icon instead of "test icon"
      initialAmount,
    ).then((_) {
      if (mounted) {
        AdService().showInterstitialAd();

        AppToast.showSuccess(context, "Wallet created successfully");
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      }
    }).catchError((error) {
      if (mounted) {
        AppToast.showError(context, error.toString());
      }
    });
  }
}