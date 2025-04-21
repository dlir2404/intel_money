import 'package:flutter/material.dart';
import 'package:intel_money/features/transaction/widgets/transaction_item.dart';
import 'package:intel_money/shared/component/typos/currency_double_text.dart';

import '../../../core/models/transaction.dart';
import '../../../shared/const/enum/transaction_type.dart';
import '../../../shared/helper/AppDate.dart';
import '../../../shared/helper/formatter.dart';

class TransactionGroupByDay extends StatelessWidget {
  final List<Transaction> transactions;

  const TransactionGroupByDay({super.key, required this.transactions});

  Widget _buildGroupHeader(BuildContext context) {
    DateTime date = transactions[0].transactionDate;

    String day = date.day.toString();

    String dayName =
        date.weekday == 1
            ? "Monday"
            : date.weekday == 2
            ? "Tuesday"
            : date.weekday == 3
            ? "Wednesday"
            : date.weekday == 4
            ? "Thursday"
            : date.weekday == 5
            ? "Friday"
            : date.weekday == 6
            ? "Saturday"
            : "Sunday";

    if (AppDate.isToday(date)) {
      dayName = "Today";
    } else if (AppDate.isYesterday(date)) {
      dayName = "Yesterday";
    }

    double totalIncome = 0;
    double totalExpense = 0;
    for (var transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        totalIncome += transaction.amount;
      } else if (transaction.type == TransactionType.expense) {
        totalExpense += transaction.amount;
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 6,
          child: Column(
            children: [
              Container(
                color: Theme.of(context).primaryColor,
                child: const SizedBox(height: 60, width: 6),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),

        Text(day, style: TextStyle(fontSize: 36, fontWeight: FontWeight.w500)),
        const SizedBox(width: 20),

        Column(
          children: [
            Text(
              dayName,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            Text(
              AppDate.monthYearFormat(date),
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
        const SizedBox(width: 20),

        Expanded(child: Container()),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (totalIncome > 0)
                CurrencyDoubleText(
                  value: totalIncome,
                  color: Colors.green,
                  fontSize: 20,
                ),

              if (totalExpense > 0)
                CurrencyDoubleText(
                  value: totalExpense,
                  color: Colors.red,
                  fontSize: 20,
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildTransactionList() {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          Transaction transaction = transactions[index];
          return TransactionItem(transaction: transaction);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildGroupHeader(context),

          Row(
            children: [
              const SizedBox(width: 20),
              Expanded(child: Container(height: 0.5, color: Colors.grey[300])),
            ],
          ),

          _buildTransactionList(),
        ],
      ),
    );
  }
}
