import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_strings.dart';
import '../services/platform_services.dart';
import '../state/app_state.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final data = ref.watch(dataProvider);
    return SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [
      Text(context.t('more'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)), const SizedBox(height: 15),
      _item(context, Icons.bar_chart, context.t('attendanceAnalytics'), context.t('attendanceHint'), () => _showAnalytics(context, ref)),
      _item(context, Icons.repeat, context.t('habitTracker'), context.t('habitHint'), () => _showHabits(context, ref)),
      _item(context, Icons.timer, context.t('focusExam'), context.t('focusHint'), () => _showFocus(context)),
      const Divider(height: 32),
      Text(context.t('dataBackup'), style: const TextStyle(fontWeight: FontWeight.bold)),
      ListTile(leading: const Icon(Icons.upload_file), title: Text(context.t('exportBackup')), onTap: () async { await ExportService().shareBackup(data); if (context.mounted) _snack(context, context.t('exportReady')); }),
      ListTile(leading: const Icon(Icons.download), title: Text(context.t('importBackup')), onTap: () async { final backup = await ExportService().importBackup(); if (backup != null) { ref.read(dataProvider.notifier).restore(subjects: backup.subjects, events: backup.events, tasks: backup.tasks, notes: backup.notes, habits: backup.habits, attendance: backup.attendance); if (context.mounted) _snack(context, context.t('saved')); } }),
      const Divider(height: 32),
      Text(context.t('settings'), style: const TextStyle(fontWeight: FontWeight.bold)),
      SwitchListTile(value: settings.motivationEnabled, onChanged: (value) => ref.read(settingsProvider.notifier).update(settings.copyWith(motivationEnabled: value)), title: Text(context.t('motivation')), subtitle: Text(context.t('motivationHint'))),
      SwitchListTile(value: settings.autoMute, onChanged: (value) async { if (value) await NotificationService.instance.requestDndAccess(); ref.read(settingsProvider.notifier).update(settings.copyWith(autoMute: value)); }, title: Text(context.t('autoMute')), subtitle: Text(context.t('dndHint'))),
      ListTile(leading: const Icon(Icons.language), title: Text(context.t('language')), trailing: DropdownButton<String>(value: settings.locale.languageCode, items: [DropdownMenuItem(value: 'en', child: Text(context.t('english'))), DropdownMenuItem(value: 'ar', child: Text(context.t('arabic')))], onChanged: (value) { if (value != null) ref.read(settingsProvider.notifier).update(settings.copyWith(locale: Locale(value))); })),
      ListTile(leading: const Icon(Icons.brightness_6), title: Text(context.t('theme')), trailing: DropdownButton<ThemeMode>(value: settings.themeMode, items: [DropdownMenuItem(value: ThemeMode.system, child: Text(context.t('system'))), DropdownMenuItem(value: ThemeMode.light, child: Text(context.t('light'))), DropdownMenuItem(value: ThemeMode.dark, child: Text(context.t('dark')))], onChanged: (value) { if (value != null) ref.read(settingsProvider.notifier).update(settings.copyWith(themeMode: value)); })),
      ListTile(leading: const Icon(Icons.text_fields), title: Text(context.t('textSize')), subtitle: Slider(value: settings.textScale, min: .85, max: 1.3, divisions: 9, onChanged: (value) => ref.read(settingsProvider.notifier).update(settings.copyWith(textScale: value)))),
      const Divider(height: 32),
      Text(context.t('about'), style: const TextStyle(fontWeight: FontWeight.bold)),
      ListTile(title: Text(context.t('developed')), subtitle: Text('${context.t('linkedin')} · ${context.t('github')}'), onTap: () => _about(context)),
    ]));
  }
  Widget _item(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) => ListTile(leading: Icon(icon), title: Text(title), subtitle: Text(subtitle), trailing: const Icon(Icons.chevron_right), onTap: onTap);
  void _snack(BuildContext context, String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  void _showAnalytics(BuildContext context, WidgetRef ref) { final data = ref.read(dataProvider); final notifier = ref.read(dataProvider.notifier); showDialog<void>(context: context, builder: (_) => AlertDialog(title: Text(context.t('attendanceAnalytics')), content: Column(mainAxisSize: MainAxisSize.min, children: [ListTile(title: Text(context.t('attendance')), trailing: Text('${(notifier.attendanceRate * 100).round()}%')), ListTile(title: Text(context.t('taskCompletion')), trailing: Text('${(notifier.taskRate * 100).round()}%')), ListTile(title: Text(context.t('notes')), trailing: Text('${data.notes.length}'))]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(context.t('close')))])); }
  void _showHabits(BuildContext context, WidgetRef ref) { showDialog<void>(context: context, builder: (_) => Consumer(builder: (context, ref, child) { final habits = ref.watch(dataProvider).habits; return AlertDialog(title: Text(context.t('habitTracker')), content: SizedBox(width: double.maxFinite, child: ListView(shrinkWrap: true, children: [for (final habit in habits) CheckboxListTile(value: habit.completedToday, onChanged: (_) => ref.read(dataProvider.notifier).toggleHabit(habit.id), title: Text(habit.name), subtitle: Text(habit.frequency.name))])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(context.t('close')))]); })); }
  void _showFocus(BuildContext context) { var seconds = 25 * 60; Timer? timer; showDialog<void>(context: context, builder: (_) => StatefulBuilder(builder: (dialogContext, setState) => AlertDialog(title: Text(context.t('focusExam')), content: Column(mainAxisSize: MainAxisSize.min, children: [Text(context.t('focusHint')), const SizedBox(height: 18), Text('${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold))]), actions: [FilledButton(onPressed: () { timer?.cancel(); timer = Timer.periodic(const Duration(seconds: 1), (_) { if (seconds > 0) { setState(() => seconds--); } else { timer?.cancel(); } }); }, child: Text(context.t('start'))), TextButton(onPressed: () { timer?.cancel(); Navigator.pop(dialogContext); }, child: Text(context.t('close')))]))); }
  void _about(BuildContext context) => showAboutDialog(context: context, applicationName: 'Unimate', applicationVersion: '1.0.1', children: [Text(context.t('developed')), TextButton(onPressed: () => launchUrl(Uri.parse('https://www.linkedin.com/in/ahmed-alaa-897a633a8/'), mode: LaunchMode.externalApplication), child: Text(context.t('linkedin'))), TextButton(onPressed: () => launchUrl(Uri.parse('https://github.com/zaedvg3096432-droid'), mode: LaunchMode.externalApplication), child: Text(context.t('github')))]);
}
