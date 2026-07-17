import 'position.dart';
import 'snake.dart';

/// An immutable N×M grid of multi-cell snakes.
///
/// Occupancy is sparse: every body cell of every snake is mapped. Mutating
/// operations return a new [Board].
class Board {
  Board._({
    required this.width,
    required this.height,
    required Map<int, Snake> byId,
    required Map<Position, int> occupancy,
  })  : assert(width > 0 && height > 0, 'Board must be non-empty'),
        _byId = Map.unmodifiable(byId),
        _occupancy = Map.unmodifiable(occupancy);

  /// An empty square board of side [size].
  factory Board.empty(int size) => Board._(
        width: size,
        height: size,
        byId: const {},
        occupancy: const {},
      );

  /// Builds a board from a list of snakes (bodies must not overlap).
  factory Board.fromSnakes({
    required int width,
    required int height,
    required List<Snake> snakes,
  }) {
    final byId = <int, Snake>{};
    final occupancy = <Position, int>{};
    for (final snake in snakes) {
      assert(!byId.containsKey(snake.id), 'Duplicate snake id ${snake.id}');
      byId[snake.id] = snake;
      for (final cell in snake.body) {
        assert(
          cell.row >= 0 &&
              cell.row < height &&
              cell.col >= 0 &&
              cell.col < width,
          'Snake $snake out of bounds at $cell',
        );
        assert(
          !occupancy.containsKey(cell),
          'Overlap at $cell',
        );
        occupancy[cell] = snake.id;
      }
    }
    return Board._(
      width: width,
      height: height,
      byId: byId,
      occupancy: occupancy,
    );
  }

  final int width;
  final int height;
  final Map<int, Snake> _byId;
  final Map<Position, int> _occupancy;

  /// All snakes currently on the board (unordered).
  Iterable<Snake> get snakes => _byId.values;

  int get snakeCount => _byId.length;

  /// Total occupied cells (sum of body lengths).
  int get occupiedCellCount => _occupancy.length;

  bool get isCleared => _byId.isEmpty;

  bool inBounds(Position p) =>
      p.row >= 0 && p.row < height && p.col >= 0 && p.col < width;

  bool isEmptyAt(Position p) => !_occupancy.containsKey(p);

  Snake? snakeAt(Position p) {
    final id = _occupancy[p];
    if (id == null) return null;
    return _byId[id];
  }

  /// Returns a new board with [snake] added. Every body cell must be empty.
  Board place(Snake snake) {
    for (final cell in snake.body) {
      assert(inBounds(cell), 'Cannot place out of bounds: $snake at $cell');
      assert(isEmptyAt(cell), 'Cell $cell is occupied');
    }
    assert(!_byId.containsKey(snake.id), 'Duplicate snake id ${snake.id}');

    return Board._(
      width: width,
      height: height,
      byId: {..._byId, snake.id: snake},
      occupancy: {
        ..._occupancy,
        for (final cell in snake.body) cell: snake.id,
      },
    );
  }

  /// Removes the snake occupying [position] (no-op if empty).
  Board removeAt(Position position) {
    final snake = snakeAt(position);
    if (snake == null) return this;
    return removeSnake(snake);
  }

  /// Removes [snake] entirely.
  Board removeSnake(Snake snake) {
    if (!_byId.containsKey(snake.id)) return this;
    final nextById = Map<int, Snake>.from(_byId)..remove(snake.id);
    final nextOcc = Map<Position, int>.from(_occupancy);
    for (final cell in snake.body) {
      nextOcc.remove(cell);
    }
    return Board._(
      width: width,
      height: height,
      byId: nextById,
      occupancy: nextOcc,
    );
  }

  @override
  String toString() =>
      'Board(${width}x$height, $snakeCount snakes, $occupiedCellCount cells)';
}
