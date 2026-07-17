import 'dart:math';

import '../entities/board.dart';
import '../entities/difficulty.dart';
import '../entities/direction.dart';
import '../entities/generated_level.dart';
import '../entities/position.dart';
import '../entities/snake.dart';
import 'ray_escapes.dart';

/// Generates guaranteed-solvable levels by **reverse generation**.
///
/// Starting from an empty board, each step places a multi-cell snake whose
/// head has a clear shot to the edge *given the current board*. Because
/// removing a snake only ever opens paths (monotonicity), replaying the
/// placement order in reverse is always a valid solution — no solver needed.
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
    var bestRatio = double.infinity;

    for (var attempt = 0; attempt < profile.maxAttempts; attempt++) {
      final level = _build(rng, profile, seed, difficulty);
      final ratio = _openRatio(level.board);
      if (ratio <= profile.maxOpenRatio) return level;
      if (ratio < bestRatio) {
        bestRatio = ratio;
        best = level;
      }
    }

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

    for (var i = 0; i < profile.snakeCount; i++) {
      final snake = _tryPlaceSnake(
        board: board,
        rng: rng,
        id: nextId,
        profile: profile,
      );
      if (snake == null) break;
      board = board.place(snake);
      placements.add(snake.head);
      nextId++;
    }

    return GeneratedLevel(
      board: board,
      solution: placements.reversed.toList(),
      seed: seed,
      difficulty: difficulty,
    );
  }

  /// Picks a clear head shot and grows a body of variable length behind it.
  Snake? _tryPlaceSnake({
    required Board board,
    required Random rng,
    required int id,
    required DifficultyProfile profile,
  }) {
    final heads = _openHeads(board);
    if (heads.isEmpty) return null;

    // Shuffle a copy of candidates for variety without bias on order.
    final order = List<_HeadCandidate>.from(heads)..shuffle(rng);

    final targetLen = profile.minLength +
        rng.nextInt(profile.maxLength - profile.minLength + 1);

    for (final head in order) {
      final body = _growBody(
        board: board,
        head: head.position,
        headDir: head.direction,
        targetLength: targetLen,
        minLength: profile.minLength,
        rng: rng,
      );
      if (body == null) continue;
      final snake = Snake(id: id, body: body, direction: head.direction);
      if (!rayEscapes(board, snake)) continue;
      return snake;
    }
    return null;
  }

  List<_HeadCandidate> _openHeads(Board board) {
    final result = <_HeadCandidate>[];
    for (var row = 0; row < board.height; row++) {
      for (var col = 0; col < board.width; col++) {
        final pos = Position(row, col);
        if (!board.isEmptyAt(pos)) continue;
        for (final dir in Direction.values) {
          final probe = Snake(id: 0, body: [pos], direction: dir);
          if (rayEscapes(board, probe)) {
            result.add(_HeadCandidate(pos, dir));
          }
        }
      }
    }
    return result;
  }

  /// Grows a body head-first behind [head], preferring long winding paths.
  List<Position>? _growBody({
    required Board board,
    required Position head,
    required Direction headDir,
    required int targetLength,
    required int minLength,
    required Random rng,
  }) {
    final body = <Position>[head];
    var cursor = head;
    var prefer = headDir.opposite;

    while (body.length < targetLength) {
      final options = <Direction>[];
      for (final d in Direction.values) {
        final next = cursor.step(d);
        if (!board.inBounds(next)) continue;
        if (!board.isEmptyAt(next)) continue;
        if (body.contains(next)) continue;
        // Never grow into the head's escape ray — that would self-block.
        if (_onEscapeRay(head, headDir, next, board)) continue;
        options.add(d);
      }
      if (options.isEmpty) break;

      Direction pick;
      if (options.contains(prefer) && rng.nextDouble() < 0.7) {
        pick = prefer;
      } else {
        pick = options[rng.nextInt(options.length)];
      }
      cursor = cursor.step(pick);
      body.add(cursor);
      prefer = pick;
    }

    if (body.length < minLength) return null;
    return body;
  }

  bool _onEscapeRay(
    Position head,
    Direction headDir,
    Position cell,
    Board board,
  ) {
    var cursor = head.step(headDir);
    while (board.inBounds(cursor)) {
      if (cursor == cell) return true;
      cursor = cursor.step(headDir);
    }
    return false;
  }

  double _openRatio(Board board) {
    if (board.snakeCount == 0) return 0;
    var open = 0;
    for (final snake in board.snakes) {
      if (rayEscapes(board, snake)) open++;
    }
    return open / board.snakeCount;
  }
}

class _HeadCandidate {
  const _HeadCandidate(this.position, this.direction);
  final Position position;
  final Direction direction;
}
