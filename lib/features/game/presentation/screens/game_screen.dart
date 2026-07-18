import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart' hide Direction;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/audio/sound_controller.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_palette.dart';
import '../../domain/entities/board.dart';
import '../../domain/entities/difficulty.dart';
import '../../domain/entities/direction.dart';
import '../../domain/entities/position.dart';
import '../../domain/entities/snake.dart';
import '../../domain/usecases/daily_challenge.dart';
import '../../domain/usecases/level_progression.dart';
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
    this.level,
    this.isDaily = false,
    super.key,
  });

  /// Opens a level on the unified ladder; difficulty is derived from it.
  GameScreen.forLevel(int level, {Key? key})
      : this(
          seed: seedForLevel(level),
          difficulty: difficultyForLevel(level),
          level: level,
          key: key,
        );

  final int seed;
  final Difficulty difficulty;

  /// Global ladder position (1..[totalLevels]); null for the daily challenge.
  final int? level;
  final bool isDaily;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final AnimationController _hintPulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);

  /// Blocks input only during the collision shake; escapes never block, so
  /// the player can chain taps while earlier snakes are still gliding out.
  bool _busy = false;

  /// Snakes already removed from the board but still animating off-screen.
  final Map<int, _Departure> _departures = {};
  Position? _collisionCell;
  int? _collidingSnakeId;
  int? _hintSnakeId;

  /// Tracks the pinch-zoom level so the painter can restore snake details
  /// once tiny cells become large enough on screen.
  final TransformationController _viewer = TransformationController();
  double _viewScale = 1.0;

  @override
  void initState() {
    super.initState();
    _viewer.addListener(() {
      final scale = _viewer.value.getMaxScaleOnAxis();
      if ((scale - _viewScale).abs() > 0.08) {
        setState(() => _viewScale = scale);
      }
    });
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
    for (final departure in _departures.values) {
      departure.controller.dispose();
    }
    _shake.dispose();
    _hintPulse.dispose();
    _breath.dispose();
    _viewer.dispose();
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
    // Glide duration scales with the distance travelled (head-to-edge plus
    // the body following through), so long escapes don't blur past.
    final travelCells = _cellsToEdge(board, snake) + snake.length + 1;
    final controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (280 + 95 * travelCells).clamp(600, 1600)),
    );

    // Apply the move immediately: the board drops the snake now, so the next
    // tap works while this one is still visually gliding out.
    unawaited(ref.read(soundControllerProvider).play(SoundEffect.escape));
    ref.read(gameProvider.notifier).applyResult(result);
    setState(() => _departures[snake.id] = _Departure(snake, controller));
    controller.forward().whenComplete(() {
      controller.dispose();
      if (mounted) {
        setState(() => _departures.remove(snake.id));
      } else {
        _departures.remove(snake.id);
      }
    });
  }

  int _cellsToEdge(Board board, Snake snake) {
    final h = snake.head;
    return switch (snake.direction) {
      Direction.right => board.width - h.col,
      Direction.left => h.col + 1,
      Direction.down => board.height - h.row,
      Direction.up => h.row + 1,
    };
  }

  void _runCollision(FireResult result) {
    setState(() {
      _busy = true;
      _collisionCell = result.collisionAt;
      _collidingSnakeId = result.firedSnake?.id;
    });
    unawaited(ref.read(soundControllerProvider).play(SoundEffect.hiss));
    _shake.forward(from: 0).whenComplete(() {
      ref.read(gameProvider.notifier).applyResult(result);
      setState(() {
        _busy = false;
        _collisionCell = null;
        _collidingSnakeId = null;
      });
      _shake.reset();
    });
  }

  void _showHint() {
    if (_busy) return;
    final id = ref.read(gameProvider.notifier).hintSnakeId();
    if (id == null) return;
    setState(() => _hintSnakeId = id);
    _hintPulse.forward(from: 0).whenComplete(() {
      if (mounted) setState(() => _hintSnakeId = null);
      _hintPulse.reset();
    });
  }

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
    final current = widget.level;
    if (current == null || current >= totalLevels) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => GameScreen.forLevel(current + 1),
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

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.isDaily
                  ? l10n.dailyChallenge
                  : l10n.levelLabel(widget.level ?? widget.seed),
            ),
            Text(
              _difficultyLabel(l10n, widget.difficulty),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: _difficultyColor(widget.difficulty),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _StatusBar(state: state),
            Expanded(
              // Pinch to zoom into dense boards (taps map correctly through
              // the transform, so tiny snakes become easy to hit), drag with
              // one finger to pan while zoomed.
              child: InteractiveViewer(
                transformationController: _viewer,
                maxScale: 4.0,
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
            ),
            _ActionBar(
              canHint: state.isPlaying && !_busy,
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
      animation: Listenable.merge([
        _shake,
        _hintPulse,
        _breath,
        for (final departure in _departures.values) departure.controller,
      ]),
      builder: (context, _) {
        final shakeDx =
            math.sin(_shake.value * math.pi * 5) * 10 * (1 - _shake.value);
        // Idle breath: stroke width ±3%. Frozen on huge boards — repainting
        // hundreds of snakes every frame just to breathe is wasted work.
        final breathScale = state.board.snakeCount > 80
            ? 1.0
            : 1.0 + 0.03 * math.sin(_breath.value * math.pi);

        final painter = BoardPainter(
          board: state.board,
          cellColor: AppPalette.surfaceHigh,
          snakeColor: AppPalette.teal,
          headAccent: AppPalette.amber,
          collisionColor: AppPalette.rose,
          hintColor: AppPalette.amber,
          // Gentle sine easing: each snake gathers speed and glides out
          // without the abrupt mid-animation rush of a cubic curve.
          departing: [
            for (final departure in _departures.values)
              DepartingSnake(
                departure.snake,
                Curves.easeInOutSine.transform(departure.controller.value),
              ),
          ],
          collisionCell: _collisionCell,
          collidingSnakeId: _collidingSnakeId,
          collisionFlash:
              _collisionCell == null ? 0.0 : math.sin(_shake.value * math.pi),
          hintSnakeId: _hintSnakeId,
          // Three soft pulses over the hint window.
          hintFlash: _hintSnakeId == null
              ? 0.0
              : math.sin(_hintPulse.value * math.pi * 3).abs(),
          breathScale: breathScale,
          viewScale: _viewScale,
        );

        return Transform.translate(
          offset: Offset(shakeDx, 0),
          child: GestureDetector(
            onTapUp: (d) => _onTapUp(d, size),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(painter: painter),
                if (!state.isPlaying && _departures.isEmpty)
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

/// A snake gliding off-board with its own animation controller, so several
/// escapes can run at once.
class _Departure {
  const _Departure(this.snake, this.controller);

  final Snake snake;
  final AnimationController controller;
}

String _difficultyLabel(AppLocalizations l10n, Difficulty difficulty) =>
    switch (difficulty) {
      Difficulty.easy => l10n.difficultyEasy,
      Difficulty.medium => l10n.difficultyMedium,
      Difficulty.hard => l10n.difficultyHard,
      Difficulty.veryHard => l10n.difficultyVeryHard,
    };

Color _difficultyColor(Difficulty difficulty) => switch (difficulty) {
      Difficulty.easy => AppPalette.teal,
      Difficulty.medium => AppPalette.amber,
      Difficulty.hard => AppPalette.rose,
      Difficulty.veryHard => const Color(0xFFB388FF),
    };

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
    required this.canHint,
    required this.onHint,
    required this.onRestart,
  });

  final bool canHint;
  final VoidCallback onHint;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
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
