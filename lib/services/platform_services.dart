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

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();
  final _plugin = notifications.FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await _plugin.initialize(const notifications.InitializationSettings(android: notifications.AndroidInitializationSettings('@drawable/ic_launcher'), iOS: notifications.DarwinInitializationSettings()));
    if (Platform.isAndroid) await Permission.notification.request();
  }

  Future<void> showMotivation(String message) => _plugin.show(901, 'Unimate', message, const notifications.NotificationDetails(android: notifications.AndroidNotificationDetails('motivation', 'Daily motivation', channelDescription: 'Private daily motivation', importance: notifications.Importance.defaultImportance)));
  Future<void> requestDndAccess() async { if (Platform.isAndroid) await openAppSettings(); }
}

class ExportService {
  Future<void> sharePng(Uint8List bytes) async { final dir = await getTemporaryDirectory(); final file = File('${dir.path}/unimate_schedule.png'); await file.writeAsBytes(bytes); await Share.shareXFiles([XFile(file.path)], text: 'My Unimate schedule'); }
  Future<void> sharePdf(Uint8List imageBytes) async { final doc = pw.Document(); final image = pw.MemoryImage(imageBytes); doc.addPage(pw.Page(pageFormat: PdfPageFormat.a4.landscape, build: (_) => pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)))); final dir = await getTemporaryDirectory(); final file = File('${dir.path}/unimate_schedule.pdf'); await file.writeAsBytes(await doc.save()); await Share.shareXFiles([XFile(file.path)], text: 'My Unimate schedule'); }
  Future<void> shareBackup(List<Subject> subjects, List<ClassEvent> events, List<StudentTask> tasks) async { final dir = await getTemporaryDirectory(); final file = File('${dir.path}/unimate_backup.json'); await file.writeAsString(backupJson(subjects, events, tasks)); await Share.shareXFiles([XFile(file.path)], text: 'Unimate backup'); }
  Future<({List<Subject> subjects, List<ClassEvent> events, List<StudentTask> tasks})?> importBackup() async { final pick = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']); if (pick?.files.single.path == null) return null; final raw = jsonDecode(await File(pick!.files.single.path!).readAsString()) as Map<String, dynamic>; return (subjects: (raw['subjects'] as List).map((x) => Subject.fromJson(x as Map<String, dynamic>)).toList(), events: (raw['events'] as List).map((x) => ClassEvent.fromJson(x as Map<String, dynamic>)).toList(), tasks: (raw['tasks'] as List).map((x) => StudentTask.fromJson(x as Map<String, dynamic>)).toList()); }
}
