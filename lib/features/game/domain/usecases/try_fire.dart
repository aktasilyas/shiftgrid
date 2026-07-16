import '../entities/arrow.dart';
import '../entities/board.dart';
import '../entities/position.dart';
import 'ray_escapes.dart';

/// The outcome of tapping a cell to fire an arrow.
enum FireOutcome {
  /// The tapped cell had no arrow.
  noArrow,

  /// The arrow escaped; [FireResult.board] has it removed.
  escaped,

  /// The arrow was blocked; [FireResult.collisionAt] holds the obstacle.
  collided,
}

/// Immutable result of a [tryFire] attempt.
class FireResult {
  const FireResult({
    required this.outcome,
    required this.board,
    this.firedArrow,
    this.collisionAt,
  });

  final FireOutcome outcome;

  /// The resulting board (unchanged unless the arrow escaped).
  final Board board;

  /// The arrow that was fired, if any.
  final Arrow? firedArrow;

  /// The first obstacle position when [outcome] is [FireOutcome.collided].
  final Position? collisionAt;

  bool get didEscape => outcome == FireOutcome.escaped;
  bool get didCollide => outcome == FireOutcome.collided;
}

/// Attempts to fire the arrow at [position].
///
/// Pure function: never mutates [board]. Life loss / scoring are decided by the
/// caller (e.g. the presentation notifier) based on the returned outcome.
FireResult tryFire(Board board, Position position) {
  final arrow = board.arrowAt(position);
  if (arrow == null) {
    return FireResult(outcome: FireOutcome.noArrow, board: board);
  }

  if (rayEscapes(board, arrow)) {
    return FireResult(
      outcome: FireOutcome.escaped,
      board: board.removeAt(position),
      firedArrow: arrow,
    );
  }

  return FireResult(
    outcome: FireOutcome.collided,
    board: board,
    firedArrow: arrow,
    collisionAt: firstObstacle(board, arrow),
  );
}
