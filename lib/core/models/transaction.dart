import 'package:intel_money/core/models/related_user.dart';
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

  factory Transaction.fromDetailJson(Map<String, dynamic> json) {
    final transaction = Transaction.fromJson(json);

    if (transaction.type == TransactionType.lend) {
      return LendTransaction.fromJson(json);
    } else if (transaction.type == TransactionType.borrow) {
      return BorrowTransaction.fromJson(json);
    } else if (transaction.type == TransactionType.transfer) {
      return TransferTransaction.fromJson(json);
    }

    return transaction;
  }
}

class LendTransaction extends Transaction {
  RelatedUser borrower;

  LendTransaction({
    required super.id,
    required super.amount,
    required this.borrower,
    required super.transactionDate,
    required super.sourceWallet,
    super.description,
    super.image,
  }) : super(type: TransactionType.lend);

  factory LendTransaction.fromJson(Map<String, dynamic> json) {
    final borrower = RelatedUser.fromContext(json['extraInfo']['borrowerId']);
    return LendTransaction(
      id: json['id'],
      amount: double.parse(json['amount'].toString()),
      borrower: borrower,
      transactionDate: AppTime.parseFromApi(json['transactionDate']),
      sourceWallet: Wallet.fromContext(json['sourceWalletId']),
      description: json['description'],
      image: json['image'],
    );
  }
}

class BorrowTransaction extends Transaction {
  RelatedUser lender;

  BorrowTransaction({
    required super.id,
    required super.amount,
    required this.lender,
    required super.transactionDate,
    required super.sourceWallet,
    super.description,
    super.image,
  }) : super(type: TransactionType.borrow);

  factory BorrowTransaction.fromJson(Map<String, dynamic> json) {
    final lender = RelatedUser.fromContext(json['extraInfo']['lenderId']);
    return BorrowTransaction(
      id: json['id'],
      amount: double.parse(json['amount'].toString()),
      lender: lender,
      transactionDate: AppTime.parseFromApi(json['transactionDate']),
      sourceWallet: Wallet.fromContext(json['sourceWalletId']),
      description: json['description'],
      image: json['image'],
    );
  }
}

class TransferTransaction extends Transaction {
  Wallet destinationWallet;

  TransferTransaction({
    required super.id,
    required super.amount,
    required this.destinationWallet,
    required super.transactionDate,
    required super.sourceWallet,
    super.description,
    super.image,
  }) : super(type: TransactionType.transfer);

  factory TransferTransaction.fromJson(Map<String, dynamic> json) {
    final destinationWallet = Wallet.fromContext(json['extraInfo']['destinationWalletId']);
    return TransferTransaction(
      id: json['id'],
      amount: double.parse(json['amount'].toString()),
      destinationWallet: destinationWallet,
      transactionDate: AppTime.parseFromApi(json['transactionDate']),
      sourceWallet: Wallet.fromContext(json['sourceWalletId']),
      description: json['description'],
      image: json['image'],
    );
  }
}