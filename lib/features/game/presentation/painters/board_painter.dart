import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/board.dart';
import '../../domain/entities/direction.dart';
import '../../domain/entities/position.dart';
import '../../domain/entities/snake.dart';
import 'board_geometry.dart';

/// A snake that has already left the board but is still animating out.
class DepartingSnake {
  const DepartingSnake(this.snake, this.progress);

  final Snake snake;

  /// 0 = idle pose, 1 = fully off-board along the escape path.
  final double progress;
}

/// Renders the whole board in a single [CustomPainter] — no widget per cell.
///
/// Visual language: sparse dot grid + naturalistic snakes — tapered bodies
/// with rounded bends, dorsal blotches, viper-shaped amber-eyed heads and a
/// flicking tongue — see DECISIONS #0015.
class BoardPainter extends CustomPainter {
  BoardPainter({
    required this.board,
    required this.cellColor,
    required this.snakeColor,
    required this.headAccent,
    required this.collisionColor,
    this.departing = const [],
    this.collisionCell,
    this.collidingSnakeId,
    this.collisionFlash = 0.0,
    this.hintSnakeId,
    this.hintColor = const Color(0xFF4FD1C5),
    this.hintFlash = 0.0,
    this.breathScale = 1.0,
    this.viewScale = 1.0,
  });

  final Board board;
  final Color cellColor;
  final Color snakeColor;
  final Color headAccent;
  final Color collisionColor;

  /// Snakes gliding off-board; they are no longer part of [board] so taps on
  /// the remaining snakes respond immediately.
  final List<DepartingSnake> departing;
  final Position? collisionCell;

  /// The snake that just hit another one — its whole body flushes
  /// [collisionColor] while [collisionFlash] pulses.
  final int? collidingSnakeId;
  final double collisionFlash;

  /// The snake highlighted by the hint button (it has an open escape).
  final int? hintSnakeId;
  final Color hintColor;
  final double hintFlash;

  /// Idle "breathing" scale applied to snake stroke width (± ~3%).
  final double breathScale;

  /// Current pinch-zoom factor of the surrounding viewer. Details that are
  /// skipped on tiny cells come back once the player zooms in.
  final double viewScale;

  @override
  void paint(Canvas canvas, Size size) {
    final geo = BoardGeometry(
      canvasSize: size,
      columns: board.width,
      rows: board.height,
    );

    _paintDotGrid(canvas, geo);

    for (final snake in board.snakes) {
      _paintSnake(canvas, geo, snake, progress: 0);
    }
    for (final gone in departing) {
      _paintSnake(
        canvas,
        geo,
        gone.snake,
        progress: gone.progress.clamp(0.0, 1.0),
      );
    }
  }

  void _paintDotGrid(Canvas canvas, BoardGeometry geo) {
    final dot = Paint()
      ..color = cellColor.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    final radius = geo.cellSize * 0.04;

    for (var row = 0; row < board.height; row++) {
      for (var col = 0; col < board.width; col++) {
        final pos = Position(row, col);
        final center = geo.centerOf(pos);

        if (collisionCell == pos && collisionFlash > 0) {
          final flash = Paint()
            ..color = Color.lerp(
              cellColor.withValues(alpha: 0.55),
              collisionColor,
              collisionFlash,
            )!
            ..style = PaintingStyle.fill;
          canvas.drawCircle(center, radius * (2 + collisionFlash * 2), flash);
        } else {
          canvas.drawCircle(center, radius, dot);
        }
      }
    }
  }

