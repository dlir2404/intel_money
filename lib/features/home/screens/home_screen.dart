import 'package:flutter/material.dart';
import 'package:intel_money/features/home/widgets/expense_income_chart.dart';
import 'package:intel_money/features/home/widgets/home_balance.dart';
import 'package:provider/provider.dart';

import '../../../core/models/user.dart';
import '../../../core/state/app_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final double _income = 5000; // Mock income
  final double _expense = 3000; // Mock expense
  final Map<String, double> _expenseCategories = {
    "Food": 40,
    "Transport": 30,
    "Entertainment": 20,
    "Others": 10,
  }; // Mock expense categories

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.user;

    return Scaffold(
      appBar: AppBar(
        title: Text("Hello ${user?.name}!"),
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: () {
              // Sync data action
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notification page
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HomeBalance(totalBalance: user?.totalBalance ?? 0),
            Container(
              width: double.infinity,
              color: Colors.grey[200],
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  ExpenseIncomeChart(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
