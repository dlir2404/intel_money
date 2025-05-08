import 'package:flutter/material.dart';
import 'package:intel_money/core/services/auth_service.dart';
import 'package:intel_money/core/state/app_state.dart';
import 'package:intel_money/core/state/related_user_state.dart';
import 'package:intel_money/core/state/transaction_state.dart';
import 'package:intel_money/core/state/wallet_state.dart';
import 'package:intel_money/features/auth/login/login_view.dart';
import 'package:intel_money/shared/component/layout/authenticated_app.dart';
import 'package:provider/provider.dart';

import 'core/config/routes.dart';
import 'core/initialization/app_initializer.dart';
import 'core/state/category_state.dart';
import 'core/state/statistic_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //initialize app
  await AppInitializer.initialize();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => AppState()),
      ChangeNotifierProvider(create: (context) => WalletState()),
      ChangeNotifierProvider(create: (context) => CategoryState()),
      ChangeNotifierProvider(create: (context) => TransactionState()),
      ChangeNotifierProvider(create: (context) => StatisticState()),
      ChangeNotifierProvider(create: (context) => RelatedUserState()),
      // Add more providers as needed
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkAuth() async {
    //can set app state here to reduce 1 api call, maybe check later
    final user = await AuthService().getMe();
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