import 'package:flutter/material.dart';
import 'package:intel_money/shared/const/enum/transaction_type.dart';
import 'package:intel_money/shared/const/icons/category_icon.dart';

import '../../../core/models/transaction.dart';
import '../../../shared/helper/formatter.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionItem({super.key, required this.transaction});

  Widget _buildIcon() {
    IconData icon;
    Color iconColor;
    if (transaction.category != null) {
      icon = CategoryIcon.getIcon(transaction.category!.icon).icon;
      iconColor = CategoryIcon.getIcon(transaction.category!.icon).color;
    } else {
      TransactionType type = transaction.type;
      icon = type.icon;
      iconColor = type.color;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor, size: 24),
    );
  }

  Widget _buildName() {
    String name;
    if (transaction.category != null) {
      name = transaction.category!.name;
    } else {
      name = transaction.type.name;
    }

    return Expanded(
      child: Text(
        name,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildValue() {
    String value = Formatter.formatCurrency(transaction.amount);

    Color color = Colors.black;
    if (transaction.type == TransactionType.expense) {
      color = Colors.red;
    } else if (transaction.type == TransactionType.income) {
      color = Colors.green;
    }

    return Text(value, style: TextStyle(color: color));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 12),

          _buildIcon(),
          const SizedBox(width: 12),

          _buildName(),
          const SizedBox(width: 12),

          _buildValue(),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}
