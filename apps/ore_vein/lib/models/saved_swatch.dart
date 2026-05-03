class SavedSwatch {
  SavedSwatch({required this.id, required this.colorArgb, this.label = ''});

  final String id;
  int colorArgb;
  String label;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'c': colorArgb,
        'l': label,
      };

  static SavedSwatch fromJson(Map<String, dynamic> j) => SavedSwatch(
        id: (j['id'] ?? '').toString(),
        colorArgb: (j['c'] is int) ? j['c'] as int : int.tryParse('${j['c']}') ?? 0xFF00897B,
        label: (j['l'] ?? '').toString(),
      );
}
