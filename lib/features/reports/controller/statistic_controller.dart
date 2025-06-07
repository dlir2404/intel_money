import 'package:intel_money/core/services/statistic_service.dart';

import '../../../core/models/analysis_data.dart';

class StatisticController {
  final StatisticService _statisticService = StatisticService();

  Future<List<AnalysisData>> getByDayAnalysisData({
    required DateTime from,
    required DateTime to,
  }) async {
    return await _statisticService.getByDayAnalysisData(from, to);
  }
}