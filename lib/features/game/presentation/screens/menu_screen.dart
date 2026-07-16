import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_palette.dart';
import '../../domain/entities/difficulty.dart';
import '../widgets/difficulty_label.dart';
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
              Text(
                l10n.chooseDifficulty,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: AppPalette.textMuted),
              ),
              const SizedBox(height: 16),
              for (final (i, difficulty) in Difficulty.values.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            LevelSelectScreen(difficulty: difficulty),
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      difficultyLabel(l10n, difficulty),
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: (300 + i * 100).ms)
                    .slideX(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
    );
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
          Icons.arrow_outward,
          color: AppPalette.amber,
          size: 48,
        ),
      ),
    ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack);
  }
}
