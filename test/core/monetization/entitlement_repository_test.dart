import 'package:flutter_test/flutter_test.dart';
import 'package:shiftgrid/core/monetization/entitlement_repository.dart';
import 'package:shiftgrid/features/game/data/datasources/progress_store.dart';

void main() {
  late EntitlementRepositoryImpl repo;

  setUp(() => repo = EntitlementRepositoryImpl(InMemoryProgressStore()));

  test('ads are not removed by default', () {
    expect(repo.adsRemoved, isFalse);
  });

  test('setAdsRemoved persists the entitlement', () async {
    await repo.setAdsRemoved(true);
    expect(repo.adsRemoved, isTrue);
    await repo.setAdsRemoved(false);
    expect(repo.adsRemoved, isFalse);
  });
}
