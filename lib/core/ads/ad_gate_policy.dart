/// Pure decision logic for when to show an interstitial ad. Kept free of any
/// platform/Flutter dependency so it is fully unit-testable.
class AdGatePolicy {
  const AdGatePolicy({this.interstitialEveryN = 3});

  /// Show an interstitial once every N completed levels.
  final int interstitialEveryN;

  bool shouldShowInterstitial({
    required int completedLevels,
    required bool adsRemoved,
  }) {
    if (adsRemoved) return false;
    if (completedLevels <= 0) return false;
    return completedLevels % interstitialEveryN == 0;
  }
}
