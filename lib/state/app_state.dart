import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/app_models.dart';

const _uuid = Uuid();
const subjectPalette = <int>[0xFF00E5FF, 0xFF7C4DFF, 0xFFFF4081, 0xFFFF6E40, 0xFFFFD740, 0xFF69F0AE, 0xFF40C4FF, 0xFFB2FF59, 0xFFEA80FC, 0xFFFF8A80, 0xFF84FFFF, 0xFFA7FFEB, 0xFFCCFF90, 0xFF8C9EFF, 0xFFFF9E80, 0xFFE040FB];

class AppSettings {
  const AppSettings({this.themeMode = ThemeMode.dark, this.locale = const Locale('en'), this.textScale = 1, this.motivationEnabled = true, this.motivationFrequency = 1, this.autoMute = false});
  final ThemeMode themeMode;
  final Locale locale;
  final double textScale;
  final bool motivationEnabled, autoMute;
  final int motivationFrequency;
  AppSettings copyWith({ThemeMode? themeMode, Locale? locale, double? textScale, bool? motivationEnabled, int? motivationFrequency, bool? autoMute}) => AppSettings(themeMode: themeMode ?? this.themeMode, locale: locale ?? this.locale, textScale: textScale ?? this.textScale, motivationEnabled: motivationEnabled ?? this.motivationEnabled, motivationFrequency: motivationFrequency ?? this.motivationFrequency, autoMute: autoMute ?? this.autoMute);
}
class SettingsNotifier extends StateNotifier<AppSettings> { SettingsNotifier(): super(const AppSettings()); void update(AppSettings value) => state = value; }
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((_) => SettingsNotifier());

class DataState { const DataState({required this.subjects, required this.events, required this.tasks, required this.notes, required this.habits, required this.attendance}); final List<Subject> subjects; final List<ClassEvent> events; final List<StudentTask> tasks; final List<Note> notes; final List<Habit> habits; final List<AttendanceRecord> attendance;
  DataState copyWith({List<Subject>? subjects, List<ClassEvent>? events, List<StudentTask>? tasks, List<Note>? notes, List<Habit>? habits, List<AttendanceRecord>? attendance}) => DataState(subjects: subjects ?? this.subjects, events: events ?? this.events, tasks: tasks ?? this.tasks, notes: notes ?? this.notes, habits: habits ?? this.habits, attendance: attendance ?? this.attendance);
}
class DataNotifier extends StateNotifier<DataState> { DataNotifier(): super(DataState(subjects: const [Subject(id: 's1', name: 'Mobile Development', color: 0xFF00E5FF, instructor: 'Dr. Ahmed'), Subject(id: 's2', name: 'Algorithms', color: 0xFF7C4DFF, instructor: 'Dr. Sara')], events: const [ClassEvent(id: 'e1', subjectId: 's1', title: 'Flutter Lecture', weekday: 1, startMinutes: 600, endMinutes: 690, location: 'Hall A', instructor: 'Dr. Ahmed'), ClassEvent(id: 'e2', subjectId: 's2', title: 'Algorithms Section', weekday: 2, startMinutes: 720, endMinutes: 810, location: 'Lab 2', isSection: true)], tasks: const [], notes: const [], habits: const [], attendance: const []));
 void addTask(String title, DateTime due, TaskPriority priority, String? subjectId) { final t = StudentTask(id: _uuid.v4(), title: title, dueAt: due, priority: priority, subjectId: subjectId); state = state.copyWith(tasks: [...state.tasks, t]); }
 void toggleTask(String id) => state = state.copyWith(tasks: [for (final t in state.tasks) t.id == id ? t.copyWith(done: !t.done) : t]);
 void logAttendance(String eventId, AttendanceStatus status) => state = state.copyWith(attendance: [...state.attendance.where((r) => !(r.eventId == eventId && _sameDay(r.date, DateTime.now()))), AttendanceRecord(eventId: eventId, date: DateTime.now(), status: status)]);
 void restore({required List<Subject> subjects, required List<ClassEvent> events, required List<StudentTask> tasks}) => state = state.copyWith(subjects: subjects, events: events, tasks: tasks);
 bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
final dataProvider = StateNotifierProvider<DataNotifier, DataState>((_) => DataNotifier());

