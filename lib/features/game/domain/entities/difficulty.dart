/// Tunable parameters for level generation.
class DifficultyProfile {
  const DifficultyProfile({
    required this.size,
    required this.snakeCount,
    required this.minLength,
    required this.maxLength,
    required this.maxOpenRatio,
    this.maxAttempts = 64,
  });

  /// Side length of the square board.
  final int size;

  /// Desired number of snakes (generation may place fewer if candidates run out).
  final int snakeCount;

  /// Inclusive minimum body length (cells).
  final int minLength;

  /// Inclusive maximum body length (cells).
  final int maxLength;

  /// Reject-and-regenerate if more than this fraction of snakes have an open
  /// escape on the finished board (lower = harder / fewer obvious first moves).
  final double maxOpenRatio;

  /// How many seeded attempts to satisfy [maxOpenRatio] before keeping the best.
  final int maxAttempts;
}

enum Difficulty {
  easy,
  medium,
  hard;

  DifficultyProfile get profile => switch (this) {
        Difficulty.easy => const DifficultyProfile(
            size: 5,
            snakeCount: 5,
            minLength: 2,
            maxLength: 4,
            maxOpenRatio: 0.55,
          ),
        Difficulty.medium => const DifficultyProfile(
            size: 6,
            snakeCount: 7,
            minLength: 2,
            maxLength: 6,
            maxOpenRatio: 0.45,
          ),
        Difficulty.hard => const DifficultyProfile(
            size: 7,
            snakeCount: 9,
            minLength: 3,
            maxLength: 8,
            maxOpenRatio: 0.40,
          ),
      };
}
