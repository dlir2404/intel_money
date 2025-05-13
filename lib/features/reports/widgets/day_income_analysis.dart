import 'package:flutter/material.dart';
import 'package:intel_money/shared/component/filters/categories_filter.dart';

import '../../../shared/component/filters/account_filter.dart';
import '../../../shared/component/filters/day_range_picker.dart';
import 'day_income_analysis_chart.dart';

class DayIncomeAnalysis extends StatefulWidget {
  const DayIncomeAnalysis({super.key});

  @override
  State<DayIncomeAnalysis> createState() => _DayIncomeAnalysisState();
}

class _DayIncomeAnalysisState extends State<DayIncomeAnalysis> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DayRangePicker(),
        const SizedBox(height: 2),

        CategoriesFilter(),
        const SizedBox(height: 2),

        AccountFilter(),
        const SizedBox(height: 6),

        Container(
          color: Colors.white,
          padding: const EdgeInsets.only(top: 12, bottom: 12, left: 16),
          child: DayIncomeAnalysisChart(),
        ),
      ],
    );
  }
}
