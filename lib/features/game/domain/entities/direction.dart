/// The four cardinal directions a snake head can face / glide toward.
///
/// Grid convention: [Position.row] grows downward, [Position.col] grows to the
/// right. Each direction exposes a unit step as ([dCol], [dRow]).
enum Direction {
  up(dCol: 0, dRow: -1),
  down(dCol: 0, dRow: 1),
  left(dCol: -1, dRow: 0),
  right(dCol: 1, dRow: 0);

  const Direction({required this.dCol, required this.dRow});

  final int dCol;
  final int dRow;

  /// The direction rotated 90° clockwise.
  Direction get clockwise => switch (this) {
        Direction.up => Direction.right,
        Direction.right => Direction.down,
        Direction.down => Direction.left,
        Direction.left => Direction.up,
      };

  /// The opposite direction.
  Direction get opposite => switch (this) {
        Direction.up => Direction.down,
        Direction.down => Direction.up,
        Direction.left => Direction.right,
        Direction.right => Direction.left,
      };
}
