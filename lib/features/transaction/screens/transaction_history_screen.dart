import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intel_money/features/transaction/controller/transaction_controller.dart';
import 'package:intel_money/features/transaction/screens/select_data_source_type_screen.dart';
import 'package:intel_money/features/transaction/widgets/select_data_source_type_button.dart';
import 'package:intel_money/features/transaction/widgets/transaction_group_by_day.dart';
import 'package:intel_money/shared/const/enum/transaction_data_source_type.dart';
import 'package:provider/provider.dart';

import '../../../core/models/transaction.dart';
import '../../../core/state/transaction_state.dart';
import '../../../shared/helper/app_time.dart';
import '../widgets/total_in_out.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final TransactionDataSourceType? type;

  const TransactionHistoryScreen({
    super.key,
    this.type = TransactionDataSourceType.thisMonth,
  });

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  TransactionDataSourceType type = TransactionDataSourceType.thisMonth;
  Map<String, DateTime>? customTimeRange;

  List<Transaction> transactions = [];

  @override
  void initState() {
    super.initState();
    type = widget.type ?? TransactionDataSourceType.thisMonth;
  }

  List<Widget> _buildTransactionList(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return [
        SizedBox(
          height: 80,
          child: const Center(
            child: Text(
              'No transactions found',
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

  Future<void> _filterTransactions(List<Transaction> allTransactions) async {
    if (type == TransactionDataSourceType.allTime) {
      transactions = allTransactions;
    } else {
      Map<String, DateTime> timeRange = type.timeRange;

      // If the type is custom, use the custom time range
      if (type == TransactionDataSourceType.customDay ||
          type == TransactionDataSourceType.customMonth ||
          type == TransactionDataSourceType.customFromTo) {
        timeRange = customTimeRange!;
      }

      List<Transaction> result = [];
      for (var transaction in allTransactions) {
        // Include transactions on or after 'from' date and on or before 'to' date
        if ((transaction.transactionDate.isAtSameMomentAs(timeRange['from']!) ||
                transaction.transactionDate.isAfter(timeRange['from']!)) &&
            (transaction.transactionDate.isAtSameMomentAs(timeRange['to']!) ||
                transaction.transactionDate.isBefore(timeRange['to']!))) {
          result.add(transaction);
        }
      }

      transactions = result;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Center(
          child: const Text(
            'Transaction history',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<TransactionState>(
        builder: (context, state, _) {
          final allTransactions = state.transactions;

          return FutureBuilder(
            future: _filterTransactions(allTransactions),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              String buttonDisplayText = type.name;
              if (type == TransactionDataSourceType.customDay) {
                buttonDisplayText = AppTime.format(
                  time: customTimeRange!['from']!,
                );
              } else if (type == TransactionDataSourceType.customMonth) {
                buttonDisplayText = AppTime.format(
                  time: customTimeRange!['from']!,
                  pattern: "MM/YYYY",
                );
              } else if (type == TransactionDataSourceType.customFromTo) {
                buttonDisplayText =
                    "${AppTime.format(time: customTimeRange!['from']!)} - ${AppTime.format(time: customTimeRange!['to']!)}";
              }

              return Container(
                color: Colors.grey[200],
                child: Column(
                  children: [
                    SelectDataSourceTypeButton(
                      displayText: buttonDisplayText,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => SelectDataSourceTypeScreen(
                                  type: type,
                                  customTimeRange: customTimeRange,
                                  onSelect: (
                                    selectedType, {
                                    Map<String, DateTime>? timeRange,
                                  }) {
                                    if (timeRange != null) {
                                      customTimeRange = timeRange;
                                    }

                                    setState(() {
                                      type = selectedType;
                                    });
                                  },
                                ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    TotalInOut(transactions: transactions),
                    const SizedBox(height: 12),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [..._buildTransactionList(transactions)],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
