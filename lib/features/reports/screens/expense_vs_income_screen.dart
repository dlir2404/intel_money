import 'package:flutter/material.dart';
import 'package:intel_money/features/reports/widgets/custom_income_vs_expense.dart';

import '../widgets/current_expense_vs_income.dart';
import '../widgets/month_expense_vs_income.dart';
import '../widgets/quarter_income_vs_expense.dart';
import '../widgets/year_income_vs_expense.dart';

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
        title: Text('Tình hình thu chi'),
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
              Tab(text: 'Hiện tại'),
              Tab(text: 'Tháng'),
              Tab(text: 'Quý'),
              Tab(text: 'Năm'),
              Tab(text: 'Tùy chọn'),
            ],
          ),
          Expanded(
            child: TabBarView(
                controller: _tabController,
                children: const [
                  CurrentExpenseVsIncome(),
                  MonthExpenseVsIncome(),
                  QuarterIncomeVsExpense(),
                  YearIncomeVsExpense(),
                  CustomIncomeVsExpense(),
                ]
            ),
          ),
        ],
      ),
    );
  }
}
