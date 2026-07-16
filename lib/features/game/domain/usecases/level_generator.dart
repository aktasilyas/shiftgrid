import 'dart:math';

import '../entities/arrow.dart';
import '../entities/board.dart';
import '../entities/difficulty.dart';
import '../entities/direction.dart';
import '../entities/generated_level.dart';
import '../entities/position.dart';
import 'ray_escapes.dart';

/// Generates guaranteed-solvable levels by **reverse generation**.
///
/// Starting from an empty board, each step places an arrow at some (cell,
/// direction) that has a clear shot to the edge *given the current board*.
/// Because removing an arrow only ever opens paths (monotonicity), replaying
/// the placement order in reverse is always a valid solution — no solver needed.
class LevelGenerator {
  const LevelGenerator();

  /// Deterministic: the same [seed] and [difficulty] always yield the same level.
  GeneratedLevel generate({
    required int seed,
    Difficulty difficulty = Difficulty.medium,
  }) {
    final profile = difficulty.profile;
    final rng = Random(seed);

    GeneratedLevel? best;
    double bestRatio = double.infinity;

    for (var attempt = 0; attempt < profile.maxAttempts; attempt++) {
      final level = _build(rng, profile, seed, difficulty);
      final ratio = _openRatio(level.board);
      if (ratio <= profile.maxOpenRatio) return level;
      if (ratio < bestRatio) {
        bestRatio = ratio;
        best = level;
      }
    }

    // Difficulty gate never satisfied within the budget: keep the hardest one.
    return best!;
  }

  GeneratedLevel _build(
    Random rng,
    DifficultyProfile profile,
    int seed,
    Difficulty difficulty,
  ) {
    var board = Board.empty(profile.size);
    final placements = <Position>[];
    var nextId = 1;

    for (var i = 0; i < profile.arrowCount; i++) {
      final candidates = _openCandidates(board);
      if (candidates.isEmpty) break;
      final pick = candidates[rng.nextInt(candidates.length)];
      board = board.place(
        Arrow(id: nextId++, position: pick.position, direction: pick.direction),
      );
      placements.add(pick.position);
    }

    return GeneratedLevel(
      board: board,
      solution: placements.reversed.toList(),
      seed: seed,
      difficulty: difficulty,
    );
  }

  List<_Candidate> _openCandidates(Board board) {
    final result = <_Candidate>[];
    for (var row = 0; row < board.height; row++) {
      for (var col = 0; col < board.width; col++) {
        final pos = Position(row, col);
        if (!board.isEmptyAt(pos)) continue;
        for (final dir in Direction.values) {
          final probe = Arrow(id: 0, position: pos, direction: dir);
          if (rayEscapes(board, probe)) {
            result.add(_Candidate(pos, dir));
          }
        }
      }
    }
    return result;
  }

  double _openRatio(Board board) {
    if (board.arrowCount == 0) return 0;
    var open = 0;
    for (final arrow in board.arrows) {
      if (rayEscapes(board, arrow)) open++;
    }
    return open / board.arrowCount;
  }
}

class _Candidate {
  const _Candidate(this.position, this.direction);
  final Position position;
  final Direction direction;
}
