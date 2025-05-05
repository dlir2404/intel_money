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
}