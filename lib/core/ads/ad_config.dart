import 'package:flutter/foundation.dart';

/// Ad unit configuration.
///
/// IMPORTANT: These are Google's official **TEST** IDs. No real ad units are
/// shipped. Replacing them with production IDs is a pre-release task tracked in
/// docs/BACKLOG.md; [assertTestOnly] guards against forgetting.
abstract final class AdConfig {
  /// Flip to false only once real, approved ad units are wired in.
  static const bool useTestIds = true;

  // --- Android test unit IDs (https://developers.google.com/admob/android/test-ads) ---
  static const String androidAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const String androidBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const String androidInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const String androidRewarded =
      'ca-app-pub-3940256099942544/5224354917';

  /// Loud reminder if someone builds a release while still on test IDs.
  static void assertTestOnly() {
    if (kReleaseMode && useTestIds) {
      debugPrint(
        'WARNING: shipping a release build with TEST AdMob IDs. '
        'Replace AdConfig IDs before store submission.',
      );
    }
  }
}
