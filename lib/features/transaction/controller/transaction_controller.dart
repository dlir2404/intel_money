import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intel_money/core/models/extract_transaction_info_response.dart';
import 'package:intel_money/core/models/transaction.dart';
import 'package:intel_money/core/services/ai_service.dart';
import 'package:intel_money/core/services/related_user_service.dart';
import 'package:intel_money/shared/helper/app_time.dart';

import '../../../core/models/category.dart';
import '../../../core/models/related_user.dart';
import '../../../core/models/scan_receipt_response.dart';
import '../../../core/models/statistic_data.dart';
import '../../../core/models/wallet.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/services/transaction_service.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/category_state.dart';
import '../../../core/state/related_user_state.dart';
import '../../../core/state/statistic_state.dart';
import '../../../core/state/transaction_state.dart';
import '../../../core/state/wallet_state.dart';
import '../../../shared/const/enum/transaction_data_source_type.dart';
import '../../../shared/const/enum/transaction_type.dart';

class TransactionController {
  static final TransactionController _instance =
      TransactionController._internal();

  factory TransactionController() => _instance;

  TransactionController._internal();

  final TransactionService _transactionService = TransactionService();
  final RelatedUserService _relatedUserService = RelatedUserService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final AppState _appState = AppState();
  final TransactionState _transactionState = TransactionState();
  final WalletState _walletState = WalletState();
  final StatisticState _statisticState = StatisticState();
  final RelatedUserState _relatedUserState = RelatedUserState();

  Future<List<Transaction>> getTransactions(
    Map<String, DateTime> timeRange,
  ) async {
    final transactions = await _transactionService.getTransactionsInTimeRange(
      from: timeRange["from"]!,
      to: timeRange["to"]!,
    );

    //we can cache later
    // _transactionState.setTransactionsByKey(type.keyStore, transactions);

    return transactions;
  }

  Future<List<Transaction>> getAllTransactions() async {
    final transactions = await _transactionService.getAllTransactions();

    _transactionState.setTransactions(transactions);
    return transactions;
  }

  static Future<TakePictureResponse> extractTransactionDataFromImage(
    CroppedFile image,
  ) async {
    //Scan text from image
    final inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText = await textRecognizer.processImage(
      inputImage,
    );
    final String scannedText = recognizedText.text;

    //call AI to extract
    final ExtractTransactionInfoResponse transInfo =
        await extractTransactionDataFromText(scannedText);

    Category? category;
    if (transInfo.categoryId != null && transInfo.categoryId != 0) {
      category = Category.fromContext(transInfo.categoryId!);
    }
    Wallet? wallet;
    if (transInfo.walletId != null && transInfo.walletId != 0) {
       wallet = Wallet.fromContext(transInfo.walletId);
    }

    return TakePictureResponse(
      receiptImage: File(image.path),
      extractedData: ExtractedData(
        amount: transInfo.amount,
        category: category,
        sourceWallet: wallet,
        date: transInfo.date,
        description: transInfo.description ?? scannedText,
      ),
    );
  }

  static Future<ExtractTransactionInfoResponse> extractTransactionDataFromText(
    String text,
  ) async {
    return extractTransactionOnline(text);
  }

  static Future<ExtractTransactionInfoResponse> extractTransactionOnline(
    String text,
  ) async {
    return await AIService().extractTransactionInfo(text);
  }

  static Map<String, dynamic> extractTransactionOffline(String text) {
    // This is a simple implementation - you'll need to improve this
    // based on the format of receipts you're expecting to scan

    final lines = text.split('\n');
    double? totalAmount;
    DateTime? date;
    String? storeName;

    // Try to find store name (usually at the top)
    if (lines.isNotEmpty) {
      storeName = lines[0];
    }

    // Look for date
    for (final line in lines) {
      // Simple regex for date formats like DD/MM/YYYY or YYYY-MM-DD
      RegExp dateRegex = RegExp(r'(\d{1,2}[/.-]\d{1,2}[/.-]\d{2,4})');
      final dateMatch = dateRegex.firstMatch(line);
      if (dateMatch != null) {
        try {
          // Try to parse the date - this is simplified
          final dateStr = dateMatch.group(0)!;
          // You'll need more robust date parsing logic based on your locale
          date = DateTime.parse(dateStr);
        } catch (e) {
          // Fallback to current date if parsing fails
          date = DateTime.now();
        }
      }
    }

    // Look for total amount
    for (final line in lines) {
      if (line.toLowerCase().contains('total') ||
          line.toLowerCase().contains('amount') ||
          line.toLowerCase().contains('sum')) {
        // Extract numbers from the line
        RegExp amountRegex = RegExp(r'(\d+[,.]\d+)');
        final amountMatch = amountRegex.firstMatch(line);
        if (amountMatch != null) {
          try {
            String amountStr = amountMatch.group(0)!;
            amountStr = amountStr.replaceAll(',', '.');
            totalAmount = double.parse(amountStr);
          } catch (e) {
            print('Error parsing amount: $e');
          }
        }
      }
    }

    return {
      'store': storeName ?? 'Unknown Store',
      'date': date ?? DateTime.now(),
      'amount': totalAmount ?? 0.0,
      'fullText': text,
    };
  }

