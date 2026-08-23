import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_state.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dataProvider);
    final done = data.tasks.where((task) => task.done).length;
    final ratio = data.tasks.isEmpty ? 0.0 : done / data.tasks.length;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(children: [
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Good morning, Ahmed', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              Text('Make today count.'),
            ])),
            IconButton(onPressed: () => showSearch(context: context, delegate: GlobalSearch(ref)), icon: const Icon(Icons.search)),
          ]),
          const SizedBox(height: 22),
          _NextClassCard(data: data),
          const SizedBox(height: 22),
          const Text('Academic pulse', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(children: [
                Expanded(child: SizedBox(height: 155, child: PieChart(PieChartData(sections: [
                  PieChartSectionData(value: 86, color: const Color(0xFF00D9FF), title: '86%', radius: 54),
                  PieChartSectionData(value: 14, color: Colors.white12, title: '', radius: 54),
                ])))),
                Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Attendance'),
                  Text('86%', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  Text('Tasks completed: $done/${data.tasks.length}'),
                ])),
              ]),
            ),
          ),
          const SizedBox(height: 18),
          Text('Task completion ${(ratio * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: ratio, minHeight: 9, borderRadius: BorderRadius.circular(8)),
          const SizedBox(height: 26),
          const Text('Quick actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
          const SizedBox(height: 10),
          Wrap(spacing: 10, runSpacing: 10, children: const [
            _Quick(icon: Icons.fact_check, label: 'Attendance'),
            _Quick(icon: Icons.timer_outlined, label: 'Pomodoro'),
            _Quick(icon: Icons.event_note, label: 'Exam countdown'),
            _Quick(icon: Icons.backup_outlined, label: 'Backup'),
          ]),
        ],
      ),
    );
  }
}

class _NextClassCard extends StatelessWidget {
  const _NextClassCard({required this.data});
  final DataState data;

  @override
  Widget build(BuildContext context) {
    final event = data.events.first;
    final subject = data.subjects.firstWhere((item) => item.id == event.subjectId);
    return Card(
      color: Color(subject.color).withValues(alpha: .17),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(children: [
          Container(width: 5, height: 72, decoration: BoxDecoration(color: Color(subject.color), borderRadius: BorderRadius.circular(5))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('NEXT UP', style: TextStyle(fontSize: 11, letterSpacing: 1.4)),
            Text(event.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('${event.location} • 10:00 – 11:30'),
          ])),
          const Icon(Icons.arrow_forward),
        ]),
      ),
    );
  }
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
  @override Widget buildResults(BuildContext context) => _results();
  @override Widget buildSuggestions(BuildContext context) => _results();
  Widget _results() {
    final data = ref.read(dataProvider);
    final q = query.toLowerCase();
    final results = [...data.subjects.map((s) => '${s.name} • ${s.instructor}'), ...data.tasks.map((t) => t.title), ...data.notes.map((n) => n.title)].where((x) => x.toLowerCase().contains(q));
    return ListView(children: [for (final result in results) ListTile(leading: const Icon(Icons.search), title: Text(result))]);
  }
}
