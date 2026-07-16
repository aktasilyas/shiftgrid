import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_palette.dart';
import '../../domain/entities/arrow.dart';
import '../../domain/entities/board.dart';
import '../../domain/entities/direction.dart';
import '../../domain/entities/position.dart';
import '../../domain/usecases/try_fire.dart';
import '../painters/board_geometry.dart';
import '../painters/board_painter.dart';
import '../providers/game_notifier.dart';
import '../providers/game_state.dart';

/// The single playable screen for FAZ 1. Renders the board via [BoardPainter],
/// handles taps, and plays slide / collision feedback.
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  late final AnimationController _slide = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
  );
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  bool _busy = false;
  int? _slidingArrowId;
  Offset _slideBase = Offset.zero;
  Position? _collisionCell;

  @override
  void dispose() {
    _slide.dispose();
    _shake.dispose();
    super.dispose();
  }

  void _onTapUp(TapUpDetails details, Size size) {
    if (_busy) return;
    final state = ref.read(gameProvider);
    if (!state.isPlaying) return;

    final geo = BoardGeometry(
      canvasSize: size,
      columns: state.board.width,
      rows: state.board.height,
    );
    final pos = geo.positionAt(details.localPosition);
    if (pos == null) return;

    final result = ref.read(gameProvider.notifier).peek(pos);
    switch (result.outcome) {
      case FireOutcome.noArrow:
        return;
      case FireOutcome.escaped:
        _runSlide(state.board, result);
      case FireOutcome.collided:
        _runCollision(result);
    }
  }

  void _runSlide(Board board, FireResult result) {
    final arrow = result.firedArrow!;
    final dist = _exitDistance(board, arrow) + 0.6;
    setState(() {
      _busy = true;
      _slidingArrowId = arrow.id;
      _slideBase = Offset(
        arrow.direction.dCol * dist,
        arrow.direction.dRow * dist,
      );
    });
    unawaited(HapticFeedback.selectionClick());
    _slide.forward(from: 0).whenComplete(() {
      ref.read(gameProvider.notifier).applyResult(result);
      setState(() {
        _busy = false;
        _slidingArrowId = null;
        _slideBase = Offset.zero;
      });
      _slide.reset();
    });
  }

  void _runCollision(FireResult result) {
    setState(() {
      _busy = true;
      _collisionCell = result.collisionAt;
    });
    unawaited(HapticFeedback.mediumImpact());
    _shake.forward(from: 0).whenComplete(() {
      ref.read(gameProvider.notifier).applyResult(result);
      setState(() {
        _busy = false;
        _collisionCell = null;
      });
      _shake.reset();
    });
  }

  double _exitDistance(Board board, Arrow arrow) => switch (arrow.direction) {
        Direction.right => (board.width - arrow.position.col).toDouble(),
        Direction.left => (arrow.position.col + 1).toDouble(),
        Direction.down => (board.height - arrow.position.row).toDouble(),
        Direction.up => (arrow.position.row + 1).toDouble(),
      };

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.appTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _StatusBar(state: state),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final size = constraints.biggest;
                        return _buildBoard(state, size);
                      },
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Text(
                l10n.howToPlay,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppPalette.textMuted),
              ),
            ),
            _Footer(onRestart: () => ref.read(gameProvider.notifier).reset()),
          ],
        ),
      ),
    );
  }

  Widget _buildBoard(GameState state, Size size) {
    return AnimatedBuilder(
      animation: Listenable.merge([_slide, _shake]),
      builder: (context, _) {
        final slideT = Curves.easeIn.transform(_slide.value);
        final shakeDx =
            math.sin(_shake.value * math.pi * 5) * 10 * (1 - _shake.value);
        final flash = math.sin(_shake.value * math.pi);

        final painter = BoardPainter(
          board: state.board,
          cellColor: AppPalette.surfaceHigh,
          arrowColor: AppPalette.amber,
          collisionColor: AppPalette.rose,
          slidingArrowId: _slidingArrowId,
          slideTranslation: _slideBase * slideT,
          slidingOpacity: 1 - slideT,
          collisionCell: _collisionCell,
          collisionFlash: _collisionCell == null ? 0.0 : flash,
        );

        return Transform.translate(
          offset: Offset(shakeDx, 0),
          child: GestureDetector(
            onTapUp: (d) => _onTapUp(d, size),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(painter: painter),
                if (!state.isPlaying)
                  _ResultOverlay(
                    status: state.status,
                    onRestart: () =>
                        ref.read(gameProvider.notifier).reset(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(state.maxLives, (i) {
              final filled = i < state.lives;
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  filled ? Icons.favorite : Icons.favorite_border,
                  color: filled ? AppPalette.rose : AppPalette.textMuted,
                  size: 22,
                ),
              );
            }),
          ),
          Text(
            '${l10n.movesLabel}: ${state.moves}',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: AppPalette.textMuted),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.onRestart});

  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: OutlinedButton.icon(
        onPressed: onRestart,
        icon: const Icon(Icons.refresh),
        label: Text(l10n.restart),
      ),
    );
  }
}

class _ResultOverlay extends StatelessWidget {
  const _ResultOverlay({required this.status, required this.onRestart});

  final GameStatus status;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final won = status == GameStatus.won;
    final message = won ? l10n.youWon : l10n.youLost;

    return ColoredBox(
      color: AppPalette.canvas.withValues(alpha: 0.82),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              won ? Icons.emoji_events : Icons.sentiment_dissatisfied,
              color: won ? AppPalette.amber : AppPalette.rose,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRestart,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.restart),
            ),
          ],
        ),
      ),
    );
  }
}
