import 'arrow.dart';
import 'position.dart';

/// An immutable N×M grid of arrows.
///
/// Cells are sparse: only occupied [Position]s appear in the internal map.
/// All mutating operations return a new [Board].
class Board {
  Board({
    required this.width,
    required this.height,
    required Map<Position, Arrow> cells,
  })  : assert(width > 0 && height > 0, 'Board must be non-empty'),
        _cells = Map.unmodifiable(cells) {
    for (final entry in _cells.entries) {
      assert(
        inBounds(entry.key),
        'Arrow ${entry.value} is out of bounds',
      );
      assert(
        entry.value.position == entry.key,
        'Arrow position ${entry.value.position} does not match key ${entry.key}',
      );
    }
  }

  /// An empty square board of side [size].
  factory Board.empty(int size) =>
      Board(width: size, height: size, cells: const {});

  /// Builds a board from a list of arrows (positions must be unique & in bounds).
  factory Board.fromArrows({
    required int width,
    required int height,
    required List<Arrow> arrows,
  }) {
    final cells = <Position, Arrow>{};
    for (final arrow in arrows) {
      assert(
        !cells.containsKey(arrow.position),
        'Duplicate arrow at ${arrow.position}',
      );
      cells[arrow.position] = arrow;
    }
    return Board(width: width, height: height, cells: cells);
  }

  final int width;
  final int height;
  final Map<Position, Arrow> _cells;

  /// All arrows currently on the board (unordered).
  Iterable<Arrow> get arrows => _cells.values;

  int get arrowCount => _cells.length;

  bool get isCleared => _cells.isEmpty;

  bool inBounds(Position p) =>
      p.row >= 0 && p.row < height && p.col >= 0 && p.col < width;

  bool isEmptyAt(Position p) => !_cells.containsKey(p);

  Arrow? arrowAt(Position p) => _cells[p];

  /// Returns a new board with [arrow] added. The target cell must be empty.
  Board place(Arrow arrow) {
    assert(inBounds(arrow.position), 'Cannot place out of bounds: $arrow');
    assert(isEmptyAt(arrow.position), 'Cell ${arrow.position} is occupied');
    return Board(
      width: width,
      height: height,
      cells: {..._cells, arrow.position: arrow},
    );
  }

  /// Returns a new board with the arrow at [position] removed (no-op if empty).
  Board removeAt(Position position) {
    if (!_cells.containsKey(position)) return this;
    final next = Map<Position, Arrow>.from(_cells)..remove(position);
    return Board(width: width, height: height, cells: next);
  }

  @override
  String toString() => 'Board(${width}x$height, $arrowCount arrows)';
}
