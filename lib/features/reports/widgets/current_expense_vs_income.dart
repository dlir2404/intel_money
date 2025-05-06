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
                title: "Today",
                totalIncome: today.totalIncome,
                totalExpense: today.totalExpense,
              ),

              ExpenseVsIncomeItem(
                title: "This week",
                totalIncome: thisWeek.totalIncome,
                totalExpense: thisWeek.totalExpense,
              ),

              ExpenseVsIncomeItem(
                title: "This month",
                totalIncome: thisMonth.totalIncome,
                totalExpense: thisMonth.totalExpense,
              ),

              ExpenseVsIncomeItem(
                title: "This quarter",
                totalIncome: thisQuarter.totalIncome,
                totalExpense: thisQuarter.totalExpense,
              ),

              ExpenseVsIncomeItem(
                title: "This year",
                totalIncome: thisYear.totalIncome,
                totalExpense: thisYear.totalExpense,
              ),
            ],
          );
        },
      ),
    );
  }
}
