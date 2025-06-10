import 'package:flutter/material.dart';
import 'package:intel_money/shared/component/typos/currency_double_text.dart';
import 'package:intel_money/shared/const/enum/transaction_type.dart';
import 'package:intel_money/shared/helper/app_time.dart';

import '../../../core/models/transaction.dart';
import '../screens/edit_transaction_screen.dart';

class TransactionItemV2 extends StatelessWidget {
  final Transaction transaction;

  const TransactionItemV2({super.key, required this.transaction});

  Widget _buildDay() {
    return Text(
      AppTime.format(time: transaction.transactionDate),
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildValue() {
    Color color = Colors.black;
    if (transaction.type == TransactionType.expense) {
      color = Colors.red;
    } else if (transaction.type == TransactionType.income) {
      color = Colors.green;
    } else if (transaction.type == TransactionType.modifyBalance) {
      if (transaction.amount < 0) {
        color = Colors.red;
      } else {
        color = Colors.green;
      }
    }

    return CurrencyDoubleText(
      value: transaction.amount.abs(),
      color: color,
      fontSize: 16,
    );
  }

  Widget _buildWallet() {
    return Row(
      children: [
        const SizedBox(width: 16),
        Expanded(
          child:
              transaction.type == TransactionType.modifyBalance
                  ? Text(
                    "Adjust account balance",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  )
                  : const SizedBox(width: 12),
        ),

        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            transaction.sourceWallet.icon.icon,
            color: transaction.sourceWallet.icon.color,
            size: 16,
          ),
        ),
        const SizedBox(width: 4),

        Text(
          transaction.sourceWallet.name,
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EditTransactionScreen(transaction: transaction),
          ),
        );
      },
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 16),

                _buildDay(),
                Expanded(child: const SizedBox()),

                _buildValue(),
                const SizedBox(width: 12),
              ],
            ),

            _buildWallet(),
          ],
        ),
      ),
    );
  }
}
