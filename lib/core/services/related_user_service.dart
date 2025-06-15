import 'package:intel_money/core/state/related_user_state.dart';

import '../models/related_user.dart';
import '../network/api_client.dart';

class RelatedUserService {
  final RelatedUserState _relatedUserState = RelatedUserState();
  final ApiClient _apiClient = ApiClient.instance;

  static final RelatedUserService _instance = RelatedUserService._internal();

  factory RelatedUserService() => _instance;

  RelatedUserService._internal();

  Future<void> createFromTemp(RelatedUser temp) async {
    final response = await _apiClient.post('/related-user', {
      'name': temp.name,
    });

    temp.id = response['id'];
    temp.isTemporary = false;
    _relatedUserState.addRelatedUser(temp);
  }

  Future<RelatedUser> create({
    required String name,
    String? email,
    String? phone,
  }) async {
    final response = await _apiClient.post('/related-user', {
      'name': name,
      'email': email,
      'phone': phone,
    });

    return RelatedUser.fromJson(response);
  }

  Future<void> edit({
    required int id,
    required String name,
    String? email,
    String? phone,
  }) async {
    await _apiClient.put('/related-user/$id', {
      'name': name,
      'email': email,
      'phone': phone,
    });
  }

  Future<void> getAll() async {
    final response = await _apiClient.get('/related-user');
    final List<RelatedUser> relatedUsers = [];

    for (var item in response) {
      relatedUsers.add(RelatedUser.fromJson(item));
    }

    _relatedUserState.setRelatedUsers(relatedUsers);
  }
}
