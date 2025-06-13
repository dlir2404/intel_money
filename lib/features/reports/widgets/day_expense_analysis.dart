import 'package:flutter/material.dart';
import 'package:intel_money/core/models/category.dart';
import 'package:intel_money/features/reports/controller/statistic_controller.dart';
import 'package:intel_money/shared/component/filters/categories_filter.dart';
import 'package:intel_money/shared/helper/app_time.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../core/models/analysis_data.dart';
import '../../../core/models/wallet.dart';
import '../../../shared/component/filters/account_filter.dart';
import '../../../shared/component/filters/day_range_picker.dart';
import '../../../shared/const/enum/category_type.dart';
import 'day_detail_analysis.dart';
import 'day_expense_analysis_chart.dart';

class DayExpenseAnalysis extends StatefulWidget {
  const DayExpenseAnalysis({super.key});

  @override
  State<DayExpenseAnalysis> createState() => _DayExpenseAnalysisState();
}

class _DayExpenseAnalysisState extends State<DayExpenseAnalysis> {
  DateTime? _startDate = AppTime.startOfMonth();
  DateTime? _endDate = AppTime.endOfToday();

  List<AnalysisData> _data = [];
  bool _isDataLoaded = false;

  List<Wallet>? _selectedWallets;
  List<Category>? _selectedCategories;

  final StatisticController _statisticController = StatisticController();

  Future<void> _loadData() async {
    if (!_isDataLoaded) {
      final from = _startDate ?? AppTime.startOfMonth();
      final to = _endDate ?? AppTime.endOfToday();

      final data = await _statisticController.getByDayAnalysisData(
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
          DayRangePicker(
            startDate: _startDate,
            endDate: _endDate,
            onChanged: (PickerDateRange? range) {
              if (range != null) {
                setState(() {
                  _isDataLoaded = false;
                  _startDate = range.startDate;
                  _endDate = range.endDate;
                });
              }
            },
          ),
          const SizedBox(height: 2),

          CategoriesFilter(
            selectedCategories: _selectedCategories,
            categoryType: CategoryType.expense,
            onSelectionChanged: (List<Category>? selectedItems) {
              setState(() {
                _isDataLoaded = false;
                _selectedCategories = selectedItems;
              });
            },
          ),
          const SizedBox(height: 2),

          AccountFilter(
            selectedWallets: _selectedWallets,
            onSelectionChanged: (List<Wallet>? selectedItems) {
              setState(() {
                _isDataLoaded = false;
                _selectedWallets = selectedItems;
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
                    padding: const EdgeInsets.only(
                      top: 12,
                      bottom: 12,
                      left: 16,
                    ),
                    child: DayExpenseAnalysisChart(data: _data),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    color: Colors.white,
                    child: DayDetailAnalysis(
                      data: _data,
                      type: AnalysisType.expense,
                    ),
                  ),
                  const SizedBox(height: 40,)
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
