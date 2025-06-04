import 'package:flutter/cupertino.dart';

import '../models/transaction.dart';

class TransactionState extends ChangeNotifier {
  static final TransactionState _instance = TransactionState._internal();
  factory TransactionState() => _instance;
  TransactionState._internal();

  //transactions in decreasing order by date
  List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  void setTransactions(List<Transaction> transactions) {
    _transactions = transactions;
    notifyListeners();
  }

  void addTransaction(Transaction transaction) {
    bool isInserted = false;
    for (var i = 0; i < _transactions.length; i++) {
      if (transaction.transactionDate.isBefore(_transactions[i].transactionDate)) {
        _transactions.insert(i + 1, transaction);
        isInserted = true;
      }
    }

    //no transaction date is after the new transaction date
    if (!isInserted) {
      _transactions.insert(0, transaction);
    }

    notifyListeners();
  }

  void updateTransaction(Transaction newTransaction) {
    for (var i = 0; i < _transactions.length; i++) {
      if (_transactions[i].id == newTransaction.id) {
        _transactions[i] = newTransaction;
        notifyListeners();
        return;
      }
    }
  }

  void removeTransaction(int id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}