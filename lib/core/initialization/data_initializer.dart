// lib/core/initialization/data_initializer.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intel_money/core/state/app_state.dart';
import 'package:intel_money/core/services/wallet_service.dart';
import 'package:intel_money/core/services/category_service.dart';
import 'package:intel_money/core/services/auth_service.dart';

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
        _loadWallets(appState),
        _loadCategories(appState),
      ]);

      // Load transactions separately as it might be heavy and have references to wallets, categories, etc.
      await _loadTransactions();

      debugPrint('>>>>>>>>> All app data loaded successfully');
    } catch (e) {
      debugPrint('Error loading app data: $e');
      // You may want to handle this error in the UI
    }
  }

  Future<void> _loadUserData(AppState appState) async {
    try {
      final authService = AuthService();
      final user = await authService.getMe();
      if (user != null) {
        appState.setUser(user);
        debugPrint('User data loaded successfully');
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      rethrow;
    }
  }

  Future<void> _loadWallets(AppState appState) async {
    try {
      final walletService = WalletService(appState: appState);
      await walletService.getWallets();
      debugPrint('Wallets loaded successfully');
    } catch (e) {
      debugPrint('Error loading wallets: $e');
      rethrow;
    }
  }

  Future<void> _loadCategories(AppState appState) async {
    try {
      final categoryService = CategoryService(appState: appState);
      await categoryService.getCategories();

      debugPrint('Categories loaded successfully');
    } catch (e) {
      debugPrint('Error loading categories: $e');
      rethrow;
    }
  }

  Future<void> _loadTransactions() async {
    try {
      final transactionService = TransactionService();
      await transactionService.getTransactions();
      debugPrint('Transactions loaded successfully');
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      rethrow;
    }
  }

  /// Refresh individual data types as needed
  Future<void> refreshWallets(BuildContext context) async {
    final appState = Provider.of<AppState>(context, listen: false);
    await _loadWallets(appState);
  }

  Future<void> refreshCategories(BuildContext context) async {
    final appState = Provider.of<AppState>(context, listen: false);
    await _loadCategories(appState);
  }

  Future<void> refreshUserData(BuildContext context) async {
    final appState = Provider.of<AppState>(context, listen: false);
    await _loadUserData(appState);
  }
}