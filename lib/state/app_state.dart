import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/app_models.dart';

const _uuid = Uuid();
const subjectPalette = <int>[0xFF00E5FF, 0xFF7C4DFF, 0xFFFF4081, 0xFFFF6E40, 0xFFFFD740, 0xFF69F0AE, 0xFF40C4FF, 0xFFB2FF59, 0xFFEA80FC, 0xFFFF8A80, 0xFF84FFFF, 0xFFA7FFEB, 0xFFCCFF90, 0xFF8C9EFF, 0xFFFF9E80, 0xFFE040FB];

class AppSettings {
  const AppSettings({this.themeMode = ThemeMode.dark, this.locale = const Locale('en'), this.textScale = 1, this.motivationEnabled = true, this.motivationFrequency = 1, this.autoMute = false});
  final ThemeMode themeMode; final Locale locale; final double textScale; final bool motivationEnabled, autoMute; final int motivationFrequency;
  AppSettings copyWith({ThemeMode? themeMode, Locale? locale, double? textScale, bool? motivationEnabled, int? motivationFrequency, bool? autoMute}) => AppSettings(themeMode: themeMode ?? this.themeMode, locale: locale ?? this.locale, textScale: textScale ?? this.textScale, motivationEnabled: motivationEnabled ?? this.motivationEnabled, motivationFrequency: motivationFrequency ?? this.motivationFrequency, autoMute: autoMute ?? this.autoMute);
  Map<String, dynamic> toJson() => {'themeMode': themeMode.name, 'locale': locale.languageCode, 'textScale': textScale, 'motivationEnabled': motivationEnabled, 'motivationFrequency': motivationFrequency, 'autoMute': autoMute};
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) { _load(); }
  Future<void> _load() async { final prefs = await SharedPreferences.getInstance(); state = state.copyWith(themeMode: ThemeMode.values.firstWhere((m) => m.name == (prefs.getString('themeMode') ?? 'dark'), orElse: () => ThemeMode.dark), locale: Locale(prefs.getString('locale') ?? 'en'), textScale: prefs.getDouble('textScale') ?? 1, motivationEnabled: prefs.getBool('motivationEnabled') ?? true, motivationFrequency: prefs.getInt('motivationFrequency') ?? 1, autoMute: prefs.getBool('autoMute') ?? false); }
  void update(AppSettings value) { state = value; _save(value); }
  Future<void> _save(AppSettings value) async { final prefs = await SharedPreferences.getInstance(); await prefs.setString('themeMode', value.themeMode.name); await prefs.setString('locale', value.locale.languageCode); await prefs.setDouble('textScale', value.textScale); await prefs.setBool('motivationEnabled', value.motivationEnabled); await prefs.setInt('motivationFrequency', value.motivationFrequency); await prefs.setBool('autoMute', value.autoMute); }
}
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((_) => SettingsNotifier());

class DataState {
  const DataState({required this.subjects, required this.events, required this.tasks, required this.notes, required this.habits, required this.attendance});
  final List<Subject> subjects; final List<ClassEvent> events; final List<StudentTask> tasks; final List<Note> notes; final List<Habit> habits; final List<AttendanceRecord> attendance;
  DataState copyWith({List<Subject>? subjects, List<ClassEvent>? events, List<StudentTask>? tasks, List<Note>? notes, List<Habit>? habits, List<AttendanceRecord>? attendance}) => DataState(subjects: subjects ?? this.subjects, events: events ?? this.events, tasks: tasks ?? this.tasks, notes: notes ?? this.notes, habits: habits ?? this.habits, attendance: attendance ?? this.attendance);
}

