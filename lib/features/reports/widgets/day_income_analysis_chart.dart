import 'package:flutter/material.dart';
import 'package:intel_money/core/models/analysis_data.dart';
import 'package:intel_money/core/state/statistic_state.dart';
import 'package:provider/provider.dart';

import '../../../shared/component/charts/time_series.dart';

class DayIncomeAnalysisChart extends StatelessWidget {
  final List<AnalysisData> data;

  const DayIncomeAnalysisChart({super.key, required this.data});

  List<TimeSeriesData> _prepareChartData(List<AnalysisData> data) {
    if (data.isEmpty) return [];

    // Find min and max dates in the data
    final DateTime minDate = data
        .map((e) => e.date)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final DateTime maxDate = data
        .map((e) => e.date)
        .reduce((a, b) => a.isAfter(b) ? a : b);

    // Create a map with existing data points
    final Map<DateTime, double> dataMap = {};
    for (var item in data) {
      final date = DateTime(item.date.year, item.date.month, item.date.day);
      dataMap[date] = item.compactStatisticData.totalIncome;
    }

    // Generate complete list with all dates in range
    final List<TimeSeriesData> result = [];
    DateTime currentDate = DateTime(minDate.year, minDate.month, minDate.day);

    while (!currentDate.isAfter(maxDate)) {
      result.add(
        TimeSeriesData(
          currentDate,
          dataMap[currentDate] ?? 0, // Use 0 for missing dates
        ),
      );
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final preparedData = _prepareChartData(data);

    return TimeSeries(
      preparedData,
      height: 300,
      totalTitle: "Tổng thu",
      averageTitle: "Trung bình thu/ngày",
    );
  }
}
