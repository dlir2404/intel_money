import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/statistic_data.dart';
import '../../../core/state/statistic_state.dart';
import '../../../shared/component/charts/grouped_bar_chart.dart';

class QuarterIncomeVsExpenseChart extends StatelessWidget {
  const QuarterIncomeVsExpenseChart({super.key});

  List<List<GroupedBarData>> _createData(StatisticData yearData) {
    if (yearData.byQuarterStatistic == null || yearData.byQuarterStatistic!.isEmpty) {
      return [];
    }

    final incomeData = [
      GroupedBarData("Quarter I", yearData.byQuarterStatistic![0].totalIncome),
      GroupedBarData("Quarter II", yearData.byQuarterStatistic![1].totalIncome),
      GroupedBarData("Quarter III", yearData.byQuarterStatistic![2].totalIncome),
      GroupedBarData("Quarter IV", yearData.byQuarterStatistic![3].totalIncome),
    ];

    final expenseData = [
      GroupedBarData("Quarter I", yearData.byQuarterStatistic![0].totalExpense),
      GroupedBarData("Quarter II", yearData.byQuarterStatistic![1].totalExpense),
      GroupedBarData("Quarter III", yearData.byQuarterStatistic![2].totalExpense),
      GroupedBarData("Quarter IV", yearData.byQuarterStatistic![3].totalExpense),
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
        titles: ["Income", "Expense"],
        height: 300,
      );
    });
  }
}
