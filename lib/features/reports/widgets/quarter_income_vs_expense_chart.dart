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
      GroupedBarData("Quý I", yearData.byQuarterStatistic![0].totalIncome),
      GroupedBarData("Quý II", yearData.byQuarterStatistic![1].totalIncome),
      GroupedBarData("Quý III", yearData.byQuarterStatistic![2].totalIncome),
      GroupedBarData("Quý IV", yearData.byQuarterStatistic![3].totalIncome),
    ];

    final expenseData = [
      GroupedBarData("Quý I", yearData.byQuarterStatistic![0].totalExpense),
      GroupedBarData("Quý II", yearData.byQuarterStatistic![1].totalExpense),
      GroupedBarData("Quý III", yearData.byQuarterStatistic![2].totalExpense),
      GroupedBarData("Quý IV", yearData.byQuarterStatistic![3].totalExpense),
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
