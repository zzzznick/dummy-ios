import 'package:flutter/foundation.dart';

import 'app_settings.dart';
import 'app_settings_store.dart';

class AppSettingsController extends ChangeNotifier {
  AppSettingsController(this._store);

  final AppSettingsStore _store;
  AppSettings _value = AppSettings.defaults;

  AppSettings get value => _value;

  Future<void> load() async {
    _value = await _store.load();
    notifyListeners();
  }

  Future<void> update(AppSettings next) async {
    _value = next;
    notifyListeners();
    await _store.save(_value);
  }
}
