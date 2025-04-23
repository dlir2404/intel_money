import '../models/statistic_data.dart';
import '../network/api_client.dart';
import '../state/app_state.dart';

class StatisticService {
  final AppState _appState = AppState();
  final ApiClient _apiClient = ApiClient.instance;


  static final StatisticService _instance = StatisticService._internal();
  factory StatisticService() => _instance;
  StatisticService._internal();

  Future<void> getTodayStatisticData() async {
    final response = await _apiClient.get('/statistic/today');

    final statisticData = StatisticData.fromJson(response);

    _appState.setTodayStatisticData(statisticData);
  }
}