import '../../domain/entities/board.dart';

enum GameStatus { playing, won, lost }

/// Immutable snapshot of a game in progress.
class GameState {
  const GameState({
    required this.board,
    required this.lives,
    required this.maxLives,
    required this.status,
    required this.moves,
    required this.combo,
    required this.bestCombo,
  });

  factory GameState.initial(Board board, {int lives = 3}) => GameState(
        board: board,
        lives: lives,
        maxLives: lives,
        status: GameStatus.playing,
        moves: 0,
        combo: 0,
        bestCombo: 0,
      );

  final Board board;
  final int lives;
  final int maxLives;
  final GameStatus status;
  final int moves;

  /// Consecutive successful escapes without a collision (original mechanic).
  final int combo;
  final int bestCombo;

  bool get isPlaying => status == GameStatus.playing;

  GameState copyWith({
    Board? board,
    int? lives,
    GameStatus? status,
    int? moves,
    int? combo,
    int? bestCombo,
  }) =>
      GameState(
        board: board ?? this.board,
        lives: lives ?? this.lives,
        maxLives: maxLives,
        status: status ?? this.status,
        moves: moves ?? this.moves,
        combo: combo ?? this.combo,
        bestCombo: bestCombo ?? this.bestCombo,
      );
}
