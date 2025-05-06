import 'package:flutter/material.dart';

import '../../../shared/component/typos/currency_double_text.dart';

class ExpenseVsIncomeItem extends StatelessWidget {
  final String title;
  final double totalIncome;
  final double totalExpense;

  const ExpenseVsIncomeItem({
    super.key,
    required this.title,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CurrencyDoubleText(
                    value: totalIncome,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 6),

                  CurrencyDoubleText(
                    value: totalExpense,
                    fontSize: 16,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 3),
                  Container(color: Colors.grey, child: const SizedBox(height: 0.2, width: 100,)),
                  const SizedBox(height: 3),

                  CurrencyDoubleText(value: totalIncome - totalExpense, fontSize: 16),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 2),
      ]
    );
  }
}
