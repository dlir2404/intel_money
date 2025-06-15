import 'package:flutter/material.dart';
import 'package:intel_money/shared/component/typos/currency_double_text.dart';

import '../../../core/models/related_user.dart';
import '../../../core/models/transaction.dart';
import '../../../shared/const/enum/transaction_data_source_type.dart';
import '../../transaction/widgets/transaction_group_by_day.dart';
import '../widgets/lend_borrow/borrow_tab.dart';

class BorrowDetailScreen extends StatelessWidget {
  final RelatedUser lender;
  final BorrowData data;
  final TransactionDataSourceType type;

  const BorrowDetailScreen({
    super.key,
    required this.lender,
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
        title: Text(lender.name),
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
                    const Text("Tổng đi vay", style: TextStyle(fontSize: 16),),
                    CurrencyDoubleText(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      value: lender.totalLoan,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Tổng đã trả (${(lender.totalCollected / lender.totalDebt * 100).toInt()}%)",
                      style: TextStyle(fontSize: 16),
                    ),
                    CurrencyDoubleText(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      value: lender.totalPaid,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Phải trả (${((1 - lender.totalPaid / lender.totalLoan) * 100).toInt()}%)",
                      style: TextStyle(fontSize: 16)
                    ),
                    CurrencyDoubleText(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      value: lender.totalLoan - lender.totalPaid,
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
                  Text(type.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Tổng đi vay", style: TextStyle(fontSize: 16)),
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
                      Text("Tổng đã trả (${(data.paid / data.total * 100).toInt()}%)", style: TextStyle(fontSize: 16)),
                      CurrencyDoubleText(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        value: data.paid,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          if (type != TransactionDataSourceType.allTime)
            const SizedBox(height: 16,),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [..._buildTransactionList(data.transactions)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
