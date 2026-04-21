import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsController extends ChangeNotifier {
  static const _kSeedColorValue = 'app.seedColorValue';

  Color _seedColor = const Color(0xFF5B5BD6);

  Color get seedColor => _seedColor;

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getInt(_kSeedColorValue);
    if (raw != null) {
      _seedColor = Color(raw);
    }
  }

  Future<void> setSeedColor(Color value) async {
    if (value.value == _seedColor.value) return;
    _seedColor = value;
    notifyListeners();

    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kSeedColorValue, value.value);
  }
}

