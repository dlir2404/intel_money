import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/models/category.dart';
import '../../../core/models/related_user.dart';
import '../../../core/models/transaction.dart';
import '../../../core/models/wallet.dart';
import '../../../core/services/ad_service.dart';
import '../../../shared/component/input/date_input.dart';
import '../../../shared/component/input/different_input.dart';
import '../../../shared/component/input/form_input.dart';
import '../../../shared/component/input/main_input.dart';
import '../../../shared/const/enum/category_type.dart';
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
  Wallet? _destinationWallet;
  late DateTime _transactionDate;

  late dynamic _image;

  RelatedUser? _borrower;
  RelatedUser? _lender;

  late double _currentBalance;
  late double _newRealBalance;

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
    _image =
        (widget.transaction.image != null &&
                widget.transaction.image!.isNotEmpty)
            ? widget.transaction.image
            : null;

    _currentBalance = 0;
    _newRealBalance = 0;
    if (widget.transaction is LendTransaction) {
      _borrower = (widget.transaction as LendTransaction).borrower;
    } else if (widget.transaction is BorrowTransaction) {
      _lender = (widget.transaction as BorrowTransaction).lender;
    } else if (widget.transaction is TransferTransaction) {
      _destinationWallet =
          (widget.transaction as TransferTransaction).destinationWallet;
    } else if (widget.transaction is ModifyBalanceTransaction) {
      _currentBalance =
          (widget.transaction as ModifyBalanceTransaction).newRealBalance -
          widget.transaction.amount;
      _newRealBalance =
          (widget.transaction as ModifyBalanceTransaction).newRealBalance;

      // getCurrentBalance();
    }
  }

  Future<void> _saveTransaction() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final newTransaction = await _transactionController.saveTransaction(
        oldTransaction: widget.transaction,
        amount: _amount,
        transactionType: _transactionType,
        sourceWallet: _sourceWallet,
        destinationWallet: _destinationWallet,
        transactionDate: _transactionDate,
        category: _category,
        description: _descriptionController.text,
        lender: _lender,
        borrower: _borrower,
        newRealBalance: _newRealBalance,
        difference: _newRealBalance - _currentBalance,
        image: _image,
      );

      AdService().showAdIfEligible();
      if (mounted) {
        AppToast.showSuccess(context, 'Đã lưu');

        final returnData = {
          "updatedTransaction": newTransaction,
        };

        Navigator.pop(context, returnData);
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

  void _deleteTransaction() async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text(
            'Bạn có chắc muốn xóa giao dịch này? Hành động này không thể hoàn tác.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Xóa'),
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
        await _transactionController.deleteTransaction(widget.transaction);

        final returnData = {
          "removedTransaction": widget.transaction,
        };

        if (mounted) {
          Navigator.pop(context, returnData);
          AppToast.showSuccess(context, "Đã xóa giao dịch");
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

  void getCurrentBalance() {
    if (_transactionType != TransactionType.modifyBalance) {
      return;
    }

    final currentBalance = _transactionController.calculateBalanceAtDate(
      sourceWallet: _sourceWallet,
      date: _transactionDate,
      excludeTransaction: widget.transaction
    );

    if (_category != null) {
      if (_category!.type == CategoryType.income &&
          _newRealBalance - currentBalance < 0) {
        _category = null;
      } else if (_category!.type ==
          CategoryType.expense &&
          _newRealBalance - currentBalance > 0) {
        _category = null;
      }
    }

    setState(() {
      _currentBalance = currentBalance;
    });
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
              _transactionType != TransactionType.modifyBalance
                  ? MainInput(
                    initialValue: _amount,
                    onChanged: (double newValue) {
                      setState(() {
                        _amount = newValue;
                      });
                    },
                    label: 'Số tiền',
                  )
                  : DifferentInput(
                    oldValue: _currentBalance,
                    newValue: _newRealBalance,
                    oldLabel: 'Số dư trên tài khoản',
                    newLabel: 'Số dư thực tế',
                    onValueChanged: (double newValue) {
                      if (_category != null) {
                        if (_category!.type == CategoryType.income &&
                            newValue - _currentBalance < 0) {
                          _category = null;
                        } else if (_category!.type == CategoryType.expense &&
                            newValue - _currentBalance > 0) {
                          _category = null;
                        }
                      }

                      setState(() {
                        _newRealBalance = newValue;
                      });
                    },
                  ),
              const SizedBox(height: 16),

              if (_transactionType != TransactionType.transfer)
                Column(
                  children: [
                    SelectCategoryInput(
                      category: _category,
                      placeholder: 'Chọn danh mục',
                      categoryType:
                          _transactionType != TransactionType.modifyBalance
                              ? _transactionType.categoryType
                              : (_newRealBalance - _currentBalance) > 0
                              ? CategoryType.income
                              : CategoryType.expense,
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
                      placeholder: 'Người vay',
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
                      placeholder: 'Người cho vay',
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
                wallet: _sourceWallet,
                placeholder: "Chọn ví nguồn",
                onWalletSelected: (wallet) {
                  setState(() {
                    _sourceWallet = wallet;
                  });

                  getCurrentBalance();
                },
              ),
              const SizedBox(height: 16),

              if (_transactionType == TransactionType.transfer)
                Column(
                  children: [
                    SelectWalletInput(
                      wallet: _destinationWallet,
                      placeholder: "Chọn ví đích",
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
                placeholder: 'Thời gian',
                onDateSelected: (DateTime date) {
                  setState(() {
                    _transactionDate = date;
                  });

                  getCurrentBalance();
                },
              ),
              const SizedBox(height: 16),

              FormInput(
                label: 'Mô tả (tùy chọn)',
                controller: _descriptionController,
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
                    child:
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : OutlinedButton.icon(
                              onPressed: () => _deleteTransaction(),
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              label: const Text(
                                "Xóa",
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
                    child:
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton.icon(
                              onPressed: _saveTransaction,
                              icon: const Icon(Icons.save, color: Colors.white),
                              label: const Text("Lưu"),
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
      ),
    );
  }
}
