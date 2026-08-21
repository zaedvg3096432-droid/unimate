import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_models.dart';
import '../state/app_state.dart';

class TasksScreen extends ConsumerWidget { const TasksScreen({super.key}); @override Widget build(BuildContext context, WidgetRef ref) { final d = ref.watch(dataProvider); return SafeArea(child: Scaffold(appBar: AppBar(title: const Text('Tasks & appointments')), floatingActionButton: FloatingActionButton.extended(onPressed: () => _add(context, ref), icon: const Icon(Icons.add), label: const Text('Add task')), body: d.tasks.isEmpty ? const Center(child: Text('No tasks yet — plan your next win.')) : ListView(padding: const EdgeInsets.all(16), children: [for (final t in d.tasks) Card(child: CheckboxListTile(value: t.done, onChanged: (_) => ref.read(dataProvider.notifier).toggleTask(t.id), title: Text(t.title), subtitle: Text('${t.priority.name.toUpperCase()} • ${t.dueAt}'), secondary: Icon(Icons.flag, color: t.priority == TaskPriority.high ? Colors.red : Colors.amber))]))); }
 void _add(BuildContext context, WidgetRef ref) { final ctrl = TextEditingController(); showModalBottomSheet(context: context, isScrollControlled: true, builder: (c) => Padding(padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(c).viewInsets.bottom + 20), child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: ctrl, autofocus: true, decoration: const InputDecoration(labelText: 'Task title')), const SizedBox(height: 18), FilledButton(onPressed: () { if (ctrl.text.trim().isNotEmpty) ref.read(dataProvider.notifier).addTask(ctrl.text.trim(), DateTime.now().add(const Duration(days: 1)), TaskPriority.medium, null); Navigator.pop(c); }, child: const Text('Save'))]))); }
}

