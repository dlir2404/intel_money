import 'package:flutter/material.dart';
import 'package:intel_money/shared/const/enum/time/month.dart';
import 'package:provider/provider.dart';

import '../../../core/models/statistic_data.dart';
import '../../../core/state/statistic_state.dart';
import 'expense_vs_income_item.dart';

class MonthExpenseVsIncomeOverview extends StatelessWidget {
  const MonthExpenseVsIncomeOverview({super.key});

  List<PreparedData> _prepareData(StatisticData yearData) {
    if (yearData.byMonthStatistic == null ||
        yearData.byMonthStatistic!.isEmpty) {
      return [];
    }

    List<PreparedData> data = [];
    for (var i = yearData.byMonthStatistic!.length - 1; i >= 0; i--) {
      final monthData = yearData.byMonthStatistic![i];
      if (monthData.totalIncome > 0 || monthData.totalExpense > 0) {
        data.add(
          PreparedData(
            title: Month.values.firstWhere((e) => e.value == i + 1).name,
            statisticData: monthData
          ),
        );
      }
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticState>(
      builder: (context, state, _) {
        final yearData =
            state.thisYearStatisticData ?? StatisticData.defaultData();
        final data = _prepareData(yearData);

        return Column(
          children:
              data.map((monthData) {
                return ExpenseVsIncomeItem(
                  title: monthData.title,
                  statisticData: monthData.statisticData,
                );
              }).toList(),
        );
      },
    );
  }
}

class PreparedData {
  final String title;
  final StatisticData statisticData;

  PreparedData({
    required this.title,
    required this.statisticData,
  });
}
