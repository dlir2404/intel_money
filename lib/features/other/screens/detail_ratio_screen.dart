import 'package:flutter/material.dart';
import 'package:intel_money/features/transaction/screens/transactions_of_categories.dart';

import '../../../core/models/statistic_data.dart';
import '../../../shared/component/charts/donut_chart.dart';
import '../../../shared/component/typos/currency_double_text.dart';
import '../../../shared/const/enum/transaction_type.dart';
import '../../../shared/helper/app_time.dart';
import '../../../shared/helper/formatter.dart';

class DetailRatioScreen extends StatefulWidget {
  final String title;
  final StatisticData statisticData;

  const DetailRatioScreen({
    super.key,
    required this.title,
    required this.statisticData,
  });

  @override
  State<DetailRatioScreen> createState() => _DetailRatioScreenState();
}

class _DetailRatioScreenState extends State<DetailRatioScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late StatisticData _statisticData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _statisticData = widget.statisticData;
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Map<String, double> _prepareData(double total, List<ByCategoryData> data) {
    Map<String, double> result = {};

    for (var d in data) {
      result[d.category.name] = d.amount;
    }

    return result;
  }

  Widget _buildDescription(double total, List<ByCategoryData> data, TransactionType type) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          ...data.map(
            (item) => InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            TransactionsOfCategories(title: item.category.name, transactions: item.transactions,),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: item.category.icon.color.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.category.icon.icon,
                            color: item.category.icon.color,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 4),

                        Expanded(
                          child: Text(
                            item.category.name,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),

                        CurrencyDoubleText(value: item.amount, fontSize: 16),
                        const SizedBox(width: 4),
                        Text(
                          "(${Formatter.formatCurrency(item.amount * 100 / total)}%)",
                          style: TextStyle(color: Colors.grey),
                        ),

                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey[400],
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      color: Colors.grey[200],
                      height: 4,
                      child: Row(
                        children: [
                          Expanded(
                            flex: item.amount.toInt(),
                            child: Container(
                              height: 4,
                              color: type == TransactionType.income ? Colors.green : Colors.redAccent,
                            ),
                          ),
                          Expanded(
                            flex: (total - item.amount).toInt(),
                            child: Container(
                              height: 4,
                              color: Colors.grey[200],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required TransactionType type,
    required String totalTitle,
    required String emptyTitle,
    required double total,
    required List<ByCategoryData> data,
  }) {
    if (total == 0 || data.isEmpty) {
      return Center(
        child: Text(
          emptyTitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      );
    }

    final dataMap = _prepareData(total, data);

    return Container(
      color: Colors.grey[200],
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text(totalTitle), CurrencyDoubleText(value: total)],
              ),
            ),
            const SizedBox(height: 12),

            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: AppDonutChart(
                dataMap: dataMap,
                width: 150,
                height: 150,
                ringStrokeWidth: 32,
                showLegends: false,
                showLegendsInRow: true,
                centerChart: true,
                type: type,
              ),
            ),
            const SizedBox(height: 12),

            _buildDescription(total, data, type),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [Tab(text: 'EXPENSE'), Tab(text: 'INCOME')],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTab(
                  type: TransactionType.expense,
                  totalTitle: "Total Expense",
                  emptyTitle: "No expense record found",
                  total: _statisticData.totalExpense,
                  data: _statisticData.byCategoryExpense,
                ),
                _buildTab(
                  type: TransactionType.income,
                  totalTitle: "Total Income",
                  emptyTitle: "No income record found",
                  total: _statisticData.totalIncome,
                  data: _statisticData.byCategoryIncome,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
