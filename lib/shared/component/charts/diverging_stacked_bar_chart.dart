import 'package:flutter/material.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;

import '../../const/enum/currency_unit.dart';

class DivergingStackedBarChart extends StatelessWidget {
  final List<DivergingStackedBarData> upData;
  final List<DivergingStackedBarData> downData;
  final String upTitle;
  final String downTitle;
  final bool animate;
  final double height;
  final double? width;
  final CurrencyUnit currencyUnit;

  DivergingStackedBarChart({
    super.key,
    this.animate = false,
    this.height = 300,
    this.width,
    required this.upData,
    required this.downData,
    required this.upTitle,
    required this.downTitle,
    CurrencyUnit? currencyUnit,
  }) : currencyUnit = currencyUnit ?? _calculateCurrencyUnit([...upData, ...downData]);

  static CurrencyUnit _calculateCurrencyUnit(List<DivergingStackedBarData> data) {
    if (data.isNotEmpty) {
      double maxValue = 0;
      for (var item in data) {
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

  List<charts.Series<DivergingStackedBarData, String>> _prepareChartData(
    List<DivergingStackedBarData> upData,
    List<DivergingStackedBarData> downData,
  ) {
    return [
      charts.Series<DivergingStackedBarData, String>(
        id: upTitle,
        domainFn: (DivergingStackedBarData data, _) => data.category,
        measureFn: (DivergingStackedBarData data, _) => data.value / currencyUnit.multiplier,
        data: upData,
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
      ),
      charts.Series<DivergingStackedBarData, String>(
        id: downTitle,
        domainFn: (DivergingStackedBarData data, _) => data.category,
        measureFn: (DivergingStackedBarData data, _) => -data.value / currencyUnit.multiplier,
        data: downData,
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final chartData = _prepareChartData(upData, downData);

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
            barGroupingType: charts.BarGroupingType.stacked,
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

  static Widget withSampleData({double height = 300, double? width}) {
    return DivergingStackedBarChart(
      upData: createSampleData().first,
      downData: createSampleData().last,
      height: height,
      width: width,
      upTitle: 'Income',
      downTitle: 'Expense',
    );
  }

  static List<List<DivergingStackedBarData>> createSampleData() {
    final incomeData = [
      DivergingStackedBarData('Jan', 50),
      DivergingStackedBarData('Feb', 75),
      DivergingStackedBarData('Mar', 60),
      DivergingStackedBarData('Apr', 80),
    ];

    final expenseData = [
      DivergingStackedBarData('Jan', -30),
      DivergingStackedBarData('Feb', -50),
      DivergingStackedBarData('Mar', -40),
      DivergingStackedBarData('Apr', -60),
    ];

    return [incomeData, expenseData];
  }
}

class DivergingStackedBarData {
  final String category;
  final double value;

  DivergingStackedBarData(this.category, this.value);
}
