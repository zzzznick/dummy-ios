import '../models/diary_entry.dart';
import '../storage/json_file_store.dart';

class DiaryRepository {
  DiaryRepository({JsonFileStore<DiaryEntry>? store})
    : _store =
          store ??
          JsonFileStore<DiaryEntry>(
            fileName: 'diary_entries.json',
            fromJson: DiaryEntry.fromJson,
            toJson: (e) => e.toJson(),
          );

  final JsonFileStore<DiaryEntry> _store;

  Future<List<DiaryEntry>> getAll() => _store.readAll();

  Future<void> upsert(DiaryEntry entry) async {
    final all = await _store.readAll();
    final idx = all.indexWhere((e) => e.id == entry.id);
    if (idx >= 0) {
      all[idx] = entry;
    } else {
      all.add(entry);
    }
    await _store.writeAll(all);
  }

  Future<void> deleteById(String id) async {
    final all = await _store.readAll();
    all.removeWhere((e) => e.id == id);
    await _store.writeAll(all);
  }
}
