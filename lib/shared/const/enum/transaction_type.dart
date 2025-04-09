enum TransactionType { income, expense, transfer, lend, borrow, modifyBalance }

extension CategoryTypeExtension on TransactionType {
  String get value {
    switch (this) {
      case TransactionType.income:
        return 'INCOME';
      case TransactionType.expense:
        return 'EXPENSE';
      case TransactionType.transfer:
        return 'TRANSFER';
      case TransactionType.lend:
        return 'LEND';
      case TransactionType.borrow:
        return 'BORROW';
      case TransactionType.modifyBalance:
        return 'MODIFY_BALANCE';
    }
  }

  String get name {
    switch (this) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.transfer:
        return 'Transfer';
      case TransactionType.lend:
        return 'Lend';
      case TransactionType.borrow:
        return 'Borrow';
      case TransactionType.modifyBalance:
        return 'Modify Balance';
    }
  }
}
