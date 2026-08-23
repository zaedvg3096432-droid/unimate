import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_strings.dart';
import '../models/app_models.dart';
import '../state/app_state.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dataProvider);
    final tasks = [...data.tasks]..sort((a, b) => a.done == b.done ? a.dueAt.compareTo(b.dueAt) : (a.done ? 1 : -1));
    return SafeArea(child: Scaffold(appBar: AppBar(title: Text(context.t('tasksAppointments'))), floatingActionButton: FloatingActionButton.extended(onPressed: () => _add(context, ref), icon: const Icon(Icons.add), label: Text(context.t('addTask'))), body: tasks.isEmpty ? Center(child: Text(context.t('noTasks'))) : ListView(padding: const EdgeInsets.all(16), children: [for (final task in tasks) Card(child: CheckboxListTile(value: task.done, onChanged: (_) => ref.read(dataProvider.notifier).toggleTask(task.id), title: Text(task.title, style: TextStyle(decoration: task.done ? TextDecoration.lineThrough : null, fontWeight: FontWeight.w600)), subtitle: Text('${task.priority.name.toUpperCase()} · ${_date(task.dueAt)}'), secondary: Icon(Icons.flag, color: task.priority == TaskPriority.high ? Colors.red : Colors.amber)))])));
  }
  Future<void> _add(BuildContext context, WidgetRef ref) async { final controller = TextEditingController(); final result = await showModalBottomSheet<bool>(context: context, isScrollControlled: true, builder: (sheetContext) => Padding(padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(sheetContext).viewInsets.bottom + 20), child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: controller, autofocus: true, decoration: InputDecoration(labelText: context.t('taskTitle'))), const SizedBox(height: 18), Row(children: [Expanded(child: FilledButton(onPressed: () { if (controller.text.trim().isNotEmpty) { ref.read(dataProvider.notifier).addTask(controller.text.trim(), DateTime.now().add(const Duration(days: 1)), TaskPriority.medium, null); Navigator.pop(sheetContext, true); } }, child: Text(context.t('save')))), const SizedBox(width: 10), TextButton(onPressed: () => Navigator.pop(sheetContext, false), child: Text(context.t('cancel')))])]))); if (result == true && context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t('saved')))); }
  String _date(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
}
