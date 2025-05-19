import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/statistic_data.dart';
import '../../../core/state/statistic_state.dart';
import '../../../shared/component/charts/grouped_bar_chart.dart';

class CustomIncomeVsExpenseChart extends StatelessWidget {
  final StatisticData data;
  final String xAxisLabel;
  const CustomIncomeVsExpenseChart({super.key, required this.data, required this.xAxisLabel});

  List<List<GroupedBarData>> _createData() {
    final incomeData = [
      GroupedBarData(xAxisLabel, data.totalIncome),
    ];

    final expenseData = [
      GroupedBarData(xAxisLabel, data.totalExpense),
    ];

    return [
      incomeData,
      expenseData,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final preparedData = _createData();

    return GroupedBarChart(
      seriesList: preparedData,
      colors: [
        Colors.green,
        Colors.red,
      ],
      titles: ["Income", "Expense"],
      height: 300,
    );
  }
}
