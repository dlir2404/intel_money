import 'package:flutter/material.dart';
import 'package:intel_money/features/transaction/screens/transactions_of_categories.dart';
import 'package:intel_money/shared/component/typos/currency_double_text.dart';

import '../../../core/models/analysis_data.dart';
import '../../../shared/helper/app_time.dart';

class MonthDetailAnalysis extends StatelessWidget {
  final List<AnalysisData> data;
  final AnalysisType type;

  const MonthDetailAnalysis({super.key, required this.data, required this.type});

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
              'Không có ghi chép',
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
                    title: AppTime.format(time: item.date, pattern: "MM/YYYY"),
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
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        type == AnalysisType.income
                            ? Colors.green
                            : Colors.redAccent,
                    radius: 20,
                    child: Text(
                      AppTime.format(time: item.date, pattern: "MM"),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppTime.format(time: item.date, pattern: "MM/YYYY"),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
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
          child: const Text("Chi tiết"),
        ),
        const SizedBox(height: 8),
        ..._buildDetails(context),
      ],
    );
  }
}

enum AnalysisType { income, expense }
