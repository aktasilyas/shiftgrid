import 'package:flutter_test/flutter_test.dart';
import 'package:shiftgrid/features/game/domain/usecases/daily_challenge.dart';

void main() {
  group('dayIndex', () {
    test('is contiguous across days and months', () {
      final d1 = dayIndex(DateTime(2020, 1, 1));
      final d2 = dayIndex(DateTime(2020, 1, 2));
      expect(d2 - d1, 1);

      final endJan = dayIndex(DateTime(2024, 1, 31));
      final startFeb = dayIndex(DateTime(2024, 2, 1));
      expect(startFeb - endJan, 1);
    });

    test('ignores the time-of-day', () {
      expect(
        dayIndex(DateTime(2024, 5, 5, 1, 30)),
        dayIndex(DateTime(2024, 5, 5, 23, 45)),
      );
    });
  });

  group('computeStreak', () {
    test('first ever completion starts a streak of 1', () {
      final r = computeStreak(todayIndex: 100, lastDayIndex: null, currentStreak: 0);
      expect(r.streak, 1);
      expect(r.lastDay, 100);
    });

    test('completing again the same day keeps the streak', () {
      final r = computeStreak(todayIndex: 100, lastDayIndex: 100, currentStreak: 5);
      expect(r.streak, 5);
    });

    test('completing on the next day increments the streak', () {
      final r = computeStreak(todayIndex: 101, lastDayIndex: 100, currentStreak: 5);
      expect(r.streak, 6);
    });

    test('a gap resets the streak to 1', () {
      final r = computeStreak(todayIndex: 103, lastDayIndex: 100, currentStreak: 5);
      expect(r.streak, 1);
    });
  });
}
