import '../entities/board.dart';
import '../entities/position.dart';
import '../entities/snake.dart';
import 'ray_escapes.dart';

/// The outcome of tapping a cell to release a snake.
enum FireOutcome {
  /// The tapped cell had no snake.
  noSnake,

  /// The snake escaped; [FireResult.board] has it removed.
  escaped,

  /// The snake was blocked; [FireResult.collisionAt] holds the obstacle.
  collided,
}

/// Immutable result of a [tryFire] attempt.
class FireResult {
  const FireResult({
    required this.outcome,
    required this.board,
    this.firedSnake,
    this.collisionAt,
  });

  final FireOutcome outcome;

  /// The resulting board (unchanged unless the snake escaped).
  final Board board;

  /// The snake that was fired, if any.
  final Snake? firedSnake;

  /// The first obstacle position when [outcome] is [FireOutcome.collided].
  final Position? collisionAt;

  bool get didEscape => outcome == FireOutcome.escaped;
  bool get didCollide => outcome == FireOutcome.collided;
}

/// Attempts to release the snake occupying [position].
///
/// Pure function: never mutates [board]. Life loss / scoring are decided by the
/// caller based on the returned outcome. Tapping any body cell fires the snake.
FireResult tryFire(Board board, Position position) {
  final snake = board.snakeAt(position);
  if (snake == null) {
    return FireResult(outcome: FireOutcome.noSnake, board: board);
  }

  if (rayEscapes(board, snake)) {
    return FireResult(
      outcome: FireOutcome.escaped,
      board: board.removeSnake(snake),
      firedSnake: snake,
    );
  }

  return FireResult(
    outcome: FireOutcome.collided,
    board: board,
    firedSnake: snake,
    collisionAt: firstObstacle(board, snake),
  );
}