  Future<void> createTransaction({
    required double amount,
    required TransactionType transactionType,
    required Wallet? sourceWallet,
    required Wallet? destinationWallet,
    required DateTime? transactionDate,
    required Category? category,
    required String? description,
    required RelatedUser? lender,
    required RelatedUser? borrower,
    required double? newRealBalance,
    required double? difference, //just use for validation
    required File? image,

    required DateTime? collectionDate,
    required DateTime? repaymentDate,
  }) async {
    _validateFields(
      amount: amount,
      transactionType: transactionType,
      sourceWallet: sourceWallet,
      destinationWallet: destinationWallet,
      transactionDate: transactionDate,
      category: category,
      description: description,
      lender: lender,
      borrower: borrower,
      newRealBalance: newRealBalance,
      difference: difference,
      image: image,
    );

    //create borrower if not exists
    if (transactionType == TransactionType.lend && borrower!.isTemporary) {
      await _relatedUserService.createFromTemp(borrower);
    }

    //create lender if not exists
    if (transactionType == TransactionType.borrow && lender!.isTemporary) {
      await _relatedUserService.createFromTemp(lender);
    }

    String imageUrl = '';
    if (image != null) {
      imageUrl = await _cloudinaryService.uploadImage(image.path);
    }

    Transaction newTransaction;

    switch (transactionType) {
      case TransactionType.expense:
        newTransaction = await _transactionService.createExpenseTransaction(
          amount: amount,
          categoryId: category!.id,
          description: description,
          transactionDate: transactionDate!,
          sourceWalletId: sourceWallet!.id,
          image: imageUrl,
          notAddToReport: false,
        );
        break;
      case TransactionType.income:
        newTransaction = await _transactionService.createIncomeTransaction(
          amount: amount,
          categoryId: category!.id,
          description: description,
          transactionDate: transactionDate!,
          sourceWalletId: sourceWallet!.id,
        );
        break;
      case TransactionType.transfer:
        newTransaction = await _transactionService.createTransferTransaction(
          amount: amount,
          transactionDate: transactionDate!,
          sourceWalletId: sourceWallet!.id,
          destinationWalletId: destinationWallet!.id,
        );
        break;
      case TransactionType.lend:
        newTransaction = await _transactionService.createLendTransaction(
          amount: amount,
          transactionDate: transactionDate!,
          sourceWalletId: sourceWallet!.id,
          categoryId: category!.id,
          borrowerId: borrower!.id!,
          collectionDate: collectionDate,
        );
        break;
      case TransactionType.collectingDebt:
        newTransaction = await _transactionService
            .createCollectingDebtTransaction(
              amount: amount,
              transactionDate: transactionDate!,
              sourceWalletId: sourceWallet!.id,
              categoryId: category!.id,
              borrowerId: borrower!.id!,
            );
        break;
      case TransactionType.borrow:
        newTransaction = await _transactionService.createBorrowTransaction(
          amount: amount,
          transactionDate: transactionDate!,
          sourceWalletId: sourceWallet!.id,
          categoryId: category!.id,
          lenderId: lender!.id!,
          repaymentDate: repaymentDate,
        );
        break;
      case TransactionType.repayment:
        newTransaction = await _transactionService.createRepaymentTransaction(
          amount: amount,
          transactionDate: transactionDate!,
          sourceWalletId: sourceWallet!.id,
          categoryId: category!.id,
          lenderId: lender!.id!,
        );
        break;
      case TransactionType.modifyBalance:
        newTransaction = await _transactionService
            .createModifyBalanceTransaction(
              newRealBalance: newRealBalance!,
              categoryId: category!.id,
              description: description,
              sourceWalletId: sourceWallet!.id,
              transactionDate: transactionDate!,
              image: imageUrl,
            );
    }

    updateStatesAfterCreateTransaction(newTransaction);
  }

