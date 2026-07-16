import 'direction.dart';

/// An immutable grid coordinate (row, col). Zero-based, top-left origin.
class Position {
  const Position(this.row, this.col);

  final int row;
  final int col;

  /// The neighbouring position one unit step along [direction].
  Position step(Direction direction) =>
      Position(row + direction.dRow, col + direction.dCol);

  @override
  bool operator ==(Object other) =>
      other is Position && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => 'Position($row, $col)';
}
