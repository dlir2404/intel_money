// lib/core/services/ad_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdService {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  int _numAttempts = 0;

  static final AdService _instance = AdService._internal();

  factory AdService() {
    return _instance;
  }

  AdService._internal();

  bool get isAdLoaded => _isAdLoaded;

  String get _interstitialAdUnitId {
    // Use test ad IDs in debug mode
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712'  // Android test ID
          : 'ca-app-pub-3940256099942544/4411468910'; // iOS test ID
    }

    // Use your real ad unit IDs in production
    return Platform.isAndroid
        ? dotenv.env['ANDROID_INTERSTITIAL_AD_UNIT_ID'] ?? ''
        : dotenv.env['IOS_INTERSTITIAL_AD_UNIT_ID'] ?? '';
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _numAttempts = 0;
          _isAdLoaded = true;

          // Set the full screen callback
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              // Khôi phục lại thanh trạng thái sau khi quảng cáo đóng
              SystemChrome.setEnabledSystemUIMode(
                SystemUiMode.manual,
                overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
              );

              ad.dispose();
              _isAdLoaded = false;
              // Load quảng cáo mới
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              // Khôi phục lại thanh trạng thái nếu quảng cáo không hiển thị được
              SystemChrome.setEnabledSystemUIMode(
                SystemUiMode.manual,
                overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
              );

              ad.dispose();
              _isAdLoaded = false;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          _numAttempts += 1;
          _isAdLoaded = false;

          if (_numAttempts <= 3) {
            loadInterstitialAd();
          }
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd != null && _isAdLoaded) {
      // Ẩn thanh trạng thái khi hiển thị quảng cáo
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
        overlays: [],
      );

      _interstitialAd!.show().then((_) {
        // Không cần làm gì thêm vì callback sẽ xử lý khi quảng cáo đóng
      });
    }
  }

  void disposeAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdLoaded = false;
  }
}