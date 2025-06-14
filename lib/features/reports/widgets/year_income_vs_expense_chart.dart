import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/statistic_data.dart';
import '../../../core/state/statistic_state.dart';
import '../../../shared/component/charts/grouped_bar_chart.dart';

class YearIncomeVsExpenseChart extends StatelessWidget {
  const YearIncomeVsExpenseChart({super.key});

  List<List<GroupedBarData>> _createData(StatisticData yearData) {
    if (yearData.byQuarterStatistic == null) {
      return [];
    }

    final incomeData = [
      GroupedBarData("2025", yearData.totalIncome),
    ];

    final expenseData = [
      GroupedBarData("2025", yearData.totalExpense),
    ];

    return [
      incomeData,
      expenseData,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticState>(builder: (context, state, _) {
      final yearData = state.thisYearStatisticData ?? StatisticData.defaultData();
      final data = _createData(yearData);

      return GroupedBarChart(
        seriesList: data,
        colors: [
          Colors.green,
          Colors.red,
        ],
        titles: ["Thu", "Chi"],
        height: 300,
      );
    });
  }
}
