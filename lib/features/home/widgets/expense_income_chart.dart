import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intel_money/features/other/screens/detail_ratio_screen.dart';
import 'package:intel_money/shared/component/typos/currency_double_text.dart';
import 'package:intel_money/shared/const/enum/transaction_data_source_type.dart';
import 'package:intel_money/shared/helper/formatter.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

import '../../../core/config/routes.dart';
import '../../../core/models/statistic_data.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/statistic_state.dart';
import '../../../shared/component/charts/donut_chart.dart';
import '../../../shared/const/enum/statistic_type.dart';
import '../../../shared/helper/app_time.dart';
import '../../transaction/screens/transaction_history_screen.dart';

class ExpenseIncomeChart extends StatefulWidget {
  const ExpenseIncomeChart({super.key});

  @override
  State<ExpenseIncomeChart> createState() => _ExpenseIncomeChartState();
}

class _ExpenseIncomeChartState extends State<ExpenseIncomeChart> {
  StatisticThisTime type = StatisticThisTime.today;

  Widget _columnChart(
    double incomeHeight,
    double expenseHeight,
    double income,
    double expense,
  ) {
    return SizedBox(
      height: 140,
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: 50,
            child: Container(height: incomeHeight, color: Colors.green),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 50,
            child: Container(height: expenseHeight, color: Colors.red),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Thu', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    CurrencyDoubleText(
                      value: income,
                      color: Colors.green,
                      fontSize: 18,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('Chi', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    CurrencyDoubleText(
                      value: expense,
                      color: Colors.red,
                      fontSize: 18,
                    ),
                  ],
                ),

                Divider(color: Colors.grey[100]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Chênh lệch', style: TextStyle(fontSize: 16)),
                    CurrencyDoubleText(value: income - expense, fontSize: 18),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pieChart(Map<String, double> expenseRate) {
    return AppDonutChart(
      dataMap: expenseRate,
      width: 150,
      height: 150,
      ringStrokeWidth: 32,
      showLegends: true,
      showLegendsInRow: true,
    );
  }

  List<Widget> _buildChart(StatisticData statisticData) {
    final income = statisticData.totalIncome;
    final expense = statisticData.totalExpense;

    double incomeHeight = 0;
    double expenseHeight = 0;

    final double maxVal = max(income, expense);
    if (maxVal != 0) {
      incomeHeight = (income / maxVal) * 140;
      expenseHeight = (expense / maxVal) * 140;
    }

    List<Widget> chartWidgets = [];

    chartWidgets.add(
      _columnChart(incomeHeight, expenseHeight, income, expense),
    );
    chartWidgets.add(const SizedBox(height: 40));

    if (expense == 0){
      chartWidgets.add(const SizedBox(
          height: 160,
          child: Center(child: Text("Không có chi tiêu nào"))
      ));
    } else {
      Map<String, double> expenseRate = {};
      for (var data in statisticData.byCategoryExpense) {
        expenseRate["${data.category.name} (${Formatter.formatCurrency(data.amount * 100 / expense)}%)"] =
            data.amount;
      }
      chartWidgets.add(_pieChart(expenseRate));
    }

    return chartWidgets;
  }

  StatisticData? _getStatisticData(StatisticState statisticState) {
    switch (type) {
      case StatisticThisTime.today:
        return statisticState.todayStatisticData;
      case StatisticThisTime.thisWeek:
        return statisticState.thisWeekStatisticData;
      case StatisticThisTime.thisMonth:
        return statisticState.thisMonthStatisticData;
      case StatisticThisTime.thisQuarter:
        return statisticState.thisQuarterStatisticData;
      case StatisticThisTime.thisYear:
        return statisticState.thisYearStatisticData;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statisticState = Provider.of<StatisticState>(context);
    final statisticData = _getStatisticData(statisticState) ?? StatisticData.defaultData();

    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () {
          AdService().showAdIfEligible();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => DetailRatioScreen(title: type.name, statisticData: statisticData,)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Tình hình thu chi", style: TextStyle(fontSize: 20)),
            DropdownButtonHideUnderline(
              child: DropdownButton<StatisticThisTime>(
                value: type,
                items:
                    StatisticThisTime.values.map((StatisticThisTime time) {
                      return DropdownMenuItem<StatisticThisTime>(
                        value: time,
                        child: Text(
                          time.name,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      );
                    }).toList(),
                onChanged: (StatisticThisTime? newValue) {
                  setState(() {
                    type = newValue!;
                  });
                },
                icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
        
            if ((statisticData.totalIncome != 0 ||
                    statisticData.totalExpense != 0))
              ..._buildChart(statisticData),
        
            if ((statisticData.totalIncome == 0 &&
                    statisticData.totalExpense == 0))
              SizedBox(
                height: 160,
                child: Center(child: const Text("Không có ghi chép nào")),
              ),
        
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                TransactionDataSourceType sourceType = TransactionDataSourceType.thisMonth;
                switch (type) {
                  case StatisticThisTime.today:
                    sourceType = TransactionDataSourceType.today;
                    break;
                  case StatisticThisTime.thisWeek:
                    sourceType = TransactionDataSourceType.thisWeek;
                    break;
                  case StatisticThisTime.thisMonth:
                    sourceType = TransactionDataSourceType.thisMonth;
                    break;
                  case StatisticThisTime.thisQuarter:
                    final quarter = AppTime.getCurrentQuarter();
                    if (quarter == 1) {
                      sourceType = TransactionDataSourceType.quarter1;
                    } else if (quarter == 2) {
                      sourceType = TransactionDataSourceType.quarter2;
                    } else if (quarter == 3) {
                      sourceType = TransactionDataSourceType.quarter3;
                    } else if (quarter == 4) {
                      sourceType = TransactionDataSourceType.quarter4;
                    }
                    break;
                  case StatisticThisTime.thisYear:
                    sourceType = TransactionDataSourceType.thisYear;
                    break;
                }

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TransactionHistoryScreen(
                      type: sourceType,
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  Expanded(child: const SizedBox()),
                  Text(
                    "Lịch sử giao dịch",
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
