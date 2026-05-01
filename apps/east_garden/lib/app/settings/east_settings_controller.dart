import 'package:flutter/foundation.dart';

import 'east_settings.dart';
import 'east_settings_store.dart';

class EastSettingsController extends ChangeNotifier {
  EastSettingsController(this._store);

  final EastSettingsStore _store;

  EastSettings _value = EastSettings.defaults;
  EastSettings get value => _value;

  bool _loaded = false;
  bool get loaded => _loaded;

  Future<void> load() async {
    _value = await _store.read();
    _loaded = true;
    notifyListeners();
  }

  Future<void> update(EastSettings next) async {
    _value = next;
    notifyListeners();
    await _store.write(next);
  }
}
