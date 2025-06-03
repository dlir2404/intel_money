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

    final Category category = Category.fromContext(transInfo.categoryId);
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

    switch (transactionType) {
      case TransactionType.expense:
        Transaction newTransaction = await _transactionService
            .createExpenseTransaction(
              amount: amount,
              categoryId: category!.id,
              description: description,
              transactionDate: transactionDate!,
              sourceWalletId: sourceWallet!.id,
              image: imageUrl,
              notAddToReport: false,
            );

        _transactionState.addTransaction(newTransaction);
        _appState.decreaseUserBalance(amount);
        _walletState.decreateWalletBalance(sourceWallet.id, amount);
        _statisticState.updateStatisticData(newTransaction);
        break;
      case TransactionType.income:
        Transaction newTransaction = await _transactionService
            .createIncomeTransaction(
              amount: amount,
              categoryId: category!.id,
              description: description,
              transactionDate: transactionDate!,
              sourceWalletId: sourceWallet!.id,
            );

        _transactionState.addTransaction(newTransaction);
        _appState.increaseUserBalance(amount);
        _walletState.increaseWalletBalance(sourceWallet.id, amount);
        _statisticState.updateStatisticData(newTransaction);
        break;
      case TransactionType.transfer:
        Transaction newTransaction = await _transactionService
            .createTransferTransaction(
              amount: amount,
              transactionDate: transactionDate!,
              sourceWalletId: sourceWallet!.id,
              destinationWalletId: destinationWallet!.id,
            );

        _transactionState.addTransaction(newTransaction);
        _walletState.decreateWalletBalance(sourceWallet.id, amount);
        _walletState.increaseWalletBalance(destinationWallet.id, amount);
        break;
      case TransactionType.lend:
        Transaction newTransaction = await _transactionService
            .createLendTransaction(
              amount: amount,
              transactionDate: transactionDate!,
              sourceWalletId: sourceWallet!.id,
              categoryId: category!.id,
              borrowerId: borrower!.id!,
            );
        _transactionState.addTransaction(newTransaction);
        _walletState.decreateWalletBalance(sourceWallet.id, amount);
        _appState.decreaseUserBalance(amount);
        //increase user total loan
        _appState.increaseUserTotalLoan(amount);

        //increase borrower total debt
        _relatedUserState.increaseRelatedUserTotalDebt(borrower.id!, amount);
        break;
      case TransactionType.borrow:
        Transaction newTransaction = await _transactionService
            .createBorrowTransaction(
              amount: amount,
              transactionDate: transactionDate!,
              sourceWalletId: sourceWallet!.id,
              categoryId: category!.id,
              lenderId: lender!.id!,
            );

        _transactionState.addTransaction(newTransaction);
        _walletState.increaseWalletBalance(sourceWallet.id, amount);
        _appState.increaseUserBalance(amount);

        //increase user total debt
        _appState.increaseUserTotalDebt(amount);

        //increase lender total loan
        _relatedUserState.increaseRelatedUserTotalLoan(lender.id!, amount);
        break;
      case TransactionType.modifyBalance:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
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

  Future<void> deleteTransaction(int transactionId) async {
    await _transactionService.deleteTransaction(transactionId);

    _transactionState.removeTransaction(transactionId);
    //TODO: change user balance & wallet balance here
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