  Future<Transaction> saveTransaction({
    required Transaction oldTransaction,
    required double amount,
    required TransactionType transactionType,
    required Wallet? sourceWallet,
    required Wallet? destinationWallet,
    required DateTime? transactionDate,
    required Category? category,
    required String? description,
    required RelatedUser? lender,
    required RelatedUser? borrower,
    required double? newRealBalance,
    required double? difference, //just use for validation
    required dynamic image,
  }) async {
    _validateFields(
      amount: amount,
      transactionType: transactionType,
      sourceWallet: sourceWallet,
      destinationWallet: destinationWallet,
      transactionDate: transactionDate,
      category: category,
      description: description,
      lender: lender,
      borrower: borrower,
      newRealBalance: newRealBalance,
      difference: difference,
      image: image,
    );

    //create borrower if not exists
    if (transactionType == TransactionType.lend && borrower!.isTemporary) {
      await _relatedUserService.createFromTemp(borrower);
    }

    //create lender if not exists
    if (transactionType == TransactionType.borrow && lender!.isTemporary) {
      await _relatedUserService.createFromTemp(lender);
    }

    String imageUrl = '';
    if (image != null) {
      if (image is File) {
        imageUrl = await _cloudinaryService.uploadImage(image.path);
      } else if (image is String) {
        // If image is a URL, we can use it directly
        imageUrl = image;
      }
    }

    Transaction newTransaction;

    switch (transactionType) {
      case TransactionType.expense:
        newTransaction = await _transactionService.updateExpenseTransaction(
          transactionId: oldTransaction.id,
          amount: amount,
          categoryId: category!.id,
          description: description,
          transactionDate: transactionDate!,
          sourceWalletId: sourceWallet!.id,
          image: imageUrl,
        );
        break;
      case TransactionType.income:
        newTransaction = await _transactionService.updateIncomeTransaction(
          transactionId: oldTransaction.id,
          amount: amount,
          categoryId: category!.id,
          description: description,
          transactionDate: transactionDate!,
          sourceWalletId: sourceWallet!.id,
        );
        break;
      case TransactionType.transfer:
        newTransaction = await _transactionService.updateTransferTransaction(
          transactionId: oldTransaction.id,
          amount: amount,
          transactionDate: transactionDate!,
          sourceWalletId: sourceWallet!.id,
          destinationWalletId: destinationWallet!.id,
        );
        break;
      case TransactionType.lend:
        newTransaction = await _transactionService.updateLendTransaction(
          transactionId: oldTransaction.id,
          amount: amount,
          transactionDate: transactionDate!,
          sourceWalletId: sourceWallet!.id,
          categoryId: category!.id,
          borrowerId: borrower!.id!,
        );
        break;
      case TransactionType.collectingDebt:
        newTransaction = await _transactionService
            .updateCollectingDebtTransaction(
              transactionId: oldTransaction.id,
              amount: amount,
              transactionDate: transactionDate!,
              sourceWalletId: sourceWallet!.id,
              categoryId: category!.id,
              borrowerId: borrower!.id!,
            );
        break;
      case TransactionType.borrow:
        newTransaction = await _transactionService.updateBorrowTransaction(
          transactionId: oldTransaction.id,
          amount: amount,
          transactionDate: transactionDate!,
          sourceWalletId: sourceWallet!.id,
          categoryId: category!.id,
          lenderId: lender!.id!,
        );
        break;
      case TransactionType.repayment:
        newTransaction = await _transactionService.updateRepaymentTransaction(
          transactionId: oldTransaction.id,
          amount: amount,
          transactionDate: transactionDate!,
          sourceWalletId: sourceWallet!.id,
          categoryId: category!.id,
          lenderId: lender!.id!,
        );
        break;
      case TransactionType.modifyBalance:
        newTransaction = await _transactionService
            .updateModifyBalanceTransaction(
              transactionId: oldTransaction.id,
              newRealBalance: newRealBalance!,
              categoryId: category!.id,
              description: description,
              sourceWalletId: sourceWallet!.id,
              transactionDate: transactionDate!,
              image: imageUrl,
            );
    }

    updateStatesAfterRemoveTransaction(oldTransaction);

    updateStatesAfterCreateTransaction(newTransaction);

    return newTransaction;
  }

  void _validateFields({
    required double amount,
    required TransactionType transactionType,
    required Wallet? sourceWallet,
    required Wallet? destinationWallet,
    required DateTime? transactionDate,
    required Category? category,
    required String? description,
    required RelatedUser? lender,
    required RelatedUser? borrower,
    required double? newRealBalance,
    required double? difference, //just use for validation
    required File? image,
  }) {
    if (transactionType != TransactionType.modifyBalance && amount <= 0) {
      throw TransactionException('Số tiền phải lớn hơn 0');
    }

    if ((transactionType != TransactionType.transfer) && category == null) {
      throw TransactionException('Vui lòng chọn danh mục');
    }

    if (sourceWallet == null) {
      throw TransactionException('Vui lòng chọn ví');
    }

    if (transactionDate == null) {
      throw TransactionException('Ngày giao dịch không được để trống');
    }

    if (transactionType == TransactionType.transfer &&
        destinationWallet == null) {
      throw TransactionException("Vui lòng chọn ví đích");
    }

    if (transactionType == TransactionType.transfer &&
        sourceWallet == destinationWallet) {
      throw TransactionException(
        "Ví nguồn và ví đích không thể giống nhau",
      );
    }

    if (transactionType == TransactionType.lend && borrower == null) {
      throw TransactionException("Vui lòng chọn người vay");
    }

    if (transactionType == TransactionType.borrow && lender == null) {
      throw TransactionException("Vui lòng chọn người cho vay");
    }

    if (transactionType == TransactionType.modifyBalance && difference == 0) {
      throw TransactionException("Chênh lệch phải khác 0");
    }
  }

  Future<void> deleteTransaction(Transaction transaction) async {
    await _transactionService.deleteTransaction(transaction.id);

    updateStatesAfterRemoveTransaction(transaction);
  }

