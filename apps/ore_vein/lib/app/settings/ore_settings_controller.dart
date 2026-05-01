import 'package:flutter/foundation.dart';

import 'ore_settings.dart';
import 'ore_settings_store.dart';

class OreSettingsController extends ChangeNotifier {
  OreSettingsController(this._store);

  final OreSettingsStore _store;

  OreSettings _value = OreSettings.defaults;
  OreSettings get value => _value;

  bool _loaded = false;
  bool get loaded => _loaded;

  Future<void> load() async {
    _value = await _store.read();
    _loaded = true;
    notifyListeners();
  }

  Future<void> update(OreSettings next) async {
    _value = next;
    notifyListeners();
    await _store.write(next);
  }
}
