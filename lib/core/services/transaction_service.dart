import 'dart:io';

import 'package:intel_money/core/network/api_client.dart';
import 'package:intel_money/core/state/app_state.dart';
import 'package:intel_money/shared/const/enum/transaction_type.dart';

import '../models/transaction.dart';
import 'cloudinary_service.dart';

class TransactionService {
  final AppState _appState = AppState();
  final ApiClient _apiClient;

  TransactionService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  Future<void> getTransactions() async {}

  Future<void> createTransaction({
    required TransactionType transactionType,
    required double amount,
    int? categoryId,
    String? description,
    required DateTime transactionDate,
    required int sourceWalletId,
    int? destinationWalletId,
    bool? notAddToReport,
    required List<File> images,
  }) async {
    List<String> imageUrls = [];
    for (var image in images) {
      final imageUrl = await CloudinaryService().uploadImage(image.path);
      imageUrls.add(imageUrl);
    }

    switch (transactionType) {
      case TransactionType.expense:
        await createExpenseTransaction(
          amount,
          categoryId,
          description,
          transactionDate,
          sourceWalletId,
          imageUrls,
          notAddToReport: notAddToReport ?? false,
        );
        break;
      case TransactionType.income:
        await createIncomeTransaction(
          amount,
          categoryId,
          description,
          transactionDate,
          sourceWalletId,
          imageUrls,
          notAddToReport: notAddToReport ?? false,
        );
        break;
      case TransactionType.transfer:
        await createTransferTransaction(
          amount,
          description,
          transactionDate,
          sourceWalletId,
          destinationWalletId!,
          imageUrls,
          notAddToReport: notAddToReport ?? false,
        );
        break;
      case TransactionType.lend:
        // TODO: Handle this case.
        throw UnimplementedError();
      case TransactionType.borrow:
        // TODO: Handle this case.
        throw UnimplementedError();
      case TransactionType.modifyBalance:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  Future<Transaction> createTransferTransaction(
      double amount,
      String? description,
      DateTime transactionDate,
      int sourceWalletId,
      int destinationWalletId,
      List<String> images, {
        bool notAddToReport = false,
      }) async {
    final response = await _apiClient.post('/transaction/transfer/create', {
      'amount': amount,
      'description': description,
      'transactionDate': transactionDate.toIso8601String(),
      'sourceWalletId': sourceWalletId,
      'destinationWalletId': destinationWalletId,
      'notAddToReport': notAddToReport,
      'images': images,
    });
    final transaction = Transaction.fromJson(response);

    _appState.addTransaction(transaction);
    _appState.decreateWalletBalance(sourceWalletId, amount);
    _appState.increaseWalletBalance(destinationWalletId, amount);
    return transaction;
  }

  Future<Transaction> createIncomeTransaction(
    double amount,
    int? categoryId,
    String? description,
    DateTime transactionDate,
    int sourceWalletId,
    List<String> images, {
    bool notAddToReport = false,
  }) async {
    final response = await _apiClient.post('/transaction/income/create', {
      'amount': amount,
      'categoryId': categoryId,
      'description': description,
      'transactionDate': transactionDate.toIso8601String(),
      'sourceWalletId': sourceWalletId,
      'notAddToReport': notAddToReport,
      'images': images,
    });
    final transaction = Transaction.fromJson(response);

    _appState.addTransaction(transaction);
    _appState.increaseUserBalance(amount);
    _appState.increaseWalletBalance(sourceWalletId, amount);
    return transaction;
  }

  Future<Transaction> createExpenseTransaction(
    double amount,
    int? categoryId,
    String? description,
    DateTime transactionDate,
    int sourceWalletId,
    List<String> images, {
    bool notAddToReport = false,
  }) async {
    final response = await _apiClient.post('/transaction/expense/create', {
      'amount': amount,
      'categoryId': categoryId,
      'description': description,
      'transactionDate': transactionDate.toIso8601String(),
      'sourceWalletId': sourceWalletId,
      'notAddToReport': notAddToReport,
      'images': images,
    });
    final transaction = Transaction.fromJson(response);

    _appState.addTransaction(transaction);
    _appState.decreaseUserBalance(amount);
    _appState.decreateWalletBalance(sourceWalletId, amount);
    return transaction;
  }
}
