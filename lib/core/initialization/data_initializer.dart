// lib/core/initialization/data_initializer.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intel_money/core/state/app_state.dart';
import 'package:intel_money/core/services/wallet_service.dart';
import 'package:intel_money/core/services/category_service.dart';
import 'package:intel_money/core/services/auth_service.dart';

import '../services/related_user_service.dart';
import '../services/statistic_service.dart';
import '../services/transaction_service.dart';

/// Handles loading all limited data sets when the app starts (after authentication)
class DataInitializer {
  static final DataInitializer _instance = DataInitializer._internal();

  factory DataInitializer() {
    return _instance;
  }

  DataInitializer._internal();

  /// Load all core data needed by the app
  Future<void> loadAllData(BuildContext context) async {
    final appState = Provider.of<AppState>(context, listen: false);

    try {
      debugPrint('Starting to load app data...');

      // Load data in parallel for better performance
      await Future.wait([
        _loadUserData(appState),
        _loadWallets(),
        _loadCategories(),
        _loadRelatedUsers(),
      ]);

      // Load transactions separately as it might be heavy and have references to wallets, categories, etc.
      await _loadTransactions();

      // Load today statistics separately as it might be heavy and have references to transactions
      await _loadTodayStatistics();


      debugPrint('>>>>>>>>> All app data loaded successfully');
    } catch (e) {
      debugPrint('Error loading app data: $e');
      // You may want to handle this error in the UI
    }
  }

  Future<void> _loadUserData(AppState appState) async {
    try {
      final user = await AuthService().getMe();
      if (user != null) {
        appState.setUser(user);
        if (user.preferences.timezone != null) {
          appState.setUserTimezone(user.preferences.timezone!);
        }
        debugPrint('User data loaded successfully');
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      rethrow;
    }
  }

  Future<void> _loadWallets() async {
    try {
      await WalletService().getWallets();
      debugPrint('Wallets loaded successfully');
    } catch (e) {
      debugPrint('Error loading wallets: $e');
      rethrow;
    }
  }

  Future<void> _loadCategories() async {
    try {
      await CategoryService().getCategories();

      debugPrint('Categories loaded successfully');
    } catch (e) {
      debugPrint('Error loading categories: $e');
      rethrow;
    }
  }

  Future<void> _loadRelatedUsers() async {
    try {
      await RelatedUserService().getAll();
      debugPrint('Related users loaded successfully');
    } catch (e) {
      debugPrint('Error loading related users: $e');
      rethrow;
    }
  }

  Future<void> _loadTransactions() async {
    try {
      await TransactionService().getTransactions();
      debugPrint('Transactions loaded successfully');
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      rethrow;
    }
  }

  Future<void> _loadTodayStatistics() async {
    try {
      await StatisticService().getTodayStatisticData();
      debugPrint('Today statistics loaded successfully');
    } catch (e) {
      debugPrint('Error loading today statistics: $e');
      rethrow;
    }
  }

  /// Refresh individual data types as needed
  Future<void> refreshWallets() async {
    await _loadWallets();
  }

  Future<void> refreshCategories() async {
    await _loadCategories();
  }

  Future<void> refreshUserData(BuildContext context) async {
    final appState = Provider.of<AppState>(context, listen: false);
    await _loadUserData(appState);
  }
}