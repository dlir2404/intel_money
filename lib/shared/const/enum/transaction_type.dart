import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'category_type.dart';

enum TransactionType { income, expense, transfer, lend, borrow, modifyBalance, collectingDebt, repayment }

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
      case TransactionType.collectingDebt:
        return CategoryType.collectingDebt;
      case TransactionType.repayment:
        return CategoryType.repayment;
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
      case TransactionType.collectingDebt:
        return 'COLLECTING_DEBT';
      case TransactionType.repayment:
        return 'REPAYMENT';
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
      case TransactionType.collectingDebt:
        return 'Thu nợ';
      case TransactionType.repayment:
        return 'Trả nợ';
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
      case TransactionType.collectingDebt:
        return MdiIcons.accountCash;
      case TransactionType.repayment:
        return MdiIcons.accountCashOutline;
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
      case TransactionType.collectingDebt:
        return Colors.purple;
      case TransactionType.repayment:
        return Colors.teal;
    }
  }
}
