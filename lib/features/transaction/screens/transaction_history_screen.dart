import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intel_money/features/transaction/controller/transaction_controller.dart';
import 'package:intel_money/features/transaction/widgets/select_data_source_type_button.dart';
import 'package:intel_money/features/transaction/widgets/transaction_group_by_day.dart';
import 'package:intel_money/shared/const/enum/transaction_data_source_type.dart';
import 'package:provider/provider.dart';

import '../../../core/models/transaction.dart';
import '../../../core/state/transaction_state.dart';
import '../widgets/total_in_out.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final TransactionController _transactionController = TransactionController();
  TransactionDataSourceType type = TransactionDataSourceType.thisMonth;
  List<Transaction> transactions = [];

  bool isDataLoaded = false;

  List<Widget> _buildTransactionList(List<Transaction> transactions) {
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

  Future<void> _loadTransactions() async {
    if (!isDataLoaded) {
      final transactionState = Provider.of<TransactionState>(context, listen: false);

      if (transactionState.isLoad(type.keyStore)) {
        transactions = transactionState.getTransactions(type.keyStore);
      } else {
        transactions = await _transactionController.getTransactions(type);
      }

      setState(() {
        isDataLoaded = true;
      });
    }
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
      body: FutureBuilder(
        future: _loadTransactions(),
        builder: (context, snapshot) {

          return Container(
            color: Colors.grey[200],
            child: Column(
              children: [
                SelectDataSourceTypeButton(type: type),
                const SizedBox(height: 12),
                TotalInOut(transactions: transactions),
                const SizedBox(height: 12),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ..._buildTransactionList(transactions),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}
