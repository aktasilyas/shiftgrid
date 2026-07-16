import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/arrow.dart';
import '../../domain/entities/board.dart';
import '../../domain/entities/direction.dart';
import '../../domain/entities/position.dart';
import '../../domain/usecases/try_fire.dart';
import 'game_state.dart';

/// A hand-built, fully solvable 5×5 board used until the generator lands (FAZ 2).
///
/// A valid solving order is: #3, #4, #5, #2, #1.
Board demoBoard() => Board.fromArrows(
      width: 5,
      height: 5,
      arrows: const [
        Arrow(id: 1, position: Position(0, 0), direction: Direction.down),
        Arrow(id: 2, position: Position(4, 0), direction: Direction.right),
        Arrow(id: 3, position: Position(2, 2), direction: Direction.up),
        Arrow(id: 4, position: Position(2, 4), direction: Direction.left),
        Arrow(id: 5, position: Position(0, 4), direction: Direction.down),
      ],
    );

/// Owns the mutable [GameState]. Domain logic stays in the use-cases; this
/// notifier only decides how outcomes affect lives and win/lose status.
class GameNotifier extends Notifier<GameState> {
  @override
  GameState build() => GameState.initial(demoBoard());

  /// Pure look-ahead: what would happen if [position] were fired now.
  /// Lets the UI animate before the state actually changes.
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

  void reset() => state = GameState.initial(demoBoard());
}

final gameProvider = NotifierProvider<GameNotifier, GameState>(GameNotifier.new);
