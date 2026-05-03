class ChecklistItem {
  ChecklistItem({required this.id, required this.text, this.done = false});

  final String id;
  String text;
  bool done;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'text': text,
        'done': done,
      };

  static ChecklistItem fromJson(Map<String, dynamic> j) => ChecklistItem(
        id: (j['id'] ?? '').toString(),
        text: (j['text'] ?? '').toString(),
        done: j['done'] == true,
      );
}

class Checklist {
  Checklist({required this.id, required this.title, List<ChecklistItem>? items})
      : items = items ?? <ChecklistItem>[];

  final String id;
  String title;
  final List<ChecklistItem> items;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'items': items.map((e) => e.toJson()).toList(),
      };

  static Checklist fromJson(Map<String, dynamic> j) => Checklist(
        id: (j['id'] ?? '').toString(),
        title: (j['title'] ?? '').toString(),
        items: (j['items'] is List)
            ? (j['items'] as List<dynamic>)
                .whereType<Map>()
                .map((e) => ChecklistItem.fromJson(e.cast<String, dynamic>()))
                .toList()
            : <ChecklistItem>[],
      );
}
