import 'package:flutter/material.dart';

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
      child: Column(
        children: [
          MonthIncomeVsExpenseChart(),
        ],
      ),
    );
  }
}
