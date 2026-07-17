/// Persists the daily-challenge streak.
abstract interface class StreakRepository {
  int get streak;
  int? get lastDay;

  bool completedToday(int todayIndex);

  /// Records a daily completion for [todayIndex], updating the streak.
  Future<void> recordDailyCompletion(int todayIndex);
}
