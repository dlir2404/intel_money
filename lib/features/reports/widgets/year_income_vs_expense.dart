import 'package:flutter/material.dart';
import 'package:intel_money/features/reports/widgets/quarter_income_vs_expense_chart.dart';
import 'package:intel_money/features/reports/widgets/year_income_vs_expense_chart.dart';

class YearIncomeVsExpense extends StatefulWidget {
  const YearIncomeVsExpense({super.key});

  @override
  State<YearIncomeVsExpense> createState() => _QuarterExpenseVsIncomeState();
}

class _QuarterExpenseVsIncomeState extends State<YearIncomeVsExpense> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: Column(children: [YearIncomeVsExpenseChart()]),
    );
  }
}
