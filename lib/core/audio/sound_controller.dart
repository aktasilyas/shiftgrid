import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/settings_notifier.dart';

enum SoundEffect { tap, escape, hiss, win }

/// Low-latency SFX via [AudioPool] (in-house procedural WAVs).
///
/// See DECISIONS #0016. Haptics remain as secondary feedback.
class SoundController {
  SoundController({required this.isEnabled});

  final bool Function() isEnabled;
  final Map<SoundEffect, AudioPool> _pools = {};
  bool _ready = false;

  static const _files = {
    SoundEffect.tap: 'audio/tap.wav',
    SoundEffect.escape: 'audio/slither.wav',
    SoundEffect.hiss: 'audio/hiss.wav',
    SoundEffect.win: 'audio/win.wav',
  };

  Future<void> init() async {
    if (_ready) return;
    for (final e in SoundEffect.values) {
      _pools[e] = await AudioPool.createFromAsset(
        path: _files[e]!,
        maxPlayers: e == SoundEffect.tap ? 3 : 2,
        playerMode: PlayerMode.lowLatency,
      );
    }
    _ready = true;
  }

  Future<void> play(SoundEffect effect) async {
    if (!isEnabled()) return;
    if (_ready) {
      await _pools[effect]?.start();
    }
    switch (effect) {
      case SoundEffect.tap:
        await HapticFeedback.selectionClick();
      case SoundEffect.escape:
        await HapticFeedback.lightImpact();
      case SoundEffect.hiss:
        await HapticFeedback.heavyImpact();
      case SoundEffect.win:
        await HapticFeedback.mediumImpact();
    }
  }

  Future<void> dispose() async {
    for (final p in _pools.values) {
      await p.dispose();
    }
    _pools.clear();
    _ready = false;
  }
}

final soundControllerProvider = Provider<SoundController>((ref) {
  final controller = SoundController(
    isEnabled: () => ref.read(settingsProvider).soundEnabled,
  );
  ref.onDispose(() {
    unawaited(controller.dispose());
  });
  return controller;
});
