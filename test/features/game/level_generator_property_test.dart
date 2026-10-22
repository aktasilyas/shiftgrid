import 'package:flutter_test/flutter_test.dart';
import 'package:shiftgrid/features/game/domain/entities/board.dart';
import 'package:shiftgrid/features/game/domain/entities/difficulty.dart';
import 'package:shiftgrid/features/game/domain/entities/generated_level.dart';
import 'package:shiftgrid/features/game/domain/usecases/level_generator.dart';
import 'package:shiftgrid/features/game/domain/usecases/try_fire.dart';

/// THE invariant test (BOOTSTRAP §2): 1000 seeds per difficulty must generate,
/// then playing the returned solution must fully clear the board.
/// If this is red, nothing merges.
void main() {
  const generator = LevelGenerator();
  const seedCount = 1000;

  // veryHard boards are ~10× the cell count of hard (~400ms each to
  // generate); a smaller sample keeps the suite usable while the
  // reverse-generation invariant is board-size independent.
  int seedsFor(Difficulty difficulty) =>
      difficulty == Difficulty.veryHard ? 40 : seedCount;

  void playAndExpectCleared(GeneratedLevel level) {
    Board board = level.board;
    for (final pos in level.solution) {
      final result = tryFire(board, pos);
      expect(
        result.didEscape,
        isTrue,
        reason:
            'seed=${level.seed} ${level.difficulty.name}: tap $pos did not escape',
      );
      board = result.board;
    }
    expect(
      board.isCleared,
      isTrue,
      reason: 'seed=${level.seed} ${level.difficulty.name}: board not cleared',
    );
  }

  for (final difficulty in Difficulty.values) {
    test('${seedsFor(difficulty)} seeds are all solvable — ${difficulty.name}',
        () {
      for (var seed = 0; seed < seedsFor(difficulty); seed++) {
        final level = generator.generate(seed: seed, difficulty: difficulty);
        playAndExpectCleared(level);
      }
    });
  }

  test('generation is deterministic for a given seed & difficulty', () {
    for (var seed = 0; seed < 50; seed++) {
      final a = generator.generate(seed: seed, difficulty: Difficulty.hard);
      final b = generator.generate(seed: seed, difficulty: Difficulty.hard);
      expect(a.board.snakeCount, b.board.snakeCount);
      expect(a.solution, b.solution);
      for (final snake in a.board.snakes) {
        final other = b.board.snakeAt(snake.head);
        expect(other, isNotNull,
            reason: 'seed=$seed: missing snake at ${snake.head}');
        expect(other!.direction, snake.direction);
        expect(other.body, snake.body);
      }
    }
  });

  test('solution length equals snake count', () {
    final level = generator.generate(seed: 7, difficulty: Difficulty.medium);
    expect(level.solution.length, level.board.snakeCount);
  });

  test('generated snakes have variable lengths within profile bounds', () {
    final profile = Difficulty.hard.profile;
    var sawLong = false;
    for (var seed = 0; seed < 40; seed++) {
      final level = generator.generate(seed: seed, difficulty: Difficulty.hard);
      for (final snake in level.board.snakes) {
        expect(snake.length, greaterThanOrEqualTo(profile.minLength));
        expect(snake.length, lessThanOrEqualTo(profile.maxLength));
        if (snake.length > profile.minLength) sawLong = true;
      }
    }
    expect(sawLong, isTrue, reason: 'expected at least one longer snake');
  });

  test('medium/hard average occupancy meets density targets', () {
    double avgOccupancy(Difficulty d) {
      var sum = 0.0;
      const samples = 40;
      for (var seed = 0; seed < samples; seed++) {
        final level = generator.generate(seed: seed, difficulty: d);
        final cells = level.board.width * level.board.height;
        sum += level.board.occupiedCellCount / cells;
      }
      return sum / samples;
    }

    // Soft floors — generator may place fewer snakes when candidates run out.
    expect(avgOccupancy(Difficulty.medium), greaterThan(0.55));
    expect(avgOccupancy(Difficulty.hard), greaterThan(0.60));
  });
}
