import '../models/recipe.dart';
import '../storage/json_file_store.dart';

class RecipeRepository {
  RecipeRepository({JsonFileStore<Recipe>? store})
    : _store =
          store ??
          JsonFileStore<Recipe>(
            fileName: 'recipes.json',
            fromJson: Recipe.fromJson,
            toJson: (r) => r.toJson(),
          );

  final JsonFileStore<Recipe> _store;

  Future<List<Recipe>> getAll() => _store.readAll();

  Future<void> upsert(Recipe recipe) async {
    final all = await _store.readAll();
    final idx = all.indexWhere((e) => e.id == recipe.id);
    if (idx >= 0) {
      all[idx] = recipe;
    } else {
      all.add(recipe);
    }
    await _store.writeAll(all);
  }

  Future<void> deleteById(String id) async {
    final all = await _store.readAll();
    all.removeWhere((e) => e.id == id);
    await _store.writeAll(all);
  }
}
