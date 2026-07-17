import 'package:flutter_test/flutter_test.dart';
import 'package:shiftgrid/features/game/domain/entities/board.dart';
import 'package:shiftgrid/features/game/domain/entities/direction.dart';
import 'package:shiftgrid/features/game/domain/entities/position.dart';
import 'package:shiftgrid/features/game/domain/entities/snake.dart';
import 'package:shiftgrid/features/game/domain/usecases/try_fire.dart';

void main() {
  group('tryFire', () {
    test('firing an empty cell reports noSnake', () {
      final board = Board.empty(3);
      final result = tryFire(board, const Position(0, 0));
      expect(result.outcome, FireOutcome.noSnake);
      expect(result.board.isCleared, isTrue);
    });

    test('escaping snake is removed from the returned board', () {
      final snake = Snake(
        id: 1,
        body: const [Position(1, 1), Position(1, 2)],
        direction: Direction.left,
      );
      final board = Board.fromSnakes(width: 3, height: 3, snakes: [snake]);
      final result = tryFire(board, const Position(1, 2));

      expect(result.didEscape, isTrue);
      expect(result.firedSnake, snake);
      expect(result.board.isCleared, isTrue);
      expect(board.snakeCount, 1, reason: 'input board is immutable');
    });

    test('blocked snake stays and reports the collision cell', () {
      // Head at (0,0) facing down; body trails to the right (not on the ray).
      final shooter = Snake(
        id: 1,
        body: const [Position(0, 0), Position(0, 1)],
        direction: Direction.down,
      );
      final blocker = Snake(
        id: 2,
        body: const [Position(2, 0)],
        direction: Direction.up,
      );
      final board =
          Board.fromSnakes(width: 3, height: 3, snakes: [shooter, blocker]);
      final result = tryFire(board, const Position(0, 0));

      expect(result.didCollide, isTrue);
      expect(result.collisionAt, const Position(2, 0));
      expect(result.board.snakeCount, 2, reason: 'nothing removed on collision');
    });

    test('tapping the tail fires the same snake as tapping the head', () {
      final snake = Snake(
        id: 1,
        body: const [Position(0, 2), Position(0, 1), Position(0, 0)],
        direction: Direction.right,
      );
      final board = Board.fromSnakes(width: 3, height: 3, snakes: [snake]);
      final fromTail = tryFire(board, const Position(0, 0));
      final fromHead = tryFire(board, const Position(0, 2));
      expect(fromTail.didEscape, isTrue);
      expect(fromHead.didEscape, isTrue);
      expect(fromTail.firedSnake!.id, fromHead.firedSnake!.id);
    });

    test('clearing a blocker then re-firing lets the shooter escape', () {
      final shooter = Snake(
        id: 1,
        body: const [Position(0, 0)],
        direction: Direction.right,
      );
      final blocker = Snake(
        id: 2,
        body: const [Position(0, 2)],
        direction: Direction.up,
      );
      var board =
          Board.fromSnakes(width: 4, height: 4, snakes: [shooter, blocker]);

      expect(tryFire(board, const Position(0, 0)).didCollide, isTrue);

      final removeBlocker = tryFire(board, const Position(0, 2));
      expect(removeBlocker.didEscape, isTrue);
      board = removeBlocker.board;

      final retry = tryFire(board, const Position(0, 0));
      expect(retry.didEscape, isTrue);
      expect(retry.board.isCleared, isTrue);
    });
  });
}
