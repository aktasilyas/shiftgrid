/// Tunable parameters for level generation.
class DifficultyProfile {
  const DifficultyProfile({
    required this.size,
    required this.snakeCount,
    required this.minLength,
    required this.maxLength,
    required this.maxOpenRatio,
    this.maxAttempts = 96,
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
  hard,
  veryHard;

  DifficultyProfile get profile => switch (this) {
        Difficulty.easy => const DifficultyProfile(
            size: 6,
            snakeCount: 6,
            minLength: 2,
            maxLength: 5,
            maxOpenRatio: 0.50,
          ),
        Difficulty.medium => const DifficultyProfile(
            size: 9,
            snakeCount: 13,
            minLength: 3,
            maxLength: 8,
            maxOpenRatio: 0.40,
          ),
        Difficulty.hard => const DifficultyProfile(
            size: 13,
            snakeCount: 26,
            minLength: 3,
            maxLength: 12,
            maxOpenRatio: 0.32,
            maxAttempts: 48,
          ),
        // A wall of snakes: hundreds of short bodies interlocked on a huge
        // grid. Short max length packs far more snakes into the board, which
        // is what makes it brutal — nearly every escape ray is blocked.
        Difficulty.veryHard => const DifficultyProfile(
            size: 36,
            snakeCount: 300,
            minLength: 3,
            maxLength: 4,
            maxOpenRatio: 0.35,
            maxAttempts: 3,
          ),
      };
}
