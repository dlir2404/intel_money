import 'package:intel_money/core/state/related_user_state.dart';

import '../models/related_user.dart';
import '../network/api_client.dart';

class RelatedUserService {
  final RelatedUserState _relatedUserState = RelatedUserState();
  final ApiClient _apiClient = ApiClient.instance;
  
  static final RelatedUserService _instance = RelatedUserService._internal();
  factory RelatedUserService() => _instance;
  RelatedUserService._internal();
  
  Future<void> create(RelatedUser temp) async {
    final response = await _apiClient.post('/related-user', {
      'name': temp.name,
    });

    temp.id = response['id'];
    temp.isTemporary = false;
    _relatedUserState.addRelatedUser(temp);
  }
}