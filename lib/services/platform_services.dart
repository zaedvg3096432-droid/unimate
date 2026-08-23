import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as notifications;
import '../models/app_models.dart';
import '../state/app_state.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();
  final _plugin = notifications.FlutterLocalNotificationsPlugin();
  Future<void> initialize() async { await _plugin.initialize(const notifications.InitializationSettings(android: notifications.AndroidInitializationSettings('@drawable/ic_launcher'), iOS: notifications.DarwinInitializationSettings())); if (Platform.isAndroid) await Permission.notification.request(); }
  Future<void> showMotivation(String message) => _plugin.show(901, 'Unimate', message, const notifications.NotificationDetails(android: notifications.AndroidNotificationDetails('motivation', 'Daily motivation', channelDescription: 'Private daily motivation', importance: notifications.Importance.defaultImportance)));
  Future<void> requestDndAccess() async { if (Platform.isAndroid) await openAppSettings(); }
}

class ExportService {
  Future<void> sharePng(Uint8List bytes) async { final dir = await getTemporaryDirectory(); final file = File('${dir.path}/unimate_schedule.png'); await file.writeAsBytes(bytes); await Share.shareXFiles([XFile(file.path)], text: 'My Unimate schedule'); }
  Future<void> sharePdf(Uint8List imageBytes) async { final doc = pw.Document(); final image = pw.MemoryImage(imageBytes); doc.addPage(pw.Page(pageFormat: PdfPageFormat.a4.landscape, build: (_) => pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)))); final dir = await getTemporaryDirectory(); final file = File('${dir.path}/unimate_schedule.pdf'); await file.writeAsBytes(await doc.save()); await Share.shareXFiles([XFile(file.path)], text: 'My Unimate schedule'); }
  Future<void> shareBackup(DataState data) async { final dir = await getTemporaryDirectory(); final file = File('${dir.path}/unimate_backup.json'); await file.writeAsString(backupJson(subjects: data.subjects, events: data.events, tasks: data.tasks, notes: data.notes, habits: data.habits, attendance: data.attendance)); await Share.shareXFiles([XFile(file.path)], text: 'Unimate backup'); }
  Future<({List<Subject> subjects, List<ClassEvent> events, List<StudentTask> tasks, List<Note> notes, List<Habit> habits, List<AttendanceRecord> attendance})?> importBackup() async { final pick = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']); final path = pick?.files.single.path; if (path == null) return null; final raw = jsonDecode(await File(path).readAsString()) as Map<String, dynamic>; return (subjects: _list(raw['subjects'], Subject.fromJson), events: _list(raw['events'], ClassEvent.fromJson), tasks: _list(raw['tasks'], StudentTask.fromJson), notes: _list(raw['notes'], Note.fromJson), habits: _list(raw['habits'], Habit.fromJson), attendance: _list(raw['attendance'], AttendanceRecord.fromJson)); }
  List<T> _list<T>(dynamic value, T Function(Map<String, dynamic>) parser) => value is List ? value.map((item) => parser(Map<String, dynamic>.from(item))).toList() : <T>[];
}
