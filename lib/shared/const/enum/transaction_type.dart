import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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

  IconData get icon {
    switch (this) {
      case TransactionType.income:
        return MdiIcons.minus;
      case TransactionType.expense:
        return MdiIcons.plus;
      case TransactionType.transfer:
        return MdiIcons.swapHorizontal;
      case TransactionType.lend:
        return MdiIcons.cashMinus;
      case TransactionType.borrow:
        return MdiIcons.cashPlus;
      case TransactionType.modifyBalance:
        return MdiIcons.clipboardEditOutline;
    }
  }

  Color get color {
    switch (this) {
      case TransactionType.income:
        return Colors.green;
      case TransactionType.expense:
        return Colors.red;
      case TransactionType.transfer:
        return Colors.grey;
      case TransactionType.lend:
        return Colors.grey;
      case TransactionType.borrow:
        return Colors.blue;
      case TransactionType.modifyBalance:
        return Colors.blue;
    }
  }
}
