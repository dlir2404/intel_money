import 'package:intel_money/core/models/statistic_data.dart';

import '../../shared/helper/app_time.dart';

class AnalysisData {
  final DateTime date;
  final CompactStatisticData compactStatisticData;

  AnalysisData({
    required this.date,
    required this.compactStatisticData,
  });

  factory AnalysisData.fromJson(Map<String, dynamic> json) {
    return AnalysisData(
      date: AppTime.parseFromApi(json['date']),
      compactStatisticData: CompactStatisticData.fromJson(json['statisticData']),
    );
  }

  factory AnalysisData.defaultData() {
    return AnalysisData(
      date: DateTime.now(),
      compactStatisticData: CompactStatisticData.defaultData(),
    );
  }
}

