import 'package:flutter/material.dart';
import 'package:intel_money/core/state/statistic_state.dart';
import 'package:provider/provider.dart';

import '../../../core/models/statistic_data.dart';
import 'expense_vs_income_item.dart';

class CurrentExpenseVsIncome extends StatefulWidget {
  const CurrentExpenseVsIncome({super.key});

  @override
  State<CurrentExpenseVsIncome> createState() => _CurrentExpenseVsIncomeState();
}

class _CurrentExpenseVsIncomeState extends State<CurrentExpenseVsIncome> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: Consumer<StatisticState>(
        builder: (context, state, _) {
          final today = state.todayStatisticData ?? StatisticData.defaultData();
          final thisWeek =
              state.thisWeekStatisticData ?? StatisticData.defaultData();
          final thisMonth =
              state.thisMonthStatisticData ?? StatisticData.defaultData();
          final thisQuarter =
              state.thisQuarterStatisticData ?? StatisticData.defaultData();
          final thisYear =
              state.thisYearStatisticData ?? StatisticData.defaultData();

          return Column(
            children: [
              ExpenseVsIncomeItem(
                title: "Hôm nay",
                statisticData: today,
              ),

              ExpenseVsIncomeItem(
                title: "Tuần này",
                statisticData: thisWeek,
              ),

              ExpenseVsIncomeItem(
                title: "Tháng này",
                statisticData: thisMonth,
              ),

              ExpenseVsIncomeItem(
                title: "Quý này",
                statisticData: thisQuarter,
              ),

              ExpenseVsIncomeItem(
                title: "Năm nay",
                statisticData: thisYear,
              ),
            ],
          );
        },
      ),
    );
  }
}
