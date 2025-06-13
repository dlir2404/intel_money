import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;
import 'package:flutter/material.dart';

import '../../const/enum/currency_unit.dart';

class GroupedBarChart extends StatelessWidget {
  final List<List<GroupedBarData>> seriesList;
  final List<String> titles;
  final List<Color> colors;
  final bool animate;
  final double height;
  final double? width;
  final CurrencyUnit currencyUnit;

  GroupedBarChart({
    super.key,
    required this.seriesList,
    this.animate = false,
    this.height = 300,
    this.width,
    CurrencyUnit? currencyUnit,
    required this.titles,
    required this.colors,
  }) : currencyUnit = currencyUnit ?? _calculateCurrencyUnit(seriesList);

  static CurrencyUnit _calculateCurrencyUnit(List<List<GroupedBarData>> data) {
    final flattenedData = data.expand((element) => element).toList();

    if (flattenedData.isNotEmpty) {
      double maxValue = 0;
      for (var item in flattenedData) {
        if (item.value > maxValue) {
          maxValue = item.value;
        }
      }

      if (maxValue > 1000000000) {
        return CurrencyUnit.b;
      } else if (maxValue > 1000000) {
        return CurrencyUnit.m;
      }
    }
    return CurrencyUnit.k;
  }

  List<charts.Series<GroupedBarData, String>> _prepareChartData(
    List<List<GroupedBarData>> data,
  ) {
    List<charts.Series<GroupedBarData, String>> result = [];

    for (int i = 0; i < data.length; i++) {
      result.add(
        charts.Series<GroupedBarData, String>(
          id: titles[i],
          domainFn: (GroupedBarData data, _) => data.category,
          measureFn: (GroupedBarData data, _) => data.value / currencyUnit.multiplier,
          data: data[i],
          colorFn: (_, __) => charts.ColorUtil.fromDartColor(colors[i]),
        ),
      );
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final chartData = _prepareChartData(seriesList);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "(Đơn vị: ${currencyUnit.name})",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        SizedBox(
          height: height,
          width: width,
          child: charts.BarChart(
            chartData,
            animate: animate,
            // This is important - set the bar rendering to stacked
            barGroupingType: charts.BarGroupingType.grouped,
            // Configure a domain axis that renders vertically
            vertical: true,
            // You can add a custom domain axis if needed
            domainAxis: const charts.OrdinalAxisSpec(
              renderSpec: charts.SmallTickRendererSpec(
                labelRotation: 0, // Keep labels horizontal
              ),
            ),
            // Make sure to include the negative values in the range
            primaryMeasureAxis: charts.NumericAxisSpec(
              // This ensures zero is included and visible
              showAxisLine: true,
              // Optional: customize the appearance of the zero line
              renderSpec: charts.GridlineRendererSpec(
                lineStyle: charts.LineStyleSpec(
                  color: charts.MaterialPalette.gray.shade300,
                  thickness: 1,
                ),
              ),
            ),
            behaviors: [
              charts.LinePointHighlighter(
                showHorizontalFollowLine:
                    charts.LinePointHighlighterFollowLineType.nearest,
                showVerticalFollowLine:
                    charts.LinePointHighlighterFollowLineType.nearest,
              ),
              charts.SelectNearest(),
              charts.SeriesLegend(
                position: charts.BehaviorPosition.bottom
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class GroupedBarData {
  final String category;
  final double value;

  GroupedBarData(this.category, this.value);
}
