import 'package:flutter/material.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;

class DivergingStackedBarChart extends StatelessWidget {
  final List<charts.Series<DivergingStackedBarData, String>> seriesList;
  final bool animate;
  final double height;
  final double? width;

  const DivergingStackedBarChart(
    this.seriesList, {
    super.key,
    this.animate = false,
    this.height = 300,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: charts.BarChart(
        seriesList,
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
            showHorizontalFollowLine: charts.LinePointHighlighterFollowLineType.nearest,
            showVerticalFollowLine: charts.LinePointHighlighterFollowLineType.nearest,
          ),
          charts.SelectNearest(),
          charts.SeriesLegend(),
        ],
      ),
    );
  }

  static Widget withSampleData({double height = 300, double? width}) {
    return DivergingStackedBarChart(
      createSampleData(),
      height: height,
      width: width,
    );
  }

  static List<charts.Series<DivergingStackedBarData, String>>
  createSampleData() {
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

    return [
      charts.Series<DivergingStackedBarData, String>(
        id: 'Income',
        domainFn: (DivergingStackedBarData data, _) => data.category,
        measureFn: (DivergingStackedBarData data, _) => data.value,
        data: incomeData,
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
      ),
      charts.Series<DivergingStackedBarData, String>(
        id: 'Expense',
        domainFn: (DivergingStackedBarData data, _) => data.category,
        measureFn: (DivergingStackedBarData data, _) => data.value,
        data: expenseData,
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
      ),
    ];
  }
}

class DivergingStackedBarData {
  final String category;
  final double value;

  DivergingStackedBarData(this.category, double value)
    : value = value / 1000000;
}
