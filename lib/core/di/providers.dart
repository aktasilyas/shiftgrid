import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/game/data/datasources/progress_store.dart';
import '../../features/game/data/repositories/progress_repository_impl.dart';
import '../../features/game/data/repositories/streak_repository_impl.dart';
import '../../features/game/domain/repositories/progress_repository.dart';
import '../../features/game/domain/repositories/streak_repository.dart';
import '../ads/ad_gate_policy.dart';
import '../ads/ad_service.dart';
import '../monetization/entitlement_repository.dart';
import '../monetization/purchase_service.dart';

/// Overridden in `main` once the async instance is ready.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);

/// Overridden in `main` with a Hive-backed store.
final progressStoreProvider = Provider<ProgressStore>(
  (ref) => throw UnimplementedError('progressStoreProvider not overridden'),
);

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => ProgressRepositoryImpl(ref.watch(progressStoreProvider)),
);

final streakRepositoryProvider = Provider<StreakRepository>(
  (ref) => StreakRepositoryImpl(ref.watch(progressStoreProvider)),
);

final entitlementRepositoryProvider = Provider<EntitlementRepository>(
  (ref) => EntitlementRepositoryImpl(ref.watch(progressStoreProvider)),
);

final adGatePolicyProvider = Provider<AdGatePolicy>(
  (ref) => const AdGatePolicy(),
);

final adServiceProvider = Provider<AdService>((ref) => GoogleAdService());

final purchaseServiceProvider = Provider<PurchaseService>(
  (ref) => PurchaseService(ref.watch(entitlementRepositoryProvider)),
);

/// Counts wins this session to drive interstitial cadence.
class SessionWinsNotifier extends Notifier<int> {
  @override
  int build() => 0;

  int increment() => state = state + 1;
}

final sessionWinsProvider =
    NotifierProvider<SessionWinsNotifier, int>(SessionWinsNotifier.new);
