import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_exception.dart';

class ApiClient {
  static ApiClient? _instance;

  final String baseUrl;
  final http.Client _client = http.Client();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String? _accessToken;

  //private contructor
  ApiClient._({required this.baseUrl});

  //factory constructor to return the singleton instance
  factory ApiClient({required String baseUrl}) {
    _instance ??= ApiClient._(baseUrl: baseUrl);
    return _instance!;
  }

  static ApiClient get instance {
    if (_instance == null) {
      throw Exception(
        'ApiClient must be initialized before accessing instance',
      );
    }
    return _instance!;
  }

  static Future<void> initialize({required String baseUrl}) async {
    _instance = ApiClient._(baseUrl: baseUrl);
    await _instance!._initTokens();
  }

  Future<void> _initTokens() async {
    _accessToken = await _secureStorage.read(key: 'accessToken');
    debugPrint('>>> User access_token: $_accessToken');
  }

  // Token management
  Future<String?> getToken() async {
    return _accessToken;
  }

  Future<void> saveToken(String token) async {
    _accessToken = token;
    await _secureStorage.write(key: 'accessToken', value: token);
  }

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: 'refreshToken', value: token);
  }

  Future<void> deleteToken() async {
    _accessToken = null;
    await _secureStorage.delete(key: 'accessToken');
  }

  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: 'refreshToken');
      if (refreshToken == null) return false;

      final response = await _client.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await saveToken(data['accessToken']);
        if (data['refreshToken'] != null) {
          await _secureStorage.write(
            key: 'refreshToken',
            value: data['refreshToken'],
          );
        }
        return true;
      } else {
        await deleteToken();
        await _secureStorage.delete(key: 'refreshToken');
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // HTTP methods
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? params}) async {
    try {
      final token = await getToken();
      if (params != null) {
        endpoint += '?${Uri(queryParameters: params).query}';
      }

      final response = await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return _handleResponse(response, () => get(endpoint, params: params));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> post(String endpoint, dynamic body) async {
    try {
      debugPrint(json.encode(body));
      final token = await getToken();
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      return _handleResponse(response, () => post(endpoint, body));
    } catch (e) {
      debugPrint(e.toString());
      throw _handleError(e);
    }
  }

  Future<dynamic> put(String endpoint, dynamic body) async {
    try {
      final token = await getToken();
      final response = await _client.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      return _handleResponse(response, () => put(endpoint, body));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final token = await getToken();
      final response = await _client.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return _handleResponse(response, () => delete(endpoint));
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Response handling
  Future<dynamic> _handleResponse(
    http.Response response,
    Future<dynamic> Function() retryFunction,
  ) async {
    final statusCode = response.statusCode;
    final responseBody =
        response.body.isNotEmpty ? json.decode(response.body) : null;

    if (statusCode >= 200 && statusCode < 300) {
      return responseBody;
    } else if (statusCode == 401) {
      final refreshed = await refreshToken();
      if (refreshed) {
        return retryFunction();
      } else {
        throw ApiException(
          message: 'Authentication failed',
          statusCode: 401,
          error: responseBody?['message'] ?? 'Unauthorized',
        );
      }
    } else {
      String message = 'Request failed';
      if (responseBody != null) {
        if (responseBody?['message'] is String) {
          message = responseBody['message'];
        } else if (responseBody?['message'] is List) {
          message = responseBody['message'][0];
        }
      }

      throw ApiException(
        message: message,
        statusCode: statusCode,
        error: responseBody?['error'],
      );
    }
  }

  ApiException _handleError(dynamic error) {
    if (error is ApiException) return error;
    return ApiException(
      message: 'Network error occurred',
      error: error.toString(),
    );
  }

  void dispose() {
    _client.close();
  }
}
