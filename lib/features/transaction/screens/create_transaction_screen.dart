import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intel_money/core/models/scan_receipt_response.dart';
import 'package:intel_money/core/network/api_exception.dart';
import 'package:intel_money/features/transaction/screens/take_picture_screen.dart';
import 'package:intel_money/features/transaction/widgets/create_transaction_appbar.dart';
import 'package:intel_money/features/transaction/widgets/transaction_image.dart';
import 'package:intel_money/features/wallet/widgets/select_wallet_input.dart';
import 'package:intel_money/shared/component/input/date_input.dart';
import 'package:intel_money/shared/component/input/main_input.dart';
import 'package:intel_money/shared/const/enum/category_type.dart';
import 'package:intel_money/shared/const/enum/transaction_type.dart';
import 'package:intel_money/shared/helper/toast.dart';
import 'package:provider/provider.dart';

import '../../../core/models/category.dart';
import '../../../core/models/wallet.dart';
import '../../../core/services/transaction_service.dart';
import '../../../core/state/app_state.dart';
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
  double _amount = 0;
  Category? _selectedCategory;
  Wallet? _sourceWallet;
  DateTime? _transactionDate;
  final TextEditingController _descriptionController = TextEditingController();
  File? _image;

  bool _isLoading = false;
  late final TransactionService _transactionService = TransactionService();

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

    try {
      final List<File> images = [];
      if (_image != null) {
        images.add(_image!);
      }

      await _transactionService.createTransaction(
        _selectedTransactionType,
        _amount,
        _selectedCategory!.id,
        _descriptionController.text,
        _transactionDate ?? DateTime.now(),
        _sourceWallet!.id,
        false,
        images,
      );

      AppToast.showSuccess(context, 'Saved');
    } catch (e) {
      if (e is ApiException) {
        AppToast.showError(context, e.message);
      } else {
        AppToast.showError(context, 'An error occurred while saving the transaction');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _scanReceipt() async {
    final TakePictureResponse result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TakePictureScreen(
              processImage: (CroppedFile image) async {
                return await TransactionController.extractTransactionDataFromImage(
                  image,
                );
              },
            ),
      ),
    );

    setState(() {
      //scan bill is only for expense transaction
      _selectedTransactionType = TransactionType.expense;
      _image = result.receiptImage;

      //if extracted data is not null
      if (result.extractedData != null) {
        _amount = result.extractedData?.amount ?? 0;
        _selectedCategory = result.extractedData!.category;
        _sourceWallet = result.extractedData!.sourceWallet;
        _transactionDate = result.extractedData!.date;
        _descriptionController.text = result.extractedData!.description ?? '';
      }
    });
  }

  @override
  void initState() {
    super.initState();

    // Get arguments if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      final appState = Provider.of<AppState>(context, listen: false);
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
                initialValue: _amount,
                controller: _amountController,
                onChanged: (String newValue) {
                  setState(() {
                    _amount = double.tryParse(newValue) ?? 0;
                  });
                },
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
