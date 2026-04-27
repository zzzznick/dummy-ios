import 'dart:convert';
import 'dart:math';

class Palette {
  Palette({
    required this.id,
    required this.name,
    required this.colors,
    required this.createdAtMs,
  });

  final String id;
  final String name;

  /// Colors stored as ARGB ints.
  final List<int> colors;

  final int createdAtMs;

  Palette copyWith({
    String? id,
    String? name,
    List<int>? colors,
    int? createdAtMs,
  }) {
    return Palette(
      id: id ?? this.id,
      name: name ?? this.name,
      colors: colors ?? this.colors,
      createdAtMs: createdAtMs ?? this.createdAtMs,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'name': name,
        'colors': colors,
        'createdAtMs': createdAtMs,
      };

  static Palette fromJson(Map<String, Object?> json) {
    final rawColors = (json['colors'] as List).cast<num>();
    return Palette(
      id: json['id'] as String,
      name: json['name'] as String,
      colors: rawColors.map((e) => e.toInt()).toList(growable: false),
      createdAtMs: (json['createdAtMs'] as num).toInt(),
    );
  }

  static Palette seed(String name, {required Random random}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = '${now}_${random.nextInt(1 << 32)}';
    final colors = List<int>.generate(5, (_) {
      final r = 80 + random.nextInt(176);
      final g = 80 + random.nextInt(176);
      final b = 80 + random.nextInt(176);
      return (0xFF << 24) | (r << 16) | (g << 8) | b;
    });
    return Palette(id: id, name: name, colors: colors, createdAtMs: now);
  }
}

String encodePalettes(List<Palette> palettes) {
  return jsonEncode(palettes.map((p) => p.toJson()).toList());
}

List<Palette> decodePalettes(String raw) {
  final decoded = (jsonDecode(raw) as List).cast<Object?>();
  return decoded
      .map((e) => Palette.fromJson((e as Map).cast<String, Object?>()))
      .toList(growable: false);
}

