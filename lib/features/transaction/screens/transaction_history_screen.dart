import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intel_money/features/transaction/widgets/select_data_source_type_button.dart';
import 'package:intel_money/features/transaction/widgets/transaction_group_by_day.dart';
import 'package:intel_money/features/transaction/widgets/transaction_item.dart';
import 'package:intel_money/shared/const/enum/transaction_data_source_type.dart';

import '../../../core/models/category.dart';
import '../../../core/models/transaction.dart';
import '../../../core/models/wallet.dart';
import '../../../shared/const/enum/transaction_type.dart';
import '../widgets/total_in_out.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  TransactionDataSourceType type = TransactionDataSourceType.thisMonth;

  @override
  Widget build(BuildContext context) {
    Category category = Category.fromContext(15);
    Wallet wallet = Wallet.fromContext(3);
    List<Transaction> mockTransactions = [
      Transaction(
        id: 1,
        amount: 100.0,
        transactionDate: DateTime.now(),
        type: TransactionType.expense,
        category: category,
        sourceWallet: wallet,
      ),
      Transaction(
        id: 2,
        amount: 200.0,
        transactionDate: DateTime.now(),
        type: TransactionType.expense,
        category: category,
        sourceWallet: wallet,
      ),
      Transaction(
        id: 3,
        amount: 700.0,
        transactionDate: DateTime.now(),
        type: TransactionType.expense,
        category: category,
        sourceWallet: wallet,
      ),

      Transaction(
        id: 3,
        amount: 700.0,
        transactionDate: DateTime.now(),
        type: TransactionType.expense,
        category: category,
        sourceWallet: wallet,
      ),

      Transaction(
        id: 3,
        amount: 700.0,
        transactionDate: DateTime.now(),
        type: TransactionType.expense,
        category: category,
        sourceWallet: wallet,
      ),

      Transaction(
        id: 3,
        amount: 700.0,
        transactionDate: DateTime.now(),
        type: TransactionType.expense,
        category: category,
        sourceWallet: wallet,
      ),
    ];

    List<Transaction> mockTransactions2 = [
      Transaction(
        id: 1,
        amount: 100.0,
        transactionDate: DateTime.now().subtract(const Duration(days: 1)),
        type: TransactionType.expense,
        category: category,
        sourceWallet: wallet,
      ),
      Transaction(
        id: 1,
        amount: 100.0,
        transactionDate: DateTime.now().subtract(const Duration(days: 1)),
        type: TransactionType.expense,
        category: category,
        sourceWallet: wallet,
      ),
    ];

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
      body: Container(
        color: Colors.grey[200],
        child: Column(
          children: [
            SelectDataSourceTypeButton(type: type),
            const SizedBox(height: 12),

            TotalInOut(transactions: []),
            const SizedBox(height: 12),

            TransactionGroupByDay(transactions: mockTransactions),
            const SizedBox(height: 12),

            TransactionGroupByDay(transactions: mockTransactions2),
          ],
        ),
      ),
    );
  }
}
