import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;
import 'package:flutter/material.dart';

class GroupedBarChart extends StatelessWidget {
  final List<charts.Series<GroupedBarData, String>> seriesList;
  final bool animate;
  final double height;
  final double? width;

  const GroupedBarChart(
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
          charts.SeriesLegend(),
        ],
      ),
    );
  }
}

class GroupedBarData {
  final String category;
  final double value;

  GroupedBarData(this.category, double value) : value = value / 1000000;
}
