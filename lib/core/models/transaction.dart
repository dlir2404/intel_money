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
    final transactionType = TransactionType.values.firstWhere(
      (e) => e.value == json['type'],
    );
    switch (transactionType) {
      case TransactionType.lend:
        return LendTransaction.fromJson(json);
      case TransactionType.borrow:
        return BorrowTransaction.fromJson(json);
      case TransactionType.transfer:
        return TransferTransaction.fromJson(json);
      case TransactionType.modifyBalance:
        return ModifyBalanceTransaction.fromJson(json);
      case TransactionType.collectingDebt:
        return CollectingDebtTransaction.fromJson(json);
      case TransactionType.repayment:
        return RepaymentTransaction.fromJson(json);
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

  Transaction copyWith({
    int? id,
    TransactionType? type,
    double? amount,
    Category? category,
    Wallet? sourceWallet,
    DateTime? transactionDate,
    String? description,
    bool? notAddToReport,
    String? image,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      sourceWallet: sourceWallet ?? this.sourceWallet,
      transactionDate: transactionDate ?? this.transactionDate,
      description: description ?? this.description,
      notAddToReport: notAddToReport ?? this.notAddToReport,
      image: image ?? this.image,
    );
  }
}

class LendTransaction extends Transaction {
  RelatedUser borrower;
  DateTime? collectionDate;

  LendTransaction({
    required super.id,
    required super.amount,
    required this.borrower,
    required super.transactionDate,
    required super.sourceWallet,
    super.category,
    super.description,
    super.image,
    required bool notAddToReport,
    required DateTime? this.collectionDate,
  }) : super(type: TransactionType.lend);

  factory LendTransaction.fromJson(Map<String, dynamic> json) {
    final borrower = RelatedUser.fromContext(json['extraInfo']['borrowerId']);

    final transaction = LendTransaction(
      id: json['id'],
      amount: double.parse(json['amount'].toString()),
      borrower: borrower,
      transactionDate: AppTime.parseFromApi(json['transactionDate']),
      sourceWallet: Wallet.fromContext(json['sourceWalletId']),
      category: Category.fromContext(json['categoryId']),
      description: json['description'],
      image: json['image'],
      notAddToReport: json['notAddToReport'] == true ? true : false,
      collectionDate: json['extraInfo']['collectionDate'] != null
          ? AppTime.parseFromApi(json['extraInfo']['collectionDate'])
          : null,
    );
    return transaction;
  }

