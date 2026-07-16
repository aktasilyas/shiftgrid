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

  /// Plays [level.solution] in order; every tap must escape and the board must
  /// end empty. Returns nothing; asserts inline for precise failure reasons.
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
    test('$seedCount seeds are all solvable — ${difficulty.name}', () {
      for (var seed = 0; seed < seedCount; seed++) {
        final level = generator.generate(seed: seed, difficulty: difficulty);
        playAndExpectCleared(level);
      }
    });
  }

  test('generation is deterministic for a given seed & difficulty', () {
    for (var seed = 0; seed < 50; seed++) {
      final a = generator.generate(seed: seed, difficulty: Difficulty.hard);
      final b = generator.generate(seed: seed, difficulty: Difficulty.hard);
      expect(a.board.arrowCount, b.board.arrowCount);
      expect(a.solution, b.solution);
      for (final arrow in a.board.arrows) {
        final other = b.board.arrowAt(arrow.position);
        expect(other, isNotNull,
            reason: 'seed=$seed: position mismatch at ${arrow.position}');
        expect(other!.direction, arrow.direction);
      }
    }
  });

  test('solution length equals arrow count', () {
    final level = generator.generate(seed: 7, difficulty: Difficulty.medium);
    expect(level.solution.length, level.board.arrowCount);
  });
}
