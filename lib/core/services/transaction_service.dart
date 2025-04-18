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

  Future<void> createTransaction(
    TransactionType transactionType,
    double amount,
    int categoryId,
    String? description,
    DateTime transactionDate,
    int sourceWalletId,
    bool? notAddToReport,
    List<File> images,
  ) async {
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
        // TODO: Handle this case.
        throw UnimplementedError();
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

  Future<Transaction> createIncomeTransaction(
    double amount,
    int categoryId,
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
    return Transaction.fromJson(response);
  }

  Future<Transaction> createExpenseTransaction(
    double amount,
    int categoryId,
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
    return transaction;
  }
}