  @override
  LendTransaction copyWith({
    int? id,
    TransactionType? type,
    double? amount,
    Category? category,
    Wallet? sourceWallet,
    DateTime? transactionDate,
    String? description,
    bool? notAddToReport,
    String? image,
    RelatedUser? borrower,
  }) {
    return LendTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      borrower: borrower ?? this.borrower,
      transactionDate: transactionDate ?? this.transactionDate,
      sourceWallet: sourceWallet ?? this.sourceWallet,
      category: category ?? this.category,
      description: description ?? this.description,
      notAddToReport: notAddToReport ?? this.notAddToReport,
      image: image ?? this.image,
      collectionDate: collectionDate ?? collectionDate,
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
    required bool notAddToReport,
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
      notAddToReport: json['notAddToReport'] == true ? true : false,
    );
  }

  @override
  BorrowTransaction copyWith({
    int? id,
    TransactionType? type,
    double? amount,
    Category? category,
    Wallet? sourceWallet,
    DateTime? transactionDate,
    String? description,
    bool? notAddToReport,
    String? image,
    RelatedUser? lender,
  }) {
    return BorrowTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      lender: lender ?? this.lender,
      transactionDate: transactionDate ?? this.transactionDate,
      sourceWallet: sourceWallet ?? this.sourceWallet,
      category: category ?? this.category,
      description: description ?? this.description,
      notAddToReport: notAddToReport ?? this.notAddToReport,
      image: image ?? this.image,
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
    final destinationWallet = Wallet.fromContext(
      json['extraInfo']['destinationWalletId'],
    );
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

  @override
  TransferTransaction copyWith({
    int? id,
    TransactionType? type,
    double? amount,
    Category? category,
    Wallet? sourceWallet,
    DateTime? transactionDate,
    String? description,
    bool? notAddToReport,
    String? image,
    Wallet? destinationWallet,
  }) {
    return TransferTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      destinationWallet: destinationWallet ?? this.destinationWallet,
      transactionDate: transactionDate ?? this.transactionDate,
      sourceWallet: sourceWallet ?? this.sourceWallet,
      description: description ?? this.description,
      image: image ?? this.image,
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
      newRealBalance: double.parse(
        json['extraInfo']['newRealBalance'].toString(),
      ),
      transactionDate: AppTime.parseFromApi(json['transactionDate']),
      sourceWallet: Wallet.fromContext(json['sourceWalletId']),
      category: Category.fromContext(json['categoryId']),
      description: json['description'],
      image: json['image'],
    );
  }

  @override
  ModifyBalanceTransaction copyWith({
    int? id,
    TransactionType? type,
    double? amount,
    Category? category,
    Wallet? sourceWallet,
    DateTime? transactionDate,
    String? description,
    bool? notAddToReport,
    String? image,
    double? newRealBalance,
  }) {
    return ModifyBalanceTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      newRealBalance: newRealBalance ?? this.newRealBalance,
      transactionDate: transactionDate ?? this.transactionDate,
      sourceWallet: sourceWallet ?? this.sourceWallet,
      category: category ?? this.category,
      description: description ?? this.description,
      image: image ?? this.image,
    );
  }
}

class CollectingDebtTransaction extends Transaction {
  RelatedUser borrower;

  CollectingDebtTransaction({
    required super.id,
    required super.amount,
    required this.borrower,
    required super.transactionDate,
    required super.sourceWallet,
    super.category,
    super.description,
    super.image,
  }) : super(type: TransactionType.collectingDebt);

  factory CollectingDebtTransaction.fromJson(Map<String, dynamic> json) {
    final borrower = RelatedUser.fromContext(json['extraInfo']['borrowerId']);
    return CollectingDebtTransaction(
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

  @override
  CollectingDebtTransaction copyWith({
    int? id,
    TransactionType? type,
    double? amount,
    Category? category,
    Wallet? sourceWallet,
    DateTime? transactionDate,
    String? description,
    bool? notAddToReport,
    String? image,
    RelatedUser? borrower,
  }) {
    return CollectingDebtTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      borrower: borrower ?? this.borrower,
      transactionDate: transactionDate ?? this.transactionDate,
      sourceWallet: sourceWallet ?? this.sourceWallet,
      category: category ?? this.category,
      description: description ?? this.description,
      image: image ?? this.image,
    );
  }
}


class RepaymentTransaction extends Transaction {
  RelatedUser lender;

  RepaymentTransaction({
    required super.id,
    required super.amount,
    required this.lender,
    required super.transactionDate,
    required super.sourceWallet,
    super.category,
    super.description,
    super.image,
  }) : super(type: TransactionType.repayment);

  factory RepaymentTransaction.fromJson(Map<String, dynamic> json) {
    final lender = RelatedUser.fromContext(json['extraInfo']['lenderId']);
    return RepaymentTransaction(
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

  @override
  RepaymentTransaction copyWith({
    int? id,
    TransactionType? type,
    double? amount,
    Category? category,
    Wallet? sourceWallet,
    DateTime? transactionDate,
    String? description,
    bool? notAddToReport,
    String? image,
    RelatedUser? lender,
  }) {
    return RepaymentTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      lender: lender ?? this.lender,
      transactionDate: transactionDate ?? this.transactionDate,
      sourceWallet: sourceWallet ?? this.sourceWallet,
      category: category ?? this.category,
      description: description ?? this.description,
      image: image ?? this.image,
    );
  }
}