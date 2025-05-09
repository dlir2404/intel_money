// lib/config/routes.dart
import 'package:flutter/material.dart';
import 'package:intel_money/features/auth/login/login_view.dart';
import 'package:intel_money/features/auth/register/register_view.dart';
import 'package:intel_money/features/transaction/screens/transaction_history_screen.dart';
import 'package:intel_money/shared/component/layout/authenticated_app.dart';

import '../../features/category/screens/create_category_screen.dart';
import '../../features/category/screens/edit_category_screen.dart';
import '../../features/wallet/screens/create_wallet_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String createWallet = '/wallets/create';
  static const String createCategory = '/categories/create';
  static const String transactionHistory = '/transaction/history';
  static const String editCategory = '/categories/edit';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginView(),
      register: (context) => const RegisterView(),
      home: (context) => const AuthenticatedApp(),

      createWallet: (context) => const CreateWalletScreen(),

      createCategory: (context) => const CreateCategoryScreen(),
      editCategory: (context) => const EditCategoryScreen(),

      transactionHistory: (context) => const TransactionHistoryScreen(),
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

  static void navigateToTransactionHistory(BuildContext context) {
    Navigator.pushNamed(context, transactionHistory);
  }
}