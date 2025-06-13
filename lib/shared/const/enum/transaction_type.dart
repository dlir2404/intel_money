import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'category_type.dart';

enum TransactionType { income, expense, transfer, lend, borrow, modifyBalance }

extension CategoryTypeExtension on TransactionType {
  CategoryType get categoryType {
    switch (this) {
      case TransactionType.income:
        return CategoryType.income;
      case TransactionType.expense:
        return CategoryType.expense;
      case TransactionType.lend:
        return CategoryType.lend;
      case TransactionType.borrow:
        return CategoryType.borrow;
      //TODO: change later
      default:
        return CategoryType.expense;
    }
  }

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
        return 'Thu tiền';
      case TransactionType.expense:
        return 'Chi tiền';
      case TransactionType.transfer:
        return 'Chuyển khoản';
      case TransactionType.lend:
        return 'Cho vay';
      case TransactionType.borrow:
        return 'Đi vay';
      case TransactionType.modifyBalance:
        return 'Điều chỉnh số dư';
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
        return Colors.redAccent;
      case TransactionType.borrow:
        return Colors.greenAccent;
      case TransactionType.modifyBalance:
        return Colors.blue;
    }
  }
}
