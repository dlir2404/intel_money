import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/statistic_data.dart';
import '../../../core/state/statistic_state.dart';
import '../../../shared/component/charts/diverging_stacked_bar_chart.dart';

class MonthIncomeVsExpenseChart extends StatelessWidget {
  const MonthIncomeVsExpenseChart({super.key});

  List<List<DivergingStackedBarData>> _createData(StatisticData yearData) {
    if (yearData.byMonthStatistic == null || yearData.byMonthStatistic!.isEmpty) {
      return [];
    }

    final incomeData = [
      DivergingStackedBarData("1", yearData.byMonthStatistic![0].totalIncome),
      DivergingStackedBarData("2", yearData.byMonthStatistic![1].totalIncome),
      DivergingStackedBarData("3", yearData.byMonthStatistic![2].totalIncome),
      DivergingStackedBarData("4", yearData.byMonthStatistic![3].totalIncome),
      DivergingStackedBarData("5", yearData.byMonthStatistic![4].totalIncome),
      DivergingStackedBarData("6", yearData.byMonthStatistic![5].totalIncome),
      DivergingStackedBarData("7", yearData.byMonthStatistic![6].totalIncome),
      DivergingStackedBarData("8", yearData.byMonthStatistic![7].totalIncome),
      DivergingStackedBarData("9", yearData.byMonthStatistic![8].totalIncome),
      DivergingStackedBarData("10", yearData.byMonthStatistic![9].totalIncome),
      DivergingStackedBarData("11", yearData.byMonthStatistic![10].totalIncome),
      DivergingStackedBarData("12", yearData.byMonthStatistic![11].totalIncome),
    ];

    final expenseData = [
      DivergingStackedBarData("1", yearData.byMonthStatistic![0].totalExpense),
      DivergingStackedBarData("2", yearData.byMonthStatistic![1].totalExpense),
      DivergingStackedBarData("3", yearData.byMonthStatistic![2].totalExpense),
      DivergingStackedBarData("4", yearData.byMonthStatistic![3].totalExpense),
      DivergingStackedBarData("5", yearData.byMonthStatistic![4].totalExpense),
      DivergingStackedBarData("6", yearData.byMonthStatistic![5].totalExpense),
      DivergingStackedBarData("7", yearData.byMonthStatistic![6].totalExpense),
      DivergingStackedBarData("8", yearData.byMonthStatistic![7].totalExpense),
      DivergingStackedBarData("9", yearData.byMonthStatistic![8].totalExpense),
      DivergingStackedBarData("10", yearData.byMonthStatistic![9].totalExpense),
      DivergingStackedBarData("11", yearData.byMonthStatistic![10].totalExpense),
      DivergingStackedBarData("12", yearData.byMonthStatistic![11].totalExpense),
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

      return DivergingStackedBarChart(
        upData: data.first,
        downData: data.last,
        upTitle: "Income",
        downTitle: "Expense",
        height: 300,
      );
    });
  }
}
