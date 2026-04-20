import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../models/recipe.dart';
import '../../services/recipe_repository.dart';
import '../../services/image_store.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  final RecipeRepository _repo = RecipeRepository();
  final TextEditingController _search = TextEditingController();

  List<Recipe> _recipes = <Recipe>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
    _refresh();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final all = await _repo.getAll();
    setState(() {
      _recipes = all;
      _loading = false;
    });
  }

  List<Recipe> get _filtered {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return List<Recipe>.from(_recipes);
    return _recipes.where((r) => r.name.toLowerCase().contains(q)).toList();
  }

  Future<void> _openAdd() async {
    final created = await Navigator.of(context).push<Recipe>(
      MaterialPageRoute<Recipe>(builder: (_) => const _AddRecipePage()),
    );
    if (created == null) return;
    await _repo.upsert(created);
    await _refresh();
  }

  Future<void> _openDetail(Recipe recipe) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => _RecipeDetailPage(recipe: recipe),
      ),
    );
  }

  Future<void> _delete(Recipe recipe) async {
    await _repo.deleteById(recipe.id);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cooking Secrets'),
        actions: [
          IconButton(
            onPressed: _openAdd,
            icon: const Icon(Icons.add),
            tooltip: 'Add',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _search,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search dish name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No recipes have been added yet.\nClick + Add your first recipe.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final r = filtered[index];
                        return Dismissible(
                          key: ValueKey(r.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) => _delete(r),
                          child: ListTile(
                            leading:
                                (r.imagePath != null && r.imagePath!.isNotEmpty)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(r.imagePath!),
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(Icons.book),
                            title: Text(r.name.isEmpty ? '(Unnamed)' : r.name),
                            subtitle: Text(
                              'Time: ${r.cookingTimeMinutes}m  •  Difficulty: ${r.difficulty}/5',
                            ),
                            onTap: () => _openDetail(r),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AddRecipePage extends StatefulWidget {
  const _AddRecipePage();

  @override
  State<_AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<_AddRecipePage> {
  final _uuid = const Uuid();
  late final String _id = _uuid.v4();
  final _name = TextEditingController();
  final _ingredients = TextEditingController();
  final _steps = TextEditingController();
  final _time = TextEditingController(text: '0');
  final _difficulty = TextEditingController(text: '1');
  final _tips = TextEditingController();
  final ImageStore _imageStore = ImageStore();
  String? _imagePath;

  @override
  void dispose() {
    _name.dispose();
    _ingredients.dispose();
    _steps.dispose();
    _time.dispose();
    _difficulty.dispose();
    _tips.dispose();
    super.dispose();
  }

  void _save() {
    final time = int.tryParse(_time.text.trim()) ?? 0;
    final diff = int.tryParse(_difficulty.text.trim()) ?? 1;
    final recipe = Recipe(
      id: _id,
      name: _name.text.trim(),
      ingredients: _ingredients.text.trim(),
      steps: _steps.text.trim(),
      cookingTimeMinutes: time,
      difficulty: diff.clamp(1, 5),
      imagePath: _imagePath,
      tips: _tips.text.trim(),
    );
    Navigator.of(context).pop(recipe);
  }

  Future<void> _pickImage(ImageSource source) async {
    final path = await _imageStore.pickAndStoreImage(id: _id, source: source);
    if (!mounted) return;
    setState(() => _imagePath = path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Recipe'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Row(
            children: [
              FilledButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.photo_camera),
                label: const Text('Camera'),
              ),
              const SizedBox(width: 12),
              FilledButton.tonalIcon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
              ),
            ],
          ),
          if (_imagePath != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_imagePath!),
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Dish Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ingredients,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Ingredients',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _steps,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Steps',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _time,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Time (minutes)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _difficulty,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Difficulty (1-5)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tips,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Tips',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeDetailPage extends StatelessWidget {
  const _RecipeDetailPage({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe Detail')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (recipe.imagePath != null && recipe.imagePath!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(recipe.imagePath!),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            recipe.name.isEmpty ? '(Unnamed)' : recipe.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text('Time: ${recipe.cookingTimeMinutes}m'),
          Text('Difficulty: ${recipe.difficulty}/5'),
          const SizedBox(height: 12),
          Text('Ingredients', style: Theme.of(context).textTheme.titleMedium),
          Text(recipe.ingredients),
          const SizedBox(height: 12),
          Text('Steps', style: Theme.of(context).textTheme.titleMedium),
          Text(recipe.steps),
          if (recipe.tips.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Tips', style: Theme.of(context).textTheme.titleMedium),
            Text(recipe.tips),
          ],
        ],
      ),
    );
  }
}
