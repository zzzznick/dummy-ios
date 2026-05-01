import 'package:flutter/foundation.dart';

import '../app/settings/ore_settings_store.dart';
import '../models/field_note.dart';

class FieldNoteStore extends ChangeNotifier {
  FieldNoteStore(this._persistence);

  final FieldDeskPersistence _persistence;

  List<FieldNote> _items = <FieldNote>[];

  List<FieldNote> get items => List<FieldNote>.unmodifiable(_items);

  FieldNote? byId(String id) {
    for (final n in _items) {
      if (n.id == id) return n;
    }
    return null;
  }

  Future<void> load() async {
    final rows = await _persistence.loadRaw();
    final list = rows.map(FieldNote.fromJson).whereType<FieldNote>().toList(growable: false)
      ..sort((a, b) => b.updatedMs.compareTo(a.updatedMs));
    _items = list;
    notifyListeners();
  }

  Future<void> upsert(FieldNote n) async {
    _items = <FieldNote>[n, ..._items.where((e) => e.id != n.id)];
    notifyListeners();
    await _flush();
  }

  Future<void> remove(String id) async {
    _items = _items.where((e) => e.id != id).toList(growable: false);
    notifyListeners();
    await _flush();
  }

  Future<void> _flush() async {
    await _persistence.saveRaw(_items.map((e) => e.toJson()).toList(growable: false));
  }
}
