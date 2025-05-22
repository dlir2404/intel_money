// lib/core/services/ad_service.dart
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdService {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  int _numAttempts = 0;

  // Tỉ lệ hiển thị quảng cáo cho người dùng thường (0.7 = 70%)
  double adProbability = 0.7;

  // Thời gian tối thiểu giữa các lần hiển thị quảng cáo (tính bằng phút)
  int minTimeBetweenAds = 3;

  // Random để tính xác suất hiển thị
  final Random _random = Random();

  // Lưu thời điểm hiển thị quảng cáo gần nhất
  DateTime? _lastAdShownTime;

  bool _isVip = false;
  void setVipStatus(bool isVip) {
    _isVip = isVip;
  }

  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
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

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    loadInterstitialAd();
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

  // Phương thức quyết định có nên hiển thị quảng cáo hay không
  bool shouldShowAd() {
    // Kiểm tra trạng thái VIP trước
    if (_isVip) {
      return false; // Người dùng VIP không hiển thị quảng cáo
    }

    // Kiểm tra thời gian giữa các lần hiển thị
    if (_lastAdShownTime != null) {
      final timeDifference = DateTime.now().difference(_lastAdShownTime!);
      if (timeDifference.inMinutes < minTimeBetweenAds) {
        return false;
      }
    }

    // Kiểm tra xem quảng cáo đã được tải chưa
    if (!_isAdLoaded) {
      return false;
    }

    // Áp dụng tỉ lệ xác suất cho người dùng thường
    return _random.nextDouble() < adProbability;
  }

  // Phương thức hiển thị quảng cáo nếu điều kiện thỏa mãn
  void showAdIfEligible() {
    if (shouldShowAd()) {
      // Cập nhật thời gian hiển thị quảng cáo gần nhất
      _lastAdShownTime = DateTime.now();

      showInterstitialAd();
    }
  }

  void showInterstitialAd() {
    if (_interstitialAd != null && _isAdLoaded) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
        overlays: [],
      );

      _interstitialAd!.show().then((_) {
        // Không cần làm gì thêm vì callback sẽ xử lý khi quảng cáo đóng
      });
    }
  }

  void setAdProbability(double probability) {
    if (probability >= 0 && probability <= 1) {
      adProbability = probability;
    }
  }

  void setMinTimeBetweenAds(int minutes) {
    if (minutes > 0) {
      minTimeBetweenAds = minutes;
    }
  }

  void disposeAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdLoaded = false;
  }
}