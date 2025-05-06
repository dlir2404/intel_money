import 'package:flutter/material.dart';

import 'financial_statement_screen.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  // Define a type for the navigation function to fix typing issues
  static final List<Map<String, dynamic>> items = [
    {
      'icon': Icons.bar_chart_rounded,
      'title': 'Financial Statement',
      'color': Colors.blue,
      'ontap': (BuildContext context) {
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
      'title': 'Expense vs Income',
      'color': Colors.greenAccent,
      'ontap': null, // Added null to maintain consistent keys
    },
    {
      'icon': Icons.insert_chart_outlined_rounded,
      'title': 'Expense analysis',
      'color': Colors.red,
      'ontap': null,
    },
    {
      'icon': Icons.insert_chart_outlined_rounded,
      'title': 'Income analysis',
      'color': Colors.green,
      'ontap': null,
    },
    {
      'icon': Icons.checklist_rounded,
      'title': 'Money lent/ borrowed',
      'color': Colors.orange,
      'ontap': null,
    },
    {
      'icon': Icons.person,
      'title': 'Payee/Payer',
      'color': Colors.blue,
      'ontap': null,
    },
    {
      'icon': Icons.calendar_month_rounded,
      'title': 'Trip/event',
      'color': Colors.greenAccent,
      'ontap': null,
    },
    {
      'icon': Icons.analytics_outlined,
      'title': 'Financial analytic',
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
        title: const Text('Report'),
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
