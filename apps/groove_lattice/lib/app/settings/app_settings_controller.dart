import 'package:flutter/foundation.dart';

import 'app_settings.dart';
import 'app_settings_store.dart';

class AppSettingsController extends ChangeNotifier {
  AppSettingsController(this._store);

  final AppSettingsStore _store;

  AppSettings _value = AppSettings.defaults;
  AppSettings get value => _value;

  bool _loaded = false;
  bool get loaded => _loaded;

  Future<void> load() async {
    _value = await _store.read();
    _loaded = true;
    notifyListeners();
  }

  Future<void> update(AppSettings next) async {
    _value = next;
    notifyListeners();
    await _store.write(next);
  }
}
