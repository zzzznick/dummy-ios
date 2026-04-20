import '../models/feast.dart';
import '../storage/json_file_store.dart';

class FeastRepository {
  FeastRepository({JsonFileStore<Feast>? store})
    : _store =
          store ??
          JsonFileStore<Feast>(
            fileName: 'feasts.json',
            fromJson: Feast.fromJson,
            toJson: (f) => f.toJson(),
          );

  final JsonFileStore<Feast> _store;

  Future<List<Feast>> getAll() => _store.readAll();

  Future<void> upsert(Feast feast) async {
    final all = await _store.readAll();
    final idx = all.indexWhere((e) => e.id == feast.id);
    if (idx >= 0) {
      all[idx] = feast;
    } else {
      all.add(feast);
    }
    await _store.writeAll(all);
  }

  Future<void> deleteById(String id) async {
    final all = await _store.readAll();
    all.removeWhere((e) => e.id == id);
    await _store.writeAll(all);
  }

  Future<void> replaceAll(List<Feast> feasts) => _store.writeAll(feasts);

  Future<JsonFileStore<Feast>> store() async => _store;
}