  void updateStatesAfterCreateTransaction(Transaction newTransaction) {
    _transactionState.addTransaction(newTransaction);

    final mostSoonModifyBalanceTransaction =
        getMostSoonModifyBalanceTransactionAfterTransaction(
          transaction: newTransaction,
          sourceWallet: newTransaction.sourceWallet,
        );

    switch (newTransaction.type) {
      case TransactionType.expense:
        if (mostSoonModifyBalanceTransaction != null) {
          updateMostSoonModifyBalanceTransactionAfterCreateTransaction(
            transaction: newTransaction,
            mostSoonModifyBalanceTransaction:
                mostSoonModifyBalanceTransaction as ModifyBalanceTransaction,
          );
        } else {
          _appState.decreaseUserBalance(newTransaction.amount);
          _walletState.decreaseWalletBalance(
            newTransaction.sourceWallet.id,
            newTransaction.amount,
          );
        }
        break;
      case TransactionType.income:
        if (mostSoonModifyBalanceTransaction != null) {
          updateMostSoonModifyBalanceTransactionAfterCreateTransaction(
            transaction: newTransaction,
            mostSoonModifyBalanceTransaction:
                mostSoonModifyBalanceTransaction as ModifyBalanceTransaction,
          );
        } else {
          _appState.increaseUserBalance(newTransaction.amount);

          _walletState.increaseWalletBalance(
            newTransaction.sourceWallet.id,
            newTransaction.amount,
          );
        }
        break;
      case TransactionType.transfer:
        //REALLY SPECIAL CASE
        final mostSoonModifyBalanceTransactionOfSourceWallet =
            mostSoonModifyBalanceTransaction;
        final mostSoonModifyBalanceTransactionOfDestinationWallet =
            getMostSoonModifyBalanceTransactionAfterTransaction(
              transaction: newTransaction,
              sourceWallet:
                  (newTransaction as TransferTransaction).destinationWallet,
            );

        if (mostSoonModifyBalanceTransactionOfSourceWallet == null &&
            mostSoonModifyBalanceTransactionOfDestinationWallet == null) {
          _walletState.decreaseWalletBalance(
            newTransaction.sourceWallet.id,
            newTransaction.amount,
          );
          _walletState.increaseWalletBalance(
            newTransaction.destinationWallet.id,
            newTransaction.amount,
          );
        } else if (mostSoonModifyBalanceTransactionOfSourceWallet != null &&
            mostSoonModifyBalanceTransactionOfDestinationWallet == null) {
          _appState.increaseUserBalance(newTransaction.amount);

          updateMostSoonModifyBalanceTransactionAfterCreateTransaction(
            transaction: newTransaction,
            mostSoonModifyBalanceTransaction:
                mostSoonModifyBalanceTransactionOfSourceWallet
                    as ModifyBalanceTransaction,
          );
          _walletState.increaseWalletBalance(
            newTransaction.destinationWallet.id,
            newTransaction.amount,
          );
        } else if (mostSoonModifyBalanceTransactionOfSourceWallet == null &&
            mostSoonModifyBalanceTransactionOfDestinationWallet != null) {
          _appState.decreaseUserBalance(newTransaction.amount);

          _walletState.decreaseWalletBalance(
            newTransaction.sourceWallet.id,
            newTransaction.amount,
          );
          updateMostSoonModifyBalanceTransactionAfterCreateTransaction(
            transaction: newTransaction,
            mostSoonModifyBalanceTransaction:
                mostSoonModifyBalanceTransactionOfDestinationWallet
                    as ModifyBalanceTransaction,
          );
        } else {
          //both modify balance transactions exists
          updateMostSoonModifyBalanceTransactionAfterCreateTransaction(
            transaction: newTransaction,
            mostSoonModifyBalanceTransaction:
                mostSoonModifyBalanceTransactionOfSourceWallet
                    as ModifyBalanceTransaction,
          );
          updateMostSoonModifyBalanceTransactionAfterCreateTransaction(
            transaction: newTransaction,
            mostSoonModifyBalanceTransaction:
                mostSoonModifyBalanceTransactionOfDestinationWallet
                    as ModifyBalanceTransaction,
          );
        }

        break;
      case TransactionType.lend:
        if (mostSoonModifyBalanceTransaction != null) {
          updateMostSoonModifyBalanceTransactionAfterCreateTransaction(
            transaction: newTransaction,
            mostSoonModifyBalanceTransaction:
                mostSoonModifyBalanceTransaction as ModifyBalanceTransaction,
          );
        } else {
          _walletState.decreaseWalletBalance(
            newTransaction.sourceWallet.id,
            newTransaction.amount,
          );
        }

        //increase user total loan
        _appState.increaseUserTotalLoan(newTransaction.amount);

        //increase borrower total debt
        _relatedUserState.increaseRelatedUserTotalDebt(
          (newTransaction as LendTransaction).borrower.id!,
          newTransaction.amount,
        );
        break;
      case TransactionType.collectingDebt:
        if (mostSoonModifyBalanceTransaction != null) {
          updateMostSoonModifyBalanceTransactionAfterCreateTransaction(
            transaction: newTransaction,
            mostSoonModifyBalanceTransaction:
                mostSoonModifyBalanceTransaction as ModifyBalanceTransaction,
          );
        } else {
          _walletState.increaseWalletBalance(
            newTransaction.sourceWallet.id,
            newTransaction.amount,
          );
        }

        //decrease user total loan
        _appState.decreaseUserTotalLoan(newTransaction.amount);

        //increase borrower total collected
        _relatedUserState.increaseRelatedUserTotalCollected(
          (newTransaction as CollectingDebtTransaction).borrower.id!,
          newTransaction.amount,
        );
        break;
      case TransactionType.borrow:
        if (mostSoonModifyBalanceTransaction != null) {
          updateMostSoonModifyBalanceTransactionAfterCreateTransaction(
            transaction: newTransaction,
            mostSoonModifyBalanceTransaction:
                mostSoonModifyBalanceTransaction as ModifyBalanceTransaction,
          );
        } else {
          _walletState.increaseWalletBalance(
            newTransaction.sourceWallet.id,
            newTransaction.amount,
          );
        }

        //increase user total debt
        _appState.increaseUserTotalDebt(newTransaction.amount);

        //increase lender total loan
        _relatedUserState.increaseRelatedUserTotalLoan(
          (newTransaction as BorrowTransaction).lender.id!,
          newTransaction.amount,
        );
        break;
      case TransactionType.repayment:
        if (mostSoonModifyBalanceTransaction != null) {
          updateMostSoonModifyBalanceTransactionAfterCreateTransaction(
            transaction: newTransaction,
            mostSoonModifyBalanceTransaction:
                mostSoonModifyBalanceTransaction as ModifyBalanceTransaction,
          );
        } else {
          _walletState.decreaseWalletBalance(
            newTransaction.sourceWallet.id,
            newTransaction.amount,
          );
        }

        //decrease user total debt
        _appState.decreaseUserTotalDebt(newTransaction.amount);

        //decrease lender total paid
        _relatedUserState.increaseRelatedUserTotalPaid(
          (newTransaction as RepaymentTransaction).lender.id!,
          newTransaction.amount,
        );
        break;
      case TransactionType.modifyBalance:
        if (mostSoonModifyBalanceTransaction != null) {
          updateMostSoonModifyBalanceTransactionAfterCreateTransaction(
            transaction: newTransaction,
            mostSoonModifyBalanceTransaction:
                mostSoonModifyBalanceTransaction as ModifyBalanceTransaction,
          );
        } else {
          if (newTransaction.amount > 0) {
            _walletState.increaseWalletBalance(
              newTransaction.sourceWallet.id,
              newTransaction.amount,
            );
            _appState.increaseUserBalance(newTransaction.amount);
          } else {
            _walletState.decreaseWalletBalance(
              newTransaction.sourceWallet.id,
              newTransaction.amount.abs(),
            );
            _appState.decreaseUserBalance(newTransaction.amount.abs());
          }
        }
    }

    if (mostSoonModifyBalanceTransaction != null) {
      //due to this case so complex, we need to recalculate statistic data from scratch
      _statisticState.recalculateStatisticData();
    } else {
      _statisticState.updateStatisticDataAfterCreateTransaction(newTransaction);
    }
  }

