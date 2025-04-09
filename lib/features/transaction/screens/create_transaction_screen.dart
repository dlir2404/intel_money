import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intel_money/core/models/scan_receipt_response.dart';
import 'package:intel_money/features/transaction/screens/take_picture_screen.dart';
import 'package:intel_money/features/transaction/widgets/create_transaction_appbar.dart';
import 'package:intel_money/features/transaction/widgets/transaction_image.dart';
import 'package:intel_money/features/wallet/widgets/select_wallet_input.dart';
import 'package:intel_money/shared/component/input/date_input.dart';
import 'package:intel_money/shared/component/input/main_input.dart';
import 'package:intel_money/shared/const/enum/category_type.dart';
import 'package:intel_money/shared/const/enum/transaction_type.dart';
import 'package:intel_money/shared/helper/toast.dart';

import '../../../core/models/category.dart';
import '../../../core/models/wallet.dart';
import '../../../shared/component/input/form_input.dart';
import '../../category/widgets/select_category_input.dart';
import '../controller/transaction_controller.dart';
import '../widgets/input_image.dart';

class CreateTransactionScreen extends StatefulWidget {
  const CreateTransactionScreen({super.key});

  @override
  State<CreateTransactionScreen> createState() =>
      _CreateTransactionScreenState();
}

class _CreateTransactionScreenState extends State<CreateTransactionScreen> {
  TransactionType _selectedTransactionType = TransactionType.expense;
  final TextEditingController _amountController = TextEditingController();
  Category? _selectedCategory;
  Wallet? _sourceWallet;
  DateTime? _transactionDate;
  final TextEditingController _descriptionController = TextEditingController();
  File? _image;

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

  Future<void> _scanReceipt() async {
    final TakePictureResponse result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TakePictureScreen(
        processImage: (CroppedFile image) async {
          return await TransactionController.extractTransactionDataFromImage(image);
        },
      )),
    );

    setState(() {
      print('>>>>>>>>>>>>> before: $_image');
      //scan bill is only for expense transaction
      _selectedTransactionType = TransactionType.expense;
      _image = result.receiptImage;

      print('>>>>>>>>>>>>> after: $_image');


      //if extracted data is not null
      if (result.extractedData != null){
        _amountController.text = result.extractedData!.amount.toString();
        _selectedCategory = result.extractedData!.category;
        _sourceWallet = result.extractedData!.sourceWallet;
        _transactionDate = result.extractedData!.date;
        _descriptionController.text = result.extractedData!.description ?? '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CreateTransactionAppbar(
        isLoading: _isLoading,
        selectedTransactionType: _selectedTransactionType,
        onTransactionTypeChanged: (transactionType) {
          setState(() {
            _selectedTransactionType = transactionType;
          });
        },
        onSave: _saveTransaction,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'scan_receipt',
            onPressed: () => _scanReceipt(),
            elevation: 4.0,
            shape: const CircleBorder(),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            child: const Icon(Icons.camera_alt_outlined),
          ),

          const SizedBox(height: 60),
        ],
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
                categoryType:
                    _selectedTransactionType == TransactionType.expense
                        ? CategoryType.expense
                        : CategoryType.income,
                onCategorySelected: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                showChildren: true,
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
                selectedDate: _transactionDate,
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

              InputImage(
                image: _image,
                onImageSelected: (File image) {
                  setState(() {
                    _image = image;
                  });
                },
                onImageRemoved: () {
                  setState(() {
                    _image = null;
                  });
                },
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

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
