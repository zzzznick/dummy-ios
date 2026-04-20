class DiaryEntry {
  const DiaryEntry({
    required this.id,
    required this.content,
    required this.createdAtIso,
    this.imagePath,
  });

  final String id;
  final String content;
  final String createdAtIso;
  final String? imagePath;

  DateTime get createdAt => DateTime.tryParse(createdAtIso) ?? DateTime.now();

  static DiaryEntry fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: (json['id'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      createdAtIso: (json['createdAtIso'] ?? '').toString(),
      imagePath: (json['imagePath'] ?? '').toString().isEmpty
          ? null
          : (json['imagePath'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'content': content,
    'createdAtIso': createdAtIso,
    'imagePath': imagePath ?? '',
  };
}