  void updateStatesAfterRemoveTransaction(Transaction transaction) {
    final mostSoonModifyBalanceTransaction =
        getMostSoonModifyBalanceTransactionAfterTransaction(
          transaction: transaction,
          sourceWallet: transaction.sourceWallet,
        );

    if (transaction.type == TransactionType.expense) {
      if (mostSoonModifyBalanceTransaction != null) {
        updateMostSoonModifyBalanceTransactionBeforeRemoveTransaction(
          transaction: transaction,
          mostSoonModifyBalanceTransaction:
              mostSoonModifyBalanceTransaction as ModifyBalanceTransaction,
        );
      } else {
        _appState.increaseUserBalance(transaction.amount);
        _walletState.increaseWalletBalance(
          transaction.sourceWallet.id,
          transaction.amount,
        );
      }
    } else if (transaction.type == TransactionType.income) {
      if (mostSoonModifyBalanceTransaction != null) {
        updateMostSoonModifyBalanceTransactionBeforeRemoveTransaction(
          transaction: transaction,
          mostSoonModifyBalanceTransaction:
              mostSoonModifyBalanceTransaction as ModifyBalanceTransaction,
        );
      } else {
        _appState.decreaseUserBalance(transaction.amount);
        _walletState.decreaseWalletBalance(
          transaction.sourceWallet.id,
          transaction.amount,
        );
      }
    } else if (transaction.type == TransactionType.lend) {
      if (mostSoonModifyBalanceTransaction != null) {
        updateMostSoonModifyBalanceTransactionBeforeRemoveTransaction(
          transaction: transaction,
          mostSoonModifyBalanceTransaction:
              mostSoonModifyBalanceTransaction as ModifyBalanceTransaction,
        );
      } else {
        _walletState.increaseWalletBalance(
          transaction.sourceWallet.id,
          transaction.amount,
        );
      }

      //decrease user total loan
      _appState.decreaseUserTotalLoan(transaction.amount);

      //decrease borrower total debt
      _relatedUserState.decreaseRelatedUserTotalDebt(
        (transaction as LendTransaction).borrower.id!,
        transaction.amount,
      );
    } else if (transaction.type == TransactionType.collectingDebt) {
      if (mostSoonModifyBalanceTransaction != null) {
        updateMostSoonModifyBalanceTransactionBeforeRemoveTransaction(
          transaction: transaction,
          mostSoonModifyBalanceTransaction:
              mostSoonModifyBalanceTransaction as ModifyBalanceTransaction,
        );
      } else {
        _walletState.decreaseWalletBalance(
          transaction.sourceWallet.id,
          transaction.amount,
        );
      }

      //increase user total loan
      _appState.increaseUserTotalLoan(transaction.amount);

      //decrease borrower total collected
      _relatedUserState.decreaseRelatedUserTotalCollected(
        (transaction as CollectingDebtTransaction).borrower.id!,
        transaction.amount,
      );
    } else if (transaction.type == TransactionType.borrow) {
      if (mostSoonModifyBalanceTransaction != null) {
        updateMostSoonModifyBalanceTransactionBeforeRemoveTransaction(
          transaction: transaction,
          mostSoonModifyBalanceTransaction:
              mostSoonModifyBalanceTransaction as ModifyBalanceTransaction,
        );
      } else {
        _walletState.decreaseWalletBalance(
          transaction.sourceWallet.id,
          transaction.amount,
        );
      }

      //decrease user total debt
      _appState.decreaseUserTotalDebt(transaction.amount);

      //decrease lender total loan
      _relatedUserState.decreaseRelatedUserTotalLoan(
        (transaction as BorrowTransaction).lender.id!,
        transaction.amount,
      );
    } else if (transaction.type == TransactionType.repayment) {
      if (mostSoonModifyBalanceTransaction != null) {
        updateMostSoonModifyBalanceTransactionBeforeRemoveTransaction(
          transaction: transaction,
          mostSoonModifyBalanceTransaction:
              mostSoonModifyBalanceTransaction as ModifyBalanceTransaction,
        );
      } else {
        _walletState.increaseWalletBalance(
          transaction.sourceWallet.id,
          transaction.amount,
        );
      }

      //increase user total debt
      _appState.increaseUserTotalDebt(transaction.amount);

      //decrease lender total paid
      _relatedUserState.decreaseRelatedUserTotalPaid(
        (transaction as RepaymentTransaction).lender.id!,
        transaction.amount,
      );
    } else if (transaction.type == TransactionType.transfer) {
      //REALLY SPECIAL CASE
      final mostSoonModifyBalanceTransactionOfSourceWallet =
          mostSoonModifyBalanceTransaction;
      final mostSoonModifyBalanceTransactionOfDestinationWallet =
          getMostSoonModifyBalanceTransactionAfterTransaction(
            transaction: transaction,
            sourceWallet:
                (transaction as TransferTransaction).destinationWallet,
          );

      if (mostSoonModifyBalanceTransactionOfSourceWallet == null &&
          mostSoonModifyBalanceTransactionOfDestinationWallet == null) {
        _walletState.increaseWalletBalance(
          transaction.sourceWallet.id,
          transaction.amount,
        );
        _walletState.decreaseWalletBalance(
          transaction.destinationWallet.id,
          transaction.amount,
        );
      } else if (mostSoonModifyBalanceTransactionOfSourceWallet != null &&
          mostSoonModifyBalanceTransactionOfDestinationWallet == null) {
        _appState.decreaseUserBalance(transaction.amount);

        updateMostSoonModifyBalanceTransactionBeforeRemoveTransaction(
          transaction: transaction,
          mostSoonModifyBalanceTransaction:
              mostSoonModifyBalanceTransactionOfSourceWallet
                  as ModifyBalanceTransaction,
        );
        _walletState.decreaseWalletBalance(
          transaction.destinationWallet.id,
          transaction.amount,
        );
      } else if (mostSoonModifyBalanceTransactionOfSourceWallet == null &&
          mostSoonModifyBalanceTransactionOfDestinationWallet != null) {
        _appState.increaseUserBalance(transaction.amount);

        _walletState.increaseWalletBalance(
          transaction.sourceWallet.id,
          transaction.amount,
        );
        updateMostSoonModifyBalanceTransactionBeforeRemoveTransaction(
          transaction: transaction,
          mostSoonModifyBalanceTransaction:
              mostSoonModifyBalanceTransactionOfDestinationWallet
                  as ModifyBalanceTransaction,
        );
      } else {
        //both modify balance transactions exists
        updateMostSoonModifyBalanceTransactionBeforeRemoveTransaction(
          transaction: transaction,
          mostSoonModifyBalanceTransaction:
              mostSoonModifyBalanceTransactionOfSourceWallet
                  as ModifyBalanceTransaction,
        );
        updateMostSoonModifyBalanceTransactionBeforeRemoveTransaction(
          transaction: transaction,
          mostSoonModifyBalanceTransaction:
              mostSoonModifyBalanceTransactionOfDestinationWallet
                  as ModifyBalanceTransaction,
        );
      }
    } else if (transaction.type == TransactionType.modifyBalance) {
      if (mostSoonModifyBalanceTransaction != null) {
        updateMostSoonModifyBalanceTransactionBeforeRemoveTransaction(
          transaction: transaction,
          mostSoonModifyBalanceTransaction:
              mostSoonModifyBalanceTransaction as ModifyBalanceTransaction,
        );
      } else {
        if (transaction.amount > 0) {
          _walletState.decreaseWalletBalance(
            transaction.sourceWallet.id,
            transaction.amount,
          );
          _appState.decreaseUserBalance(transaction.amount);
        } else {
          _walletState.increaseWalletBalance(
            transaction.sourceWallet.id,
            transaction.amount.abs(),
          );
          _appState.increaseUserBalance(transaction.amount.abs());
        }
      }
    }

    if (mostSoonModifyBalanceTransaction != null) {
      //due to this case so complex, we need to recalculate statistic data from scratch
      _transactionState.removeTransaction(transaction.id);
      _statisticState.recalculateStatisticData();
    } else {
      _statisticState.updateStatisticDataAfterRemoveTransaction(transaction);
      _transactionState.removeTransaction(transaction.id);
    }
  }

