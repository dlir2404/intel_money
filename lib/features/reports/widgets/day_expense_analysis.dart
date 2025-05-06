import 'package:flutter/material.dart';
import 'package:intel_money/shared/component/filters/year_range_picker.dart';

import '../../../shared/component/filters/day_range_picker.dart';
import '../../../shared/component/filters/month_range_picker.dart';

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
        MonthRangePicker(),
        YearRangePicker()
      ],
    );
  }
}
