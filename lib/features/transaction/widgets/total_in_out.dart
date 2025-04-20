import 'package:flutter/material.dart';
import 'package:intel_money/shared/const/enum/transaction_type.dart';

import '../../../core/models/transaction.dart';
import '../../../shared/helper/formatter.dart';

class TotalInOut extends StatelessWidget {
  final List<Transaction> transactions;

  const TotalInOut({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    double totalIncome = 0;
    double totalExpense = 0;
    for (var transaction in transactions) {
      if (transaction.type == TransactionType.income){
        totalIncome += transaction.amount;
      } else if (transaction.type == TransactionType.expense) {
        totalExpense += transaction.amount;
      }
    }

    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Column(
                children: [
                  Text(
                    "Total Income",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Formatter.formatCurrency(totalIncome),
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(width: 0.5, color: Colors.grey[300], height: 80),

          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "Total Expense",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatter.formatCurrency(totalExpense),
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
