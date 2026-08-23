import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_strings.dart';
import '../models/app_models.dart';
import '../state/app_state.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dataProvider);
    final notifier = ref.read(dataProvider.notifier);
    final percent = (notifier.attendanceRate * 100).round();
    final sections = <PieChartSectionData>[
      PieChartSectionData(value: percent.toDouble(), title: '$percent%', radius: 48, color: Colors.green),
      PieChartSectionData(value: (100 - percent).toDouble(), title: '', radius: 48, color: Theme.of(context).colorScheme.surfaceContainerHighest),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(context.t('attendance'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [SizedBox(width: 130, height: 130, child: PieChart(PieChartData(sections: sections))), const SizedBox(width: 16), Expanded(child: Text('${context.t('attendance')}\n$percent%', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)))]))),
          const SizedBox(height: 14),
          for (final event in data.events)
            Card(
              child: ListTile(
                title: Text('${notifier.subjectFor(event.subjectId).name} · ${event.title}'),
                subtitle: Text(event.location),
                trailing: PopupMenuButton<AttendanceStatus>(
                  onSelected: (value) => notifier.logAttendance(event.id, value),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: AttendanceStatus.present, child: Text(context.t('present'))),
                    PopupMenuItem(value: AttendanceStatus.absent, child: Text(context.t('absent'))),
                    PopupMenuItem(value: AttendanceStatus.excused, child: Text(context.t('excused'))),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(dataProvider).habits;
    return Scaffold(
      appBar: AppBar(title: Text(context.t('habitTracker'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final habit in habits)
            Card(
              child: CheckboxListTile(
                value: habit.completedToday,
                onChanged: (_) => ref.read(dataProvider.notifier).toggleHabit(habit.id),
                title: Text(habit.name),
                subtitle: Text('${habit.frequency.name} · target ${habit.target}'),
                secondary: Icon(habit.completedToday ? Icons.local_fire_department : Icons.repeat, color: habit.completedToday ? Colors.orange : null),
              ),
            ),
        ],
      ),
    );
  }
}

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(dataProvider.notifier);
    final groups = [
      BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: notifier.attendanceRate * 100, color: Colors.cyan, width: 22)]),
      BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: notifier.taskRate * 100, color: Colors.deepPurpleAccent, width: 22)]),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(context.t('attendanceAnalytics'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(child: Padding(padding: const EdgeInsets.all(18), child: SizedBox(height: 240, child: BarChart(BarChartData(barGroups: groups, maxY: 100, titlesData: const FlTitlesData(show: true)))))) ,
          ListTile(title: Text(context.t('attendance')), trailing: Text('${(notifier.attendanceRate * 100).round()}%')),
          ListTile(title: Text(context.t('taskCompletion')), trailing: Text('${(notifier.taskRate * 100).round()}%')),
        ],
      ),
    );
  }
}

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});
  @override State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  Timer? timer;
  int seconds = 25 * 60;
  bool running = false;

  @override
  void dispose() { timer?.cancel(); super.dispose(); }
  void toggle() { setState(() => running = !running); if (running) { timer = Timer.periodic(const Duration(seconds: 1), (_) { if (seconds == 0) { timer?.cancel(); setState(() => running = false); } else { setState(() => seconds--); } }); } else { timer?.cancel(); } }
  void reset() { timer?.cancel(); setState(() { seconds = 25 * 60; running = false; }); }

  @override
  Widget build(BuildContext context) {
    final progress = 1 - seconds / (25 * 60);
    final time = '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
    return Scaffold(
      appBar: AppBar(title: Text(context.t('focus'))),
      body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(width: 240, height: 240, child: Stack(alignment: Alignment.center, children: [CircularProgressIndicator(value: progress, strokeWidth: 12, color: Theme.of(context).colorScheme.primary), Text(time, style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold))])),
        const SizedBox(height: 28),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [FilledButton.icon(onPressed: toggle, icon: Icon(running ? Icons.pause : Icons.play_arrow), label: Text(running ? context.t('pause') : context.t('start'))), const SizedBox(width: 12), OutlinedButton.icon(onPressed: reset, icon: const Icon(Icons.restart_alt), label: Text(context.t('reset')))]),
      ]))),
    );
  }
}
