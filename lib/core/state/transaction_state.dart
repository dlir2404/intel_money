import 'package:flutter/cupertino.dart';
import 'package:intel_money/shared/helper/app_time.dart';

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
      if (transaction.transactionDate.isAfter(_transactions[i].transactionDate)) {
        _transactions.insert(i, transaction);
        isInserted = true;
        break;
      }

      if (AppTime.isSame(transaction.transactionDate, _transactions[i].transactionDate)) {
        if (transaction.id > _transactions[i].id) {
          // If the transaction date is the same, insert based on ID
          _transactions.insert(i, transaction);
          isInserted = true;
          break;
        }
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
        // Check if the transaction date has changed
        bool dateChanged = !_transactions[i].transactionDate.isAtSameMomentAs(newTransaction.transactionDate);

        if (dateChanged) {
          // Remove and re-insert to maintain sort order
          _transactions.removeAt(i);
          addTransaction(newTransaction);
        } else {
          // Date hasn't changed, simple replacement is fine
          _transactions[i] = newTransaction;
        }

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