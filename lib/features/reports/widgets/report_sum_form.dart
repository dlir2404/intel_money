import 'package:flutter/material.dart';

import '../../../shared/component/typos/currency_double_text.dart';

class ReportSumForm extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;

  const ReportSumForm({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}
