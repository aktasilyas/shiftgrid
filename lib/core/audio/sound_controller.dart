import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/settings_notifier.dart';

enum SoundEffect { tap, escape, hiss, win }

/// Lightweight feedback controller.
///
/// Uses the platform's built-in click sound + haptics so we ship no
/// third-party audio assets (Legal Gate §6). Licensed hiss SFX via
/// audioplayers is tracked in docs/BACKLOG.md.
class SoundController {
  const SoundController({required this.enabled});

  final bool enabled;

  Future<void> play(SoundEffect effect) async {
    if (!enabled) return;
    switch (effect) {
      case SoundEffect.tap:
        await HapticFeedback.selectionClick();
      case SoundEffect.escape:
        await SystemSound.play(SystemSoundType.click);
        await HapticFeedback.lightImpact();
      case SoundEffect.hiss:
        // Stand-in for a real hiss until licensed SFX ships.
        await SystemSound.play(SystemSoundType.alert);
        await HapticFeedback.heavyImpact();
      case SoundEffect.win:
        await HapticFeedback.mediumImpact();
    }
  }
}

final soundControllerProvider = Provider<SoundController>((ref) {
  final settings = ref.watch(settingsProvider);
  return SoundController(enabled: settings.soundEnabled);
});
