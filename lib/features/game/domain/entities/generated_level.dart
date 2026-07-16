import 'board.dart';
import 'difficulty.dart';
import 'position.dart';

/// A generated puzzle plus a guaranteed solution.
///
/// [solution] is the reverse of the placement order: tapping these positions
/// in sequence always clears the board (see the reverse-generation invariant).
class GeneratedLevel {
  const GeneratedLevel({
    required this.board,
    required this.solution,
    required this.seed,
    required this.difficulty,
  });

  final Board board;
  final List<Position> solution;
  final int seed;
  final Difficulty difficulty;
}
