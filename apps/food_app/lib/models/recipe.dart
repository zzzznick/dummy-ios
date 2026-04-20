class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.steps,
    required this.cookingTimeMinutes,
    required this.difficulty,
    this.imagePath,
    required this.tips,
  });

  final String id;
  final String name;
  final String ingredients;
  final String steps;
  final int cookingTimeMinutes;
  final int difficulty;
  final String? imagePath;
  final String tips;

  static Recipe fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      ingredients: (json['ingredients'] ?? '').toString(),
      steps: (json['steps'] ?? '').toString(),
      cookingTimeMinutes: (json['cookingTimeMinutes'] ?? 0) is int
          ? json['cookingTimeMinutes'] as int
          : int.tryParse((json['cookingTimeMinutes'] ?? '0').toString()) ?? 0,
      difficulty: (json['difficulty'] ?? 1) is int
          ? json['difficulty'] as int
          : int.tryParse((json['difficulty'] ?? '1').toString()) ?? 1,
      imagePath: (json['imagePath'] ?? '').toString().isEmpty
          ? null
          : (json['imagePath'] ?? '').toString(),
      tips: (json['tips'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'ingredients': ingredients,
    'steps': steps,
    'cookingTimeMinutes': cookingTimeMinutes,
    'difficulty': difficulty,
    'imagePath': imagePath ?? '',
    'tips': tips,
  };
}
