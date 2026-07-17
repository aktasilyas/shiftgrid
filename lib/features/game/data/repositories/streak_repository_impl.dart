import '../../domain/repositories/streak_repository.dart';
import '../../domain/usecases/daily_challenge.dart';
import '../datasources/progress_store.dart';

class StreakRepositoryImpl implements StreakRepository {
  const StreakRepositoryImpl(this._store);

  static const _kStreak = 'daily.streak';
  static const _kLastDay = 'daily.lastDay';

  final ProgressStore _store;

  @override
  int get streak => _store.read(_kStreak) ?? 0;

  @override
  int? get lastDay => _store.read(_kLastDay);

  @override
  bool completedToday(int todayIndex) => lastDay == todayIndex;

  @override
  Future<void> recordDailyCompletion(int todayIndex) async {
    final update = computeStreak(
      todayIndex: todayIndex,
      lastDayIndex: lastDay,
      currentStreak: streak,
    );
    await _store.write(_kStreak, update.streak);
    await _store.write(_kLastDay, update.lastDay);
  }
}
