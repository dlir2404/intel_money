import 'package:intel_money/core/state/statistic_state.dart';
import 'package:intel_money/shared/helper/app_time.dart';

import '../models/analysis_data.dart';
import '../models/statistic_data.dart';
import '../network/api_client.dart';

class StatisticService {
  final StatisticState _state = StatisticState();
  final ApiClient _apiClient = ApiClient.instance;

  static final StatisticService _instance = StatisticService._internal();

  factory StatisticService() => _instance;

  StatisticService._internal();

  Future<void> getTodayStatisticData() async {
    final response = await _apiClient.get('/statistic/today');

    final statisticData = StatisticData.fromJson(response);

    _state.setTodayStatisticData(statisticData);
  }

  Future<void> getThisWeekStatisticData() async {
    final response = await _apiClient.get('/statistic/this-week');

    final statisticData = StatisticData.fromJson(response);

    _state.setThisWeekStatisticData(statisticData);
  }

  Future<void> getThisMonthStatisticData() async {
    final response = await _apiClient.get('/statistic/this-month');

    final statisticData = StatisticData.fromJson(response);

    _state.setThisMonthStatisticData(statisticData);
  }

  Future<void> getThisQuarterStatisticData() async {
    final response = await _apiClient.get('/statistic/this-quarter');

    final statisticData = StatisticData.fromJson(response);

    _state.setThisQuarterStatisticData(statisticData);
  }

  Future<void> getThisYearStatisticData() async {
    final response = await _apiClient.get('/statistic/this-year');

    final statisticData = StatisticData.fromJson(response);

    _state.setThisYearStatisticData(statisticData);
  }

  Future<void> getByDayAnalysisData(DateTime from, DateTime to) async {
    final response = await _apiClient.get(
      '/statistic/by-day',
      params: {'from': AppTime.toUtcIso8601String(from), 'to': AppTime.toUtcIso8601String(to)},
    );

    final analysisData =
        (response as List)
            .map((analysisData) => AnalysisData.fromJson(analysisData))
            .toList();

    _state.setByDayAnalysisData(analysisData);
  }

  Future<void> getByMonthAnalysisData(DateTime from, DateTime to) async {
    final response = await _apiClient.get(
      '/statistic/by-month',
      params: {'from': AppTime.toUtcIso8601String(from), 'to': AppTime.toUtcIso8601String(to)},
    );

    final analysisData =
        (response as List)
            .map((analysisData) => AnalysisData.fromJson(analysisData))
            .toList();

    _state.setByMonthAnalysisData(analysisData);
  }
}
