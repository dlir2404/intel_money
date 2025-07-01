import 'package:flutter/material.dart';
import 'package:intel_money/shared/component/typos/currency_double_text.dart';
import 'package:intel_money/shared/helper/app_time.dart';

import '../../../core/models/related_user.dart';
import '../../../core/models/transaction.dart';
import '../../../shared/const/enum/transaction_data_source_type.dart';
import '../../../shared/const/enum/transaction_type.dart';
import '../../transaction/screens/create_transaction_screen.dart';
import '../../transaction/widgets/transaction_group_by_day.dart';
import '../widgets/lend_borrow/lend_tab.dart';

class LendDetailScreen extends StatelessWidget {
  final RelatedUser borrower;
  final LendData data;
  final TransactionDataSourceType type;

  const LendDetailScreen({
    super.key,
    required this.borrower,
    required this.data,
    required this.type,
  });

  List<Widget> _buildTransactionList(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return [
        SizedBox(
          height: 80,
          child: const Center(
            child: Text(
              'Không có giao dịch nào',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      ];
    }

    // Group transactions by date
    Map<String, List<Transaction>> groupedTransactions = {};
    for (var transaction in transactions) {
      String dateKey = transaction.transactionDate.toString().split(' ')[0];
      if (groupedTransactions[dateKey] == null) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]!.add(transaction);
    }

    // Sort the grouped transactions by date in descending order
    final sortedKeys =
        groupedTransactions.keys.toList()
          ..sort((a, b) => DateTime.parse(b).compareTo(DateTime.parse(a)));

    // Build the list of widgets
    List<Widget> widgets = [];
    for (var date in sortedKeys) {
      widgets.add(
        TransactionGroupByDay(transactions: groupedTransactions[date]!),
      );
      widgets.add(const SizedBox(height: 12));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(borrower.name),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Tổng cho vay", style: TextStyle(fontSize: 16)),
                    CurrencyDoubleText(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      value: borrower.totalDebt,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Tổng đã thu (${(borrower.totalCollected / borrower.totalDebt * 100).toInt()}%)",
                      style: TextStyle(fontSize: 16),
                    ),
                    CurrencyDoubleText(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      value: borrower.totalCollected,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Cần thu (${((1 - borrower.totalCollected / borrower.totalDebt) * 100).toInt()}%)",
                      style: TextStyle(fontSize: 16),
                    ),
                    CurrencyDoubleText(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      value: borrower.totalDebt - borrower.totalCollected,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (type != TransactionDataSourceType.allTime)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Tổng cho vay",
                        style: TextStyle(fontSize: 16),
                      ),
                      CurrencyDoubleText(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        value: data.total,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tổng đã thu (${(data.collected / data.total * 100).toInt()}%)",
                        style: TextStyle(fontSize: 16),
                      ),
                      CurrencyDoubleText(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        value: data.collected,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          if (type != TransactionDataSourceType.allTime)
            const SizedBox(height: 16),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [..._buildTransactionList(data.transactions)],
              ),
            ),
          ),

          if (borrower.totalDebt > borrower.totalCollected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder:
                          (context) => CreateTransactionScreen(
                            onSave: () {
                              Navigator.of(context).pop();
                            },
                            transactionType: TransactionType.collectingDebt,
                            borrower: borrower,
                            amount:
                                borrower.totalDebt - borrower.totalCollected,
                          ),
                    ),
                  );
                },
                child: const Text("Thu nợ"),
              ),
            ),
        ],
      ),
    );
  }
}
