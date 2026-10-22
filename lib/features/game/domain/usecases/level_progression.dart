import '../entities/difficulty.dart';

/// One continuous ladder of levels: the game picks the difficulty from how
/// far the player has come instead of offering easy/medium/hard up front.
///
/// Levels 1..[easyLevelCount] are an easy on-ramp; every level after that is
/// medium, hard or very hard, shuffled in a fixed repeating pattern so the
/// mix feels varied but stays deterministic. Persistence still keys on
/// (difficulty, seed), so existing progress carries over unchanged.
const int easyLevelCount = 5;
const int totalLevels = 120;

const List<Difficulty> _mixedPattern = [
  Difficulty.medium,
  Difficulty.hard,
  Difficulty.medium,
  Difficulty.veryHard,
  Difficulty.hard,
  Difficulty.medium,
  Difficulty.veryHard,
  Difficulty.hard,
  Difficulty.medium,
  Difficulty.veryHard,
];

Difficulty difficultyForLevel(int level) {
  assert(level >= 1 && level <= totalLevels, 'level out of range: $level');
  if (level <= easyLevelCount) return Difficulty.easy;
  return _mixedPattern[(level - easyLevelCount - 1) % _mixedPattern.length];
}

/// Generator seed for a global level: its 1-based rank among the levels of
/// the same difficulty, so every (difficulty, seed) pair stays unique.
int seedForLevel(int level) {
  final difficulty = difficultyForLevel(level);
  var seed = 0;
  for (var l = 1; l <= level; l++) {
    if (difficultyForLevel(l) == difficulty) seed++;
  }
  return seed;
}