  Transaction? getMostSoonModifyBalanceTransactionAfterTransaction({
    required Transaction transaction,
    required Wallet sourceWallet,
  }) {
    final transactions = _transactionState.transactions;

    final transactionIndex = transactions.indexWhere(
      (trans) => trans.id == transaction.id,
    );

    for (var i = transactionIndex; i >= 0; i--) {
      if (transactions[i].type != TransactionType.modifyBalance) {
        continue;
      }

      if (transactions[i].sourceWallet.id != sourceWallet.id) {
        continue;
      }

      if (AppTime.isSame(
        transactions[i].transactionDate,
        transaction.transactionDate,
      )) {
        if (transactions[i].id > transaction.id) {
          return transactions[i] as ModifyBalanceTransaction;
        }
      } else {
        if (transactions[i].transactionDate.isBefore(
          transaction.transactionDate,
        )) {
          continue;
        } else {
          return transactions[i] as ModifyBalanceTransaction;
        }
      }
    }

    return null;
  }

  double calculateBalanceAtDate({
    required Wallet sourceWallet,
    required DateTime date,
    Transaction? excludeTransaction,
  }) {
    double baseBalance = sourceWallet.baseBalance;
    double diff = 0;

    final transactions = _transactionState.transactions;
    for (var i = 0; i < transactions.length; i++) {
      // skip others, only keep (date, latestModifyDate]
      if (transactions[i].transactionDate.isAfter(date)) {
        continue;
      }

      // skip excluded transaction
      if (excludeTransaction != null &&
          transactions[i].id == excludeTransaction.id) {
        continue;
      }

      // only filter transactions that are related to the source wallet
      // can be source wallet of transaction or destination wallet in case of transfer
      if (!((transactions[i].sourceWallet.id == sourceWallet.id) ||
          (transactions[i].type == TransactionType.transfer &&
              (transactions[i] as TransferTransaction).destinationWallet.id ==
                  sourceWallet.id))) {
        continue;
      }

      if (transactions[i].type == TransactionType.income) {
        diff += transactions[i].amount;
      } else if (transactions[i].type == TransactionType.expense) {
        diff -= transactions[i].amount;
      } else if (transactions[i].type == TransactionType.transfer) {
        if (transactions[i].sourceWallet.id == sourceWallet.id) {
          diff -= transactions[i].amount; // transfer out
        } else {
          diff += transactions[i].amount; // transfer in
        }
      } else if (transactions[i].type == TransactionType.lend) {
        diff -= transactions[i].amount; // lend out
      } else if (transactions[i].type == TransactionType.collectingDebt) {
        diff += transactions[i].amount; // collecting debt
      } else if (transactions[i].type == TransactionType.borrow) {
        diff += transactions[i].amount; // borrow in
      } else if (transactions[i].type == TransactionType.repayment) {
        diff -= transactions[i].amount;
      } else if (transactions[i].type == TransactionType.modifyBalance) {
        baseBalance =
            (transactions[i] as ModifyBalanceTransaction).newRealBalance;
        break;
      }
    }
    return baseBalance + diff;
  }