  void _paintSnake(
    Canvas canvas,
    BoardGeometry geo,
    Snake snake, {
    required double progress,
  }) {
    final cell = geo.cellSize;
    // On huge boards the cells are tiny and there are hundreds of snakes:
    // skip the clip-based shading, blotches and facial details — they are
    // invisible at that scale and cost real frame time. Zooming in restores
    // them, because what matters is the size on screen.
    final detailed = cell * viewScale >= 24;
    // Widest at mid-torso (~26% of a cell), slimmer neck, pointed tail.
    // The pixel floor keeps snakes clearly visible on very dense boards.
    final maxHalf = math.max(cell * 0.13, 1.7) * breathScale;
    final alpha = progress > 0 ? (1.0 - progress * 0.85).clamp(0.15, 1.0) : 1.0;

    final spine = _slitherSpine(geo, snake, progress);
    if (spine.isEmpty) return;

    // A snake that just collided flushes red for the duration of the flash;
    // the hinted snake brightens toward white while its halo pulses.
    var bodyBase = snake.id == collidingSnakeId && collisionFlash > 0
        ? Color.lerp(snakeColor, collisionColor, collisionFlash * 0.85)!
        : snakeColor;
    final hinted = snake.id == hintSnakeId && hintFlash > 0;
    if (hinted) {
      bodyBase = Color.lerp(bodyBase, Colors.white, 0.30 * hintFlash)!;
    }
    final baseColor = bodyBase.withValues(alpha: alpha);
    final dark = Color.lerp(bodyBase, const Color(0xFF0B1216), 0.45)!;
    final light = Color.lerp(bodyBase, Colors.white, 0.38)!;

    final metrics = _arcLength(spine);
    final bodyLen = metrics.last;
    // The head must always face the slide direction — it is the player's
    // only cue for where a tap sends the snake. The neck may approach from
    // a perpendicular cell; the forward lead in the spine bridges the bend.
    final headAngle = _angleOf(snake.direction);

    if (bodyLen < cell * 0.2) {
      // Degenerate pose (window collapsed to a point): plump blob + head.
      canvas.drawCircle(
        spine.first,
        maxHalf * 1.1,
        Paint()
          ..color = baseColor
          ..style = PaintingStyle.fill,
      );
      _paintHead(
        canvas,
        spine.first,
        headAngle,
        alpha,
        maxHalf * 2,
        bodyBase,
        detailed: detailed,
      );
      return;
    }

    final halfWidths = [
      for (var i = 0; i < spine.length; i++)
        _halfWidthAt(metrics[i], bodyLen, cell, maxHalf),
    ];
    final body = _bodyOutline(spine, halfWidths);

    if (hinted) {
      canvas.drawPath(
        body,
        Paint()
          ..color = hintColor.withValues(alpha: 0.6 * hintFlash * alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = maxHalf * 1.6
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, maxHalf * 0.8),
      );
    }

    canvas.drawPath(
      body,
      Paint()
        ..color = baseColor
        ..style = PaintingStyle.fill,
    );

    if (detailed) {
      // Shade inside the silhouette — darker flanks, a light dorsal ridge and
      // the scale blotches — clipped so nothing spills past the outline.
      canvas.save();
      canvas.clipPath(body);
      canvas.drawPath(
        body,
        Paint()
          ..color = dark.withValues(alpha: 0.30 * alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = maxHalf * 0.9,
      );
      final spinePath = Path()..moveTo(spine.first.dx, spine.first.dy);
      for (var i = 1; i < spine.length; i++) {
        spinePath.lineTo(spine[i].dx, spine[i].dy);
      }
      canvas.drawPath(
        spinePath,
        Paint()
          ..color = light.withValues(alpha: 0.35 * alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = maxHalf * 0.55
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      _paintBlotches(
        canvas,
        spine,
        metrics,
        maxHalf,
        cell,
        dark.withValues(alpha: 0.35 * alpha),
      );
      canvas.restore();
    } else {
      // Cheap contrast for tiny snakes: a short dorsal highlight (stops well
      // before the pointed tail so it cannot spill past the outline).
      final n = (spine.length * 0.7).floor();
      if (n >= 2) {
        final spinePath = Path()..moveTo(spine.first.dx, spine.first.dy);
        for (var i = 1; i < n; i++) {
          spinePath.lineTo(spine[i].dx, spine[i].dy);
        }
        canvas.drawPath(
          spinePath,
          Paint()
            ..color = light.withValues(alpha: 0.35 * alpha)
            ..style = PaintingStyle.stroke
            ..strokeWidth = maxHalf * 0.5
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      }
    }

    canvas.drawPath(
      body,
      Paint()
        ..color = dark.withValues(alpha: 0.5 * alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(cell * 0.015, 0.6)
        ..strokeJoin = StrokeJoin.round,
    );

    _paintHead(
      canvas,
      spine.first,
      headAngle,
      alpha,
      maxHalf * 2,
      bodyBase,
      detailed: detailed,
    );
  }

  /// Body half-width at arc distance [d] from the head. Slim neck, full
  /// torso, tail tapering to a point. Neck and tail lengths are in cell
  /// units (not proportional), so long snakes don't become giant spikes.
  double _halfWidthAt(double d, double total, double cell, double maxHalf) {
    final neckLen = math.min(cell * 0.4, total * 0.15);
    final neck = d < neckLen ? 0.72 + 0.28 * (d / neckLen) : 1.0;
    final tailLen = math.min(cell * 1.8, total * 0.45);
    final fromTail = total - d;
    var tail = 1.0;
    if (fromTail < tailLen) {
      final u = 1.0 - fromTail / tailLen;
      tail = 1.0 - 0.94 * u * u;
    }
    return maxHalf * neck * tail;
  }

  /// Closed silhouette around [spine] with per-sample [halfWidths].
  Path _bodyOutline(List<Offset> spine, List<double> halfWidths) {
    final n = spine.length;
    final left = List<Offset>.filled(n, Offset.zero);
    final right = List<Offset>.filled(n, Offset.zero);
    var normal = const Offset(0, 1);
    for (var i = 0; i < n; i++) {
      final delta = spine[math.min(n - 1, i + 1)] - spine[math.max(0, i - 1)];
      if (delta.distance > 1e-6) {
        final t = delta / delta.distance;
        normal = Offset(-t.dy, t.dx);
      }
      left[i] = spine[i] + normal * halfWidths[i];
      right[i] = spine[i] - normal * halfWidths[i];
    }

    final tailDelta = spine[n - 1] - spine[math.max(0, n - 2)];
    final tailDir = tailDelta.distance < 1e-6
        ? const Offset(1, 0)
        : tailDelta / tailDelta.distance;
    final tip = spine[n - 1] + tailDir * halfWidths.first * 0.6;

    final path = Path()..moveTo(left[0].dx, left[0].dy);
    for (var i = 1; i < n; i++) {
      path.lineTo(left[i].dx, left[i].dy);
    }
    path.quadraticBezierTo(tip.dx, tip.dy, right[n - 1].dx, right[n - 1].dy);
    for (var i = n - 2; i >= 0; i--) {
      path.lineTo(right[i].dx, right[i].dy);
    }
    path.close();
    return path;
  }

  /// Dorsal blotches spaced by arc-length, so the pattern travels with the
  /// body during a slide instead of staying glued to the board.
  void _paintBlotches(
    Canvas canvas,
    List<Offset> spine,
    List<double> metrics,
    double maxHalf,
    double cell,
    Color color,
  ) {
    final total = metrics.last;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    for (var d = cell * 0.55; d < total - cell * 0.15; d += cell * 0.52) {
      final p = _pointAt(spine, metrics, d);
      final tan = _tangentAt(spine, metrics, d);
      final half = _halfWidthAt(d, total, cell, maxHalf);
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(math.atan2(tan.dy, tan.dx));
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: cell * 0.28,
          height: half * 1.3,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  /// Head-first sample of the snake along its body, then out the escape ray.
  ///
  /// At [progress] 0 the pose matches the board; as it rises the head leads
  /// off-board and the tail follows the original spine (true slither).
  List<Offset> _slitherSpine(BoardGeometry geo, Snake snake, double progress) {
    final cell = geo.cellSize;
    final bodyCenters = [
      for (final p in snake.body) geo.centerOf(p),
    ]; // head … tail

    // Escape path: tail → … → head → off-board along facing direction.
    final escape = <Offset>[
      ...bodyCenters.reversed,
    ];
    final head = bodyCenters.first;
    final step = Offset(
      snake.direction.dCol * cell,
      snake.direction.dRow * cell,
    );
    final exitCells = _exitCells(snake, board) + snake.length + 1;
    for (var i = 1; i <= exitCells; i++) {
      escape.add(head + step * i.toDouble());
    }

    final metrics = _arcLength(escape);
    final total = metrics.last;
    if (total <= 0) return bodyCenters;

    final bodyLen = _arcLength(bodyCenters).last;
    final headDist = (bodyLen + progress * (total - bodyLen)).clamp(0.0, total);
    final tailDist = (headDist - bodyLen).clamp(0.0, total);
    // Small forward lead along the escape ray: the neck visibly cranes
    // toward the slide direction, so the head always faces where the snake
    // will actually go — even when the neck cell sits perpendicular to it.
    final visualHeadDist = math.min(headDist + cell * 0.22, total);

    // Sample head→tail along the window (reverse of travel order). Dense
    // sampling + a smoothing pass turns right-angle grid corners into the
    // rounded bends of a real body.
    final samples = math.max(24, 12 + 6 * snake.length);
    final spine = <Offset>[];
    for (var i = 0; i < samples; i++) {
      final t = samples == 1 ? 0.0 : i / (samples - 1);
      final dist = visualHeadDist - t * (visualHeadDist - tailDist);
      var point = _pointAt(escape, metrics, dist);
      // Serpentine glide: the lateral offset depends on the absolute arc
      // position, so every body point follows the same fixed wavy track —
      // the snake curves along a path like a real slither instead of
      // wobbling in place.
      if (progress > 0 && progress < 1) {
        final tangent = _tangentAt(escape, metrics, dist);
        final normal = Offset(-tangent.dy, tangent.dx);
        final envelope = math.sin(math.pi * progress);
        final wave = math.sin(dist / (cell * 1.15) * 2 * math.pi) *
            cell *
            0.09 *
            envelope;
        point += normal * wave;
      }
      spine.add(point);
    }
    return _rounded(spine);
  }

  /// Neighbour-averaging passes that keep endpoints fixed — rounds the sharp
  /// grid corners without shortening the snake.
  List<Offset> _rounded(List<Offset> pts) {
    var out = pts;
    for (var pass = 0; pass < 3; pass++) {
      final next = List<Offset>.of(out);
      for (var i = 1; i < out.length - 1; i++) {
        next[i] = (out[i - 1] + out[i] * 2.0 + out[i + 1]) / 4.0;
      }
      out = next;
    }
    return out;
  }

  int _exitCells(Snake snake, Board board) {
    final h = snake.head;
    return switch (snake.direction) {
      Direction.right => board.width - h.col,
      Direction.left => h.col + 1,
      Direction.down => board.height - h.row,
      Direction.up => h.row + 1,
    };
  }

  List<double> _arcLength(List<Offset> pts) {
    final out = List<double>.filled(pts.length, 0);
    for (var i = 1; i < pts.length; i++) {
      out[i] = out[i - 1] + (pts[i] - pts[i - 1]).distance;
    }
    return out;
  }

  Offset _pointAt(List<Offset> pts, List<double> lengths, double dist) {
    if (pts.length == 1) return pts.first;
    final d = dist.clamp(0.0, lengths.last);
    for (var i = 1; i < pts.length; i++) {
      if (d <= lengths[i]) {
        final seg = lengths[i] - lengths[i - 1];
        final t = seg < 1e-6 ? 0.0 : (d - lengths[i - 1]) / seg;
        return Offset.lerp(pts[i - 1], pts[i], t)!;
      }
    }
    return pts.last;
  }

  Offset _tangentAt(List<Offset> pts, List<double> lengths, double dist) {
    if (pts.length < 2) return const Offset(1, 0);
    final d = dist.clamp(0.0, lengths.last);
    for (var i = 1; i < pts.length; i++) {
      if (d <= lengths[i]) {
        final delta = pts[i] - pts[i - 1];
        final len = delta.distance;
        if (len < 1e-6) continue;
        return delta / len;
      }
    }
    final delta = pts.last - pts[pts.length - 2];
    final len = delta.distance;
    return len < 1e-6 ? const Offset(1, 0) : delta / len;
  }

  /// Tongue extension 0..1 driven by the idle breath phase — never fully
  /// retracted (a resting floor keeps it visible on boards where the breath
  /// animation is frozen), with a stronger flick at the top of each breath.
  double get _tongueFlick {
    final f = ((breathScale - 1.0) / 0.03).clamp(0.0, 1.0);
    return math.max(0.45, f * f * f);
  }

  /// Viper-shaped head: wide jaws, blunt snout, amber eyes with slit pupils,
  /// nostrils and a forked tongue that flicks with the breath cycle.
  void _paintHead(
    Canvas canvas,
    Offset center,
    double angle,
    double alpha,
    double bodyWidth,
    Color color, {
    bool detailed = true,
  }) {
    final r = bodyWidth * 0.8;
    final dark = Color.lerp(color, const Color(0xFF0B1216), 0.45)!;
    final light = Color.lerp(color, Colors.white, 0.38)!;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    // Tongue first, so its base stays hidden under the snout.
    final flick = _tongueFlick;
    if (flick > 0.05) {
      final tongue = Paint()
        ..color = const Color(0xFFE0526E).withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        // Pixel floor: on dense boards r is a few pixels and an r-relative
        // stroke would vanish entirely.
        ..strokeWidth = math.max(r * 0.13, 0.9)
        ..strokeCap = StrokeCap.round;
      final len = r * (0.5 + 1.1 * flick);
      final base = Offset(r * 0.9, 0);
      final fork = base + Offset(len * 0.6, 0);
      canvas.drawLine(base, fork, tongue);
      canvas.drawLine(fork, base + Offset(len, -r * 0.22), tongue);
      canvas.drawLine(fork, base + Offset(len, r * 0.22), tongue);
    }

    final head = Path()
      ..moveTo(r * 1.15, 0)
      ..cubicTo(r * 1.12, -r * 0.42, r * 0.55, -r * 0.72, -r * 0.05, -r * 0.76)
      ..cubicTo(-r * 0.55, -r * 0.79, -r * 0.9, -r * 0.6, -r * 1.05, -r * 0.4)
      ..lineTo(-r * 1.05, r * 0.4)
      ..cubicTo(-r * 0.9, r * 0.6, -r * 0.55, r * 0.79, -r * 0.05, r * 0.76)
      ..cubicTo(r * 0.55, r * 0.72, r * 1.12, r * 0.42, r * 1.15, 0)
      ..close();
    canvas.drawPath(
      head,
      Paint()
        ..color = color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill,
    );

    if (detailed) {
      // Soft crown highlight + darker rim for a rounded skull.
      canvas.save();
      canvas.clipPath(head);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(r * 0.05, 0),
          width: r * 1.5,
          height: r * 0.8,
        ),
        Paint()..color = light.withValues(alpha: 0.30 * alpha),
      );
      canvas.drawPath(
        head,
        Paint()
          ..color = dark.withValues(alpha: 0.30 * alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.35,
      );
      canvas.restore();
      canvas.drawPath(
        head,
        Paint()
          ..color = dark.withValues(alpha: 0.5 * alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.06
          ..strokeJoin = StrokeJoin.round,
      );
    }

    final eye = Paint()..color = headAccent.withValues(alpha: alpha);
    for (final side in const [-1.0, 1.0]) {
      final c = Offset(r * 0.3, side * r * 0.48);
      canvas.drawCircle(c, r * 0.21, eye);
    }
    if (detailed) {
      final pupil = Paint()
        ..color = const Color(0xFF14161C).withValues(alpha: alpha);
      final glint = Paint()
        ..color = Colors.white.withValues(alpha: 0.7 * alpha);
      for (final side in const [-1.0, 1.0]) {
        final c = Offset(r * 0.3, side * r * 0.48);
        // Slit pupil, elongated across the eye.
        canvas.drawOval(
          Rect.fromCenter(center: c, width: r * 0.10, height: r * 0.30),
          pupil,
        );
        canvas.drawCircle(
          c + Offset(r * 0.06, -side * r * 0.06),
          r * 0.05,
          glint,
        );
      }

      final nostril = Paint()
        ..color = dark.withValues(alpha: 0.8 * alpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(r * 0.88, -r * 0.16), r * 0.05, nostril);
      canvas.drawCircle(Offset(r * 0.88, r * 0.16), r * 0.05, nostril);
    }

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
      old.departing.isNotEmpty ||
      departing.isNotEmpty ||
      old.collisionCell != collisionCell ||
      old.collidingSnakeId != collidingSnakeId ||
      old.collisionFlash != collisionFlash ||
      old.hintSnakeId != hintSnakeId ||
      old.hintFlash != hintFlash ||
      old.breathScale != breathScale ||
      old.viewScale != viewScale;
}
