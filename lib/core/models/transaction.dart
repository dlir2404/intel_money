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
    final transactionType = TransactionType.values.firstWhere((e) => e.value == json['type']);
    switch (transactionType) {
      case TransactionType.lend:
        return LendTransaction.fromJson(json);
      case TransactionType.borrow:
        return BorrowTransaction.fromJson(json);
      case TransactionType.transfer:
        return TransferTransaction.fromJson(json);
      case TransactionType.modifyBalance:
        return ModifyBalanceTransaction.fromJson(json);
      default:
        break;
    }

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
}

class LendTransaction extends Transaction {
  RelatedUser borrower;

  LendTransaction({
    required super.id,
    required super.amount,
    required this.borrower,
    required super.transactionDate,
    required super.sourceWallet,
    super.category,
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
      category: Category.fromContext(json['categoryId']),
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
    super.category,
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
      category: Category.fromContext(json['categoryId']),
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

class ModifyBalanceTransaction extends Transaction {
  double newRealBalance;
  ModifyBalanceTransaction({
    required super.id,
    required super.amount,
    required this.newRealBalance,
    required super.transactionDate,
    required super.sourceWallet,
    super.category,
    super.description,
    super.image,
  }) : super(type: TransactionType.modifyBalance);

  factory ModifyBalanceTransaction.fromJson(Map<String, dynamic> json) {
    return ModifyBalanceTransaction(
      id: json['id'],
      amount: double.parse(json['amount'].toString()),
      newRealBalance: double.parse(json['extraInfo']['newRealBalance'].toString()),
      transactionDate: AppTime.parseFromApi(json['transactionDate']),
      sourceWallet: Wallet.fromContext(json['sourceWalletId']),
      category: Category.fromContext(json['categoryId']),
      description: json['description'],
      image: json['image'],
    );
  }
}