  Transaction? getFirstModifyBalanceTransaction(int walletId) {
    final transactions = _transactionState.transactions;

    for (var i = transactions.length - 1; i >= 0; i--) {
      if (transactions[i].type == TransactionType.modifyBalance &&
          transactions[i].sourceWallet.id == walletId) {
        return transactions[i];
      }
    }
    return null;
  }

  void updateMostSoonModifyBalanceTransactionAfterCreateTransaction({
    required Transaction transaction,
    required ModifyBalanceTransaction mostSoonModifyBalanceTransaction,
  }) {
    final oldDiff = mostSoonModifyBalanceTransaction.amount;

    double newDiff;
    if (transaction.type == TransactionType.income) {
      newDiff = oldDiff - transaction.amount;
    } else if (transaction.type == TransactionType.expense) {
      newDiff = oldDiff + transaction.amount;
    } else if (transaction.type == TransactionType.transfer) {
      if (transaction.sourceWallet.id ==
          mostSoonModifyBalanceTransaction.sourceWallet.id) {
        newDiff = oldDiff + transaction.amount; //transfer out
      } else {
        newDiff = oldDiff - transaction.amount; //transfer in
      }
    } else if (transaction.type == TransactionType.lend) {
      newDiff = oldDiff + transaction.amount; //lend out
    } else if (transaction.type == TransactionType.borrow) {
      newDiff = oldDiff - transaction.amount; //borrow in
    } else if (transaction.type == TransactionType.modifyBalance) {
      newDiff = oldDiff - transaction.amount;
    } else if (transaction.type == TransactionType.collectingDebt) {
      newDiff = oldDiff - transaction.amount; //collecting debt
    } else if (transaction.type == TransactionType.repayment) {
      newDiff = oldDiff + transaction.amount; //repayment
    } else {
      newDiff = oldDiff; //default case, should not happen
    }

    ModifyBalanceTransaction updated;
    if (oldDiff < 0 && newDiff > 0) {
      //it means that change from expense to income
      updated = mostSoonModifyBalanceTransaction.copyWith(
        category: CategoryState().otherIncomeCategory,
        amount: newDiff,
      );
    } else if (oldDiff > 0 && newDiff < 0) {
      //it means that change from income to expense
      updated = mostSoonModifyBalanceTransaction.copyWith(
        category: CategoryState().otherExpenseCategory,
        amount: newDiff,
      );
    } else {
      //normal case, just update amount
      updated = mostSoonModifyBalanceTransaction.copyWith(amount: newDiff);
    }

    _transactionState.updateTransaction(updated);
  }

