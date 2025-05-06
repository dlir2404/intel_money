import 'package:flutter/material.dart';

import 'month_expense_vs_income_overview.dart';
import 'month_income_vs_expense_chart.dart';

class MonthExpenseVsIncome extends StatefulWidget {
  const MonthExpenseVsIncome({super.key});

  @override
  State<MonthExpenseVsIncome> createState() => _MonthExpenseVsIncomeState();
}

class _MonthExpenseVsIncomeState extends State<MonthExpenseVsIncome> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: MonthIncomeVsExpenseChart(),
            ),
            const SizedBox(height: 6),

            MonthExpenseVsIncomeOverview(),
          ],
        ),
      ),
    );
  }
}
