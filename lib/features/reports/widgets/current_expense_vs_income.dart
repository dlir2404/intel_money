import 'package:flutter/material.dart';
import 'package:intel_money/core/state/statistic_state.dart';
import 'package:intel_money/features/reports/widgets/report_sum_form.dart';
import 'package:provider/provider.dart';

import '../../../core/models/statistic_data.dart';

class CurrentExpenseVsIncome extends StatefulWidget {
  const CurrentExpenseVsIncome({super.key});

  @override
  State<CurrentExpenseVsIncome> createState() => _CurrentExpenseVsIncomeState();
}

class _CurrentExpenseVsIncomeState extends State<CurrentExpenseVsIncome> {
  Widget _buildItem(String title, double totalIncome, double totalExpense) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          ReportSumForm(totalIncome: totalIncome, totalExpense: totalExpense),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: Consumer<StatisticState>(
        builder: (context, state, _) {
          final today = state.todayStatisticData ?? StatisticData.defaultData();
          final thisWeek = state.thisWeekStatisticData ?? StatisticData.defaultData();
          final thisMonth = state.thisMonthStatisticData ?? StatisticData.defaultData();
          final thisQuarter = state.thisQuarterStatisticData ?? StatisticData.defaultData();
          final thisYear = state.thisYearStatisticData ?? StatisticData.defaultData();

          return Column(
            children: [
              _buildItem("Today", today.totalIncome, today.totalExpense),
              const SizedBox(height: 1),

              _buildItem(
                "This week",
                thisWeek.totalIncome,
                thisWeek.totalExpense,
              ),
              const SizedBox(height: 1),

              _buildItem(
                "This month",
                thisMonth.totalIncome,
                thisMonth.totalExpense,
              ),
              const SizedBox(height: 1),

              _buildItem(
                "This quarter",
                thisQuarter.totalIncome,
                thisQuarter.totalExpense,
              ),
              const SizedBox(height: 1),

              _buildItem(
                "This year",
                thisYear.totalIncome,
                thisYear.totalExpense,
              ),
              const SizedBox(height: 1),
            ],
          );
        },
      ),
    );
  }
}
