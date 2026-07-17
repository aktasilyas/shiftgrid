import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart' hide Direction;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/audio/sound_controller.dart';
import '../../../../core/constants/game_constants.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_palette.dart';
import '../../domain/entities/board.dart';
import '../../domain/entities/difficulty.dart';
import '../../domain/entities/direction.dart';
import '../../domain/entities/position.dart';
import '../../domain/entities/snake.dart';
import '../../domain/usecases/daily_challenge.dart';
import '../../domain/usecases/try_fire.dart';
import '../painters/board_geometry.dart';
import '../painters/board_painter.dart';
import '../providers/game_notifier.dart';
import '../providers/game_state.dart';

/// The playable screen for a single generated level.
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({
    required this.seed,
    required this.difficulty,
    this.isDaily = false,
    super.key,
  });

  final int seed;
  final Difficulty difficulty;
  final bool isDaily;

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
  late final AnimationController _hintPulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  bool _busy = false;
  int? _slidingSnakeId;
  Offset _slideBase = Offset.zero;
  Position? _collisionCell;
  Position? _hintCell;

  @override
  void initState() {
    super.initState();
    // Riverpod 3 forbids mutating a provider during a widget life-cycle
    // (initState runs inside build). Defer the load until after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(gameProvider.notifier).loadLevel(
            seed: widget.seed,
            difficulty: widget.difficulty,
          );
    });
  }

  @override
  void dispose() {
    _slide.dispose();
    _shake.dispose();
    _hintPulse.dispose();
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
      case FireOutcome.noSnake:
        return;
      case FireOutcome.escaped:
        _runSlide(state.board, result);
      case FireOutcome.collided:
        _runCollision(result);
    }
  }

  void _runSlide(Board board, FireResult result) {
    final snake = result.firedSnake!;
    final dist = _exitDistance(board, snake) + 0.6;
    setState(() {
      _busy = true;
      _slidingSnakeId = snake.id;
      _slideBase = Offset(
        snake.direction.dCol * dist,
        snake.direction.dRow * dist,
      );
    });
    unawaited(ref.read(soundControllerProvider).play(SoundEffect.escape));
    _slide.forward(from: 0).whenComplete(() {
      ref.read(gameProvider.notifier).applyResult(result);
      setState(() {
        _busy = false;
        _slidingSnakeId = null;
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
    unawaited(ref.read(soundControllerProvider).play(SoundEffect.hiss));
    _shake.forward(from: 0).whenComplete(() {
      ref.read(gameProvider.notifier).applyResult(result);
      setState(() {
        _busy = false;
        _collisionCell = null;
      });
      _shake.reset();
    });
  }

  void _showHint() {
    if (_busy) return;
    final pos = ref.read(gameProvider.notifier).hint();
    if (pos == null) return;
    setState(() => _hintCell = pos);
    _hintPulse.forward(from: 0).whenComplete(() {
      if (mounted) setState(() => _hintCell = null);
      _hintPulse.reset();
    });
  }

  double _exitDistance(Board board, Snake snake) => switch (snake.direction) {
        Direction.right => (board.width - snake.head.col).toDouble(),
        Direction.left => (snake.head.col + 1).toDouble(),
        Direction.down => (board.height - snake.head.row).toDouble(),
        Direction.up => (snake.head.row + 1).toDouble(),
      };

  void _maybeShowInterstitial() {
    final wins = ref.read(sessionWinsProvider.notifier).increment();
    final adsRemoved = ref.read(entitlementRepositoryProvider).adsRemoved;
    final shouldShow = ref.read(adGatePolicyProvider).shouldShowInterstitial(
          completedLevels: wins,
          adsRemoved: adsRemoved,
        );
    if (shouldShow) {
      unawaited(ref.read(adServiceProvider).showInterstitial());
    }
  }

  Future<void> _watchAdToRevive() async {
    final earned = await ref.read(adServiceProvider).showRewarded();
    if (earned) ref.read(gameProvider.notifier).revive();
  }

  void _nextLevel() {
    final nextSeed = widget.seed + 1;
    if (nextSeed > levelsPerDifficulty) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) =>
            GameScreen(seed: nextSeed, difficulty: widget.difficulty),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);
    final l10n = AppLocalizations.of(context);

    ref.listen(gameProvider, (prev, next) {
      final justWon =
          next.status == GameStatus.won && prev?.status != GameStatus.won;
      if (justWon) {
        if (widget.isDaily) {
          unawaited(
            ref
                .read(streakRepositoryProvider)
                .recordDailyCompletion(dayIndex(DateTime.now())),
          );
        } else {
          unawaited(
            ref.read(progressRepositoryProvider).recordCompletion(
                  widget.difficulty,
                  widget.seed,
                  next.moves,
                ),
          );
        }
        unawaited(ref.read(soundControllerProvider).play(SoundEffect.win));
        _maybeShowInterstitial();
      }
    });

    final canUndo = state.moves > 0 && state.isPlaying;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isDaily ? l10n.dailyChallenge : l10n.levelLabel(widget.seed),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _StatusBar(state: state),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: LayoutBuilder(
                      builder: (context, constraints) =>
                          _buildBoard(state, constraints.biggest),
                    ),
                  ),
                ),
              ),
            ),
            _ActionBar(
              canUndo: canUndo,
              canHint: state.isPlaying && !_busy,
              onUndo: () => ref.read(gameProvider.notifier).undo(),
              onHint: _showHint,
              onRestart: () => ref.read(gameProvider.notifier).reset(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildBoard(GameState state, Size size) {
    return AnimatedBuilder(
      animation: Listenable.merge([_slide, _shake, _hintPulse]),
      builder: (context, _) {
        final slideT = Curves.easeIn.transform(_slide.value);
        final shakeDx =
            math.sin(_shake.value * math.pi * 5) * 10 * (1 - _shake.value);

        final painter = BoardPainter(
          board: state.board,
          cellColor: AppPalette.surfaceHigh,
          snakeColor: AppPalette.teal,
          headAccent: AppPalette.amber,
          collisionColor: AppPalette.rose,
          hintColor: AppPalette.amber,
          slidingSnakeId: _slidingSnakeId,
          slideTranslation: _slideBase * slideT,
          slidingOpacity: 1 - slideT,
          collisionCell: _collisionCell,
          collisionFlash: _collisionCell == null ? 0.0 : math.sin(_shake.value * math.pi),
          hintCell: _hintCell,
          hintFlash: _hintCell == null ? 0.0 : math.sin(_hintPulse.value * math.pi),
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
                    onRestart: () => ref.read(gameProvider.notifier).reset(),
                    onNext: _nextLevel,
                    onWatchAd: _watchAdToRevive,
                    showWatchAd: state.status == GameStatus.lost &&
                        !ref.read(entitlementRepositoryProvider).adsRemoved,
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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
          if (state.combo >= 2)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppPalette.teal.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l10n.comboLabel(state.combo),
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: AppPalette.teal),
              ),
            ).animate(key: ValueKey(state.combo)).scale(
                  duration: 220.ms,
                  begin: const Offset(0.7, 0.7),
                  end: const Offset(1, 1),
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

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.canUndo,
    required this.canHint,
    required this.onUndo,
    required this.onHint,
    required this.onRestart,
  });

  final bool canUndo;
  final bool canHint;
  final VoidCallback onUndo;
  final VoidCallback onHint;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(
          icon: Icons.undo,
          label: l10n.undo,
          onPressed: canUndo ? onUndo : null,
        ),
        _ActionButton(
          icon: Icons.lightbulb_outline,
          label: l10n.hint,
          onPressed: canHint ? onHint : null,
        ),
        _ActionButton(
          icon: Icons.refresh,
          label: l10n.restart,
          onPressed: onRestart,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _ResultOverlay extends StatelessWidget {
  const _ResultOverlay({
    required this.status,
    required this.onRestart,
    required this.onNext,
    required this.onWatchAd,
    required this.showWatchAd,
  });

  final GameStatus status;
  final VoidCallback onRestart;
  final VoidCallback onNext;
  final VoidCallback onWatchAd;
  final bool showWatchAd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final won = status == GameStatus.won;
    final message = won ? l10n.youWon : l10n.youLost;

    return ColoredBox(
      color: AppPalette.canvas.withValues(alpha: 0.85),
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
            Text(message, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            if (won)
              FilledButton.icon(
                onPressed: onNext,
                icon: const Icon(Icons.arrow_forward),
                label: Text(l10n.nextLevel),
              )
            else ...[
              if (showWatchAd)
                FilledButton.icon(
                  onPressed: onWatchAd,
                  icon: const Icon(Icons.play_circle_outline),
                  label: Text(l10n.watchAdForLife),
                ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onRestart,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.restart),
              ),
            ],
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 250.ms)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }
}
