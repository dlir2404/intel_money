import 'package:flutter/material.dart';
import 'package:intel_money/core/models/category.dart';
import 'package:intel_money/features/transaction/widgets/transaction_item_v2.dart';
import 'package:intel_money/shared/const/enum/category_type.dart';

import '../../../core/models/statistic_data.dart';
import '../../../core/models/transaction.dart';
import '../../../shared/component/typos/currency_double_text.dart';

class TransactionsOfCategories extends StatelessWidget {
  final ByCategoryData byCategoryData;

  const TransactionsOfCategories({super.key, required this.byCategoryData});

  Widget _buildGroupTransactions(
    Category category,
    List<Transaction> transactions,
  ) {
    final totalValue = transactions.fold(
      0.0,
      (previousValue, element) => previousValue + element.amount,
    );

    return Container(
      color: Colors.white,
      child: ExpansionTile(
        collapsedShape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.transparent),
        ),
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.transparent),
        ),
        backgroundColor: Colors.white,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: category.icon.color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.icon.icon,
                color: category.icon.color,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Text(
                category.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 12),

            CurrencyDoubleText(
              value: totalValue,
              color:
                  CategoryType.values
                      .firstWhere((item) => item == category.type)
                      .color,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            const SizedBox(width: 12),
          ],
        ),
        children: [
          ...transactions.map((item) {
            return Column(
              children: [
                TransactionItemV2(transaction: item),
                Divider(height: 0, thickness: 0.5),
              ],
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = byCategoryData.category;

    final transactions =
        byCategoryData.transactions.where((item) {
          return item.category!.id == category.id;
        }).toList();

    final groupedData = [];
    if (transactions.isNotEmpty) {
      groupedData.add({'category': category, 'transactions': transactions});
    }

    if (category.children.isNotEmpty) {
      for (var child in category.children) {
        final childTransactions =
            byCategoryData.transactions.where((item) {
              return item.category!.id == child.id;
            }).toList();

        if (childTransactions.isNotEmpty) {
          groupedData.add({
            'category': child,
            'transactions': childTransactions,
          });
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey[200],
        child: SingleChildScrollView(
          child: Column(
            children: [
              ...groupedData.map((item) {
                return _buildGroupTransactions(
                  item['category'],
                  item['transactions'],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
