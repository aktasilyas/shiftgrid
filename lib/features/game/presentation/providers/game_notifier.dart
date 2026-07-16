import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/difficulty.dart';
import '../../domain/entities/generated_level.dart';
import '../../domain/entities/position.dart';
import '../../domain/usecases/level_generator.dart';
import '../../domain/usecases/try_fire.dart';
import 'game_state.dart';

/// Owns the mutable [GameState]. Domain logic stays in the use-cases; this
/// notifier only decides how outcomes affect lives and win/lose status, and
/// which generated level is currently loaded.
class GameNotifier extends Notifier<GameState> {
  static const _generator = LevelGenerator();

  late GeneratedLevel _level;

  @override
  GameState build() => _start(seed: 1, difficulty: Difficulty.medium);

  GameState _start({required int seed, required Difficulty difficulty}) {
    _level = _generator.generate(seed: seed, difficulty: difficulty);
    return GameState.initial(_level.board);
  }

  /// A guaranteed solution for the current level (used by hints later).
  List<Position> get solution => _level.solution;

  Difficulty get difficulty => _level.difficulty;

  /// Pure look-ahead: what would happen if [position] were fired now.
  FireResult peek(Position position) => tryFire(state.board, position);

  /// Applies a previously [peek]ed result to the game state.
  void applyResult(FireResult result) {
    if (!state.isPlaying) return;
    switch (result.outcome) {
      case FireOutcome.noArrow:
        return;
      case FireOutcome.escaped:
        final board = result.board;
        state = state.copyWith(
          board: board,
          moves: state.moves + 1,
          status: board.isCleared ? GameStatus.won : GameStatus.playing,
        );
      case FireOutcome.collided:
        final lives = state.lives - 1;
        state = state.copyWith(
          lives: lives,
          moves: state.moves + 1,
          status: lives <= 0 ? GameStatus.lost : GameStatus.playing,
        );
    }
  }

  /// Restarts the current level from scratch.
  void reset() => state = GameState.initial(_level.board);

  /// Loads a new level. Defaults to the next seed at the current difficulty.
  void newGame({int? seed, Difficulty? difficulty}) => state = _start(
        seed: seed ?? _level.seed + 1,
        difficulty: difficulty ?? _level.difficulty,
      );
}

final gameProvider = NotifierProvider<GameNotifier, GameState>(GameNotifier.new);
