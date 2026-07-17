import '../../features/game/data/datasources/progress_store.dart';

/// Tracks non-consumable entitlements (currently: "remove ads").
abstract interface class EntitlementRepository {
  bool get adsRemoved;
  Future<void> setAdsRemoved(bool value);
}

class EntitlementRepositoryImpl implements EntitlementRepository {
  const EntitlementRepositoryImpl(this._store);

  static const _kAdsRemoved = 'ads.removed';

  final ProgressStore _store;

  @override
  bool get adsRemoved => (_store.read(_kAdsRemoved) ?? 0) == 1;

  @override
  Future<void> setAdsRemoved(bool value) =>
      _store.write(_kAdsRemoved, value ? 1 : 0);
}
