import 'package:flutter/material.dart';
import 'package:intel_money/core/models/category.dart';
import 'package:intel_money/features/transaction/widgets/transaction_item_v2.dart';
import 'package:intel_money/shared/const/enum/category_type.dart';

import '../../../core/models/statistic_data.dart';
import '../../../core/models/transaction.dart';
import '../../../shared/component/typos/currency_double_text.dart';
import 'edit_transaction_screen.dart';

class TransactionsOfCategories extends StatefulWidget {
  final List<Transaction> transactions;
  final String title;
  final Function(List<Transaction>)? onListChanged;

  const TransactionsOfCategories({
    super.key,
    required this.transactions,
    required this.title, this.onListChanged,
  });

  @override
  State<TransactionsOfCategories> createState() =>
      _TransactionsOfCategoriesState();
}

class _TransactionsOfCategoriesState extends State<TransactionsOfCategories> {
  List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _transactions = widget.transactions;
  }

  Widget _buildGroupTransactions(
    Category category,
    List<Transaction> transactions,
  ) {
    final totalValue = transactions.fold(
      0.0,
      (previousValue, element) => previousValue + element.amount.abs(),
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
                InkWell(
                  onTap: () async {
                    final returnData = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                EditTransactionScreen(transaction: item),
                      ),
                    );

                    if (returnData != null &&
                        returnData['removedTransaction'] != null) {
                      // Handle transaction removal
                      setState(() {
                        _transactions.remove(item);
                      });

                      if (widget.onListChanged != null) {
                        widget.onListChanged!(_transactions);
                      }
                    } else if (returnData != null &&
                        returnData['updatedTransaction'] != null) {
                      // Handle transaction update
                      final updatedTransaction =
                          returnData['updatedTransaction'] as Transaction;
                      setState(() {
                        _transactions.remove(item);
                        _transactions.add(updatedTransaction);
                      });

                      if (widget.onListChanged != null) {
                        widget.onListChanged!(_transactions);
                      }
                    }
                  },
                  child: TransactionItemV2(transaction: item),
                ),
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
    final Map<Category, List<Transaction>> groupedData = {};
    for (var transaction in _transactions) {
      final cat = transaction.category!;
      if (!groupedData.containsKey(cat)) {
        groupedData[cat] = [];
      }
      groupedData[cat]!.add(transaction);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey[200],
        child: SingleChildScrollView(
          child: Column(
            children: [
              ...groupedData.entries.map((item) {
                return _buildGroupTransactions(item.key, item.value);
              }),
            ],
          ),
        ),
      ),
    );
  }
}
