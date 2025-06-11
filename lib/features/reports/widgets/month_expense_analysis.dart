import 'package:flutter/material.dart';
import 'package:intel_money/features/reports/controller/statistic_controller.dart';
import 'package:intel_money/shared/component/filters/account_filter.dart';
import 'package:intel_money/shared/component/filters/categories_filter.dart';
import 'package:intel_money/shared/component/filters/month_range_picker.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../core/models/analysis_data.dart';
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

  final StatisticController _statisticController = StatisticController();

  Future<void> _loadData() async {
    if (!_isDataLoaded) {
      final from = _startDate ?? AppTime.startOfYear();
      final to = _endDate ?? AppTime.endOfToday();

      final data = await _statisticController.getByMonthAnalysisData(from: from, to: to);

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

        CategoriesFilter(),
        const SizedBox(height: 2),

        AccountFilter(),
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
              child: MonthExpenseAnalysisChart(
                data: _data,
              ),
            );
          }
        ),
      ],
    );
  }
}
