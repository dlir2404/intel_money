import 'package:flutter/cupertino.dart';
import 'package:intel_money/core/models/user.dart';
import 'package:intel_money/core/types/wallet.dart';

import '../../shared/const/enum/category_type.dart';
import '../types/category.dart';

class AppState extends ChangeNotifier {
  User? _user;
  List<Wallet> _wallets = [];
  List<Category> _categories = [];
  List<Category> _expenseCategories = [];
  List<Category> _incomeCategories = [];



  User? get user => _user;
  List<Wallet> get wallets => _wallets;
  List<Category> get categories => _categories;
  List<Category> get expenseCategories => _expenseCategories;
  List<Category> get incomeCategories => _incomeCategories;

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
    _expenseCategories = categories.where((element) => element.type == CategoryType.expense).toList();
    _incomeCategories = categories.where((element) => element.type == CategoryType.income).toList();
    notifyListeners();
  }

  void addCategory(Category category) {
    _categories.add(category);
    if (category.type == CategoryType.expense) {
      _expenseCategories.add(category);
    } else {
      _incomeCategories.add(category);
    }
    notifyListeners();
  }

  void updateCategory(Category category) {
    final index = _categories.indexWhere((element) => element.id == category.id);
    _categories[index] = category;

    if (category.type == CategoryType.expense) {
      final index = _expenseCategories.indexWhere((element) => element.id == category.id);
      _expenseCategories[index] = category;
    } else {
      final index = _incomeCategories.indexWhere((element) => element.id == category.id);
      _incomeCategories[index] = category;
    }
    notifyListeners();
  }

  void removeCategory(int id) {
    _categories.removeWhere((element) => element.id == id);
    if (_expenseCategories.indexWhere((element) => element.id == id) != -1) {
      _expenseCategories.removeWhere((element) => element.id == id);
    } else {
      _incomeCategories.removeWhere((element) => element.id == id);
    }
    notifyListeners();
  }




  void clear() {
    _user = null;
    _wallets = [];
    notifyListeners();
  }
}