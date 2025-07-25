import 'package:flutter/material.dart';
import 'package:intel_money/features/reports/controller/statistic_controller.dart';
import 'package:intel_money/features/reports/widgets/month_detail_analysis.dart';
import 'package:intel_money/shared/component/filters/account_filter.dart';
import 'package:intel_money/shared/component/filters/categories_filter.dart';
import 'package:intel_money/shared/component/filters/month_range_picker.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../core/models/analysis_data.dart';
import '../../../core/models/category.dart';
import '../../../core/models/wallet.dart';
import '../../../shared/const/enum/category_type.dart';
import '../../../shared/helper/app_time.dart';
import 'month_expense_analysis_chart.dart';

class MonthExpenseAnalysis extends StatefulWidget {
  const MonthExpenseAnalysis({super.key});

  @override
  State<MonthExpenseAnalysis> createState() => _MonthExpenseAnalysisState();
}

class _MonthExpenseAnalysisState extends State<MonthExpenseAnalysis> {
  DateTime? _startDate = AppTime.startOfYear();
  DateTime? _endDate = AppTime.endOfYear();

  List<AnalysisData> _data = [];
  bool _isDataLoaded = false;

  List<Wallet>? _selectedWallets;
  List<Category>? _selectedCategories;

  final StatisticController _statisticController = StatisticController();

  Future<void> _loadData() async {
    if (!_isDataLoaded) {
      final from = _startDate ?? AppTime.startOfYear();
      final to = _endDate ?? AppTime.endOfToday();

      final data = await _statisticController.getByMonthAnalysisData(
        from: from,
        to: to,
        wallets: _selectedWallets,
        categories: _selectedCategories,
      );

      setState(() {
        _data = data;
        _isDataLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          MonthRangePicker(
            startDate: _startDate,
            endDate: _endDate,
            onChanged: (PickerDateRange? range) {
              if (range != null) {
                setState(() {
                  _startDate = range.startDate;
                  _endDate = range.endDate;
                  _isDataLoaded = false;
                });
              }
            },
          ),
          const SizedBox(height: 2),
      
          CategoriesFilter(
            categoryType: CategoryType.expense,
            selectedCategories: _selectedCategories,
            onSelectionChanged: (List<Category>? categories) {
              setState(() {
                _selectedCategories = categories;
                _isDataLoaded = false;
              });
            },
          ),
          const SizedBox(height: 2),
      
          AccountFilter(
            selectedWallets: _selectedWallets,
            onSelectionChanged: (List<Wallet>? wallets) {
              setState(() {
                _selectedWallets = wallets;
                _isDataLoaded = false;
              });
            },
          ),
          const SizedBox(height: 6),
      
          FutureBuilder(
            future: _loadData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
      
              return Column(
                children: [
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.only(top: 12, bottom: 12, left: 16),
                    child: MonthExpenseAnalysisChart(data: _data),
                  ),
                  const SizedBox(height: 12),
      
                  Container(
                    color: Colors.white,
                    child: MonthDetailAnalysis(
                      data: _data,
                      type: AnalysisType.expense,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
