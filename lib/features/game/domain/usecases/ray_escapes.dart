import '../entities/board.dart';
import '../entities/position.dart';
import '../entities/snake.dart';

/// Whether [snake] has a clear path off the board from its head.
///
/// Steps from the cell in front of the head along [Snake.direction]. Treats
/// both other occupants and this snake's own body cells as blockers (so a
/// not-yet-placed probe cannot self-block its escape ray). Empty cells until
/// the edge means escape (true).
///
/// Monotonicity: removing a snake only ever opens paths, never closes them.
bool rayEscapes(Board board, Snake snake) {
  Position cursor = snake.head.step(snake.direction);
  while (board.inBounds(cursor)) {
    if (snake.occupies(cursor)) return false;
    if (!board.isEmptyAt(cursor)) return false;
    cursor = cursor.step(snake.direction);
  }
  return true;
}

/// The first occupied cell in the snake's escape path, or null if clear.
Position? firstObstacle(Board board, Snake snake) {
  Position cursor = snake.head.step(snake.direction);
  while (board.inBounds(cursor)) {
    if (snake.occupies(cursor) || !board.isEmptyAt(cursor)) return cursor;
    cursor = cursor.step(snake.direction);
  }
  return null;
}
