import 'package:intel_money/core/network/api_client.dart';

import '../state/app_state.dart';

class UserService {
  final ApiClient _apiClient = ApiClient.instance;

  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  Future<void> updateUserTimezone(String timezone) async {
    _apiClient.post('/user/change-timezone', {
      'timezone': timezone,
    });

    AppState().setUserTimezone(timezone);
  }
}