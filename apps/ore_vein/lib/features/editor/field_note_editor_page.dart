import 'package:flutter/material.dart';

import '../../models/field_note.dart';
import '../../models/mineral_ref.dart';
import '../../services/field_note_store.dart';

class FieldNoteEditorPage extends StatefulWidget {
  const FieldNoteEditorPage({
    super.key,
    required this.store,
    this.noteId,
  });

  final FieldNoteStore store;

  /// null → create on save.
  final String? noteId;

  @override
  State<FieldNoteEditorPage> createState() => _FieldNoteEditorPageState();
}

class _FieldNoteEditorPageState extends State<FieldNoteEditorPage> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _context = TextEditingController();
  late String _mineralKey;
  bool _guessOn = false;
  double _guess = 5;
  bool _primed = false;

  void _primeOnce(FieldNote? n) {
    if (_primed || n == null) return;
    _primed = true;
    _title.text = n.title;
    _context.text = n.contextLine;
    _mineralKey = n.mineralKey;
    if (n.mohsGuess != null) {
      _guessOn = true;
      _guess = n.mohsGuess!.clamp(1, 10);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    final cat = MineralRef.catalog;
    _mineralKey = cat.first.key;
    final seed = widget.noteId == null ? null : widget.store.byId(widget.noteId!);
    if (seed != null) _primeOnce(seed);
  }

  @override
  void dispose() {
    _title.dispose();
    _context.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = _title.text.trim();
    final ctxLine = _context.text.trim();
    if (t.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title required')));
      return;
    }
    final id = widget.noteId ?? DateTime.now().microsecondsSinceEpoch.toString();

    await widget.store.upsert(
      FieldNote(
        id: id,
        title: t,
        mineralKey: _mineralKey,
        mohsGuess: _guessOn ? _guess : null,
        contextLine: ctxLine.isEmpty ? 'No field gloss yet.' : ctxLine,
        updatedMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vault updated')));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final existing = widget.noteId == null ? null : widget.store.byId(widget.noteId!);
        if (!_primed) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _primeOnce(existing));
        }
        if (widget.noteId != null && existing == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Missing note')),
            body: const Center(child: Text('That specimen record was discarded.')),
          );
        }

        final cat = MineralRef.catalog;

        return Scaffold(
          appBar: AppBar(title: Text(widget.noteId == null ? 'New vault entry' : 'Edit entry')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
            children: <Widget>[
              TextField(controller: _title, decoration: const InputDecoration(labelText: 'Nickname')),
              const SizedBox(height: 14),
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Anchored mineral'),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _mineralKey,
                    items: cat
                        .map((m) => DropdownMenuItem<String>(value: m.key, child: Text(m.commonName)))
                        .toList(),
                    onChanged: (v) => setState(() => _mineralKey = v ?? cat.first.key),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SwitchListTile.adaptive(
                title: const Text('Log Mohs suspicion'),
                value: _guessOn,
                onChanged: (v) => setState(() => _guessOn = v),
              ),
              if (_guessOn) ...<Widget>[
                Text('Suspected hardness ${_guess.toStringAsFixed(1)}'),
                Slider(
                  min: 1,
                  max: 10,
                  divisions: 90,
                  value: _guess,
                  onChanged: (v) => setState(() => _guess = v),
                ),
              ],
              TextField(
                controller: _context,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  alignLabelWithHint: true,
                  labelText: 'Terrain notes',
                  hintText: 'Grainy breccia spill, rusty halos near contact…',
                ),
              ),
              const SizedBox(height: 22),
              FilledButton(onPressed: _save, child: const Text('Save to vault')),
            ],
          ),
        );
      },
    );
  }
}
