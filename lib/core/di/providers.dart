import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/game/data/datasources/progress_store.dart';
import '../../features/game/data/repositories/progress_repository_impl.dart';
import '../../features/game/data/repositories/streak_repository_impl.dart';
import '../../features/game/domain/repositories/progress_repository.dart';
import '../../features/game/domain/repositories/streak_repository.dart';

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
