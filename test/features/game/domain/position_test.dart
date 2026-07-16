import 'package:flutter_test/flutter_test.dart';
import 'package:shiftgrid/features/game/domain/entities/direction.dart';
import 'package:shiftgrid/features/game/domain/entities/position.dart';

void main() {
  group('Position', () {
    test('value equality and hashCode', () {
      expect(const Position(1, 2), const Position(1, 2));
      expect(const Position(1, 2).hashCode, const Position(1, 2).hashCode);
      expect(const Position(1, 2), isNot(const Position(2, 1)));
    });

    test('step moves one cell along a direction', () {
      const p = Position(2, 2);
      expect(p.step(Direction.up), const Position(1, 2));
      expect(p.step(Direction.down), const Position(3, 2));
      expect(p.step(Direction.left), const Position(2, 1));
      expect(p.step(Direction.right), const Position(2, 3));
    });
  });
}
