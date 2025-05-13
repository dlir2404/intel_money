import 'package:flutter/material.dart';
import 'package:intel_money/features/reports/widgets/year_income_analysis_chart.dart';
import 'package:intel_money/shared/component/filters/year_range_picker.dart';

import '../../../shared/component/filters/account_filter.dart';
import '../../../shared/component/filters/categories_filter.dart';

class YearIncomeAnalysis extends StatefulWidget {
  const YearIncomeAnalysis({super.key});

  @override
  State<YearIncomeAnalysis> createState() => _YearIncomeAnalysisState();
}

class _YearIncomeAnalysisState extends State<YearIncomeAnalysis> {
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
          child: YearIncomeAnalysisChart(),
        ),
      ],
    );
  }
}
