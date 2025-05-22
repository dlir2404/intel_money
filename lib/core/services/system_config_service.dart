import 'package:intel_money/core/models/system_config.dart';

import '../network/api_client.dart';
import '../state/app_state.dart';

class SystemConfigService {
  final AppState _appState = AppState();
  final ApiClient _apiClient = ApiClient.instance;

  static final SystemConfigService _instance = SystemConfigService._internal();
  SystemConfigService._internal();
  factory SystemConfigService() => _instance;

  // Method to get system configuration
  Future<void> getSystemConfig() async {
    final response = await _apiClient.get('/system-config');

    final SystemConfig config = SystemConfig.fromJson(response);
    _appState.setSystemConfig(config);
  }
}