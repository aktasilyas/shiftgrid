import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/difficulty.dart';
import '../../domain/entities/generated_level.dart';
import '../../domain/entities/position.dart';
import '../../domain/usecases/level_generator.dart';
import '../../domain/usecases/try_fire.dart';
import 'game_state.dart';

/// Owns the mutable [GameState]. Domain logic stays in the use-cases; this
/// notifier only decides how outcomes affect lives / status, keeps an undo
/// history, and exposes a guaranteed hint.
class GameNotifier extends Notifier<GameState> {
  static const _generator = LevelGenerator();

  late GeneratedLevel _level;
  final List<GameState> _history = [];

  @override
  GameState build() => _start(seed: 1, difficulty: Difficulty.medium);

  GameState _start({required int seed, required Difficulty difficulty}) {
    _level = _generator.generate(seed: seed, difficulty: difficulty);
    _history.clear();
    return GameState.initial(_level.board);
  }

  int get seed => _level.seed;
  Difficulty get difficulty => _level.difficulty;
  List<Position> get solution => _level.solution;

  FireResult peek(Position position) => tryFire(state.board, position);

  /// A guaranteed-safe next move: the arrow with the highest placement id that
  /// remains always has a clear shot (see the reverse-generation invariant).
  Position? hint() {
    Position? best;
    var bestId = -1;
    for (final arrow in state.board.arrows) {
      if (arrow.id > bestId) {
        bestId = arrow.id;
        best = arrow.position;
      }
    }
    return best;
  }

  void applyResult(FireResult result) {
    if (!state.isPlaying) return;
    switch (result.outcome) {
      case FireOutcome.noArrow:
        return;
      case FireOutcome.escaped:
        _history.add(state);
        final board = result.board;
        state = state.copyWith(
          board: board,
          moves: state.moves + 1,
          status: board.isCleared ? GameStatus.won : GameStatus.playing,
        );
      case FireOutcome.collided:
        _history.add(state);
        final lives = state.lives - 1;
        state = state.copyWith(
          lives: lives,
          moves: state.moves + 1,
          status: lives <= 0 ? GameStatus.lost : GameStatus.playing,
        );
    }
  }

  /// Reverts the last move. No-op when there is nothing to undo.
  void undo() {
    if (_history.isEmpty) return;
    state = _history.removeLast();
  }

  /// Restarts the current level.
  void reset() => state = _start(seed: _level.seed, difficulty: _level.difficulty);

  /// Loads a specific level.
  void loadLevel({required int seed, required Difficulty difficulty}) =>
      state = _start(seed: seed, difficulty: difficulty);

  /// Loads the next seed at the current difficulty.
  void newGame({int? seed, Difficulty? difficulty}) => state = _start(
        seed: seed ?? _level.seed + 1,
        difficulty: difficulty ?? _level.difficulty,
      );
}

final gameProvider = NotifierProvider<GameNotifier, GameState>(GameNotifier.new);