class DataNotifier extends StateNotifier<DataState> {
  DataNotifier() : super(_seed()) { _load(); }
  static DataState _seed() => DataState(
        subjects: const [Subject(id: 's1', name: 'Mobile Development', color: 0xFF00E5FF, instructor: 'Dr. Ahmed'), Subject(id: 's2', name: 'Algorithms', color: 0xFF7C4DFF, instructor: 'Dr. Sara')],
        events: const [ClassEvent(id: 'e1', subjectId: 's1', title: 'Flutter Lecture', weekday: 1, startMinutes: 600, endMinutes: 690, location: 'Hall A', instructor: 'Dr. Ahmed'), ClassEvent(id: 'e2', subjectId: 's2', title: 'Algorithms Section', weekday: 2, startMinutes: 720, endMinutes: 810, location: 'Lab 2', instructor: 'Dr. Sara', isSection: true, weekPattern: WeekPattern.odd)],
        tasks: const [StudentTask(id: 't1', title: 'Prepare the mobile UX wireframes', dueAt: _datePlusOne, subjectId: 's1', priority: TaskPriority.high)],
        notes: const [Note(id: 'n1', title: 'Algorithms revision map', body: 'Review algorithms, proofs, and recurrence relations.', subjectId: 's2', pinned: true, tags: ['exam', 'priority']), Note(id: 'n2', title: 'Flutter architecture', body: 'Keep UI, state, and services separated for maintainability.', subjectId: 's1', tags: ['flutter'])],
        habits: const [Habit(id: 'h1', name: 'Read lecture notes', frequency: HabitFrequency.daily, target: 1), Habit(id: 'h2', name: 'Practice coding', frequency: HabitFrequency.weekly, weekdays: [1, 3, 6])],
        attendance: const [],
      );
  static const DateTime _datePlusOne = DateTime(2030, 1, 2);

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('unimate_data');
    if (raw == null) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      state = DataState(subjects: _subjects(map['subjects']), events: _events(map['events']), tasks: _tasks(map['tasks']), notes: _notes(map['notes']), habits: _habits(map['habits']), attendance: _attendance(map['attendance']));
    } catch (_) {}
  }
  List<Subject> _subjects(dynamic value) => value is List ? value.map((x) => Subject.fromJson(Map<String, dynamic>.from(x))).toList() : state.subjects;
  List<ClassEvent> _events(dynamic value) => value is List ? value.map((x) => ClassEvent.fromJson(Map<String, dynamic>.from(x))).toList() : state.events;
  List<StudentTask> _tasks(dynamic value) => value is List ? value.map((x) => StudentTask.fromJson(Map<String, dynamic>.from(x))).toList() : state.tasks;
  List<Note> _notes(dynamic value) => value is List ? value.map((x) => Note.fromJson(Map<String, dynamic>.from(x))).toList() : state.notes;
  List<Habit> _habits(dynamic value) => value is List ? value.map((x) => Habit.fromJson(Map<String, dynamic>.from(x))).toList() : state.habits;
  List<AttendanceRecord> _attendance(dynamic value) => value is List ? value.map((x) => AttendanceRecord.fromJson(Map<String, dynamic>.from(x))).toList() : state.attendance;
  void _commit(DataState next) { state = next; _save(); }
  Future<void> _save() async { final prefs = await SharedPreferences.getInstance(); await prefs.setString('unimate_data', backupJson(subjects: state.subjects, events: state.events, tasks: state.tasks, notes: state.notes, habits: state.habits, attendance: state.attendance)); }

  Subject subjectFor(String id) => state.subjects.firstWhere((s) => s.id == id, orElse: () => state.subjects.first);
  ClassEvent? eventFor(String id) => state.events.where((e) => e.id == id).firstOrNull;
  double get attendanceRate { final counted = state.attendance.where((r) => r.status != AttendanceStatus.excused).toList(); return counted.isEmpty ? 1 : counted.where((r) => r.status == AttendanceStatus.present).length / counted.length; }
  int get completedTasks => state.tasks.where((t) => t.done).length;
  double get taskRate => state.tasks.isEmpty ? 0 : completedTasks / state.tasks.length;
  List<String> search(String query) { final q = query.trim().toLowerCase(); if (q.isEmpty) return const []; return [...state.subjects.map((s) => '${s.name} · ${s.instructor}'), ...state.events.map((e) => e.title), ...state.tasks.map((t) => t.title), ...state.notes.map((n) => n.title)].where((x) => x.toLowerCase().contains(q)).toList(); }
  void addTask(String title, DateTime due, TaskPriority priority, String? subjectId) => _commit(state.copyWith(tasks: [...state.tasks, StudentTask(id: _uuid.v4(), title: title, dueAt: due, priority: priority, subjectId: subjectId)]));
  void addEvent({required String subjectId, required String title, required String location, required int weekday, required int startMinutes, required int endMinutes}) => _commit(state.copyWith(events: [...state.events, ClassEvent(id: _uuid.v4(), subjectId: subjectId, title: title, location: location, weekday: weekday, startMinutes: startMinutes, endMinutes: endMinutes)]));
  void toggleTask(String id) => _commit(state.copyWith(tasks: [for (final t in state.tasks) t.id == id ? t.copyWith(done: !t.done) : t]));
  void addNote(String title, String body, String? subjectId) => _commit(state.copyWith(notes: [Note(id: _uuid.v4(), title: title, body: body, subjectId: subjectId), ...state.notes]));
  void toggleNotePin(String id) => _commit(state.copyWith(notes: [for (final n in state.notes) n.id == id ? n.copyWith(pinned: !n.pinned) : n]));
  void toggleHabit(String id) => _commit(state.copyWith(habits: [for (final h in state.habits) h.id == id ? h.copyWith(completedToday: !h.completedToday) : h]));
  void logAttendance(String eventId, AttendanceStatus status) => _commit(state.copyWith(attendance: [...state.attendance.where((r) => !(r.eventId == eventId && _sameDay(r.date, DateTime.now()))), AttendanceRecord(eventId: eventId, date: DateTime.now(), status: status)]));
  void restore({required List<Subject> subjects, required List<ClassEvent> events, required List<StudentTask> tasks, List<Note>? notes, List<Habit>? habits, List<AttendanceRecord>? attendance}) => _commit(state.copyWith(subjects: subjects, events: events, tasks: tasks, notes: notes ?? state.notes, habits: habits ?? state.habits, attendance: attendance ?? state.attendance));
  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
final dataProvider = StateNotifierProvider<DataNotifier, DataState>((_) => DataNotifier());
