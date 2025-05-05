import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intel_money/core/models/scan_receipt_response.dart';
import 'package:intel_money/core/network/api_exception.dart';
import 'package:intel_money/features/transaction/screens/take_picture_screen.dart';
import 'package:intel_money/features/transaction/widgets/create_transaction_appbar.dart';
import 'package:intel_money/features/wallet/widgets/select_wallet_input.dart';
import 'package:intel_money/shared/component/input/date_input.dart';
import 'package:intel_money/shared/component/input/main_input.dart';
import 'package:intel_money/shared/const/enum/category_type.dart';
import 'package:intel_money/shared/const/enum/transaction_type.dart';
import 'package:intel_money/shared/helper/toast.dart';

import '../../../core/models/category.dart';
import '../../../core/models/wallet.dart';
import '../../../core/services/transaction_service.dart';
import '../../../core/state/wallet_state.dart';
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
  double _amount = 0;
  Category? _selectedCategory;
  Wallet? _sourceWallet;
  Wallet? _destinationWallet;
  DateTime? _transactionDate = DateTime.now();
  final TextEditingController _descriptionController = TextEditingController();
  File? _image;

  bool _isLoading = false;

  void _clearFields() {
    setState(() {
      _amount = 0;
      _selectedCategory = null;
      _destinationWallet = null;
      _transactionDate = DateTime.now();
      _descriptionController.clear();
      _image = null;
    });
  }

  Future<void> _saveTransaction() async {
    if (_amount <= 0) {
      AppToast.showError(context, 'Amount must be greater than 0');
      return;
    }
    if ((_selectedTransactionType == TransactionType.expense || _selectedTransactionType == TransactionType.income) && _selectedCategory == null) {
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

    if (_selectedTransactionType == TransactionType.transfer && _destinationWallet == null){
      AppToast.showError(context, "Please choose a destination wallet");
      return;
    }
    if (_selectedTransactionType == TransactionType.transfer && _sourceWallet == _destinationWallet){
      AppToast.showError(context, "Source wallet and destination wallet can not be the same");
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

      await TransactionService().createTransaction(
        transactionType: _selectedTransactionType,
        amount: _amount,
        categoryId: _selectedCategory?.id,
        description: _descriptionController.text,
        transactionDate: _transactionDate ?? DateTime.now(),
        sourceWalletId: _sourceWallet!.id,
        destinationWalletId: _destinationWallet?.id,
        notAddToReport: false,
        images: images,
      );

      AppToast.showSuccess(context, 'Saved');

      // Clear fields after saving
      _clearFields();
    } catch (e) {
      if (e is ApiException) {
        AppToast.showError(context, e.message);
      } else {
        AppToast.showError(
          context,
          'An error occurred while saving the transaction',
        );
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
        _sourceWallet = result.extractedData!.sourceWallet ?? WalletState().defaultWallet;
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
                initialValue: _amount,
                onChanged: (double newValue) {
                  setState(() {
                    _amount = newValue;
                  });
                },
                label: 'Amount',
              ),
              const SizedBox(height: 16),

              if (_selectedTransactionType == TransactionType.income ||
                  _selectedTransactionType == TransactionType.expense)
                Column(
                  children: [
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
                  ],
                ),

              SelectWalletInput(
                placeholder: "Select Source Wallet",
                onWalletSelected: (wallet) {
                  setState(() {
                    _sourceWallet = wallet;
                  });
                },
              ),
              const SizedBox(height: 16),

              if (_selectedTransactionType == TransactionType.transfer)
                Column(
                  children: [
                    SelectWalletInput(
                      placeholder: "Select Destination Wallet",
                      onWalletSelected: (wallet) {
                        setState(() {
                          _destinationWallet = wallet;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

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
