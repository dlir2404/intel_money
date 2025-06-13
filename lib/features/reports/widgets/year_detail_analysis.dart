import 'package:flutter/material.dart';
import 'package:intel_money/features/transaction/screens/transactions_of_categories.dart';
import 'package:intel_money/shared/component/typos/currency_double_text.dart';

import '../../../core/models/analysis_data.dart';
import '../../../shared/helper/app_time.dart';

class YearDetailAnalysis extends StatelessWidget {
  final List<AnalysisData> data;
  final AnalysisType type;

  const YearDetailAnalysis({super.key, required this.data, required this.type});

  List<Widget> _buildDetails(BuildContext context) {
    if (data.every(
      (item) =>
          item.compactStatisticData.totalIncome == 0 &&
          item.compactStatisticData.totalExpense == 0,
    )) {
      return [
        SizedBox(
          height: 80,
          child: const Center(
            child: Text(
              'No details available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      ];
    }

    return data.map((item) {
      if ((type == AnalysisType.income &&
              item.compactStatisticData.totalIncome == 0) ||
          (type == AnalysisType.expense &&
              item.compactStatisticData.totalExpense == 0)) {
        return const SizedBox.shrink();
      }

      return InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => TransactionsOfCategories(
                    title: AppTime.format(time: item.date, pattern: "YYYY"),
                    transactions:
                        type == AnalysisType.income
                            ? item.compactStatisticData.incomeTransactions
                            : item.compactStatisticData.expenseTransactions,
                  ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  AppTime.format(time: item.date, pattern: "YYYY"),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Row(
                children: [
                  type == AnalysisType.income
                      ? CurrencyDoubleText(
                        value: item.compactStatisticData.totalIncome,
                        color: Colors.green,
                      )
                      : CurrencyDoubleText(
                        value: item.compactStatisticData.totalExpense,
                        color: Colors.redAccent,
                      ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: const Text("Details"),
        ),
        const SizedBox(height: 8),
        ..._buildDetails(context),
      ],
    );
  }
}

enum AnalysisType { income, expense }
