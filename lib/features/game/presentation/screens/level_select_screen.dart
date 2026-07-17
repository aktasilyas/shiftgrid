import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/game_constants.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_palette.dart';
import '../../domain/entities/difficulty.dart';
import '../widgets/difficulty_label.dart';
import 'game_screen.dart';

class LevelSelectScreen extends ConsumerStatefulWidget {
  const LevelSelectScreen({required this.difficulty, super.key});

  final Difficulty difficulty;

  @override
  ConsumerState<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends ConsumerState<LevelSelectScreen> {
  Future<void> _openLevel(int seed) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameScreen(seed: seed, difficulty: widget.difficulty),
      ),
    );
    if (mounted) setState(() {}); // refresh progress after returning
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final progress = ref.watch(progressRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(difficultyLabel(l10n, widget.difficulty))),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: levelsPerDifficulty,
          itemBuilder: (context, index) {
            final seed = index + 1;
            final unlocked = progress.isUnlocked(widget.difficulty, seed);
            final completed = progress.isCompleted(widget.difficulty, seed);
            final best = progress.bestMoves(widget.difficulty, seed);

            return _LevelTile(
              seed: seed,
              unlocked: unlocked,
              completed: completed,
              bestMoves: best,
              onTap: unlocked ? () => _openLevel(seed) : null,
            );
          },
        ),
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.seed,
    required this.unlocked,
    required this.completed,
    required this.bestMoves,
    required this.onTap,
  });

  final int seed;
  final bool unlocked;
  final bool completed;
  final int? bestMoves;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final Color background =
        completed ? AppPalette.amber.withValues(alpha: 0.18) : AppPalette.surfaceHigh;
    final Color foreground = unlocked ? AppPalette.textPrimary : AppPalette.textMuted;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!unlocked)
                const Icon(Icons.lock, color: AppPalette.textMuted, size: 22)
              else ...[
                Text(
                  '$seed',
                  style: theme.textTheme.titleLarge?.copyWith(color: foreground),
                ),
                if (completed && bestMoves != null)
                  Text(
                    l10n.bestMovesLabel(bestMoves!),
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: AppPalette.textMuted),
                  ),
              ],
              if (completed)
                const Icon(Icons.check_circle, color: AppPalette.teal, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
