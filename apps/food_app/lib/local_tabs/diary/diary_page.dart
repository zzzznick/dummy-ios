import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../models/diary_entry.dart';
import '../../services/diary_repository.dart';
import '../../services/image_store.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  final DiaryRepository _repo = DiaryRepository();
  final TextEditingController _search = TextEditingController();

  List<DiaryEntry> _entries = <DiaryEntry>[];
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
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    setState(() {
      _entries = all;
      _loading = false;
    });
  }

  List<DiaryEntry> get _filtered {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return List<DiaryEntry>.from(_entries);
    return _entries.where((e) => e.content.toLowerCase().contains(q)).toList();
  }

  Future<void> _openAdd() async {
    final created = await Navigator.of(context).push<DiaryEntry>(
      MaterialPageRoute<DiaryEntry>(builder: (_) => const _AddDiaryPage()),
    );
    if (created == null) return;
    await _repo.upsert(created);
    await _refresh();
  }

  Future<void> _openDetail(DiaryEntry entry) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => _DiaryDetailPage(entry: entry)),
    );
  }

  Future<void> _delete(DiaryEntry entry) async {
    await _repo.deleteById(entry.id);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Diary'),
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
                hintText: 'Search for food diaries',
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
                      'There are no food diaries yet.\nClick to add in the upper right corner.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final e = filtered[index];
                        final preview = (e.content.length > 60)
                            ? '${e.content.substring(0, 60)}...'
                            : e.content;
                        return Dismissible(
                          key: ValueKey(e.id),
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
                          onDismissed: (_) => _delete(e),
                          child: ListTile(
                            leading:
                                (e.imagePath != null && e.imagePath!.isNotEmpty)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(e.imagePath!),
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(Icons.photo),
                            title: Text(preview.isEmpty ? '(Empty)' : preview),
                            subtitle: Text(e.createdAt.toLocal().toString()),
                            onTap: () => _openDetail(e),
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

class _AddDiaryPage extends StatefulWidget {
  const _AddDiaryPage();

  @override
  State<_AddDiaryPage> createState() => _AddDiaryPageState();
}

class _AddDiaryPageState extends State<_AddDiaryPage> {
  final _uuid = const Uuid();
  late final String _id = _uuid.v4();
  final _content = TextEditingController();
  final ImageStore _imageStore = ImageStore();
  String? _imagePath;

  @override
  void dispose() {
    _content.dispose();
    super.dispose();
  }

  void _save() {
    final entry = DiaryEntry(
      id: _id,
      content: _content.text.trim(),
      createdAtIso: DateTime.now().toUtc().toIso8601String(),
      imagePath: _imagePath,
    );
    Navigator.of(context).pop(entry);
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
        title: const Text('Add Diary'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
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
              controller: _content,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiaryDetailPage extends StatelessWidget {
  const _DiaryDetailPage({required this.entry});

  final DiaryEntry entry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diary Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry.imagePath != null && entry.imagePath!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(entry.imagePath!),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              entry.createdAt.toLocal().toString(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(entry.content),
          ],
        ),
      ),
    );
  }
}
