import 'package:flutter/material.dart';
import 'package:intel_money/features/reports/widgets/year_expense_analysis.dart';

import '../widgets/day_expense_analysis.dart';
import '../widgets/day_income_analysis.dart';
import '../widgets/month_expense_analysis.dart';
import '../widgets/month_income_analysis.dart';
import '../widgets/year_income_analysis.dart';

class IncomeAnalysis extends StatefulWidget {
  const IncomeAnalysis({super.key});

  @override
  State<IncomeAnalysis> createState() => _IncomeAnalysisState();
}

class _IncomeAnalysisState extends State<IncomeAnalysis>
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
        title: Text("Income Analysis"),
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
              Tab(text: 'DAY'),
              Tab(text: 'MONTH'),
              Tab(text: 'YEAR'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                DayIncomeAnalysis(),
                MonthIncomeAnalysis(),
                YearIncomeAnalysis(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
