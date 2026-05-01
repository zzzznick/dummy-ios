class FieldNote {
  const FieldNote({
    required this.id,
    required this.title,
    required this.mineralKey,
    required this.mohsGuess,
    required this.contextLine,
    required this.updatedMs,
  });

  final String id;
  final String title;
  final String mineralKey;

  /// User-estimated hardness 1–10, nullable when unknown.
  final double? mohsGuess;
  final String contextLine;
  final int updatedMs;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'mineralKey': mineralKey,
        'mohsGuess': mohsGuess,
        'contextLine': contextLine,
        'updatedMs': updatedMs,
      };

  static FieldNote? fromJson(Map<String, dynamic> m) {
    final id = m['id'];
    final title = m['title'];
    final mineralKey = m['mineralKey'];
    final contextLine = m['contextLine'];
    final updatedMs = m['updatedMs'];
    if (id is! String ||
        title is! String ||
        mineralKey is! String ||
        contextLine is! String ||
        updatedMs is! int) {
      return null;
    }
    final g = m['mohsGuess'];
    final guess = g is num ? g.toDouble() : null;
    return FieldNote(
      id: id,
      title: title,
      mineralKey: mineralKey,
      mohsGuess: guess,
      contextLine: contextLine,
      updatedMs: updatedMs,
    );
  }

  FieldNote copyWith({
    String? title,
    String? mineralKey,
    double? mohsGuess,
    String? contextLine,
    int? updatedMs,
  }) =>
      FieldNote(
        id: id,
        title: title ?? this.title,
        mineralKey: mineralKey ?? this.mineralKey,
        mohsGuess: mohsGuess ?? this.mohsGuess,
        contextLine: contextLine ?? this.contextLine,
        updatedMs: updatedMs ?? this.updatedMs,
      );
}
