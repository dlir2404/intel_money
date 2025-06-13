import 'package:flutter/material.dart';
import 'package:intel_money/features/reports/widgets/year_expense_analysis.dart';

import '../widgets/day_expense_analysis.dart';
import '../widgets/month_expense_analysis.dart';

class ExpenseAnalysis extends StatefulWidget {
  const ExpenseAnalysis({super.key});

  @override
  State<ExpenseAnalysis> createState() => _ExpenseAnalysisState();
}

class _ExpenseAnalysisState extends State<ExpenseAnalysis>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: Text("Phân tích chi tiêu"),
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
            tabs: const [
              Tab(text: 'Ngày'),
              Tab(text: 'Tháng'),
              Tab(text: 'Năm'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                DayExpenseAnalysis(),
                MonthExpenseAnalysis(),
                YearExpenseAnalysis(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
