import 'package:flutter/cupertino.dart';
import 'package:pie_chart/pie_chart.dart';

import '../../const/colors/app_pie_chart_colors.dart';

class AppDonutChart extends StatelessWidget {
  final Map<String, double> dataMap;
  final double width;
  final double height;
  final double ringStrokeWidth;
  final bool showLegends;
  final bool showLegendsInRow;
  final bool centerChart;

  const AppDonutChart({
    super.key,
    required this.dataMap,
    required this.width,
    required this.height,
    required this.ringStrokeWidth,
    this.showLegends = true,
    this.showLegendsInRow = true,
    this.centerChart = false,
  });

  Widget _buildLegend(Color color, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }

  Widget _buildLegends(Map<String, double> dataMap) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 180),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: dataMap.entries.toList().asMap().entries.map((indexedEntry) {
          final index = indexedEntry.key;
          final entry = indexedEntry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildLegend(AppPieChartColor.getColor(index), entry.key),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: centerChart ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          height: width,
          width: height,
          child: PieChart(
            dataMap: dataMap,
            animationDuration: const Duration(milliseconds: 800),
            chartType: ChartType.ring,
            ringStrokeWidth: ringStrokeWidth,
            legendOptions: const LegendOptions(showLegends: false),
            chartValuesOptions: const ChartValuesOptions(showChartValues: false),
          ),
        ),

        if (showLegends) const SizedBox(width: 24),
        if (showLegends) Flexible(
          child: _buildLegends(dataMap),
        ),
      ],
    );
  }
}