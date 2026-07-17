import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';

/// Thin wrapper around the AdMob SDK so the rest of the app depends on an
/// interface rather than the plugin directly.
abstract interface class AdService {
  Future<void> initialize();
  Future<void> loadInterstitial();
  Future<void> showInterstitial();
  Future<void> loadRewarded();

  /// Shows a rewarded ad; resolves true if the reward was earned.
  Future<bool> showRewarded();

  String get bannerUnitId;
}

class GoogleAdService implements AdService {
  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;
  bool _initialized = false;

  @override
  String get bannerUnitId => AdConfig.androidBanner;

  @override
  Future<void> initialize() async {
    if (_initialized || !Platform.isAndroid) return;
    AdConfig.assertTestOnly();
    await MobileAds.instance.initialize();
    _initialized = true;
    await loadInterstitial();
    await loadRewarded();
  }

  @override
  Future<void> loadInterstitial() async {
    if (!_initialized) return;
    await InterstitialAd.load(
      adUnitId: AdConfig.androidInterstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (error) {
          _interstitial = null;
          debugPrint('Interstitial failed: $error');
        },
      ),
    );
  }

  @override
  Future<void> showInterstitial() async {
    final ad = _interstitial;
    if (ad == null) return;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitial = null;
        loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitial = null;
        loadInterstitial();
      },
    );
    await ad.show();
  }

  @override
  Future<void> loadRewarded() async {
    if (!_initialized) return;
    await RewardedAd.load(
      adUnitId: AdConfig.androidRewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewarded = ad,
        onAdFailedToLoad: (error) {
          _rewarded = null;
          debugPrint('Rewarded failed: $error');
        },
      ),
    );
  }

  @override
  Future<bool> showRewarded() async {
    final ad = _rewarded;
    if (ad == null) return false;
    var earned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewarded = null;
        loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewarded = null;
        loadRewarded();
      },
    );
    await ad.show(
      onUserEarnedReward: (_, _) => earned = true,
    );
    return earned;
  }
}
