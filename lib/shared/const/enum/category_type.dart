import 'package:flutter/material.dart';
enum CategoryType { income, expense, lend, borrow, collectingDebt, repayment }

extension CategoryTypeExtension on CategoryType {
  String get value {
    switch (this) {
      case CategoryType.income:
        return 'INCOME';
      case CategoryType.expense:
        return 'EXPENSE';
      case CategoryType.lend:
        return 'LEND';
      case CategoryType.borrow:
        return 'BORROW';
      case CategoryType.collectingDebt:
        return 'COLLECTING_DEBT';
      case CategoryType.repayment:
        return 'REPAYMENT';
    }
  }

  String get name {
    switch (this) {
      case CategoryType.income:
        return 'Income';
      case CategoryType.expense:
        return 'Expense';
      case CategoryType.lend:
        return 'Lend';
      case CategoryType.borrow:
        return 'Borrow';
      case CategoryType.collectingDebt:
        return 'Collecting Debt';
      case CategoryType.repayment:
        return 'Repayment';
    }
  }

  Color get color {
    switch (this) {
      case CategoryType.income:
        return Colors.green;
      case CategoryType.expense:
        return Colors.red;
      case CategoryType.lend:
        return Colors.blue;
      case CategoryType.borrow:
        return Colors.orange;
      case CategoryType.collectingDebt:
        return Colors.purple;
      case CategoryType.repayment:
        return Colors.teal;
    }
  }
}
