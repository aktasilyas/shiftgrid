import 'package:flutter_test/flutter_test.dart';
import 'package:shiftgrid/features/game/domain/entities/board.dart';
import 'package:shiftgrid/features/game/domain/entities/direction.dart';
import 'package:shiftgrid/features/game/domain/entities/position.dart';
import 'package:shiftgrid/features/game/domain/entities/snake.dart';
import 'package:shiftgrid/features/game/domain/usecases/ray_escapes.dart';

void main() {
  group('rayEscapes', () {
    test('single-cell snake always escapes', () {
      final snake = Snake(
        id: 1,
        body: const [Position(2, 2)],
        direction: Direction.up,
      );
      final board = Board.fromSnakes(width: 5, height: 5, snakes: [snake]);
      expect(rayEscapes(board, snake), isTrue);
    });

    test('edge head pointing outward escapes immediately', () {
      final snake = Snake(
        id: 1,
        body: const [Position(0, 0), Position(1, 0)],
        direction: Direction.up,
      );
      final board = Board.fromSnakes(width: 3, height: 3, snakes: [snake]);
      expect(rayEscapes(board, snake), isTrue);
      expect(firstObstacle(board, snake), isNull);
    });

    test('blocked when another snake is on the path', () {
      // Head at (2,1) facing right; body trails left (behind the head).
      final shooter = Snake(
        id: 1,
        body: const [Position(2, 1), Position(2, 0)],
        direction: Direction.right,
      );
      final blocker = Snake(
        id: 2,
        body: const [Position(2, 3)],
        direction: Direction.up,
      );
      final board =
          Board.fromSnakes(width: 5, height: 5, snakes: [shooter, blocker]);
      expect(rayEscapes(board, shooter), isFalse);
      expect(firstObstacle(board, shooter), const Position(2, 3));
    });

    test('adjacent blocker directly in front of the head blocks', () {
      final shooter = Snake(
        id: 1,
        body: const [Position(0, 0), Position(1, 0)],
        direction: Direction.right,
      );
      final blocker = Snake(
        id: 2,
        body: const [Position(0, 1)],
        direction: Direction.up,
      );
      final board =
          Board.fromSnakes(width: 4, height: 4, snakes: [shooter, blocker]);
      expect(rayEscapes(board, shooter), isFalse);
      expect(firstObstacle(board, shooter), const Position(0, 1));
    });

    test('long snake escapes when the head path is clear', () {
      final snake = Snake(
        id: 1,
        body: const [
          Position(0, 0),
          Position(0, 1),
          Position(1, 1),
          Position(2, 1),
        ],
        direction: Direction.left,
      );
      final other = Snake(
        id: 2,
        body: const [Position(3, 3)],
        direction: Direction.down,
      );
      final board =
          Board.fromSnakes(width: 5, height: 5, snakes: [snake, other]);
      expect(rayEscapes(board, snake), isTrue);
    });
  });
}
