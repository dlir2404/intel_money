import 'package:intel_money/core/models/wallet.dart';

import '../../shared/const/enum/transaction_type.dart';
import 'category.dart';

class Transaction {
  int id;
  TransactionType type;
  double amount;
  Category category;
  Wallet sourceWallet;
  DateTime transactionDate;
  String? description;
  bool notAddToReport;
  List<String>? images;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.sourceWallet,
    required this.transactionDate,
    this.description,
    this.notAddToReport = false,
    this.images,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final category = Category.fromContext(json['category']['id']);
    final sourceWallet = Wallet.fromContext(json['sourceWallet']['id']);

    return Transaction(
      id: json['id'],
      type: TransactionType.values.firstWhere((e) => e.value == json['type']),
      amount: double.parse(json['amount'].toString()),
      category: category,
      sourceWallet: sourceWallet,
      transactionDate: DateTime.parse(json['transactionDate']),
      description: json['description'],
      notAddToReport: json['notAddToReport'] == true ? true : false,
      images: json['images'] is List ? List<String>.from(json['images']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'amount': amount,
      'category': category.toJson(),
      'sourceWallet': sourceWallet.toJson(),
      'transactionDate': transactionDate.toIso8601String(),
      'description': description,
      'notAddToReport': notAddToReport,
      'images': images,
    };
  }
}
