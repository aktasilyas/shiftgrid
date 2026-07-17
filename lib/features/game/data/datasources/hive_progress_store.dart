import 'package:hive/hive.dart';

import 'progress_store.dart';

/// [ProgressStore] backed by a Hive box of ints.
class HiveProgressStore implements ProgressStore {
  const HiveProgressStore(this._box);

  static const boxName = 'progress';

  final Box<int> _box;

  @override
  int? read(String key) => _box.get(key);

  @override
  Future<void> write(String key, int value) => _box.put(key, value);
}
