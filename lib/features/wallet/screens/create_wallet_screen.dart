import 'package:flutter/material.dart';
import 'package:intel_money/core/services/wallet_service.dart';
import 'package:intel_money/core/state/app_state.dart';
import 'package:intel_money/features/wallet/controller/wallet_controller.dart';
import 'package:intel_money/shared/component/input/main_input.dart';
import 'package:intel_money/shared/helper/toast.dart';
import 'package:provider/provider.dart';

import '../../../core/models/app_icon.dart';
import '../../../core/services/ad_service.dart';
import '../../../shared/component/input/form_input.dart';
import '../../../shared/const/icons/wallet_icon.dart';

class CreateWalletScreen extends StatefulWidget {
  const CreateWalletScreen({super.key});

  @override
  State<CreateWalletScreen> createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends State<CreateWalletScreen> {
  final _formKey = GlobalKey<FormState>();

  double initialAmount = 0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  AppIcon _selectedIcon = WalletIcon.defaultIcon(); // Default icon
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
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Create Wallet',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
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

                const Text(
                  'Wallet Name',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 10),
                FormInput(
                  controller: _nameController,
                  placeholder: 'Enter wallet name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a wallet name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Initial amount
                MainInput(
                  label: 'Initial Amount',
                  currency: '\$',
                  onChanged: (value) {
                    setState(() {
                      initialAmount = value;
                    });
                  },
                ),
                const SizedBox(height: 20),

                FormInput(
                  label: 'Description (Optional)',
                  controller: _descriptionController,
                  placeholder: 'Add some notes about this wallet',
                  maxLines: 3,
                  prefixIcon: const Icon(Icons.description),
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
    final icons = WalletIcon.icons;

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
            children: icons.map((icon) {
              final bool isSelected = _selectedIcon == icon;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIcon = icon;
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
                    icon.icon,
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _walletService.create(
      _nameController.text,
      _descriptionController.text,
      _selectedIcon.name, // Use the selected icon instead of "test icon"
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