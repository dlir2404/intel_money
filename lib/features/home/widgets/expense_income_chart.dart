import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

import '../../../core/config/routes.dart';

class ExpenseIncomeChart extends StatefulWidget {
  const ExpenseIncomeChart({super.key});

  @override
  State<ExpenseIncomeChart> createState() => _ExpenseIncomeChartState();
}

class _ExpenseIncomeChartState extends State<ExpenseIncomeChart> {
  String _selectedTimeRange = 'Today';

  final List<String> _timeRanges = [
    'Today',
    'This week',
    'This month',
    'This quarter',
    'This year',
  ];

  final double _income = 5000; // Mock income value
  final double _expense = 3000; // Mock expense value

  Map<String, double> expenseRate = {
    "Food (28,6%)": 500000,
    "Shopping (68,6%)": 1200000,
    "Coffee (2,8%)": 50000,
  };

  @override
  Widget build(BuildContext context) {
    final incomeHeight = (_income / max(_income, _expense)) * 140;
    final expenseHeight = (_expense / max(_income, _expense)) * 140;

    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Expense vs Income", style: TextStyle(fontSize: 20)),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedTimeRange,
              items:
                  _timeRanges.map((String timeRange) {
                    return DropdownMenuItem<String>(
                      value: timeRange,
                      child: Text(
                        timeRange,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTimeRange = newValue!;
                });
              },
              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          SizedBox(
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
                              const Text(
                                'Income',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          Text(
                            '\$$_income',
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 18,
                            ),
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
                              Text(
                                'Expense',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          Text(
                            '\$$_expense',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),

                      Divider(color: Colors.grey[100]),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '\$${_income - _expense}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(16),
            height: 150,
            width: double.infinity,
            child: PieChart(
              dataMap: expenseRate,
              animationDuration: Duration(milliseconds: 800),
              chartType: ChartType.ring,
              ringStrokeWidth: 32,
              legendOptions: LegendOptions(
                showLegendsInRow: false,
                legendPosition: LegendPosition.right,
                showLegends: true,
                legendShape: BoxShape.circle,
                legendTextStyle: TextStyle(fontWeight: FontWeight.w400),
              ),
              chartValuesOptions: ChartValuesOptions(
                showChartValues: false,
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              AppRoutes.navigateToTransactionHistory(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Transaction history",
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
          )
        ],
      ),
    );
  }
}
