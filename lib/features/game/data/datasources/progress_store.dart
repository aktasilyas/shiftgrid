/// A tiny key→int persistence abstraction so the progress repository can be
/// tested without a real Hive box.
abstract interface class ProgressStore {
  int? read(String key);
  Future<void> write(String key, int value);
}

/// In-memory store for tests and previews.
class InMemoryProgressStore implements ProgressStore {
  final Map<String, int> _data = {};

  @override
  int? read(String key) => _data[key];

  @override
  Future<void> write(String key, int value) async {
    _data[key] = value;
  }
}
