import 'package:flutter/foundation.dart';

/// Ad unit configuration.
///
/// Ships with Google's official **TEST** IDs. Real production IDs are supplied
/// at build time via `--dart-define` (never committed):
///
/// ```
/// flutter build appbundle \
///   --dart-define=ADMOB_BANNER=ca-app-pub-XXXX/XXXX \
///   --dart-define=ADMOB_INTERSTITIAL=ca-app-pub-XXXX/XXXX \
///   --dart-define=ADMOB_REWARDED=ca-app-pub-XXXX/XXXX
/// ```
///
/// The manifest `APPLICATION_ID` must also be swapped to the real app id before
/// release (see docs/RELEASE.md). [assertTestOnly] warns if forgotten.
abstract final class AdConfig {
  // Production IDs (empty unless provided via --dart-define).
  static const String _prodBanner = String.fromEnvironment('ADMOB_BANNER');
  static const String _prodInterstitial =
      String.fromEnvironment('ADMOB_INTERSTITIAL');
  static const String _prodRewarded = String.fromEnvironment('ADMOB_REWARDED');

  // Google official test IDs.
  static const String _testAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const String _testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewarded =
      'ca-app-pub-3940256099942544/5224354917';

  /// True when no production banner id was injected at build time.
  static const bool useTestIds = _prodBanner == '';

  static String get androidAppId => _testAppId;
  static String get androidBanner => useTestIds ? _testBanner : _prodBanner;
  static String get androidInterstitial =>
      useTestIds ? _testInterstitial : _prodInterstitial;
  static String get androidRewarded =>
      useTestIds ? _testRewarded : _prodRewarded;

  /// Loud reminder if someone builds a release while still on test IDs.
  static void assertTestOnly() {
    if (kReleaseMode && useTestIds) {
      debugPrint(
        'WARNING: shipping a release build with TEST AdMob IDs. '
        'Pass real IDs via --dart-define and update the manifest APPLICATION_ID.',
      );
    }
  }
}
