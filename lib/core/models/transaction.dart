import 'package:intel_money/core/models/wallet.dart';
import 'package:intel_money/shared/helper/app_time.dart';

import '../../shared/const/enum/transaction_type.dart';
import '../state/transaction_state.dart';
import 'category.dart';

class Transaction {
  int id;
  TransactionType type;
  double amount;
  Category? category;
  Wallet sourceWallet;
  DateTime transactionDate;
  String? description;
  bool notAddToReport;
  String? image;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    this.category,
    required this.sourceWallet,
    required this.transactionDate,
    this.description,
    this.notAddToReport = false,
    this.image,
  });

  factory Transaction.fromContext(int id) {
    final List<Transaction> transactions = TransactionState().transactions;
    for (var i = 0; i < transactions.length; i++) {
      if (transactions[i].id == id) {
        return transactions[i];
      }
    }

    throw Exception('Transaction not found');
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    Category? category;
    if (json['categoryId'] != null) {
      category = Category.fromContext(json['categoryId']);
    }
    final sourceWallet = Wallet.fromContext(json['sourceWalletId']);

    return Transaction(
      id: json['id'],
      type: TransactionType.values.firstWhere((e) => e.value == json['type']),
      amount: double.parse(json['amount'].toString()),
      category: category,
      sourceWallet: sourceWallet,
      transactionDate: AppTime.parseFromApi(json['transactionDate']),
      description: json['description'],
      notAddToReport: json['notAddToReport'] == true ? true : false,
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'amount': amount,
      'category': category?.toJson(),
      'sourceWallet': sourceWallet.toJson(),
      'transactionDate': AppTime.toUtcIso8601String(transactionDate),
      'description': description,
      'notAddToReport': notAddToReport,
      'image': image,
    };
  }
}
