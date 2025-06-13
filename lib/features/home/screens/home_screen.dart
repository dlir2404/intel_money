import 'package:flutter/material.dart';
import 'package:intel_money/features/home/widgets/expense_income_chart.dart';
import 'package:intel_money/features/home/widgets/home_balance.dart';
import 'package:intel_money/features/home/widgets/home_section.dart';
import 'package:provider/provider.dart';

import '../../../core/state/app_state.dart';
import '../../reports/widgets/month_income_vs_expense_chart.dart';
import '../widgets/recent_lend_borrow.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.user;

    return Scaffold(
      appBar: AppBar(
        title: Text("Xin chào ${user?.name}!"),
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HomeBalance(totalBalance: user?.totalBalance ?? 0),
            Container(
              width: double.infinity,
              color: Colors.grey[200],
              child: Column(
                children: [const SizedBox(height: 16), ExpenseIncomeChart()],
              ),
            ),
            const SizedBox(height: 16),

            HomeSection(
              title: "Phân tích chi tiêu năm nay",
              child: MonthIncomeVsExpenseChart(),
            ),
            const SizedBox(height: 16),

            HomeSection(
              title: "Theo dõi vay nợ",
              child: RecentLendBorrow(),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
