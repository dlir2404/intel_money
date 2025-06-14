import 'package:flutter/material.dart';
import 'package:intel_money/features/reports/screens/expense_vs_income_screen.dart';
import 'package:intel_money/features/reports/screens/income_analysis.dart';
import 'package:intel_money/features/reports/screens/lend_borrow_screen.dart';

import '../../../core/services/ad_service.dart';
import 'expense_analysis.dart';
import 'financial_statement_screen.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  // Define a type for the navigation function to fix typing issues
  static final List<Map<String, dynamic>> items = [
    {
      'icon': Icons.bar_chart_rounded,
      'title': 'Tài chính hiện tại',
      'color': Colors.blue,
      'ontap': (BuildContext context) {
        AdService().showAdIfEligible();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const FinancialStatementScreen(),
          ),
        );
      }, // Added missing closing brace here
    },
    {
      'icon': Icons.stacked_line_chart_rounded,
      'title': 'Tình hình thu chi',
      'color': Colors.greenAccent,
      'ontap': (BuildContext context) {
        AdService().showAdIfEligible();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ExpenseVsIncomeScreen(),
          ),
        );
      }, // Added null to maintain consistent keys
    },
    {
      'icon': Icons.insert_chart_outlined_rounded,
      'title': 'Phân tích chi tiêu',
      'color': Colors.red,
      'ontap': (BuildContext context) {
        AdService().showAdIfEligible();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ExpenseAnalysis()),
        );
      },
    },
    {
      'icon': Icons.insert_chart_outlined_rounded,
      'title': 'Phân tích thu',
      'color': Colors.green,
      'ontap': (BuildContext context) {
        AdService().showAdIfEligible();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const IncomeAnalysis()),
        );
      },
    },
    {
      'icon': Icons.checklist_rounded,
      'title': 'Theo dõi vay nợ',
      'color': Colors.orange,
      'ontap': (BuildContext context) {
        AdService().showAdIfEligible();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LendBorrowScreen()),
        );
      },
    },
    {
      'icon': Icons.person,
      'title': 'Đối tượng thu/chi',
      'color': Colors.blue,
      'ontap': null,
    },
    {
      'icon': Icons.calendar_month_rounded,
      'title': 'Chuyến đi/sự kiện',
      'color': Colors.greenAccent,
      'ontap': null,
    },
    {
      'icon': Icons.analytics_outlined,
      'title': 'Phân tích tài chính',
      'color': Colors.deepPurple,
      'ontap': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Báo cáo'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final icon = items[index]['icon'] as IconData;
                  final title = items[index]['title'] as String;
                  final color = items[index]['color'] as Color;
                  final onTap = items[index]['ontap'] as Function?;

                  return InkWell(
                    onTap: onTap != null ? () => onTap(context) : null,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icon, size: 32, color: color),
                          const SizedBox(height: 8),
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
