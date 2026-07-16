import 'package:flutter_test/flutter_test.dart';
import 'package:shiftgrid/features/game/domain/entities/arrow.dart';
import 'package:shiftgrid/features/game/domain/entities/board.dart';
import 'package:shiftgrid/features/game/domain/entities/direction.dart';
import 'package:shiftgrid/features/game/domain/entities/position.dart';
import 'package:shiftgrid/features/game/domain/usecases/ray_escapes.dart';

void main() {
  group('rayEscapes', () {
    test('single arrow always escapes', () {
      const arrow = Arrow(
        id: 1,
        position: Position(2, 2),
        direction: Direction.up,
      );
      final board = Board.fromArrows(width: 5, height: 5, arrows: const [arrow]);
      expect(rayEscapes(board, arrow), isTrue);
    });

    test('edge arrow pointing outward escapes immediately', () {
      const arrow = Arrow(
        id: 1,
        position: Position(0, 0),
        direction: Direction.up,
      );
      final board = Board.fromArrows(width: 3, height: 3, arrows: const [arrow]);
      expect(rayEscapes(board, arrow), isTrue);
      expect(firstObstacle(board, arrow), isNull);
    });

    test('blocked when another arrow is on the path', () {
      const shooter = Arrow(
        id: 1,
        position: Position(2, 0),
        direction: Direction.right,
      );
      const blocker = Arrow(
        id: 2,
        position: Position(2, 3),
        direction: Direction.up,
      );
      final board = Board.fromArrows(
        width: 5,
        height: 5,
        arrows: const [shooter, blocker],
      );
      expect(rayEscapes(board, shooter), isFalse);
      expect(firstObstacle(board, shooter), const Position(2, 3));
    });

    test('adjacent blocker directly in front blocks', () {
      const shooter = Arrow(
        id: 1,
        position: Position(0, 0),
        direction: Direction.right,
      );
      const blocker = Arrow(
        id: 2,
        position: Position(0, 1),
        direction: Direction.up,
      );
      final board = Board.fromArrows(
        width: 4,
        height: 4,
        arrows: const [shooter, blocker],
      );
      expect(rayEscapes(board, shooter), isFalse);
      expect(firstObstacle(board, shooter), const Position(0, 1));
    });

    test('escapes over previously-cleared path (monotonicity)', () {
      const shooter = Arrow(
        id: 1,
        position: Position(0, 0),
        direction: Direction.right,
      );
      // Board where the only other arrow sits elsewhere, not on the path.
      const other = Arrow(
        id: 2,
        position: Position(3, 3),
        direction: Direction.down,
      );
      final board = Board.fromArrows(
        width: 5,
        height: 5,
        arrows: const [shooter, other],
      );
      expect(rayEscapes(board, shooter), isTrue);
    });
  });
}
