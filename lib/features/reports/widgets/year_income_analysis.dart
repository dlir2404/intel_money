import 'package:flutter/material.dart';
import 'package:intel_money/features/reports/widgets/year_detail_analysis.dart';
import 'package:intel_money/features/reports/widgets/year_income_analysis_chart.dart';
import 'package:intel_money/shared/component/filters/year_range_picker.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../core/models/analysis_data.dart';
import '../../../core/models/category.dart';
import '../../../core/models/wallet.dart';
import '../../../shared/component/filters/account_filter.dart';
import '../../../shared/component/filters/categories_filter.dart';
import '../../../shared/const/enum/category_type.dart';
import '../../../shared/helper/app_time.dart';
import '../controller/statistic_controller.dart';

class YearIncomeAnalysis extends StatefulWidget {
  const YearIncomeAnalysis({super.key});

  @override
  State<YearIncomeAnalysis> createState() => _YearIncomeAnalysisState();
}

class _YearIncomeAnalysisState extends State<YearIncomeAnalysis> {
  DateTime? _startDate = AppTime.startOfYear(
    date: DateTime(DateTime.now().year - 10),
  );
  DateTime? _endDate = AppTime.endOfYear();

  List<AnalysisData> _data = [];
  bool _isDataLoaded = false;

  List<Wallet>? _selectedWallets;
  List<Category>? _selectedCategories;

  final StatisticController _statisticController = StatisticController();

  Future<void> _loadData() async {
    if (!_isDataLoaded) {
      final from =
          _startDate ??
              AppTime.startOfYear(date: DateTime(DateTime.now().year - 10));
      final to = _endDate ?? AppTime.endOfYear();

      final data = await _statisticController.getByYearAnalysisData(
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
          YearRangePicker(
            startDate: _startDate,
            endDate: _endDate,
            onChanged: (PickerDateRange? range) {
              if (range != null) {
                setState(() {
                  _startDate = range.startDate;
                  _endDate = range.endDate;
                  _isDataLoaded = false; // Reset data loading state
                });
                _loadData(); // Load data for the new date range
              }
            },
          ),
          const SizedBox(height: 2),
      
          CategoriesFilter(
            categoryType: CategoryType.income,
            selectedCategories: _selectedCategories,
            onSelectionChanged: (List<Category>? categories) {
              setState(() {
                _selectedCategories = categories;
                _isDataLoaded = false; // Reset data loading state
              });
              _loadData(); // Load data for the new category selection
            },
          ),
          const SizedBox(height: 2),
      
          AccountFilter(
            selectedWallets: _selectedWallets,
            onSelectionChanged: (List<Wallet>? wallets) {
              setState(() {
                _selectedWallets = wallets;
                _isDataLoaded = false; // Reset data loading state
              });
              _loadData(); // Load data for the new wallet selection
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
                    child: YearIncomeAnalysisChart(
                      data: _data,
                    ),
                  ),
                  const SizedBox(height: 12),
      
                  Container(
                    color: Colors.white,
                    child: YearDetailAnalysis(
                      data: _data,
                      type: AnalysisType.income,
                    ),
                  ),
                  const SizedBox(height: 40,)
                ],
              );
            }
          ),
        ],
      ),
    );
  }
}
