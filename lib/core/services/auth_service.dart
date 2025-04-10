// lib/core/services/auth_service.dart
import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../network/api_client.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient.instance;

  Future<void> login(String email, String password) async {
    final response = await _apiClient.post('/auth/login', {
      'email': email,
      'password': password
    });

    await _apiClient.saveToken(response['accessToken']);
    await _apiClient.saveRefreshToken(response['refreshToken']);
  }


  Future<void> register(String name, String email, String password) async {
    final response = await _apiClient.post('/auth/register', {
      'name': name,
      'email': email,
      'password': password
    });

    await _apiClient.saveToken(response['accessToken']);
    await _apiClient.saveRefreshToken(response['refreshToken']);
  }

  Future<void> logout() async {
    await _apiClient.deleteToken();
  }

  Future<User?> getMe() async {
    try {
      final response = await _apiClient.get('/auth/me');
      return User.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}