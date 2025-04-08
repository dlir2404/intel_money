import 'package:flutter/material.dart';
import 'package:intel_money/features/transaction/widgets/create_transaction_appbar.dart';
import 'package:intel_money/features/wallet/widgets/select_wallet_input.dart';
import 'package:intel_money/shared/component/input/date_input.dart';
import 'package:intel_money/shared/component/input/main_input.dart';
import 'package:intel_money/shared/const/enum/category_type.dart';
import 'package:intel_money/shared/helper/toast.dart';

import '../../../core/models/category.dart';
import '../../../core/models/wallet.dart';
import '../../../shared/component/input/form_input.dart';
import '../../category/widgets/select_category_input.dart';

class CreateTransactionScreen extends StatefulWidget {
  const CreateTransactionScreen({super.key});

  @override
  State<CreateTransactionScreen> createState() =>
      _CreateTransactionScreenState();
}

class _CreateTransactionScreenState extends State<CreateTransactionScreen> {
  CategoryType _selectedCategoryType = CategoryType.expense;
  final TextEditingController _amountController = TextEditingController();
  Category? _selectedCategory;
  Wallet? _sourceWallet;
  DateTime? _transactionDate;
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = false;

  Future<void> _saveTransaction() async {
    if (_amountController.text.isEmpty) {
      AppToast.showError(context, 'Please enter an amount');
      return;
    }
    if (_selectedCategory == null) {
      AppToast.showError(context, 'Please select a category');
      return;
    }
    if (_sourceWallet == null) {
      AppToast.showError(context, 'Please select a wallet');
      return;
    }
    if (_transactionDate == null) {
      AppToast.showError(context, 'Please select a transaction date');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Call your transaction service to save the transaction here
    Future.delayed(const Duration(seconds: 2), () {
      // Simulate a network call
      setState(() {
        _isLoading = false;
      });
      AppToast.showSuccess(context, 'Transaction created successfully');
    });

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CreateTransactionAppbar(
        isLoading: _isLoading,
        selectedCategoryType: _selectedCategoryType,
        onCategoryTypeChanged: (categoryType) {
          setState(() {
            _selectedCategoryType = categoryType;
          });
        },
        onSave: _saveTransaction,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MainInput(
                controller: _amountController,
                label: 'Amount',
                currency: '\$',
              ),
              const SizedBox(height: 16),

              SelectCategoryInput(
                category: _selectedCategory,
                placeholder: 'Select Category',
                categoryType: _selectedCategoryType,
                onCategorySelected: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
              ),
              const SizedBox(height: 16),

              SelectWalletInput(
                wallet: _sourceWallet,
                placeholder: "Select Wallet",
                onWalletSelected: (wallet) {
                  setState(() {
                    _sourceWallet = wallet;
                  });
                },
              ),
              const SizedBox(height: 16),

              DateInput(
                placeholder: 'Transaction Date',
                onDateSelected: (DateTime date) {
                  setState(() {
                    _transactionDate = date;
                  });
                },
              ),
              const SizedBox(height: 16),

              FormInput(
                label: 'Description (Optional)',
                controller: _descriptionController,
                placeholder: 'Add some notes about this transaction',
                maxLines: 3,
                prefixIcon: const Icon(Icons.description),
              ),
              const SizedBox(height: 16),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 2.0,
                            ),
                          )
                          : const Text(
                            'Save transaction',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
