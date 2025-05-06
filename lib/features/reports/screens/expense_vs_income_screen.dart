import 'package:flutter/material.dart';

import '../widgets/current_expense_vs_income.dart';
import '../widgets/month_expense_vs_income.dart';

class ExpenseVsIncomeScreen extends StatefulWidget {
  const ExpenseVsIncomeScreen({super.key});

  @override
  State<ExpenseVsIncomeScreen> createState() => _ExpenseVsIncomeScreenState();
}

class _ExpenseVsIncomeScreenState extends State<ExpenseVsIncomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense vs Income'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            tabs: const [
              Tab(text: 'CURRENT'),
              Tab(text: 'MONTH'),
              Tab(text: 'QUARTER'),
              Tab(text: 'YEAR'),
              Tab(text: 'CUSTOM'),
            ],
          ),
          Expanded(
            child: TabBarView(
                controller: _tabController,
                children: const [
                  CurrentExpenseVsIncome(),
                  MonthExpenseVsIncome(),
                  Center(child: Text("Quarter")),
                  Center(child: Text("Year")),
                  Center(child: Text("Custom")),
                ]
            ),
          ),
        ],
      ),
    );
  }
}