  void updateMostSoonModifyBalanceTransactionBeforeRemoveTransaction({
    required Transaction transaction,
    required ModifyBalanceTransaction mostSoonModifyBalanceTransaction,
  }) {
    final oldDiff = mostSoonModifyBalanceTransaction.amount;

    double newDiff;
    if (transaction.type == TransactionType.income) {
      newDiff = oldDiff + transaction.amount;
    } else if (transaction.type == TransactionType.expense) {
      newDiff = oldDiff - transaction.amount;
    } else if (transaction.type == TransactionType.transfer) {
      if (transaction.sourceWallet.id ==
          mostSoonModifyBalanceTransaction.sourceWallet.id) {
        newDiff = oldDiff - transaction.amount; //transfer out
      } else {
        newDiff = oldDiff + transaction.amount; //transfer in
      }
    } else if (transaction.type == TransactionType.lend) {
      newDiff = oldDiff - transaction.amount; //lend out
    } else if (transaction.type == TransactionType.borrow) {
      newDiff = oldDiff + transaction.amount; //borrow in
    } else if (transaction.type == TransactionType.modifyBalance) {
      newDiff = oldDiff + transaction.amount;
    } else if (transaction.type == TransactionType.collectingDebt) {
      newDiff = oldDiff + transaction.amount; //collecting debt
    } else if (transaction.type == TransactionType.repayment) {
      newDiff = oldDiff - transaction.amount; //repayment
    } else {
      newDiff = oldDiff; //default case, should not happen
    }

    ModifyBalanceTransaction updated;
    if (oldDiff < 0 && newDiff > 0) {
      //it means that change from expense to income
      updated = mostSoonModifyBalanceTransaction.copyWith(
        category: CategoryState().otherIncomeCategory,
        amount: newDiff,
      );
    } else if (oldDiff > 0 && newDiff < 0) {
      //it means that change from income to expense
      updated = mostSoonModifyBalanceTransaction.copyWith(
        category: CategoryState().otherExpenseCategory,
        amount: newDiff,
      );
    } else {
      //normal case, just update amount
      updated = mostSoonModifyBalanceTransaction.copyWith(amount: newDiff);
    }

    _transactionState.updateTransaction(updated);
  }

  Future<Transaction> getTransactionById(int transactionId) async {
    return await _transactionService.getTransactionById(transactionId);
  }

  Future<void> removeTransactionsByWallet(int walletId) async {
    final transactions = _transactionState.transactions;

    final transactionsToRemove = [];
    for (var transaction in transactions) {
      if (transaction.sourceWallet.id == walletId ||
          (transaction.type == TransactionType.transfer &&
              (transaction as TransferTransaction).destinationWallet.id ==
                  walletId)) {
        transactionsToRemove.add(transaction);
      }
    }

    for (var transaction in transactionsToRemove) {
      updateStatesAfterRemoveTransaction(transaction);
    }
  }

  Future<void> removeTransactionsByCategory(int categoryId) async {
    final transactions = _transactionState.transactions;

    final transactionsToRemove = [];
    for (var transaction in transactions) {
      if (transaction.category?.id == categoryId) {
        transactionsToRemove.add(transaction);
      }
    }

    for (var transaction in transactionsToRemove) {
      updateStatesAfterRemoveTransaction(transaction);
    }
  }
}

class TransactionException implements Exception {
  final String message;

  TransactionException(this.message);

  @override
  String toString() {
    return message;
  }
}
