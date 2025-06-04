import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intel_money/core/models/extract_transaction_info_response.dart';
import 'package:intel_money/core/models/transaction.dart';
import 'package:intel_money/core/services/ai_service.dart';
import 'package:intel_money/core/services/related_user_service.dart';

import '../../../core/models/category.dart';
import '../../../core/models/related_user.dart';
import '../../../core/models/scan_receipt_response.dart';
import '../../../core/models/wallet.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/services/transaction_service.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/related_user_state.dart';
import '../../../core/state/statistic_state.dart';
import '../../../core/state/transaction_state.dart';
import '../../../core/state/wallet_state.dart';
import '../../../shared/const/enum/transaction_data_source_type.dart';
import '../../../shared/const/enum/transaction_type.dart';

class TransactionController {
  final TransactionService _transactionService = TransactionService();
  final RelatedUserService _relatedUserService = RelatedUserService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final AppState _appState = AppState();
  final TransactionState _transactionState = TransactionState();
  final WalletState _walletState = WalletState();
  final StatisticState _statisticState = StatisticState();
  final RelatedUserState _relatedUserState = RelatedUserState();

  Future<List<Transaction>> getTransactions(Map<String, DateTime> timeRange) async {
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
    if (transInfo.categoryId != null) {
      category = Category.fromContext(transInfo.categoryId!);
    }
    final Wallet wallet = Wallet.fromContext(transInfo.walletId);

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

    required File? image,
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
      image: image,
    );

    //create borrower if not exists
    if (transactionType == TransactionType.lend && borrower!.isTemporary) {
      await _relatedUserService.create(borrower);
    }

    //create lender if not exists
    if (transactionType == TransactionType.borrow && lender!.isTemporary) {
      await _relatedUserService.create(lender);
    }

    String imageUrl = '';
    if (image != null) {
      imageUrl = await _cloudinaryService.uploadImage(image.path);
    }

    Transaction newTransaction;

    switch (transactionType) {
      case TransactionType.expense:
        newTransaction = await _transactionService
            .createExpenseTransaction(
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
        newTransaction = await _transactionService
            .createIncomeTransaction(
              amount: amount,
              categoryId: category!.id,
              description: description,
              transactionDate: transactionDate!,
              sourceWalletId: sourceWallet!.id,
            );
        break;
      case TransactionType.transfer:
        newTransaction = await _transactionService
            .createTransferTransaction(
              amount: amount,
              transactionDate: transactionDate!,
              sourceWalletId: sourceWallet!.id,
              destinationWalletId: destinationWallet!.id,
            );
        break;
      case TransactionType.lend:
        newTransaction = await _transactionService
            .createLendTransaction(
              amount: amount,
              transactionDate: transactionDate!,
              sourceWalletId: sourceWallet!.id,
              categoryId: category!.id,
              borrowerId: borrower!.id!,
            );
        break;
      case TransactionType.borrow:
        newTransaction = await _transactionService
            .createBorrowTransaction(
              amount: amount,
              transactionDate: transactionDate!,
              sourceWalletId: sourceWallet!.id,
              categoryId: category!.id,
              lenderId: lender!.id!,
            );
        break;
      case TransactionType.modifyBalance:
        // TODO: Handle this case.
        throw UnimplementedError();
    }

    _transactionState.addTransaction(newTransaction);
    updateOtherStatesAfterCreateTransaction(newTransaction);
  }

