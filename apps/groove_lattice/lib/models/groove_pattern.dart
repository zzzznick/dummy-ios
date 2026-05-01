class GroovePattern {
  GroovePattern({
    required this.id,
    required this.name,
    required this.bpm,
    required this.steps,
    required this.updatedMillis,
  }) : assert(steps.every((s) => s > 0), 'steps positive');

  final String id;
  String name;
  int bpm;
  /// Each voice triggers every `steps[i]` pulses within one master cycle (= product of voices).
  List<int> steps;
  int updatedMillis;

  int get pulseCycleLength {
    if (steps.isEmpty) return 1;
    var g = steps.first;
    for (var i = 1; i < steps.length; i++) {
      g = _lcm(g, steps[i]);
    }
    return g;
  }

  GroovePattern copyWith({
    String? name,
    int? bpm,
    List<int>? steps,
    int? updatedMillis,
  }) {
    return GroovePattern(
      id: id,
      name: name ?? this.name,
      bpm: bpm ?? this.bpm,
      steps: steps ?? List<int>.from(this.steps),
      updatedMillis: updatedMillis ?? this.updatedMillis,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'bpm': bpm,
      'steps': steps,
      'updatedMillis': updatedMillis,
    };
  }

  factory GroovePattern.fromJson(Map<String, dynamic> m) {
    final rawSteps = m['steps'];
    final parsed = rawSteps is List
        ? rawSteps.map((e) => (e as num).round()).where((e) => e > 0).toList()
        : <int>[3, 4];
    return GroovePattern(
      id: (m['id'] ?? '').toString(),
      name: (m['name'] ?? 'Untitled').toString(),
      bpm: (m['bpm'] as num?)?.round() ?? 120,
      steps: parsed.isEmpty ? <int>[3, 4] : parsed,
      updatedMillis: (m['updatedMillis'] as num?)?.round() ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  static int _lcm(int a, int b) {
    if (a == 0 || b == 0) return 0;
    return (a ~/ _gcd(a, b)) * b;
  }

  static int _gcd(int a, int b) {
    var x = a.abs();
    var y = b.abs();
    while (y != 0) {
      final t = y;
      y = x % y;
      x = t;
    }
    return x;
  }
}
