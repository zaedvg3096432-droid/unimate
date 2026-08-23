import 'dart:convert';

enum WeekPattern { every, odd, even }
enum AttendanceStatus { present, absent, excused }
enum TaskPriority { low, medium, high }
enum Importance { normal, important, critical }
enum HabitFrequency { daily, weekly, interval }

T _enum<T extends Enum>(List<T> values, String? value, T fallback) => values.where((item) => item.name == value).firstOrNull ?? fallback;
extension<T> on Iterable<T> { T? get firstOrNull => isEmpty ? null : first; }

class Subject {
  const Subject({required this.id, required this.name, required this.color, this.instructor = '', this.maxAbsencePercent = 25});
  final String id, name; final int color; final String instructor; final double maxAbsencePercent;
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'color': color, 'instructor': instructor, 'maxAbsencePercent': maxAbsencePercent};
  factory Subject.fromJson(Map<String, dynamic> j) => Subject(id: j['id'] as String, name: j['name'] as String, color: j['color'] as int, instructor: (j['instructor'] ?? '') as String, maxAbsencePercent: ((j['maxAbsencePercent'] ?? 25) as num).toDouble());
}

class ClassEvent {
  const ClassEvent({required this.id, required this.subjectId, required this.title, required this.weekday, required this.startMinutes, required this.endMinutes, required this.location, this.instructor = '', this.weekPattern = WeekPattern.every, this.reminderMinutes = 15, this.isSection = false});
  final String id, subjectId, title, location, instructor; final int weekday, startMinutes, endMinutes, reminderMinutes; final WeekPattern weekPattern; final bool isSection;
  Map<String, dynamic> toJson() => {'id': id, 'subjectId': subjectId, 'title': title, 'weekday': weekday, 'startMinutes': startMinutes, 'endMinutes': endMinutes, 'location': location, 'instructor': instructor, 'weekPattern': weekPattern.name, 'reminderMinutes': reminderMinutes, 'isSection': isSection};
  factory ClassEvent.fromJson(Map<String, dynamic> j) => ClassEvent(id: j['id'] as String, subjectId: j['subjectId'] as String, title: j['title'] as String, weekday: j['weekday'] as int, startMinutes: j['startMinutes'] as int, endMinutes: j['endMinutes'] as int, location: j['location'] as String, instructor: (j['instructor'] ?? '') as String, weekPattern: _enum(WeekPattern.values, j['weekPattern'] as String?, WeekPattern.every), reminderMinutes: (j['reminderMinutes'] ?? 15) as int, isSection: (j['isSection'] ?? false) as bool);
}

class StudentTask {
  const StudentTask({required this.id, required this.title, required this.dueAt, this.subjectId, this.priority = TaskPriority.medium, this.done = false});
  final String id, title; final String? subjectId; final DateTime dueAt; final TaskPriority priority; final bool done;
  StudentTask copyWith({bool? done}) => StudentTask(id: id, title: title, dueAt: dueAt, subjectId: subjectId, priority: priority, done: done ?? this.done);
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'dueAt': dueAt.toIso8601String(), 'subjectId': subjectId, 'priority': priority.name, 'done': done};
  factory StudentTask.fromJson(Map<String, dynamic> j) => StudentTask(id: j['id'] as String, title: j['title'] as String, dueAt: DateTime.parse(j['dueAt'] as String), subjectId: j['subjectId'] as String?, priority: _enum(TaskPriority.values, j['priority'] as String?, TaskPriority.medium), done: (j['done'] ?? false) as bool);
}

class Note {
  const Note({required this.id, required this.title, required this.body, this.subjectId, this.importance = Importance.normal, this.pinned = false, this.tags = const [], this.attachments = const []});
  final String id, title, body; final String? subjectId; final Importance importance; final bool pinned; final List<String> tags, attachments;
  Note copyWith({String? title, String? body, bool? pinned}) => Note(id: id, title: title ?? this.title, body: body ?? this.body, subjectId: subjectId, importance: importance, pinned: pinned ?? this.pinned, tags: tags, attachments: attachments);
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'body': body, 'subjectId': subjectId, 'importance': importance.name, 'pinned': pinned, 'tags': tags, 'attachments': attachments};
  factory Note.fromJson(Map<String, dynamic> j) => Note(id: j['id'] as String, title: j['title'] as String, body: j['body'] as String, subjectId: j['subjectId'] as String?, importance: _enum(Importance.values, j['importance'] as String?, Importance.normal), pinned: (j['pinned'] ?? false) as bool, tags: List<String>.from(j['tags'] ?? const []), attachments: List<String>.from(j['attachments'] ?? const []));
}

class Habit {
  const Habit({required this.id, required this.name, required this.frequency, this.target = 1, this.intervalHours, this.weekdays = const [], this.completedToday = false});
  final String id, name; final HabitFrequency frequency; final int target; final int? intervalHours; final List<int> weekdays; final bool completedToday;
  Habit copyWith({bool? completedToday}) => Habit(id: id, name: name, frequency: frequency, target: target, intervalHours: intervalHours, weekdays: weekdays, completedToday: completedToday ?? this.completedToday);
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'frequency': frequency.name, 'target': target, 'intervalHours': intervalHours, 'weekdays': weekdays, 'completedToday': completedToday};
  factory Habit.fromJson(Map<String, dynamic> j) => Habit(id: j['id'] as String, name: j['name'] as String, frequency: _enum(HabitFrequency.values, j['frequency'] as String?, HabitFrequency.daily), target: (j['target'] ?? 1) as int, intervalHours: j['intervalHours'] as int?, weekdays: List<int>.from(j['weekdays'] ?? const []), completedToday: (j['completedToday'] ?? false) as bool);
}

class AttendanceRecord {
  const AttendanceRecord({required this.eventId, required this.date, required this.status});
  final String eventId; final DateTime date; final AttendanceStatus status;
  Map<String, dynamic> toJson() => {'eventId': eventId, 'date': date.toIso8601String(), 'status': status.name};
  factory AttendanceRecord.fromJson(Map<String, dynamic> j) => AttendanceRecord(eventId: j['eventId'] as String, date: DateTime.parse(j['date'] as String), status: _enum(AttendanceStatus.values, j['status'] as String?, AttendanceStatus.present));
}

String backupJson({required List<Subject> subjects, required List<ClassEvent> events, required List<StudentTask> tasks, required List<Note> notes, required List<Habit> habits, required List<AttendanceRecord> attendance}) => jsonEncode({'version': 2, 'subjects': subjects.map((x) => x.toJson()).toList(), 'events': events.map((x) => x.toJson()).toList(), 'tasks': tasks.map((x) => x.toJson()).toList(), 'notes': notes.map((x) => x.toJson()).toList(), 'habits': habits.map((x) => x.toJson()).toList(), 'attendance': attendance.map((x) => x.toJson()).toList()});
