import 'package:flutter/material.dart';
import 'package:intel_money/shared/component/filters/day_range_picker.dart';
import 'package:intel_money/shared/helper/app_time.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../core/models/statistic_data.dart';
import '../../../core/services/statistic_service.dart';
import 'custom_income_vs_expense_chart.dart';
import 'expense_vs_income_item.dart';

class CustomIncomeVsExpense extends StatefulWidget {
  const CustomIncomeVsExpense({super.key});

  @override
  State<CustomIncomeVsExpense> createState() => _CustomIncomeVsExpenseState();
}

class _CustomIncomeVsExpenseState extends State<CustomIncomeVsExpense> {
  StatisticData _data = StatisticData.defaultData();
  DateTime _startDate = AppTime.startOfMonth();
  DateTime _endDate = AppTime.endOfToday();
  bool _isLoading = true;

  Future<void> _getData() async {
    final data = await StatisticService().getCustomRangeStatisticData(
      _startDate,
      _endDate,
    );

    setState(() {
      _data = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          DayRangePicker(
            startDate: _startDate,
            endDate: _endDate,
            onChanged: (PickerDateRange? range) {
              if (range != null) {
                setState(() {
                  _startDate = range.startDate!;
                  _endDate = range.endDate!;
                  _isLoading = true;
                });

                _getData();
              }
            },
          ),
          const SizedBox(height: 6),

          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: CustomIncomeVsExpenseChart(
              data: _data,
              xAxisLabel:
                  "${AppTime.format(time: _startDate)} - ${AppTime.format(time: _endDate)}",
            ),
          ),
          const SizedBox(height: 6),

          ExpenseVsIncomeItem(
            title:
                "${AppTime.format(time: _startDate)} - ${AppTime.format(time: _endDate)}",
            statisticData: _data,
          ),
        ],
      ),
    );
  }
}
