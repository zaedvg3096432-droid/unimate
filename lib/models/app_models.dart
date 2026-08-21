import 'dart:convert';

enum WeekPattern { every, odd, even }
enum AttendanceStatus { present, absent, excused }
enum TaskPriority { low, medium, high }
enum Importance { normal, important, critical }
enum HabitFrequency { daily, weekly, interval }

class Subject {
  const Subject({required this.id, required this.name, required this.color, this.instructor = '', this.maxAbsencePercent = 25});
  final String id;
  final String name;
  final int color;
  final String instructor;
  final double maxAbsencePercent;
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'color': color, 'instructor': instructor, 'maxAbsencePercent': maxAbsencePercent};
  factory Subject.fromJson(Map<String, dynamic> j) => Subject(id: j['id'], name: j['name'], color: j['color'], instructor: j['instructor'] ?? '', maxAbsencePercent: (j['maxAbsencePercent'] ?? 25).toDouble());
}

class ClassEvent {
  const ClassEvent({required this.id, required this.subjectId, required this.title, required this.weekday, required this.startMinutes, required this.endMinutes, required this.location, this.instructor = '', this.weekPattern = WeekPattern.every, this.reminderMinutes = 15, this.isSection = false});
  final String id, subjectId, title, location, instructor;
  final int weekday, startMinutes, endMinutes, reminderMinutes;
  final WeekPattern weekPattern;
  final bool isSection;
  Map<String, dynamic> toJson() => {'id': id, 'subjectId': subjectId, 'title': title, 'weekday': weekday, 'startMinutes': startMinutes, 'endMinutes': endMinutes, 'location': location, 'instructor': instructor, 'weekPattern': weekPattern.name, 'reminderMinutes': reminderMinutes, 'isSection': isSection};
  factory ClassEvent.fromJson(Map<String, dynamic> j) => ClassEvent(id: j['id'], subjectId: j['subjectId'], title: j['title'], weekday: j['weekday'], startMinutes: j['startMinutes'], endMinutes: j['endMinutes'], location: j['location'], instructor: j['instructor'] ?? '', weekPattern: WeekPattern.values.byName(j['weekPattern'] ?? 'every'), reminderMinutes: j['reminderMinutes'] ?? 15, isSection: j['isSection'] ?? false);
}

class StudentTask {
  const StudentTask({required this.id, required this.title, required this.dueAt, this.subjectId, this.priority = TaskPriority.medium, this.done = false});
  final String id, title;
  final String? subjectId;
  final DateTime dueAt;
  final TaskPriority priority;
  final bool done;
  StudentTask copyWith({bool? done}) => StudentTask(id: id, title: title, dueAt: dueAt, subjectId: subjectId, priority: priority, done: done ?? this.done);
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'dueAt': dueAt.toIso8601String(), 'subjectId': subjectId, 'priority': priority.name, 'done': done};
  factory StudentTask.fromJson(Map<String, dynamic> j) => StudentTask(id: j['id'], title: j['title'], dueAt: DateTime.parse(j['dueAt']), subjectId: j['subjectId'], priority: TaskPriority.values.byName(j['priority'] ?? 'medium'), done: j['done'] ?? false);
}

class Note {
  const Note({required this.id, required this.title, required this.body, this.subjectId, this.importance = Importance.normal, this.pinned = false, this.tags = const [], this.attachments = const []});
  final String id, title, body;
  final String? subjectId;
  final Importance importance;
  final bool pinned;
  final List<String> tags, attachments;
}

class Habit {
  const Habit({required this.id, required this.name, required this.frequency, this.target = 1, this.intervalHours, this.weekdays = const []});
  final String id, name;
  final HabitFrequency frequency;
  final int target;
  final int? intervalHours;
  final List<int> weekdays;
}

class AttendanceRecord {
  const AttendanceRecord({required this.eventId, required this.date, required this.status});
  final String eventId;
  final DateTime date;
  final AttendanceStatus status;
}

String backupJson(List<Subject> subjects, List<ClassEvent> events, List<StudentTask> tasks) => jsonEncode({'version': 1, 'subjects': subjects.map((x) => x.toJson()).toList(), 'events': events.map((x) => x.toJson()).toList(), 'tasks': tasks.map((x) => x.toJson()).toList()});

