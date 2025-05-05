import 'dart:io';

import 'package:intel_money/core/network/api_client.dart';
import 'package:intel_money/core/state/app_state.dart';
import 'package:intel_money/core/state/category_state.dart';
import 'package:intel_money/core/state/statistic_state.dart';
import 'package:intel_money/core/state/transaction_state.dart';
import 'package:intel_money/core/state/wallet_state.dart';
import 'package:intel_money/shared/const/enum/transaction_type.dart';

import '../models/transaction.dart';
import 'cloudinary_service.dart';

class TransactionService {
  final AppState _appState = AppState();
  final TransactionState _transactionState = TransactionState();
  final WalletState _walletState = WalletState();
  final StatisticState _statisticState = StatisticState();

  final ApiClient _apiClient = ApiClient.instance;

  static final TransactionService _instance = TransactionService._internal();
  factory TransactionService() => _instance;
  TransactionService._internal();

  Future<void> getTransactions() async {
    final response = await _apiClient.get('/transaction/all/test-only');

    final transactions = (response as List)
        .map((transaction) => Transaction.fromJson(transaction))
        .toList();

    _transactionState.setTransactions(transactions);
  }

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
    int? borrowerId,
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
        await createLendTransaction(
          amount,
          description,
          transactionDate,
          sourceWalletId,
          categoryId!,
          borrowerId!,
          imageUrls,
        );
        break;
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

    _transactionState.addTransaction(transaction);
    _walletState.decreateWalletBalance(sourceWalletId, amount);
    _walletState.increaseWalletBalance(destinationWalletId, amount);
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

    _transactionState.addTransaction(transaction);
    _appState.increaseUserBalance(amount);
    _walletState.increaseWalletBalance(sourceWalletId, amount);
    _statisticState.updateStatisticData(transaction);
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

    _transactionState.addTransaction(transaction);
    _appState.decreaseUserBalance(amount);
    _walletState.decreateWalletBalance(sourceWalletId, amount);
    _statisticState.updateStatisticData(transaction);
    return transaction;
  }

  Future<Transaction> createLendTransaction(
    double amount,
    String? description,
    DateTime transactionDate,
    int sourceWalletId,
    int categoryId,
    int borrowerId,
    List<String> images,
  ) async {
    final response = await _apiClient.post('/transaction/lend/create', {
      'amount': amount,
      'description': description,
      'transactionDate': transactionDate.toIso8601String(),
      'sourceWalletId': sourceWalletId,
      'borrowerId': borrowerId,
      'categoryId': categoryId,
      'images': images,
    });
    final transaction = Transaction.fromJson(response);

    _transactionState.addTransaction(transaction);
    _walletState.decreateWalletBalance(sourceWalletId, amount);
    _appState.decreaseUserBalance(transaction.amount);
    _appState.increaseUserTotalLoan(transaction.amount);

    return transaction;
  }
}
