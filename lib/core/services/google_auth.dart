import 'package:google_sign_in/google_sign_in.dart';

import '../network/api_client.dart';

class GoogleAuthService {
  final ApiClient _apiClient;

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  GoogleAuthService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient.instance;

  signIn() async {
    final GoogleSignInAccount? account = await _googleSignIn.signIn();
    final GoogleSignInAuthentication? auth = await account?.authentication;

    if (auth == null || auth.idToken == null) {
      throw Exception('Google Sign-In failed');
    }

    // Gửi idToken đến backend để xác thực
    final response = await _apiClient.post('/auth/google', {
      'idToken': auth.idToken,
    });

    await _apiClient.saveToken(response['accessToken']);
    await _apiClient.saveRefreshToken(response['refreshToken']);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
