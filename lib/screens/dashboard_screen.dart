import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_strings.dart';
import '../state/app_state.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dataProvider);
    final notifier = ref.read(dataProvider.notifier);
    final completed = data.tasks.where((task) => task.done).length;
    final taskRate = data.tasks.isEmpty ? 0.0 : completed / data.tasks.length;
    final next = data.events.first;
    final subject = data.subjects.firstWhere((item) => item.id == next.subjectId);
    final attendance = (notifier.attendanceRate * 100).round();
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? context.t('goodMorning') : hour < 18 ? context.t('goodAfternoon') : context.t('goodEvening');
    final now = DateTime.now();
    final dateLabel = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(greeting, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                Text('${context.t('dateToday')} · $dateLabel'),
              ])),
              IconButton(onPressed: () => showSearch(context: context, delegate: GlobalSearch(ref)), icon: const Icon(Icons.search)),
            ],
          ),
          const SizedBox(height: 22),
          Card(
            color: Color(subject.color).withValues(alpha: .17),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(width: 5, height: 76, decoration: BoxDecoration(color: Color(subject.color), borderRadius: BorderRadius.circular(5))),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(context.t('nextUp'), style: const TextStyle(fontSize: 11, letterSpacing: 1.4)),
                    Text(next.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('${subject.name} · ${next.location}'),
                    Text('${_time(next.startMinutes)} – ${_time(next.endMinutes)}'),
                  ])),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(context.t('academicPulse'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 150,
                      child: PieChart(PieChartData(sections: [
                        PieChartSectionData(value: attendance.toDouble(), color: const Color(0xFF00D9FF), title: '$attendance%', radius: 54),
                        PieChartSectionData(value: (100 - attendance).toDouble(), color: Colors.white12, title: '', radius: 54),
                      ])),
                    ),
                  ),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(context.t('attendance')),
                    Text('$attendance%', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 12),
                    Text('$completed/${data.tasks.length} ${context.t('completed')}'),
                  ])),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text('${context.t('taskCompletion')} ${(taskRate * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: taskRate, minHeight: 9, borderRadius: BorderRadius.circular(8)),
          const SizedBox(height: 26),
          Text(context.t('quickActions'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
          const SizedBox(height: 10),
          Wrap(spacing: 10, runSpacing: 10, children: [
            _Quick(icon: Icons.fact_check, label: context.t('attendance')),
            _Quick(icon: Icons.timer_outlined, label: context.t('pomodoro')),
            _Quick(icon: Icons.event_note, label: context.t('examCountdown')),
            _Quick(icon: Icons.backup_outlined, label: context.t('backup')),
          ]),
          const SizedBox(height: 26),
          Text(context.t('tasks'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
          ...data.tasks.take(3).map((task) => Card(child: CheckboxListTile(value: task.done, onChanged: (_) => ref.read(dataProvider.notifier).toggleTask(task.id), title: Text(task.title, style: TextStyle(decoration: task.done ? TextDecoration.lineThrough : null)), subtitle: Text(task.priority.name.toUpperCase())))),
        ],
      ),
    );
  }

  static String _time(int minutes) => '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';
}

class _Quick extends StatelessWidget {
  const _Quick({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => SizedBox(width: 145, child: Card(child: Padding(padding: const EdgeInsets.all(15), child: Column(children: [Icon(icon, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 7), Text(label)]))));
}

class GlobalSearch extends SearchDelegate<void> {
  GlobalSearch(this.ref);
  final WidgetRef ref;
  @override List<Widget>? buildActions(BuildContext context) => [IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear))];
  @override Widget? buildLeading(BuildContext context) => BackButton(onPressed: () => close(context, null));
  @override Widget buildResults(BuildContext context) => _results(context);
  @override Widget buildSuggestions(BuildContext context) => _results(context);
  Widget _results(BuildContext context) { final results = ref.read(dataProvider.notifier).search(query); return ListView(children: [if (results.isEmpty) ListTile(title: Text(context.t('noResults'))) else for (final result in results) ListTile(leading: const Icon(Icons.search), title: Text(result))]); }
}
