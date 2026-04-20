import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../models/feast.dart';
import '../../services/feast_backup_manager.dart';
import '../../services/feast_repository.dart';
import '../../services/image_store.dart';

class FeastPage extends StatefulWidget {
  const FeastPage({super.key});

  @override
  State<FeastPage> createState() => _FeastPageState();
}

class _FeastPageState extends State<FeastPage> {
  final FeastRepository _repo = FeastRepository();
  final FeastBackupManager _backup = FeastBackupManager();

  final TextEditingController _search = TextEditingController();
  List<Feast> _feasts = <Feast>[];
  bool _loading = true;

  int _sortPreference = 0; // 0 date desc, 1 date asc, 2 cost desc, 3 cost asc

  @override
  void initState() {
    super.initState();
    _search.addListener(_applyFilters);
    _init();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await _loadSortPreference();
    await _backup.restoreIfPresent();
    await _refresh();
  }

  Future<void> _loadSortPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _sortPreference = prefs.getInt('FeastSortPreference') ?? 0;
  }

  Future<void> _saveSortPreference(int v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('FeastSortPreference', v);
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final all = await _repo.getAll();
    setState(() {
      _feasts = all;
      _loading = false;
    });
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {});
  }

  List<Feast> get _filtered {
    final q = _search.text.trim().toLowerCase();
    var items = _feasts;
    if (q.isNotEmpty) {
      items = items
          .where(
            (f) =>
                f.restaurantName.toLowerCase().contains(q) ||
                f.dishNames.toLowerCase().contains(q),
          )
          .toList();
    } else {
      items = List<Feast>.from(items);
    }

    items.sort((a, b) {
      switch (_sortPreference) {
        case 0:
          return b.diningDate.compareTo(a.diningDate);
        case 1:
          return a.diningDate.compareTo(b.diningDate);
        case 2:
          return b.cost.compareTo(a.cost);
        case 3:
          return a.cost.compareTo(b.cost);
        default:
          return b.diningDate.compareTo(a.diningDate);
      }
    });
    return items;
  }

  double get _totalCost => _feasts.fold(0.0, (sum, f) => sum + f.cost);

  Future<void> _delete(Feast feast) async {
    await _repo.deleteById(feast.id);
    await _refresh();
  }

  Future<void> _openAdd() async {
    final created = await Navigator.of(context).push<Feast>(
      MaterialPageRoute<Feast>(builder: (_) => const _AddFeastPage()),
    );
    if (created != null) {
      await _repo.upsert(created);
      await _refresh();
    }
  }

  Future<void> _openDetail(Feast feast) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => _FeastDetailPage(feast: feast)),
    );
  }

  Future<void> _pickSort() async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      builder: (context) {
        final options = <(int, String)>[
          (0, 'Date (Latest First)'),
          (1, 'Date (Oldest First)'),
          (2, 'Cost (Highest First)'),
          (3, 'Cost (Lowest First)'),
        ];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options
                .map(
                  (o) => ListTile(
                    title: Text(o.$2),
                    leading: Icon(o.$1 == _sortPreference ? Icons.check : null),
                    onTap: () => Navigator.pop(context, o.$1),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
    if (selected == null) return;
    setState(() => _sortPreference = selected);
    await _saveSortPreference(selected);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Feast'),
        actions: [
          IconButton(
            onPressed: _pickSort,
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
          ),
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
                hintText: 'Search for restaurants or dishes',
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
                      'No food records have been added yet\nClick + Add in the upper right corner',
                      textAlign: TextAlign.center,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final feast = filtered[index];
                        return Dismissible(
                          key: ValueKey(feast.id),
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
                          confirmDismiss: (_) async {
                            return await showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Delete'),
                                      content: const Text(
                                        'Delete this record?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        FilledButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                ) ??
                                false;
                          },
                          onDismissed: (_) => _delete(feast),
                          child: ListTile(
                            leading:
                                (feast.imagePath != null &&
                                    feast.imagePath!.isNotEmpty)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(feast.imagePath!),
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(Icons.fork_right),
                            title: Text(
                              feast.restaurantName.isEmpty
                                  ? '(Unnamed)'
                                  : feast.restaurantName,
                            ),
                            subtitle: Text(
                              '${feast.dishNames}\n${feast.diningDate.toLocal()}  •  ¥${feast.cost.toStringAsFixed(2)}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            isThreeLine: true,
                            onTap: () => _openDetail(feast),
                          ),
                        );
                      },
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Total Cost: ¥${_totalCost.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddFeastPage extends StatefulWidget {
  const _AddFeastPage();

  @override
  State<_AddFeastPage> createState() => _AddFeastPageState();
}

class _AddFeastPageState extends State<_AddFeastPage> {
  final _uuid = const Uuid();
  late final String _id = _uuid.v4();
  final _restaurant = TextEditingController();
  final _dishes = TextEditingController();
  final _people = TextEditingController(text: '1');
  final _cost = TextEditingController(text: '0');

  DateTime _date = DateTime.now();
  final ImageStore _imageStore = ImageStore();
  String? _imagePath;

  @override
  void dispose() {
    _restaurant.dispose();
    _dishes.dispose();
    _people.dispose();
    _cost.dispose();
    super.dispose();
  }

  void _save() {
    final numberOfPeople = int.tryParse(_people.text.trim()) ?? 1;
    final cost = double.tryParse(_cost.text.trim()) ?? 0;

    final feast = Feast(
      id: _id,
      restaurantName: _restaurant.text.trim(),
      dishNames: _dishes.text.trim(),
      diningDateIso: _date.toUtc().toIso8601String(),
      numberOfPeople: numberOfPeople,
      cost: cost,
      imagePath: _imagePath,
    );
    Navigator.of(context).pop(feast);
  }

  Future<void> _pickImage(ImageSource source) async {
    final path = await _imageStore.pickAndStoreImage(id: _id, source: source);
    if (!mounted) return;
    setState(() => _imagePath = path);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(
      () => _date = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _date.hour,
        _date.minute,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Feast'),
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
            controller: _restaurant,
            decoration: const InputDecoration(
              labelText: 'Restaurant Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _dishes,
            decoration: const InputDecoration(
              labelText: 'Dish Names',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _people,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Number of People',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cost,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Cost (¥)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Dining Date'),
            subtitle: Text(_date.toLocal().toString()),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickDate,
          ),
        ],
      ),
    );
  }
}

class _FeastDetailPage extends StatelessWidget {
  const _FeastDetailPage({required this.feast});

  final Feast feast;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feast Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (feast.imagePath != null && feast.imagePath!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(feast.imagePath!),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              feast.restaurantName.isEmpty ? '(Unnamed)' : feast.restaurantName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Dishes: ${feast.dishNames}'),
            const SizedBox(height: 8),
            Text('Date: ${feast.diningDate.toLocal()}'),
            const SizedBox(height: 8),
            Text('People: ${feast.numberOfPeople}'),
            const SizedBox(height: 8),
            Text('Cost: ¥${feast.cost.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}
