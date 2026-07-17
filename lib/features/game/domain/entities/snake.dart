import 'direction.dart';
import 'position.dart';

/// A multi-cell snake on the board.
///
/// [body] is ordered head-first: `body.first` is the head (faces [direction]),
/// `body.last` is the tip of the tail. [id] is a stable identity for animation;
/// domain logic never depends on it.
class Snake {
  Snake({
    required this.id,
    required List<Position> body,
    required this.direction,
  })  : assert(body.isNotEmpty, 'Snake body must not be empty'),
        body = List.unmodifiable(body);

  final int id;
  final List<Position> body;
  final Direction direction;

  Position get head => body.first;
  Position get tail => body.last;
  int get length => body.length;

  bool occupies(Position p) => body.contains(p);

  Snake copyWith({List<Position>? body, Direction? direction}) => Snake(
        id: id,
        body: body ?? this.body,
        direction: direction ?? this.direction,
      );

  @override
  bool operator ==(Object other) =>
      other is Snake &&
      other.id == id &&
      other.direction == direction &&
      _listEquals(other.body, body);

  @override
  int get hashCode => Object.hash(id, direction, Object.hashAll(body));

  @override
  String toString() =>
      'Snake(#$id, head=$head, len=$length, ${direction.name})';
}

bool _listEquals(List<Position> a, List<Position> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
