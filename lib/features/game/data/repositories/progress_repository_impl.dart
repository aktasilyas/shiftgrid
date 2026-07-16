import '../../domain/entities/difficulty.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_store.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  const ProgressRepositoryImpl(this._store);

  final ProgressStore _store;

  String _key(Difficulty difficulty, int seed) => '${difficulty.name}:$seed';

  @override
  bool isCompleted(Difficulty difficulty, int seed) =>
      _store.read(_key(difficulty, seed)) != null;

  @override
  int? bestMoves(Difficulty difficulty, int seed) =>
      _store.read(_key(difficulty, seed));

  @override
  Future<void> recordCompletion(
    Difficulty difficulty,
    int seed,
    int moves,
  ) async {
    final current = bestMoves(difficulty, seed);
    if (current == null || moves < current) {
      await _store.write(_key(difficulty, seed), moves);
    }
  }

  @override
  bool isUnlocked(Difficulty difficulty, int seed) =>
      seed <= 1 || isCompleted(difficulty, seed - 1);
}
