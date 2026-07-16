import 'package:flutter_test/flutter_test.dart';
import 'package:shiftgrid/features/game/domain/entities/arrow.dart';
import 'package:shiftgrid/features/game/domain/entities/board.dart';
import 'package:shiftgrid/features/game/domain/entities/direction.dart';
import 'package:shiftgrid/features/game/domain/entities/position.dart';
import 'package:shiftgrid/features/game/domain/usecases/try_fire.dart';

void main() {
  group('tryFire', () {
    test('firing an empty cell reports noArrow', () {
      final board = Board.empty(3);
      final result = tryFire(board, const Position(0, 0));
      expect(result.outcome, FireOutcome.noArrow);
      expect(result.board.isCleared, isTrue);
    });

    test('escaping arrow is removed from the returned board', () {
      const arrow = Arrow(
        id: 1,
        position: Position(1, 1),
        direction: Direction.left,
      );
      final board = Board.fromArrows(width: 3, height: 3, arrows: const [arrow]);
      final result = tryFire(board, const Position(1, 1));

      expect(result.didEscape, isTrue);
      expect(result.firedArrow, arrow);
      expect(result.board.isCleared, isTrue);
      expect(board.arrowCount, 1, reason: 'input board is immutable');
    });

    test('blocked arrow stays and reports the collision cell', () {
      const shooter = Arrow(
        id: 1,
        position: Position(0, 0),
        direction: Direction.down,
      );
      const blocker = Arrow(
        id: 2,
        position: Position(2, 0),
        direction: Direction.up,
      );
      final board = Board.fromArrows(
        width: 3,
        height: 3,
        arrows: const [shooter, blocker],
      );
      final result = tryFire(board, const Position(0, 0));

      expect(result.didCollide, isTrue);
      expect(result.collisionAt, const Position(2, 0));
      expect(result.board.arrowCount, 2, reason: 'nothing removed on collision');
    });

    test('clearing a blocker then re-firing lets the shooter escape', () {
      const shooter = Arrow(
        id: 1,
        position: Position(0, 0),
        direction: Direction.right,
      );
      const blocker = Arrow(
        id: 2,
        position: Position(0, 2),
        direction: Direction.up,
      );
      var board = Board.fromArrows(
        width: 4,
        height: 4,
        arrows: const [shooter, blocker],
      );

      expect(tryFire(board, const Position(0, 0)).didCollide, isTrue);

      // Remove the blocker (it points up from the top row -> escapes).
      final removeBlocker = tryFire(board, const Position(0, 2));
      expect(removeBlocker.didEscape, isTrue);
      board = removeBlocker.board;

      final retry = tryFire(board, const Position(0, 0));
      expect(retry.didEscape, isTrue);
      expect(retry.board.isCleared, isTrue);
    });
  });
}
