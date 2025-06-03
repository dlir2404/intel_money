import 'package:flutter/material.dart';
import 'package:intel_money/shared/const/enum/time/month.dart';
import 'package:provider/provider.dart';

import '../../../core/models/statistic_data.dart';
import '../../../core/state/statistic_state.dart';
import '../../../shared/const/enum/time/quarter.dart';
import 'expense_vs_income_item.dart';

class QuarterExpenseVsIncomeOverview extends StatelessWidget {
  const QuarterExpenseVsIncomeOverview({super.key});

  List<PreparedData> _prepareData(StatisticData yearData) {
    if (yearData.byQuarterStatistic == null ||
        yearData.byQuarterStatistic!.isEmpty) {
      return [];
    }

    List<PreparedData> data = [];
    for (var i = yearData.byQuarterStatistic!.length - 1; i >= 0; i--) {
      final quarterData = yearData.byQuarterStatistic![i];
      if (quarterData.totalIncome > 0 || quarterData.totalExpense > 0) {
        data.add(
          PreparedData(
            title: Quarter.values.firstWhere((e) => e.value == i + 1).name,
            statisticData: quarterData
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
              data.map((quarterData) {
                return ExpenseVsIncomeItem(
                  title: quarterData.title,
                  statisticData: quarterData.statisticData,
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
