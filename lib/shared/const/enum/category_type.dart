enum CategoryType { income, expense }

extension CategoryTypeExtension on CategoryType {
  String get value {
    switch (this) {
      case CategoryType.income:
        return 'INCOME';
      case CategoryType.expense:
        return 'EXPENSE';
    }
  }

  String get name {
    switch (this) {
      case CategoryType.income:
        return 'Income';
      case CategoryType.expense:
        return 'Expense';
    }
  }
}
