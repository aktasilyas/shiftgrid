import 'direction.dart';
import 'position.dart';

/// A single arrow on the board.
///
/// [id] is a stable identity that survives board transformations, so the
/// presentation layer can animate the same arrow across states. Domain logic
/// never depends on [id].
class Arrow {
  const Arrow({
    required this.id,
    required this.position,
    required this.direction,
  });

  final int id;
  final Position position;
  final Direction direction;

  Arrow copyWith({Position? position, Direction? direction}) => Arrow(
        id: id,
        position: position ?? this.position,
        direction: direction ?? this.direction,
      );

  @override
  bool operator ==(Object other) =>
      other is Arrow &&
      other.id == id &&
      other.position == position &&
      other.direction == direction;

  @override
  int get hashCode => Object.hash(id, position, direction);

  @override
  String toString() => 'Arrow(#$id, $position, ${direction.name})';
}
