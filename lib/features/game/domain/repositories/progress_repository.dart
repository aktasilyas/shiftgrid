import '../entities/difficulty.dart';

/// Tracks which levels the player has finished and their best scores.
///
/// Levels are identified by (difficulty, seed). Seeds start at 1.
abstract interface class ProgressRepository {
  bool isCompleted(Difficulty difficulty, int seed);

  /// Fewest moves recorded for a level, or null if never completed.
  int? bestMoves(Difficulty difficulty, int seed);

  /// Records a completion, keeping only the best (lowest) move count.
  Future<void> recordCompletion(Difficulty difficulty, int seed, int moves);

  /// Whether a level is playable yet (sequential unlock per difficulty).
  bool isUnlocked(Difficulty difficulty, int seed);
}
