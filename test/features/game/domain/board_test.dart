import 'package:flutter_test/flutter_test.dart';
import 'package:shiftgrid/features/game/domain/entities/arrow.dart';
import 'package:shiftgrid/features/game/domain/entities/board.dart';
import 'package:shiftgrid/features/game/domain/entities/direction.dart';
import 'package:shiftgrid/features/game/domain/entities/position.dart';

void main() {
  group('Board', () {
    test('empty board reports cleared', () {
      final board = Board.empty(4);
      expect(board.isCleared, isTrue);
      expect(board.arrowCount, 0);
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

    test('place adds an arrow immutably', () {
      final board = Board.empty(3);
      const arrow = Arrow(
        id: 1,
        position: Position(1, 1),
        direction: Direction.up,
      );
      final next = board.place(arrow);

      expect(board.isCleared, isTrue, reason: 'original unchanged');
      expect(next.arrowCount, 1);
      expect(next.arrowAt(const Position(1, 1)), arrow);
      expect(next.isEmptyAt(const Position(1, 1)), isFalse);
    });

    test('removeAt returns a board without the arrow', () {
      final board = Board.fromArrows(
        width: 3,
        height: 3,
        arrows: const [
          Arrow(id: 1, position: Position(0, 0), direction: Direction.right),
        ],
      );
      final cleared = board.removeAt(const Position(0, 0));
      expect(cleared.isCleared, isTrue);
      expect(board.arrowCount, 1, reason: 'original unchanged');
    });

    test('removeAt on empty cell is a no-op', () {
      final board = Board.empty(3);
      expect(board.removeAt(const Position(0, 0)).arrowCount, 0);
    });
  });
}
