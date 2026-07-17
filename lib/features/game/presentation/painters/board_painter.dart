import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/board.dart';
import '../../domain/entities/direction.dart';
import '../../domain/entities/position.dart';
import '../../domain/entities/snake.dart';
import 'board_geometry.dart';

/// Renders the whole board in a single [CustomPainter] — no widget per cell.
class BoardPainter extends CustomPainter {
  BoardPainter({
    required this.board,
    required this.cellColor,
    required this.snakeColor,
    required this.headAccent,
    required this.collisionColor,
    this.slidingSnakeId,
    this.slideTranslation = Offset.zero,
    this.slidingOpacity = 1.0,
    this.collisionCell,
    this.collisionFlash = 0.0,
    this.hintCell,
    this.hintColor = const Color(0xFF4FD1C5),
    this.hintFlash = 0.0,
  });

  final Board board;
  final Color cellColor;
  final Color snakeColor;
  final Color headAccent;
  final Color collisionColor;

  final int? slidingSnakeId;
  final Offset slideTranslation;
  final double slidingOpacity;
  final Position? collisionCell;
  final double collisionFlash;
  final Position? hintCell;
  final Color hintColor;
  final double hintFlash;

  @override
  void paint(Canvas canvas, Size size) {
    final geo = BoardGeometry(
      canvasSize: size,
      columns: board.width,
      rows: board.height,
    );

    _paintCells(canvas, geo);

    for (final snake in board.snakes) {
      final isSliding = snake.id == slidingSnakeId;
      final translation =
          isSliding ? slideTranslation * geo.cellSize : Offset.zero;
      final opacity = isSliding ? slidingOpacity : 1.0;
      _paintSnake(canvas, geo, snake, translation, opacity);
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
        } else if (hintCell == pos && hintFlash > 0) {
          final flash = Paint()
            ..color = Color.lerp(cellColor, hintColor, hintFlash)!;
          canvas.drawRRect(rrect, flash);
        } else {
          canvas.drawRRect(rrect, base);
        }
      }
    }
  }

  void _paintSnake(
    Canvas canvas,
    BoardGeometry geo,
    Snake snake,
    Offset translation,
    double opacity,
  ) {
    final alpha = opacity.clamp(0.0, 1.0);
    final strokeWidth = geo.cellSize * 0.42;

    final bodyPaint = Paint()
      ..color = snakeColor.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final centers = [
      for (final cell in snake.body) geo.centerOf(cell) + translation,
    ];

    if (centers.length == 1) {
      canvas.drawCircle(centers.first, strokeWidth * 0.45, Paint()
        ..color = snakeColor.withValues(alpha: alpha)
        ..style = PaintingStyle.fill);
    } else {
      final path = Path()..moveTo(centers.first.dx, centers.first.dy);
      for (var i = 1; i < centers.length; i++) {
        path.lineTo(centers[i].dx, centers[i].dy);
      }
      canvas.drawPath(path, bodyPaint);
    }

    _paintHead(canvas, geo, snake, centers.first, alpha);
  }

  void _paintHead(
    Canvas canvas,
    BoardGeometry geo,
    Snake snake,
    Offset center,
    double alpha,
  ) {
    final r = geo.cellSize * 0.28;
    final fill = Paint()
      ..color = snakeColor.withValues(alpha: alpha)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(_angleOf(snake.direction));

    // Rounded head pointing right (pre-rotation).
    final head = Path()
      ..moveTo(r, 0)
      ..quadraticBezierTo(r * 0.3, -r * 0.95, -r * 0.55, -r * 0.7)
      ..quadraticBezierTo(-r * 0.9, 0, -r * 0.55, r * 0.7)
      ..quadraticBezierTo(r * 0.3, r * 0.95, r, 0)
      ..close();
    canvas.drawPath(head, fill);

    // Eyes — amber accent, original (not reference lavender).
    final eye = Paint()
      ..color = headAccent.withValues(alpha: alpha)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(r * 0.15, -r * 0.32), r * 0.18, eye);
    canvas.drawCircle(Offset(r * 0.15, r * 0.32), r * 0.18, eye);
    final pupil = Paint()
      ..color = const Color(0xFF14161C).withValues(alpha: alpha);
    canvas.drawCircle(Offset(r * 0.22, -r * 0.32), r * 0.08, pupil);
    canvas.drawCircle(Offset(r * 0.22, r * 0.32), r * 0.08, pupil);

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
      old.slidingSnakeId != slidingSnakeId ||
      old.slideTranslation != slideTranslation ||
      old.slidingOpacity != slidingOpacity ||
      old.collisionCell != collisionCell ||
      old.collisionFlash != collisionFlash ||
      old.hintCell != hintCell ||
      old.hintFlash != hintFlash;
}
