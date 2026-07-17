import 'package:flutter_test/flutter_test.dart';
import 'package:shiftgrid/features/game/domain/entities/board.dart';
import 'package:shiftgrid/features/game/domain/entities/direction.dart';
import 'package:shiftgrid/features/game/domain/entities/position.dart';
import 'package:shiftgrid/features/game/domain/entities/snake.dart';

void main() {
  group('Board', () {
    test('empty board reports cleared', () {
      final board = Board.empty(4);
      expect(board.isCleared, isTrue);
      expect(board.snakeCount, 0);
      expect(board.width, 4);
      expect(board.height, 4);
    });

    test('inBounds respects width and height', () {
      final board = Board.empty(3);
      expect(board.inBounds(const Position(0, 0)), isTrue);
      expect(board.inBounds(const Position(2, 2)), isTrue);
      expect(board.inBounds(const Position(-1, 0)), isFalse);
      expect(board.inBounds(const Position(3, 0)), isFalse);
    });

    test('place adds a snake immutably across all body cells', () {
      final board = Board.empty(4);
      final snake = Snake(
        id: 1,
        body: const [Position(1, 1), Position(1, 2), Position(1, 3)],
        direction: Direction.left,
      );
      final next = board.place(snake);

      expect(board.isCleared, isTrue, reason: 'original unchanged');
      expect(next.snakeCount, 1);
      expect(next.occupiedCellCount, 3);
      expect(next.snakeAt(const Position(1, 1)), snake);
      expect(next.snakeAt(const Position(1, 3)), snake);
      expect(next.isEmptyAt(const Position(1, 1)), isFalse);
    });

    test('removeAt removes the whole snake when tapping the tail', () {
      final snake = Snake(
        id: 1,
        body: const [Position(0, 2), Position(0, 1), Position(0, 0)],
        direction: Direction.right,
      );
      final board = Board.fromSnakes(width: 3, height: 3, snakes: [snake]);
      final cleared = board.removeAt(const Position(0, 0));
      expect(cleared.isCleared, isTrue);
      expect(board.snakeCount, 1, reason: 'original unchanged');
    });

    test('removeAt on empty cell is a no-op', () {
      final board = Board.empty(3);
      expect(board.removeAt(const Position(0, 0)).snakeCount, 0);
    });
  });
}
