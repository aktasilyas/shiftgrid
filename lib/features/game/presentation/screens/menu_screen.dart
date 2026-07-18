import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ads/banner_ad_widget.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_palette.dart';
import '../../domain/entities/difficulty.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/usecases/daily_challenge.dart';
import '../../domain/usecases/level_progression.dart';
import 'game_screen.dart';
import 'level_select_screen.dart';
import 'settings_screen.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l10n.settings,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Logo(),
              const SizedBox(height: 12),
              Text(
                l10n.appTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppPalette.textPrimary,
                ),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3, end: 0),
              const SizedBox(height: 8),
              Text(
                l10n.howToPlay,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppPalette.textMuted),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
              const SizedBox(height: 40),
              // No difficulty picker: the ladder ramps up on its own as the
              // player progresses (see level_progression.dart).
              FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => GameScreen.forLevel(
                      _nextUncompletedLevel(
                        ref.read(progressRepositoryProvider),
                      ),
                    ),
                  ),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(l10n.play, style: theme.textTheme.titleMedium),
              ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.2, end: 0),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const LevelSelectScreen(),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(l10n.levels, style: theme.textTheme.titleMedium),
              ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.2, end: 0),
              const SizedBox(height: 8),
              _DailyButton(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const SafeArea(child: BannerAdWidget()),
    );
  }
}

/// First unfinished rung of the ladder (or the last level when all done).
int _nextUncompletedLevel(ProgressRepository progress) {
  for (var level = 1; level <= totalLevels; level++) {
    if (!progress.isCompleted(difficultyForLevel(level), seedForLevel(level))) {
      return level;
    }
  }
  return totalLevels;
}

class _DailyButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final streak = ref.watch(streakRepositoryProvider).streak;
    final today = dayIndex(DateTime.now());

    final label = streak > 0
        ? '${l10n.dailyChallenge}  •  ${l10n.streakLabel(streak)}'
        : l10n.dailyChallenge;

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => GameScreen(
            seed: dailySeed(today),
            difficulty: Difficulty.medium,
            isDaily: true,
          ),
        ),
      ),
      icon: const Icon(Icons.today, color: AppPalette.teal),
      label: Text(label),
    ).animate().fadeIn(delay: 700.ms);
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: AppPalette.surfaceHigh,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.gesture,
          color: AppPalette.amber,
          size: 48,
        ),
      ),
    ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack);
  }
}
