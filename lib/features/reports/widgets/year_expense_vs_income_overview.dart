import 'package:flutter/material.dart';
import 'package:intel_money/shared/const/enum/time/month.dart';
import 'package:provider/provider.dart';

import '../../../core/models/statistic_data.dart';
import '../../../core/state/statistic_state.dart';
import '../../../shared/const/enum/time/quarter.dart';
import 'expense_vs_income_item.dart';

class YearExpenseVsIncomeOverview extends StatelessWidget {
  const YearExpenseVsIncomeOverview({super.key});

  List<PreparedData> _prepareData(StatisticData yearData) {
    if (yearData.totalIncome == 0 && yearData.totalExpense == 0) {
      return [];
    }

    List<PreparedData> data = [
      PreparedData(
        title: "2025",
        statisticData: yearData,
      )
    ];

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
              data.map((yearData) {
                return ExpenseVsIncomeItem(
                  title: yearData.title,
                  statisticData: yearData.statisticData,
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
