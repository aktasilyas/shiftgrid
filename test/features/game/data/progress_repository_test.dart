import 'package:flutter_test/flutter_test.dart';
import 'package:shiftgrid/features/game/data/datasources/progress_store.dart';
import 'package:shiftgrid/features/game/data/repositories/progress_repository_impl.dart';
import 'package:shiftgrid/features/game/domain/entities/difficulty.dart';

void main() {
  late ProgressRepositoryImpl repo;

  setUp(() {
    repo = ProgressRepositoryImpl(InMemoryProgressStore());
  });

  group('ProgressRepositoryImpl', () {
    test('a fresh level is not completed and has no best score', () {
      expect(repo.isCompleted(Difficulty.easy, 1), isFalse);
      expect(repo.bestMoves(Difficulty.easy, 1), isNull);
    });

    test('recording completion stores the move count', () async {
      await repo.recordCompletion(Difficulty.easy, 1, 7);
      expect(repo.isCompleted(Difficulty.easy, 1), isTrue);
      expect(repo.bestMoves(Difficulty.easy, 1), 7);
    });

    test('only the best (lowest) move count is kept', () async {
      await repo.recordCompletion(Difficulty.easy, 1, 7);
      await repo.recordCompletion(Difficulty.easy, 1, 9);
      expect(repo.bestMoves(Difficulty.easy, 1), 7);
      await repo.recordCompletion(Difficulty.easy, 1, 4);
      expect(repo.bestMoves(Difficulty.easy, 1), 4);
    });

    test('difficulties are tracked independently', () async {
      await repo.recordCompletion(Difficulty.easy, 1, 5);
      expect(repo.isCompleted(Difficulty.hard, 1), isFalse);
    });

    test('levels unlock sequentially', () async {
      expect(repo.isUnlocked(Difficulty.medium, 1), isTrue);
      expect(repo.isUnlocked(Difficulty.medium, 2), isFalse);

      await repo.recordCompletion(Difficulty.medium, 1, 6);
      expect(repo.isUnlocked(Difficulty.medium, 2), isTrue);
      expect(repo.isUnlocked(Difficulty.medium, 3), isFalse);
    });
  });
}
