import 'package:flutter/foundation.dart';

import '../app/settings/east_settings_store.dart';
import '../models/saved_hand.dart';

class HandLibraryStore extends ChangeNotifier {
  HandLibraryStore(this._persistence);

  final HandLibraryPersistence _persistence;

  List<SavedHand> _items = <SavedHand>[];

  List<SavedHand> get items => List<SavedHand>.unmodifiable(_items);

  SavedHand? byId(String id) {
    for (final h in _items) {
      if (h.id == id) return h;
    }
    return null;
  }

  Future<void> load() async {
    final rows = await _persistence.loadRaw();
    final list = rows.map(SavedHand.fromJson).whereType<SavedHand>().toList(growable: false);
    list.sort((a, b) => b.updatedMs.compareTo(a.updatedMs));
    _items = list;
    notifyListeners();
  }

  Future<void> upsert(SavedHand hand) async {
    final next = List<SavedHand>.from(_items.where((h) => h.id != hand.id))..insert(0, hand);
    _items = next;
    notifyListeners();
    await _flush();
  }

  Future<void> remove(String id) async {
    _items = _items.where((h) => h.id != id).toList(growable: false);
    notifyListeners();
    await _flush();
  }

  Future<void> _flush() async {
    await _persistence.saveRaw(_items.map((e) => e.toJson()).toList(growable: false));
  }
}
