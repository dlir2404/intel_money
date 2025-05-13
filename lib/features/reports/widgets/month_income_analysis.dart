import 'package:flutter/material.dart';
import 'package:intel_money/shared/component/filters/account_filter.dart';
import 'package:intel_money/shared/component/filters/categories_filter.dart';
import 'package:intel_money/shared/component/filters/month_range_picker.dart';

import 'month_income_analysis_chart.dart';

class MonthIncomeAnalysis extends StatefulWidget {
  const MonthIncomeAnalysis({super.key});

  @override
  State<MonthIncomeAnalysis> createState() => _MonthIncomeAnalysisState();
}

class _MonthIncomeAnalysisState extends State<MonthIncomeAnalysis> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MonthRangePicker(),
        const SizedBox(height: 2),

        CategoriesFilter(),
        const SizedBox(height: 2),

        AccountFilter(),
        const SizedBox(height: 6),

        Container(
          color: Colors.white,
          padding: const EdgeInsets.only(top: 12, bottom: 12, left: 16),
          child: MonthIncomeAnalysisChart(),
        ),
      ],
    );
  }
}
