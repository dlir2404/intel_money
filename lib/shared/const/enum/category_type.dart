enum CategoryType { income, expense, lend, borrow }

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
    }
  }
}
