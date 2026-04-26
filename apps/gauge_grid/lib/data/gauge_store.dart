import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class SavedBoard {
  SavedBoard({
    required this.id,
    required this.name,
    required this.cells,
    required this.gridSize,
  });

  final String id;
  final String name;
  final Map<String, String> cells;
  final int gridSize;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'cells': cells,
    'gridSize': gridSize,
  };

  static SavedBoard fromJson(Map<String, dynamic> j) {
    final raw = j['cells'];
    final map = <String, String>{};
    if (raw is Map) {
      raw.forEach((k, v) {
        map['$k'] = '$v';
      });
    }
    return SavedBoard(
      id: '${j['id']}',
      name: '${j['name']}',
      cells: map,
      gridSize: (j['gridSize'] as num?)?.toInt() ?? 8,
    );
  }
}

class GaugeStore extends ChangeNotifier {
  late final Future<void> _loadFuture = _load();
  Future<void> get ready => _loadFuture;

  int _gridSize = 8;
  int get gridSize => _gridSize;
  set gridSize(int v) {
    final n = v.clamp(4, 12);
    if (n == _gridSize) return;
    _gridSize = n;
    _liveCells.removeWhere((k, _) {
      final p = k.split(',');
      if (p.length != 2) return true;
      final r = int.tryParse(p[0]) ?? 0;
      final c = int.tryParse(p[1]) ?? 0;
      return r >= n || c >= n;
    });
    notifyListeners();
    _save();
  }

  String _defaultLengthUnit = 'cm';
  String get defaultLengthUnit => _defaultLengthUnit;
  set defaultLengthUnit(String u) {
    if (!<String>['mm', 'cm', 'in'].contains(u)) return;
    _defaultLengthUnit = u;
    notifyListeners();
    _save();
  }

  int _decimalPlaces = 1;
  int get decimalPlaces => _decimalPlaces;
  set decimalPlaces(int d) {
    _decimalPlaces = d.clamp(0, 3);
    notifyListeners();
    _save();
  }

  final Map<String, String> _liveCells = <String, String>{};
  Map<String, String> get liveCells => Map<String, String>.unmodifiable(_liveCells);

  final List<SavedBoard> _boards = <SavedBoard>[];
  List<SavedBoard> get boards => List<SavedBoard>.unmodifiable(_boards);

  String _key(int r, int c) => '$r,$c';

  String? cellAt(int r, int c) => _liveCells[_key(r, c)];

  void setCell(int r, int c, String? value) {
    final k = _key(r, c);
    if (value == null || value.trim().isEmpty) {
      _liveCells.remove(k);
    } else {
      _liveCells[k] = value.trim();
    }
    notifyListeners();
    _save();
  }

  void clearAllCells() {
    _liveCells.clear();
    notifyListeners();
    _save();
  }

  /// Wipe live grid, saved boards, and reset preferences to defaults.
  void eraseAllLocalData() {
    _liveCells.clear();
    _boards.clear();
    _gridSize = 8;
    _defaultLengthUnit = 'cm';
    _decimalPlaces = 1;
    notifyListeners();
    _save();
  }

  void saveAsBoard(String name) {
    final t = name.trim();
    if (t.isEmpty) return;
    final b = SavedBoard(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: t,
      cells: Map<String, String>.from(_liveCells),
      gridSize: _gridSize,
    );
    _boards.add(b);
    notifyListeners();
    _save();
  }

  void applyBoard(SavedBoard b) {
    _gridSize = b.gridSize.clamp(4, 12);
    _liveCells
      ..clear()
      ..addAll(b.cells);
    notifyListeners();
    _save();
  }

  void removeBoard(String id) {
    _boards.removeWhere((e) => e.id == id);
    notifyListeners();
    _save();
  }

  Future<void> _load() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final f = File(p.join(dir.path, 'gauge_grid_state.json'));
      if (!await f.exists()) return;
      final j = jsonDecode(await f.readAsString()) as Map<String, dynamic>;
      _gridSize = (j['gridSize'] as num?)?.toInt() ?? 8;
      _defaultLengthUnit = '${j['defaultLengthUnit'] ?? 'cm'}';
      if (!<String>['mm', 'cm', 'in'].contains(_defaultLengthUnit)) {
        _defaultLengthUnit = 'cm';
      }
      _decimalPlaces = (j['decimalPlaces'] as num?)?.toInt() ?? 1;
      _liveCells.clear();
      final live = j['liveCells'];
      if (live is Map) {
        live.forEach((k, v) {
          _liveCells['$k'] = '$v';
        });
      }
      _boards.clear();
      final list = j['boards'];
      if (list is List) {
        for (final e in list) {
          if (e is Map<String, dynamic>) {
            _boards.add(SavedBoard.fromJson(e));
          }
        }
      }
    } catch (_) {
      // keep defaults
    } finally {
      notifyListeners();
    }
  }

  Future<void> _save() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final f = File(p.join(dir.path, 'gauge_grid_state.json'));
      final payload = <String, dynamic>{
        'gridSize': _gridSize,
        'defaultLengthUnit': _defaultLengthUnit,
        'decimalPlaces': _decimalPlaces,
        'liveCells': _liveCells,
        'boards': _boards.map((b) => b.toJson()).toList(),
      };
      await f.writeAsString(const JsonEncoder.withIndent('  ').convert(payload));
    } catch (_) {}
  }
}
