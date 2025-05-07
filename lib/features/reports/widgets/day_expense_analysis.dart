import 'package:flutter/material.dart';
import 'package:intel_money/shared/component/filters/categories_filter.dart';

import '../../../shared/component/filters/account_filter.dart';
import '../../../shared/component/filters/day_range_picker.dart';

class DayExpenseAnalysis extends StatefulWidget {
  const DayExpenseAnalysis({super.key});

  @override
  State<DayExpenseAnalysis> createState() => _DayExpenseAnalysisState();
}

class _DayExpenseAnalysisState extends State<DayExpenseAnalysis> {
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


      ],
    );
  }
}
