import 'package:flutter/material.dart';
import 'package:intel_money/shared/const/enum/month.dart';
import 'package:provider/provider.dart';

import '../../../core/models/statistic_data.dart';
import '../../../core/state/statistic_state.dart';
import '../../../shared/const/enum/quarter.dart';
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
        totalIncome: yearData.totalIncome,
        totalExpense: yearData.totalExpense,
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
                  totalIncome: yearData.totalIncome,
                  totalExpense: yearData.totalExpense,
                );
              }).toList(),
        );
      },
    );
  }
}

class PreparedData {
  final String title;
  final double totalIncome;
  final double totalExpense;

  PreparedData({
    required this.title,
    required this.totalIncome,
    required this.totalExpense,
  });
}
