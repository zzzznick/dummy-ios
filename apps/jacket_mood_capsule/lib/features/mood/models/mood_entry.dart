class MoodEntry {
  MoodEntry({
    required this.id,
    required this.createdAtMs,
    required this.mood,
    required this.note,
    required this.tags,
    required this.isPinned,
  });

  final String id;
  final int createdAtMs;

  /// 1..5
  final int mood;

  final String note;
  final List<String> tags;
  final bool isPinned;

  DateTime get createdAt => DateTime.fromMillisecondsSinceEpoch(createdAtMs);

  MoodEntry copyWith({
    int? mood,
    String? note,
    List<String>? tags,
    bool? isPinned,
  }) {
    return MoodEntry(
      id: id,
      createdAtMs: createdAtMs,
      mood: mood ?? this.mood,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'createdAtMs': createdAtMs,
        'mood': mood,
        'note': note,
        'tags': tags,
        'isPinned': isPinned,
      };

  static MoodEntry fromJson(Map<String, dynamic> json) {
    final tagsRaw = json['tags'];
    final tags = <String>[];
    if (tagsRaw is List) {
      for (final t in tagsRaw) {
        final s = t?.toString().trim() ?? '';
        if (s.isNotEmpty) tags.add(s);
      }
    }

    return MoodEntry(
      id: (json['id'] ?? '').toString(),
      createdAtMs: (json['createdAtMs'] is num)
          ? (json['createdAtMs'] as num).toInt()
          : int.tryParse((json['createdAtMs'] ?? '').toString()) ?? 0,
      mood: (json['mood'] is num)
          ? (json['mood'] as num).toInt()
          : int.tryParse((json['mood'] ?? '').toString()) ?? 3,
      note: (json['note'] ?? '').toString(),
      tags: tags,
      isPinned: json['isPinned'] == true,
    );
  }
}

