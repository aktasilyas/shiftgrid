import '../../../../core/l10n/app_localizations.dart';
import '../../domain/entities/difficulty.dart';

String difficultyLabel(AppLocalizations l10n, Difficulty difficulty) =>
    switch (difficulty) {
      Difficulty.easy => l10n.difficultyEasy,
      Difficulty.medium => l10n.difficultyMedium,
      Difficulty.hard => l10n.difficultyHard,
    };
