import '../entities/arrow.dart';
import '../entities/board.dart';
import '../entities/position.dart';

/// Whether [arrow] has a clear path off the board along its direction.
///
/// Steps from the cell in front of the arrow to the edge. If every cell is
/// empty until it leaves the board, the shot escapes (true). If any occupied
/// cell is hit first, the shot is blocked (false).
///
/// This is the monotonic primitive the level generator relies on: removing an
/// arrow can only open paths, never close them.
bool rayEscapes(Board board, Arrow arrow) {
  Position cursor = arrow.position.step(arrow.direction);
  while (board.inBounds(cursor)) {
    if (!board.isEmptyAt(cursor)) return false;
    cursor = cursor.step(arrow.direction);
  }
  return true;
}

/// The first occupied cell in the arrow's path, or null if the path is clear.
Position? firstObstacle(Board board, Arrow arrow) {
  Position cursor = arrow.position.step(arrow.direction);
  while (board.inBounds(cursor)) {
    if (!board.isEmptyAt(cursor)) return cursor;
    cursor = cursor.step(arrow.direction);
  }
  return null;
}
