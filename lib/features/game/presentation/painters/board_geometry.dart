import 'dart:ui';

import '../../domain/entities/position.dart';

/// Maps between pixel space and grid coordinates for a square-celled board.
///
/// The grid is centred inside [canvasSize]; cells are square with side
/// [cellSize]. Shared by the painter and the tap handler so hit-testing and
/// rendering never drift apart.
class BoardGeometry {
  BoardGeometry({
    required this.canvasSize,
    required this.columns,
    required this.rows,
  }) : cellSize = _computeCellSize(canvasSize, columns, rows) {
    final gridWidth = cellSize * columns;
    final gridHeight = cellSize * rows;
    origin = Offset(
      (canvasSize.width - gridWidth) / 2,
      (canvasSize.height - gridHeight) / 2,
    );
  }

  final Size canvasSize;
  final int columns;
  final int rows;
  final double cellSize;
  late final Offset origin;

  static double _computeCellSize(Size size, int columns, int rows) {
    final byWidth = size.width / columns;
    final byHeight = size.height / rows;
    return byWidth < byHeight ? byWidth : byHeight;
  }

  /// Top-left pixel of a cell.
  Offset topLeftOf(Position p) =>
      origin + Offset(p.col * cellSize, p.row * cellSize);

  /// Centre pixel of a cell.
  Offset centerOf(Position p) =>
      topLeftOf(p) + Offset(cellSize / 2, cellSize / 2);

  Rect rectOf(Position p) => topLeftOf(p) & Size(cellSize, cellSize);

  /// The cell under a local pixel [offset], or null if outside the grid.
  Position? positionAt(Offset offset) {
    final local = offset - origin;
    if (local.dx < 0 || local.dy < 0) return null;
    final col = (local.dx / cellSize).floor();
    final row = (local.dy / cellSize).floor();
    if (col < 0 || col >= columns || row < 0 || row >= rows) return null;
    return Position(row, col);
  }
}
