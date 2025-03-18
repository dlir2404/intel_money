// lib/config/routes.dart
import 'package:flutter/material.dart';
import 'package:intel_money/features/auth/login/login_view.dart';
import 'package:intel_money/features/auth/register/register_view.dart';
import 'package:intel_money/shared/component/layout/authenticated_app.dart';

import '../../features/wallet/screens/create_wallet_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String createWallet = '/wallets/create';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginView(),
      register: (context) => const RegisterView(),
      home: (context) => const AuthenticatedApp(),

      createWallet: (context) => const CreateWalletScreen(),
    };
  }

  // Navigation helper methods
  static void navigateToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, login);
  }

  static void navigateToHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, home);
  }

  static void navigateToRegister(BuildContext context) {
    Navigator.pushNamed(context, register);
  }
}