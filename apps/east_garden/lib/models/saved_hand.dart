class SavedHand {
  const SavedHand({
    required this.id,
    required this.title,
    required this.tiles,
    required this.updatedMs,
  });

  final String id;
  final String title;
  final List<String> tiles;
  final int updatedMs;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'tiles': tiles,
        'updatedMs': updatedMs,
      };

  static SavedHand? fromJson(Map<String, dynamic> m) {
    final id = m['id'];
    final title = m['title'];
    final tilesRaw = m['tiles'];
    final updatedMs = m['updatedMs'];
    if (id is! String || title is! String || tilesRaw is! List || updatedMs is! int) {
      return null;
    }
    final tiles = tilesRaw.whereType<String>().toList(growable: false);
    return SavedHand(id: id, title: title, tiles: tiles, updatedMs: updatedMs);
  }

  SavedHand copyWith({
    String? title,
    List<String>? tiles,
    int? updatedMs,
  }) =>
      SavedHand(
        id: id,
        title: title ?? this.title,
        tiles: tiles ?? this.tiles,
        updatedMs: updatedMs ?? this.updatedMs,
      );
}
