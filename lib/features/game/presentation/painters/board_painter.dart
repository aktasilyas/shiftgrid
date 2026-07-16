import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/arrow.dart';
import '../../domain/entities/board.dart';
import '../../domain/entities/direction.dart';
import '../../domain/entities/position.dart';
import 'board_geometry.dart';

/// Renders the whole board in a single [CustomPainter] — no widget per cell.
class BoardPainter extends CustomPainter {
  BoardPainter({
    required this.board,
    required this.cellColor,
    required this.arrowColor,
    required this.collisionColor,
    this.slidingArrowId,
    this.slideTranslation = Offset.zero,
    this.slidingOpacity = 1.0,
    this.collisionCell,
    this.collisionFlash = 0.0,
  });

  final Board board;
  final Color cellColor;
  final Color arrowColor;
  final Color collisionColor;

  final int? slidingArrowId;
  final Offset slideTranslation;
  final double slidingOpacity;
  final Position? collisionCell;
  final double collisionFlash;

  @override
  void paint(Canvas canvas, Size size) {
    final geo = BoardGeometry(
      canvasSize: size,
      columns: board.width,
      rows: board.height,
    );

    _paintCells(canvas, geo);

    for (final arrow in board.arrows) {
      final isSliding = arrow.id == slidingArrowId;
      // slideTranslation is expressed in cell units so it is size-independent.
      final translation =
          isSliding ? slideTranslation * geo.cellSize : Offset.zero;
      final opacity = isSliding ? slidingOpacity : 1.0;
      _paintArrow(canvas, geo, arrow, translation, opacity);
    }
  }

  void _paintCells(Canvas canvas, BoardGeometry geo) {
    final radius = Radius.circular(geo.cellSize * 0.18);
    final gap = geo.cellSize * 0.08;
    final base = Paint()..color = cellColor;

    for (var row = 0; row < board.height; row++) {
      for (var col = 0; col < board.width; col++) {
        final pos = Position(row, col);
        final rect = geo.rectOf(pos).deflate(gap / 2);
        final rrect = RRect.fromRectAndRadius(rect, radius);

        if (collisionCell == pos && collisionFlash > 0) {
          final flash = Paint()
            ..color = Color.lerp(cellColor, collisionColor, collisionFlash)!;
          canvas.drawRRect(rrect, flash);
        } else {
          canvas.drawRRect(rrect, base);
        }
      }
    }
  }

  void _paintArrow(
    Canvas canvas,
    BoardGeometry geo,
    Arrow arrow,
    Offset translation,
    double opacity,
  ) {
    final center = geo.centerOf(arrow.position) + translation;
    final extent = geo.cellSize * 0.30;

    final paint = Paint()
      ..color = arrowColor.withValues(alpha: opacity.clamp(0.0, 1.0))
      ..style = PaintingStyle.fill
      ..strokeJoin = StrokeJoin.round;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(_angleOf(arrow.direction));

    // A chevron pointing to the right (before rotation).
    final path = Path()
      ..moveTo(extent, 0)
      ..lineTo(-extent * 0.7, -extent)
      ..lineTo(-extent * 0.3, 0)
      ..lineTo(-extent * 0.7, extent)
      ..close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  double _angleOf(Direction d) => switch (d) {
        Direction.right => 0,
        Direction.down => math.pi / 2,
        Direction.left => math.pi,
        Direction.up => -math.pi / 2,
      };

  @override
  bool shouldRepaint(covariant BoardPainter old) =>
      old.board != board ||
      old.slidingArrowId != slidingArrowId ||
      old.slideTranslation != slideTranslation ||
      old.slidingOpacity != slidingOpacity ||
      old.collisionCell != collisionCell ||
      old.collisionFlash != collisionFlash;
}
