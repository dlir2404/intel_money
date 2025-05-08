import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/analysis_data.dart';
import '../../../core/state/statistic_state.dart';
import '../../../shared/component/charts/time_series.dart';

class MonthExpenseAnalysisChart extends StatelessWidget {
  const MonthExpenseAnalysisChart({super.key});

  List<TimeSeriesData> _prepareChartData(List<AnalysisData> data) {
    if (data.isEmpty) return [];

    // Find min and max dates in the data
    final DateTime minDate = data.map((e) => e.date).reduce((a, b) => a.isBefore(b) ? a : b);
    final DateTime maxDate = data.map((e) => e.date).reduce((a, b) => a.isAfter(b) ? a : b);

    // Create a map with existing data points
    final Map<DateTime, double> dataMap = {};
    for (var item in data) {
      final date = DateTime(item.date.year, item.date.month);
      dataMap[date] = item.compactStatisticData.totalExpense;
    }

    // Generate complete list with all dates in range
    final List<TimeSeriesData> result = [];
    DateTime currentDate = DateTime(minDate.year, minDate.month);

    while (!currentDate.isAfter(maxDate)) {
      result.add(TimeSeriesData(
        currentDate,
        dataMap[currentDate] ?? 0, // Use 0 for missing dates
      ));
      currentDate = DateTime(currentDate.year, currentDate.month + 1);
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticState>(
      builder: (context, state, _) {
        final monthData = state.byMonthAnalysisData ?? [];
        final data = _prepareChartData(monthData);

        return TimeSeries(
          data,
          height: 300,
        );
      },
    );
  }
}
