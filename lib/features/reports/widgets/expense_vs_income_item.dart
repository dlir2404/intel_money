import 'package:flutter/material.dart';
import 'package:intel_money/core/services/ad_service.dart';

import '../../../core/models/statistic_data.dart';
import '../../../shared/component/typos/currency_double_text.dart';
import '../../other/screens/detail_ratio_screen.dart';

class ExpenseVsIncomeItem extends StatelessWidget {
  final String title;
  final StatisticData statisticData;

  const ExpenseVsIncomeItem({
    super.key,
    required this.title,
    required this.statisticData,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        AdService().showAdIfEligible();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => DetailRatioScreen(title: title, statisticData: statisticData,)),
        );
      },
      child: Column(
        children: [
          Container(
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

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CurrencyDoubleText(
                      value: statisticData.totalIncome,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 6),

                    CurrencyDoubleText(
                      value: statisticData.totalExpense,
                      fontSize: 16,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 3),
                    Container(color: Colors.grey, child: const SizedBox(height: 0.2, width: 100,)),
                    const SizedBox(height: 3),

                    CurrencyDoubleText(value: statisticData.totalIncome - statisticData.totalExpense, fontSize: 16),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 2),
        ]
      ),
    );
  }
}