  Future<void> saveTransaction({
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
      image: image,
    );

    //create borrower if not exists
    if (transactionType == TransactionType.lend && borrower!.isTemporary) {
      await _relatedUserService.create(borrower);
    }

    //create lender if not exists
    if (transactionType == TransactionType.borrow && lender!.isTemporary) {
      await _relatedUserService.create(lender);
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
        // TODO: Handle this case.
        throw UnimplementedError();
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
      case TransactionType.modifyBalance:
        // TODO: Handle this case.
        throw UnimplementedError();
    }

    updateOtherStatesAfterRemoveTransaction(oldTransaction);
    _transactionState.removeTransaction(oldTransaction.id);

    _transactionState.addTransaction(newTransaction);
    updateOtherStatesAfterCreateTransaction(newTransaction);
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

    required File? image,
  }) {
    if (amount <= 0) {
      throw TransactionException('Amount must be greater than 0');
    }

    if ((transactionType == TransactionType.expense ||
            transactionType == TransactionType.income ||
            transactionType == TransactionType.lend ||
            transactionType == TransactionType.borrow) &&
        category == null) {
      throw TransactionException('Please select a category');
    }

    if (sourceWallet == null) {
      throw TransactionException('Please select a wallet');
    }

    if (transactionDate == null) {
      throw TransactionException('Please select a transaction date');
    }

    if (transactionType == TransactionType.transfer &&
        destinationWallet == null) {
      throw TransactionException("Please choose a destination wallet");
    }

    if (transactionType == TransactionType.transfer &&
        sourceWallet == destinationWallet) {
      throw TransactionException(
        "Source wallet and destination wallet can not be the same",
      );
    }

    if (transactionType == TransactionType.lend && borrower == null) {
      throw TransactionException("Please choose a borrower");
    }

    if (transactionType == TransactionType.borrow && lender == null) {
      throw TransactionException("Please choose a lender");
    }
  }

  Future<void> deleteTransaction(Transaction transaction) async {
    await _transactionService.deleteTransaction(transaction.id);

    updateOtherStatesAfterRemoveTransaction(transaction);
    _transactionState.removeTransaction(transaction.id);
  }

  void updateOtherStatesAfterCreateTransaction(Transaction newTransaction) {
    switch (newTransaction.type) {
      case TransactionType.expense:
        _appState.decreaseUserBalance(newTransaction.amount);
        _walletState.decreateWalletBalance(newTransaction.sourceWallet.id, newTransaction.amount);
        _statisticState.updateStatisticDataAfterCreateTransaction(newTransaction);
        break;
      case TransactionType.income:
        _appState.increaseUserBalance(newTransaction.amount);
        _walletState.increaseWalletBalance(newTransaction.sourceWallet.id, newTransaction.amount);
        _statisticState.updateStatisticDataAfterCreateTransaction(newTransaction);
        break;
      case TransactionType.transfer:
        _walletState.decreateWalletBalance(newTransaction.sourceWallet.id, newTransaction.amount);
        _walletState.increaseWalletBalance((newTransaction as TransferTransaction).destinationWallet.id, newTransaction.amount);
        break;
      case TransactionType.lend:
        _walletState.decreateWalletBalance(newTransaction.sourceWallet.id, newTransaction.amount);
        //increase user total loan
        _appState.increaseUserTotalLoan(newTransaction.amount);

        //increase borrower total debt
        _relatedUserState.increaseRelatedUserTotalDebt((newTransaction as LendTransaction).borrower.id!, newTransaction.amount);
        break;
      case TransactionType.borrow:
        _walletState.increaseWalletBalance(newTransaction.sourceWallet.id, newTransaction.amount);

        //increase user total debt
        _appState.increaseUserTotalDebt(newTransaction.amount);

        //increase lender total loan
        _relatedUserState.increaseRelatedUserTotalLoan((newTransaction as BorrowTransaction).lender.id!, newTransaction.amount);
        break;
      case TransactionType.modifyBalance:
      // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  void updateOtherStatesAfterRemoveTransaction(Transaction transaction) {
    if (transaction.type == TransactionType.expense) {
      _appState.increaseUserBalance(transaction.amount);
      _walletState.increaseWalletBalance(transaction.sourceWallet.id, transaction.amount);

      _statisticState.updateStatisticDataAfterRemoveTransaction(transaction);
    } else if (transaction.type == TransactionType.income) {
      _appState.decreaseUserBalance(transaction.amount);
      _walletState.decreateWalletBalance(transaction.sourceWallet.id, transaction.amount);

      _statisticState.updateStatisticDataAfterRemoveTransaction(transaction);
    } else if (transaction.type == TransactionType.lend) {
      _walletState.increaseWalletBalance(transaction.sourceWallet.id, transaction.amount);
      //decrease user total loan
      _appState.decreaseUserTotalLoan(transaction.amount);

      //decrease borrower total debt
      _relatedUserState.decreaseRelatedUserTotalDebt((transaction as LendTransaction).borrower.id!, transaction.amount);
    } else if (transaction.type == TransactionType.borrow) {
      _walletState.decreateWalletBalance(transaction.sourceWallet.id, transaction.amount);

      //decrease user total debt
      _appState.decreaseUserTotalDebt(transaction.amount);

      //decrease lender total loan
      _relatedUserState.decreaseRelatedUserTotalLoan((transaction as BorrowTransaction).lender.id!, transaction.amount);
    }
  }

  Future<Transaction> getTransactionById(int transactionId) async {
    return await _transactionService.getTransactionById(transactionId);
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
