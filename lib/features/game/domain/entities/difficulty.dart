/// Tunable parameters for level generation.
class DifficultyProfile {
  const DifficultyProfile({
    required this.size,
    required this.arrowCount,
    required this.maxOpenRatio,
    this.maxAttempts = 48,
  });

  /// Side length of the square board.
  final int size;

  /// Desired number of arrows (generation may place fewer if it runs out of
  /// legal placements).
  final int arrowCount;

  /// Reject-and-regenerate if more than this fraction of arrows have an open
  /// shot on the finished board (lower = harder / fewer obvious first moves).
  final double maxOpenRatio;

  /// How many seeded attempts to satisfy [maxOpenRatio] before keeping the best.
  final int maxAttempts;
}

enum Difficulty {
  easy,
  medium,
  hard;

  DifficultyProfile get profile => switch (this) {
        Difficulty.easy =>
          const DifficultyProfile(size: 4, arrowCount: 6, maxOpenRatio: 0.65),
        Difficulty.medium =>
          const DifficultyProfile(size: 5, arrowCount: 10, maxOpenRatio: 0.5),
        Difficulty.hard =>
          const DifficultyProfile(size: 6, arrowCount: 15, maxOpenRatio: 0.45),
      };
}
