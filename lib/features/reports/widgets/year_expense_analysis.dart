import 'package:flutter/material.dart';
import 'package:intel_money/features/reports/widgets/year_expense_analysis_chart.dart';
import 'package:intel_money/shared/component/filters/year_range_picker.dart';

import '../../../shared/component/filters/account_filter.dart';
import '../../../shared/component/filters/categories_filter.dart';

class YearExpenseAnalysis extends StatefulWidget {
  const YearExpenseAnalysis({super.key});

  @override
  State<YearExpenseAnalysis> createState() => _YearExpenseAnalysisState();
}

class _YearExpenseAnalysisState extends State<YearExpenseAnalysis> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        YearRangePicker(),
        const SizedBox(height: 2),

        CategoriesFilter(),
        const SizedBox(height: 2),

        AccountFilter(),
        const SizedBox(height: 6),

        Container(
          color: Colors.white,
          padding: const EdgeInsets.only(top: 12, bottom: 12, left: 16),
          child: YearExpenseAnalysisChart(),
        ),
      ],
    );
  }
}
