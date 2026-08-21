import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_state.dart';

class NotesScreen extends ConsumerWidget { const NotesScreen({super.key}); @override Widget build(BuildContext context, WidgetRef ref) { final notes = ref.watch(dataProvider).notes; return SafeArea(child: Scaffold(appBar: AppBar(title: const Text('Notes hub'), actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list))]), floatingActionButton: FloatingActionButton.extended(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('New note')), body: notes.isEmpty ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.edit_note, size: 52), SizedBox(height: 12), Text('Capture ideas, slides, images, and audio notes.')])) : ListView(children: []))); }
}

