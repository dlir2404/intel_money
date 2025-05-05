import 'package:intel_money/core/state/statistic_state.dart';

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
}