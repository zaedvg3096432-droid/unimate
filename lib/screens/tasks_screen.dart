import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_models.dart';
import '../state/app_state.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dataProvider);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Tasks & appointments')),
        floatingActionButton: FloatingActionButton.extended(onPressed: () => _add(context, ref), icon: const Icon(Icons.add), label: const Text('Add task')),
        body: data.tasks.isEmpty
            ? const Center(child: Text('No tasks yet — plan your next win.'))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [for (final task in data.tasks) Card(child: CheckboxListTile(value: task.done, onChanged: (_) => ref.read(dataProvider.notifier).toggleTask(task.id), title: Text(task.title, style: TextStyle(decoration: task.done ? TextDecoration.lineThrough : null)), subtitle: Text('${task.priority.name.toUpperCase()} • ${task.dueAt}'), secondary: Icon(Icons.flag, color: task.priority == TaskPriority.high ? Colors.red : Colors.amber)))],
              ),
      ),
    );
  }

  void _add(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(sheetContext).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: 'Task title')),
          const SizedBox(height: 18),
          FilledButton(onPressed: () { if (controller.text.trim().isNotEmpty) ref.read(dataProvider.notifier).addTask(controller.text.trim(), DateTime.now().add(const Duration(days: 1)), TaskPriority.medium, null); Navigator.pop(sheetContext); }, child: const Text('Save')),
        ]),
      ),
    );
  }
}
