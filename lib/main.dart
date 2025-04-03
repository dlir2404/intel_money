import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' hide AppState;
import 'package:intel_money/core/network/api_client.dart';
import 'package:intel_money/core/services/auth_service.dart';
import 'package:intel_money/core/state/app_state.dart';
import 'package:intel_money/features/auth/login/login_view.dart';
import 'package:intel_money/shared/component/layout/authenticated_app.dart';
import 'package:provider/provider.dart';

import 'core/config/routes.dart';
import 'core/initialization/app_initializer.dart';
import 'core/services/ad_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //initialize app
  await AppInitializer.initialize();

  runApp(ChangeNotifierProvider(
    create: (context) => AppState(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  final _authService = AuthService();
  MyApp({super.key});

  Future<bool> _checkAuth() async {
    //can set app state here to reduce 1 api call, maybe check later
    final user = await _authService.getMe();
    return user != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Intel Money',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      routes: AppRoutes.getRoutes(),
      home: FutureBuilder(
          future: _checkAuth(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting){
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            return snapshot.data == false ? const LoginView() : const AuthenticatedApp();
          }
      ),
    );
  }
}