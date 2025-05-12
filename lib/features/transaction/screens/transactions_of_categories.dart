import 'package:flutter/material.dart';
import 'package:intel_money/core/models/category.dart';
import 'package:intel_money/features/transaction/widgets/transaction_item_v2.dart';
import 'package:intel_money/shared/const/enum/category_type.dart';
import 'package:provider/provider.dart';

import '../../../core/models/transaction.dart';
import '../../../core/state/transaction_state.dart';
import '../../../shared/component/typos/currency_double_text.dart';

class TransactionsOfCategories extends StatefulWidget {
  final Category category;
  final DateTime from;
  final DateTime to;

  const TransactionsOfCategories({
    super.key,
    required this.category,
    required this.from,
    required this.to,
  });

  @override
  State<TransactionsOfCategories> createState() =>
      _TransactionsOfCategoriesState();
}

class _TransactionsOfCategoriesState extends State<TransactionsOfCategories> {
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
    return Consumer<TransactionState>(
      builder: (context, state, _) {
        final transactions = state.filterTransactions(
          widget.from,
          widget.to,
          widget.category,
        );

        final groupedData = [];
        if (transactions.isNotEmpty) {
          groupedData.add({
            'category': widget.category,
            'transactions': transactions,
          });
        }

        if (widget.category.children.isNotEmpty) {
          for (var child in widget.category.children) {
            final childTransactions = state.filterTransactions(
              widget.from,
              widget.to,
              child,
            );

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
            title: Text(widget.category.name),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            centerTitle: true,
          ),
          body: Container(
            color: Colors.grey[200],
            child: Column(children: [
              ...groupedData.map((item) {
                return _buildGroupTransactions(
                  item['category'],
                  item['transactions'],
                );
              })
            ]),
          ),
        );
      },
    );
  }
}
