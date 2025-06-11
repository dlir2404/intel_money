import 'package:flutter/material.dart';
import 'package:intel_money/shared/component/filters/categories_filter.dart';
import 'package:intel_money/shared/helper/app_time.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../core/models/analysis_data.dart';
import '../../../core/models/category.dart';
import '../../../core/models/wallet.dart';
import '../../../shared/component/filters/account_filter.dart';
import '../../../shared/component/filters/day_range_picker.dart';
import '../../../shared/const/enum/category_type.dart';
import '../controller/statistic_controller.dart';
import 'day_income_analysis_chart.dart';

class DayIncomeAnalysis extends StatefulWidget {
  const DayIncomeAnalysis({super.key});

  @override
  State<DayIncomeAnalysis> createState() => _DayIncomeAnalysisState();
}

class _DayIncomeAnalysisState extends State<DayIncomeAnalysis> {
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
    return Column(
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
          categoryType: CategoryType.income,
          selectedCategories: _selectedCategories,
          onSelectionChanged: (List<Category>? selectedItems) {
            setState(() {
              _selectedCategories = selectedItems;
              _isDataLoaded = false; // Reset data when categories change
            });
          },
        ),
        const SizedBox(height: 2),

        AccountFilter(
          selectedWallets: _selectedWallets,
          onSelectionChanged: (List<Wallet>? selectedItems) {
            setState(() {
              _selectedWallets = selectedItems;
              _isDataLoaded = false; // Reset data when wallets change
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

            return Container(
              color: Colors.white,
              padding: const EdgeInsets.only(top: 12, bottom: 12, left: 16),
              child: DayIncomeAnalysisChart(data: _data),
            );
          },
        ),
      ],
    );
  }
}
