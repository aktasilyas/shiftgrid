import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_palette.dart';
import '../../domain/usecases/level_progression.dart';
import 'game_screen.dart';

/// One continuous ladder of levels; difficulty ramps automatically.
class LevelSelectScreen extends ConsumerStatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  ConsumerState<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends ConsumerState<LevelSelectScreen> {
  Future<void> _openLevel(int level) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => GameScreen.forLevel(level)),
    );
    if (mounted) setState(() {}); // refresh progress after returning
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final progress = ref.watch(progressRepositoryProvider);

    bool completed(int level) => progress.isCompleted(
          difficultyForLevel(level),
          seedForLevel(level),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.levels)),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: totalLevels,
          itemBuilder: (context, index) {
            final level = index + 1;
            final unlocked = level == 1 || completed(level - 1);

            return _LevelTile(
              seed: level,
              unlocked: unlocked,
              completed: completed(level),
              bestMoves: progress.bestMoves(
                difficultyForLevel(level),
                seedForLevel(level),
              ),
              onTap: unlocked ? () => _openLevel(level) : null,
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
          // Scale the tile content down instead of overflowing on narrow
          // phone tiles.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!unlocked)
                  const Icon(Icons.lock, color: AppPalette.textMuted, size: 22)
                else ...[
                  Text(
                    '$seed',
                    style:
                        theme.textTheme.titleLarge?.copyWith(color: foreground),
                  ),
                  if (completed && bestMoves != null)
                    Text(
                      l10n.bestMovesLabel(bestMoves!),
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: AppPalette.textMuted),
                    ),
                ],
                if (completed)
                  const Icon(
                    Icons.check_circle,
                    color: AppPalette.teal,
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
