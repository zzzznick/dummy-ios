import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'app_paths.dart';

typedef FromJson<T> = T Function(Map<String, dynamic> json);
typedef ToJson<T> = Map<String, dynamic> Function(T value);

class JsonFileStore<T> {
  JsonFileStore({
    required this.fileName,
    required this.fromJson,
    required this.toJson,
    AppPaths? paths,
  }) : _paths = paths ?? AppPaths();

  final String fileName;
  final FromJson<T> fromJson;
  final ToJson<T> toJson;
  final AppPaths _paths;

  Future<File> _file() async {
    final docs = await _paths.documentsDir();
    return File(p.join(docs, fileName));
  }

  Future<List<T>> readAll() async {
    final f = await _file();
    if (!await f.exists()) return <T>[];
    final raw = await f.readAsString();
    if (raw.trim().isEmpty) return <T>[];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return <T>[];
    return decoded
        .whereType<Map>()
        .map((m) => fromJson(m.cast<String, dynamic>()))
        .toList();
  }

  Future<void> writeAll(List<T> items) async {
    final f = await _file();
    await f.parent.create(recursive: true);
    final encoded = jsonEncode(items.map(toJson).toList());
    await f.writeAsString(encoded);
  }

  Future<bool> exists() async {
    final f = await _file();
    return f.exists();
  }

  Future<File> rawFile() => _file();
}
