import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_strings.dart';
import '../state/app_state.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dataProvider);
    final notes = [...data.notes]..sort((a, b) => a.pinned == b.pinned ? 0 : (a.pinned ? -1 : 1));
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text(context.t('notesHub'))),
        floatingActionButton: FloatingActionButton.extended(onPressed: () => _add(context, ref), icon: const Icon(Icons.add), label: Text(context.t('newNote'))),
        body: notes.isEmpty
            ? Center(child: Text(context.t('captureNotes')))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final note in notes)
                    Card(
                      child: ListTile(
                        leading: Icon(note.pinned ? Icons.push_pin : Icons.notes, color: note.pinned ? Colors.amber : null),
                        title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(note.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                        trailing: IconButton(onPressed: () => ref.read(dataProvider.notifier).toggleNotePin(note.id), icon: Icon(note.pinned ? Icons.bookmark : Icons.bookmark_border)),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final title = TextEditingController();
    final body = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.t('newNote')),
        content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: title, decoration: InputDecoration(labelText: context.t('noteTitle'))), TextField(controller: body, maxLines: 3, decoration: InputDecoration(labelText: context.t('noteBody')))]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(context.t('cancel'))),
          FilledButton(onPressed: () { if (title.text.trim().isNotEmpty) { ref.read(dataProvider.notifier).addNote(title.text.trim(), body.text.trim(), null); Navigator.pop(dialogContext, true); } }, child: Text(context.t('save'))),
        ],
      ),
    );
    if (result == true && context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('saved'))));
  }
}
