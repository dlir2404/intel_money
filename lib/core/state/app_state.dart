import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:intel_money/core/models/transaction.dart';
import 'package:intel_money/core/models/user.dart';
import 'package:intel_money/core/models/wallet.dart';
import 'package:intel_money/shared/const/enum/transaction_type.dart';

import '../../shared/const/enum/category_type.dart';
import '../models/category.dart';

class AppState extends ChangeNotifier {
  // Singleton instance
  static final AppState _instance = AppState._internal();

  // Factory constructor
  factory AppState() => _instance;

  // Private constructor
  AppState._internal();

  //system config
  Currency? _currency = CurrencyService().findByCode("VND");


  User? _user;
  List<Wallet> _wallets = [];
  List<Category> _categories = [];
  List<Category> _expenseCategories = [];
  List<Category> _incomeCategories = [];

  //transactions in decreasing order by date
  List<Transaction> _transactions = [];

  Currency? get currency => _currency;

  void setCurrency(Currency? currency) {
    _currency = currency;
    notifyListeners();
  }


  User? get user => _user;

  List<Wallet> get wallets => _wallets;

  List<Category> get categories => _categories;

  List<Category> get expenseCategories => _expenseCategories;

  List<Category> get incomeCategories => _incomeCategories;

  List<Transaction> get transactions => _transactions;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void setWallets(List<Wallet> wallets) {
    _wallets = wallets;
    notifyListeners();
  }

  void addWallet(Wallet wallet) {
    _wallets.add(wallet);
    notifyListeners();
  }

  void updateWallet(Wallet wallet) {
    final index = _wallets.indexWhere((element) => element.id == wallet.id);
    _wallets[index] = wallet;
    notifyListeners();
  }

  void removeWallet(int id) {
    _wallets.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  void setCategories(List<Category> categories) {
    _categories = categories;

    //reference variables
    _expenseCategories =
        categories
            .where((element) => element.type == CategoryType.expense)
            .toList();
    _incomeCategories =
        categories
            .where((element) => element.type == CategoryType.income)
            .toList();
    notifyListeners();
  }

  void addCategory(Category category) {
    if (category.parentId == null) {
      _categories.add(category);
      if (category.type == CategoryType.expense) {
        _expenseCategories.add(category);
      } else {
        _incomeCategories.add(category);
      }
    } else {
      final parent = _categories.firstWhere(
        (element) => element.id == category.parentId,
      );
      parent.addChild(category);
      //NOTICE: cause income & expense categories just reference variables, we do not need to add once again
      //The code below is wrong
      // if (category.type == CategoryType.expense) {
      //   final expenseParent = _expenseCategories.firstWhere(
      //     (element) => element.id == category.parentId,
      //   );
      //   expenseParent.addChild(category);
      // } else {
      //   final incomeParent = _incomeCategories.firstWhere(
      //     (element) => element.id == category.parentId,
      //   );
      //   incomeParent.addChild(category);
      // }
    }
    notifyListeners();
  }

  void updateCategory(Category category) {
    final index = _categories.indexWhere(
      (element) => element.id == category.id,
    );
    _categories[index] = category;

    if (category.type == CategoryType.expense) {
      final index = _expenseCategories.indexWhere(
        (element) => element.id == category.id,
      );
      _expenseCategories[index] = category;
    } else {
      final index = _incomeCategories.indexWhere(
        (element) => element.id == category.id,
      );
      _incomeCategories[index] = category;
    }
    notifyListeners();
  }

  void removeCategory(int id) {
    //TODO: must remove in children too
    _categories.removeWhere((element) => element.id == id);
    if (_expenseCategories.indexWhere((element) => element.id == id) != -1) {
      _expenseCategories.removeWhere((element) => element.id == id);
    } else {
      _incomeCategories.removeWhere((element) => element.id == id);
    }
    notifyListeners();
  }

  void setTransactions(List<Transaction> transactions) {
    _transactions = transactions;
    notifyListeners();
  }


  //TODO: review later
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

  void decreaseUserBalance(double amount) {
    _user!.totalBalance -= amount;
    notifyListeners();
  }

  void increaseUserBalance(double amount) {
    _user!.totalBalance += amount;
    notifyListeners();
  }

  void decreateWalletBalance(int walletId, double amount) {
    final index = _wallets.indexWhere((element) => element.id == walletId);
    _wallets[index].balance -= amount;
    notifyListeners();
  }

  void increaseWalletBalance(int walletId, double amount) {
    final index = _wallets.indexWhere((element) => element.id == walletId);
    _wallets[index].balance += amount;
    notifyListeners();
  }

  void clear() {
    _user = null;
    _wallets = [];
    notifyListeners();
  }
}
