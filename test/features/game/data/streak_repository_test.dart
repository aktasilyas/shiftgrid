import 'package:flutter_test/flutter_test.dart';
import 'package:shiftgrid/features/game/data/datasources/progress_store.dart';
import 'package:shiftgrid/features/game/data/repositories/streak_repository_impl.dart';

void main() {
  late StreakRepositoryImpl repo;

  setUp(() => repo = StreakRepositoryImpl(InMemoryProgressStore()));

  test('starts empty', () {
    expect(repo.streak, 0);
    expect(repo.lastDay, isNull);
    expect(repo.completedToday(100), isFalse);
  });

  test('first completion sets streak 1', () async {
    await repo.recordDailyCompletion(100);
    expect(repo.streak, 1);
    expect(repo.completedToday(100), isTrue);
  });

  test('same-day completion does not double count', () async {
    await repo.recordDailyCompletion(100);
    await repo.recordDailyCompletion(100);
    expect(repo.streak, 1);
  });

  test('consecutive days increment, gaps reset', () async {
    await repo.recordDailyCompletion(100);
    await repo.recordDailyCompletion(101);
    expect(repo.streak, 2);
    await repo.recordDailyCompletion(105);
    expect(repo.streak, 1);
  });
}
