// lib/core/initialization/app_initializer.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intel_money/core/services/ad_service.dart';
import 'package:intel_money/core/network/api_client.dart';

/// Handles all initialization tasks when the app starts, before context is available
class AppInitializer {
  static Future<void> initialize() async {
    try {
      // Initialize configs
      await dotenv.load(fileName: '.env.dev');

      // Initialize API client
      await ApiClient.initialize(
          baseUrl: dotenv.env['API_URL'] ?? 'https://dev-api.intel-money.com'
      );

      // Initialize ads
      await _initializeAds();

      debugPrint('App initialization completed successfully');
    } catch (e) {
      debugPrint('Error during app initialization: $e');
    }
  }

  static Future<void> _initializeAds() async {
    await MobileAds.instance.initialize();
    AdService().loadInterstitialAd();
  }
}