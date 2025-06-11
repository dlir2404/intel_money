import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/analysis_data.dart';
import '../../../core/state/statistic_state.dart';
import '../../../shared/component/charts/time_series.dart';

class MonthIncomeAnalysisChart extends StatelessWidget {
  final List<AnalysisData> data;

  const MonthIncomeAnalysisChart({super.key, required this.data});

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
      final date = DateTime(item.date.year, item.date.month);
      dataMap[date] = item.compactStatisticData.totalIncome;
    }

    // Generate complete list with all dates in range
    final List<TimeSeriesData> result = [];
    DateTime currentDate = DateTime(minDate.year, minDate.month);

    while (!currentDate.isAfter(maxDate)) {
      result.add(
        TimeSeriesData(
          currentDate,
          dataMap[currentDate] ?? 0, // Use 0 for missing dates
        ),
      );
      currentDate = DateTime(currentDate.year, currentDate.month + 1);
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final preparedData = _prepareChartData(data);
    return TimeSeries(
      preparedData,
      height: 300,
      totalTitle: "Total Income",
      averageTitle: "Average spending/month",
    );
  }
}
