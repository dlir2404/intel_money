import 'package:flutter/cupertino.dart';

import '../../shared/const/enum/category_type.dart';
import '../models/category.dart';

class CategoryState extends ChangeNotifier {
  static final CategoryState _instance = CategoryState._internal();
  factory CategoryState() => _instance;
  CategoryState._internal();

  List<Category> _categories = [];
  List<Category> _expenseCategories = [];
  List<Category> _incomeCategories = [];
  List<Category> _lendCategories = [];
  List<Category> _borrowCategories = [];

  List<Category> get categories => _categories;

  List<Category> get expenseCategories => _expenseCategories;

  List<Category> get incomeCategories => _incomeCategories;

  List<Category> get lendCategories => _lendCategories;

  List<Category> get borrowCategories => _borrowCategories;

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
    _lendCategories =
        categories
            .where((element) => element.type == CategoryType.lend)
            .toList();

    _borrowCategories =
        categories
            .where((element) => element.type == CategoryType.borrow)
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


  //done
  void updateCategory(Category category) {
    if (category.parentId != null && category.parentId != 0) {
      final parent = _categories.firstWhere((element) => element.id == category.parentId);
      final index = parent.children.indexWhere((element) => element.id == category.id);
      parent.children[index] = category;
    } else {
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
}