import 'package:flutter_test/flutter_test.dart';
import 'package:shiftgrid/core/ads/ad_gate_policy.dart';

void main() {
  const policy = AdGatePolicy(interstitialEveryN: 3);

  test('shows on every Nth completed level', () {
    expect(policy.shouldShowInterstitial(completedLevels: 1, adsRemoved: false), isFalse);
    expect(policy.shouldShowInterstitial(completedLevels: 2, adsRemoved: false), isFalse);
    expect(policy.shouldShowInterstitial(completedLevels: 3, adsRemoved: false), isTrue);
    expect(policy.shouldShowInterstitial(completedLevels: 6, adsRemoved: false), isTrue);
  });

  test('never shows when ads are removed', () {
    expect(policy.shouldShowInterstitial(completedLevels: 3, adsRemoved: true), isFalse);
    expect(policy.shouldShowInterstitial(completedLevels: 9, adsRemoved: true), isFalse);
  });

  test('does not show before any level is completed', () {
    expect(policy.shouldShowInterstitial(completedLevels: 0, adsRemoved: false), isFalse);
  });
}
