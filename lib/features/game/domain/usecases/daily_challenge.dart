// Pure helpers for the daily challenge and day-streak.

/// A stable, contiguous day number (days since 2020-01-01, UTC). Contiguous so
/// "yesterday" is always `todayIndex - 1`, unlike yyyymmdd.
int dayIndex(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day)
        .difference(DateTime.utc(2020, 1, 1))
        .inDays;

/// The generator seed for a given day's challenge.
int dailySeed(int todayIndex) => todayIndex;

class StreakUpdate {
  const StreakUpdate({required this.streak, required this.lastDay});
  final int streak;
  final int lastDay;
}

/// Computes the new streak when the daily challenge is completed on
/// [todayIndex], given the previously stored [lastDayIndex] and [currentStreak].
StreakUpdate computeStreak({
  required int todayIndex,
  required int? lastDayIndex,
  required int currentStreak,
}) {
  if (lastDayIndex == null) {
    return StreakUpdate(streak: 1, lastDay: todayIndex);
  }
  if (lastDayIndex == todayIndex) {
    return StreakUpdate(streak: currentStreak, lastDay: todayIndex);
  }
  if (lastDayIndex == todayIndex - 1) {
    return StreakUpdate(streak: currentStreak + 1, lastDay: todayIndex);
  }
  return StreakUpdate(streak: 1, lastDay: todayIndex);
}
