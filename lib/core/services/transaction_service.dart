import 'dart:io';

import 'package:intel_money/core/network/api_client.dart';
import 'package:intel_money/core/state/app_state.dart';
import 'package:intel_money/core/state/related_user_state.dart';
import 'package:intel_money/core/state/statistic_state.dart';
import 'package:intel_money/core/state/transaction_state.dart';
import 'package:intel_money/core/state/wallet_state.dart';
import 'package:intel_money/shared/const/enum/transaction_type.dart';
import 'package:intel_money/shared/helper/app_time.dart';

import '../models/transaction.dart';
import 'cloudinary_service.dart';

class TransactionService {
  final TransactionState _transactionState = TransactionState();

  final ApiClient _apiClient = ApiClient.instance;

  static final TransactionService _instance = TransactionService._internal();

  factory TransactionService() => _instance;

  TransactionService._internal();

  Future<Transaction> getTransactionById(int id) async {
    final response = await _apiClient.get('/transaction/$id');
    final transaction = Transaction.fromJson(response);

    return transaction;
  }

  Future<List<Transaction>> getTransactionsInTimeRange({
    required DateTime from,
    required DateTime to,
  }) async {
    final response = await _apiClient.get(
      '/transaction/time-range',
      params: {
        'from': AppTime.toUtcIso8601String(from),
        'to': AppTime.toUtcIso8601String(to),
      },
    );

    final transactions =
        (response as List)
            .map((transaction) => Transaction.fromJson(transaction))
            .toList();

    return transactions;
  }

  Future<List<Transaction>> getAllTransactions() async {
    final response = await _apiClient.get('/transaction/all');

    final transactions =
        (response as List)
            .map((transaction) => Transaction.fromJson(transaction))
            .toList();

    return transactions;
  }

  Future<Transaction> createTransferTransaction({
    required double amount,
    String? description,
    required DateTime transactionDate,
    required int sourceWalletId,
    required int destinationWalletId,
    String? image,
    bool notAddToReport = false,
  }) async {
    final response = await _apiClient.post('/transaction/transfer/create', {
      'amount': amount,
      'description': description,
      'transactionDate': AppTime.toUtcIso8601String(transactionDate),
      'sourceWalletId': sourceWalletId,
      'destinationWalletId': destinationWalletId,
      'notAddToReport': notAddToReport,
      'image': image,
    });
    final transaction = Transaction.fromJson(response);
    return transaction;
  }

  Future<Transaction> createIncomeTransaction({
    required double amount,
    required int? categoryId,
    required String? description,
    required DateTime transactionDate,
    required int sourceWalletId,
    String? image,
    bool notAddToReport = false,
  }) async {
    final response = await _apiClient.post('/transaction/income/create', {
      'amount': amount,
      'categoryId': categoryId,
      'description': description,
      'transactionDate': AppTime.toUtcIso8601String(transactionDate),
      'sourceWalletId': sourceWalletId,
      'notAddToReport': notAddToReport,
      'image': image,
    });
    final transaction = Transaction.fromJson(response);
    return transaction;
  }

  Future<Transaction> createExpenseTransaction({
    required double amount,
    required int? categoryId,
    required String? description,
    required DateTime transactionDate,
    required int sourceWalletId,
    String? image,
    bool notAddToReport = false,
  }) async {
    final response = await _apiClient.post('/transaction/expense/create', {
      'amount': amount,
      'categoryId': categoryId,
      'description': description,
      'transactionDate': AppTime.toUtcIso8601String(transactionDate),
      'sourceWalletId': sourceWalletId,
      'notAddToReport': notAddToReport,
      'image': image,
    });
    final transaction = Transaction.fromJson(response);
    return transaction;
  }

  Future<Transaction> createLendTransaction({
    required double amount,
    String? description,
    required DateTime transactionDate,
    required int sourceWalletId,
    required int categoryId,
    required int borrowerId,
    String? image,
  }) async {
    final response = await _apiClient.post('/transaction/lend/create', {
      'amount': amount,
      'description': description,
      'transactionDate': AppTime.toUtcIso8601String(transactionDate),
      'sourceWalletId': sourceWalletId,
      'borrowerId': borrowerId,
      'categoryId': categoryId,
      'image': image,
    });
    final transaction = Transaction.fromJson(response);
    return transaction;
  }

  Future<Transaction> createBorrowTransaction({
    required double amount,
    String? description,
    required DateTime transactionDate,
    required int sourceWalletId,
    required int categoryId,
    required int lenderId,
    String? image,
  }) async {
    final response = await _apiClient.post('/transaction/borrow/create', {
      'amount': amount,
      'description': description,
      'transactionDate': AppTime.toUtcIso8601String(transactionDate),
      'sourceWalletId': sourceWalletId,
      'lenderId': lenderId,
      'categoryId': categoryId,
      'image': image,
    });
    final transaction = Transaction.fromJson(response);
    return transaction;
  }

  Future<void> deleteTransaction(int transactionId) async {
    final response = await _apiClient.delete('/transaction/$transactionId');
    if (response == null || response['result'] != true) {
      throw Exception('Delete transaction failed');
    }
  }
}
