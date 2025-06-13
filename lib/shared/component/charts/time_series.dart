import 'package:flutter/material.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;
import 'package:intel_money/shared/component/typos/currency_double_text.dart';
import 'package:intel_money/shared/const/enum/currency_unit.dart';

class TimeSeries extends StatelessWidget {
  final List<TimeSeriesData> seriesList;
  final bool animate;
  final double height;
  final double? width;
  final String totalTitle;
  final String averageTitle;
  final CurrencyUnit currencyUnit;

  TimeSeries(
    this.seriesList, {
    super.key,
    this.animate = false,
    this.height = 300,
    this.width,
    CurrencyUnit? currencyUnit,
    this.totalTitle = "Total",
    this.averageTitle = "Average",
  }) : currencyUnit = currencyUnit ?? _calculateCurrencyUnit(seriesList);

  factory TimeSeries.withSampleData() {
    return TimeSeries(_createSampleData(), animate: false);
  }

  static CurrencyUnit _calculateCurrencyUnit(List<TimeSeriesData> data) {
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

  double _calculateTotal() {
    double total = 0;
    for (var data in seriesList) {
      total += data.value;
    }
    return total;
  }

  List<charts.Series<TimeSeriesData, DateTime>> _prepareChartData(
    List<TimeSeriesData> data,
  ) {
    return [
      charts.Series<TimeSeriesData, DateTime>(
        id: 'Data',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesData data, _) => data.time,
        measureFn:
            (TimeSeriesData data, _) => data.value / currencyUnit.multiplier,
        data: data,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    double total = _calculateTotal();
    double average = seriesList.isNotEmpty ? total / seriesList.length : 0;

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
          child: charts.TimeSeriesChart(
            chartData,
            animate: animate,
            dateTimeFactory: const charts.LocalDateTimeFactory(),
          ),
        ),
        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                totalTitle,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              CurrencyDoubleText(value: total, fontSize: 16),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                averageTitle,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              CurrencyDoubleText(value: average, fontSize: 16),
            ],
          ),
        ),
      ],
    );
  }

  static List<TimeSeriesData> _createSampleData() {
    return [
      TimeSeriesData(DateTime(2017, 9, 19), 5000000),
      TimeSeriesData(DateTime(2017, 9, 26), 25000000),
      TimeSeriesData(DateTime(2017, 10, 3), 100000000),
      TimeSeriesData(DateTime(2017, 10, 10), 75000000),
    ];
  }
}

class TimeSeriesData {
  final DateTime time;
  final double value;

  TimeSeriesData(this.time, this.value);
}
