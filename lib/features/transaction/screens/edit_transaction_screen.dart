import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/models/category.dart';
import '../../../core/models/related_user.dart';
import '../../../core/models/transaction.dart';
import '../../../core/models/wallet.dart';
import '../../../shared/component/input/date_input.dart';
import '../../../shared/component/input/form_input.dart';
import '../../../shared/component/input/main_input.dart';
import '../../../shared/const/enum/transaction_type.dart';
import '../../../shared/helper/toast.dart';
import '../../category/widgets/select_category_input.dart';
import '../../related_user/widgets/select_related_user_input.dart';
import '../../wallet/widgets/select_wallet_input.dart';
import '../controller/transaction_controller.dart';
import '../widgets/create_transaction_appbar.dart';
import '../widgets/input_image.dart';

class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late TransactionType _transactionType;
  late double _amount;
  late Category? _category;
  late Wallet _sourceWallet;
  late Wallet? _destinationWallet;
  late DateTime _transactionDate;

  late dynamic _image;

  late RelatedUser? _borrower;
  late RelatedUser? _lender;

  bool _isLoading = false;

  final TextEditingController _descriptionController = TextEditingController();

  final TransactionController _transactionController = TransactionController();

  @override
  void initState() {
    super.initState();
    _transactionType = widget.transaction.type;
    _amount = widget.transaction.amount;
    _category = widget.transaction.category;
    _sourceWallet = widget.transaction.sourceWallet;
    _transactionDate = widget.transaction.transactionDate;
    _image = (widget.transaction.image != null && widget.transaction.image!.isNotEmpty)
        ? widget.transaction.image
        : null;
    if (widget.transaction is LendTransaction) {
      _borrower = (widget.transaction as LendTransaction).borrower;
    } else if (widget.transaction is BorrowTransaction) {
      _lender = (widget.transaction as BorrowTransaction).lender;
    } else if (widget.transaction is TransferTransaction) {
      _destinationWallet = (widget.transaction as TransferTransaction).destinationWallet;
    }
  }

  void _saveTransaction() {
    setState(() {
      _isLoading = true;
    });

    // Simulate a save operation
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context, widget.transaction);
    });
  }

  void _deleteTransaction() async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this transaction? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _transactionController.deleteTransaction(widget.transaction.id);

        if (mounted) {
          Navigator.pop(context);
          AppToast.showSuccess(context, "Transaction deleted successfully");
        }
      } catch (e) {
        if (mounted) {
          AppToast.showError(context, e.toString());
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CreateTransactionAppbar(
        isLoading: _isLoading,
        selectedTransactionType: _transactionType,
        onSave: _saveTransaction,
        selectable: false,
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

              if (_transactionType == TransactionType.income ||
                  _transactionType == TransactionType.expense ||
                  _transactionType == TransactionType.lend ||
                  _transactionType == TransactionType.borrow)
                Column(
                  children: [
                    SelectCategoryInput(
                      category: _category,
                      placeholder: 'Select Category',
                      categoryType: _transactionType.categoryType,
                      onCategorySelected: (category) {
                        setState(() {
                          _category = category;
                        });
                      },
                      showChildren: true,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              if (_transactionType == TransactionType.lend)
                Column(
                  children: [
                    SelectRelatedUserInput(
                      placeholder: 'Borrower',
                      relatedUser: _borrower,
                      onRelatedUserSelected: (user) {
                        setState(() {
                          _borrower = user;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              if (_transactionType == TransactionType.borrow)
                Column(
                  children: [
                    SelectRelatedUserInput(
                      placeholder: 'Lender',
                      relatedUser: _lender,
                      onRelatedUserSelected: (user) {
                        setState(() {
                          _lender = user;
                        });
                      },
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

              if (_transactionType == TransactionType.transfer)
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
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton.icon(
                      onPressed: () => _deleteTransaction(),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      label: const Text(
                        "Delete Transaction",
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  Expanded(
                    flex: 1,
                    child: ElevatedButton.icon(
                      onPressed: _saveTransaction,
                      icon: const Icon(Icons.save, color: Colors.white,),
                      label: const Text("Save Transaction"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      )
    );
  }
}
