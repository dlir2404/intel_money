import 'package:flutter/material.dart';
import 'package:intel_money/features/reports/widgets/quarter_expense_vs_income_overview.dart';
import 'package:intel_money/features/reports/widgets/quarter_income_vs_expense_chart.dart';

class QuarterIncomeVsExpense extends StatefulWidget {
  const QuarterIncomeVsExpense({super.key});

  @override
  State<QuarterIncomeVsExpense> createState() => _QuarterExpenseVsIncomeState();
}

class _QuarterExpenseVsIncomeState extends State<QuarterIncomeVsExpense> {
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
              child: QuarterIncomeVsExpenseChart(),
            ),
            const SizedBox(height: 6),

            QuarterExpenseVsIncomeOverview(),
          ],
        ),
      ),
    );
  }
}
