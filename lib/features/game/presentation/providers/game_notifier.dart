import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/difficulty.dart';
import '../../domain/entities/generated_level.dart';
import '../../domain/entities/position.dart';
import '../../domain/usecases/level_generator.dart';
import '../../domain/usecases/ray_escapes.dart';
import '../../domain/usecases/try_fire.dart';
import 'game_state.dart';

/// Owns the mutable [GameState]. Domain logic stays in the use-cases; this
/// notifier only decides how outcomes affect lives / status, keeps an undo
/// history, and exposes a guaranteed hint.
class GameNotifier extends Notifier<GameState> {
  static const _generator = LevelGenerator();

  /// Every Nth consecutive escape (combo) refunds one life, up to max.
  static const comboRewardThreshold = 4;

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

  /// A snake that can escape right now, chosen at random for variety.
  ///
  /// The reverse-generation invariant guarantees at least one open snake
  /// exists while the board is uncleared, so this only returns null when
  /// the board is empty.
  int? hintSnakeId() {
    final open = [
      for (final snake in state.board.snakes)
        if (rayEscapes(state.board, snake)) snake.id,
    ];
    if (open.isEmpty) return null;
    return open[Random().nextInt(open.length)];
  }

  void applyResult(FireResult result) {
    if (!state.isPlaying) return;
    switch (result.outcome) {
      case FireOutcome.noSnake:
        return;
      case FireOutcome.escaped:
        _history.add(state);
        final board = result.board;
        final combo = state.combo + 1;
        final rewardLife = combo % comboRewardThreshold == 0 &&
            state.lives < state.maxLives;
        state = state.copyWith(
          board: board,
          moves: state.moves + 1,
          combo: combo,
          bestCombo: combo > state.bestCombo ? combo : state.bestCombo,
          lives: rewardLife ? state.lives + 1 : state.lives,
          status: board.isCleared ? GameStatus.won : GameStatus.playing,
        );
      case FireOutcome.collided:
        _history.add(state);
        final lives = state.lives - 1;
        state = state.copyWith(
          lives: lives,
          moves: state.moves + 1,
          combo: 0,
          status: lives <= 0 ? GameStatus.lost : GameStatus.playing,
        );
    }
  }

  /// Reverts the last move. No-op when there is nothing to undo.
  void undo() {
    if (_history.isEmpty) return;
    state = _history.removeLast();
  }

  /// Restores one life after a loss (e.g. via a rewarded ad).
  void revive() {
    if (state.status != GameStatus.lost) return;
    _history.clear();
    state = state.copyWith(lives: 1, status: GameStatus.playing, combo: 0);
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
