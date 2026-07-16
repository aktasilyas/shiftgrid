import 'package:flutter_test/flutter_test.dart';
import 'package:shiftgrid/features/game/domain/entities/direction.dart';

void main() {
  group('Direction', () {
    test('unit steps point the expected way', () {
      expect((Direction.up.dCol, Direction.up.dRow), (0, -1));
      expect((Direction.down.dCol, Direction.down.dRow), (0, 1));
      expect((Direction.left.dCol, Direction.left.dRow), (-1, 0));
      expect((Direction.right.dCol, Direction.right.dRow), (1, 0));
    });

    test('opposite reverses the direction', () {
      expect(Direction.up.opposite, Direction.down);
      expect(Direction.left.opposite, Direction.right);
    });

    test('clockwise rotates 90 degrees', () {
      expect(Direction.up.clockwise, Direction.right);
      expect(Direction.right.clockwise, Direction.down);
      expect(Direction.down.clockwise, Direction.left);
      expect(Direction.left.clockwise, Direction.up);
    });
  });
}
