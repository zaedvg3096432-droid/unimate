import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/platform_services.dart';
import 'state/app_state.dart';
import 'widgets/unimate_shell.dart';

Future<void> main() async { WidgetsFlutterBinding.ensureInitialized(); await NotificationService.instance.initialize(); runApp(const ProviderScope(child: UnimateApp())); }
class UnimateApp extends ConsumerWidget { const UnimateApp({super.key});
 @override Widget build(BuildContext context, WidgetRef ref) { final s = ref.watch(settingsProvider); return MaterialApp(title: 'Unimate', debugShowCheckedModeBanner: false, locale: s.locale, supportedLocales: const [Locale('en'), Locale('ar')], localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate], themeMode: s.themeMode, theme: _theme(Brightness.light), darkTheme: _theme(Brightness.dark), builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(s.textScale)), child: Directionality(textDirection: s.locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr, child: child!)), home: const SplashScreen()); }
 ThemeData _theme(Brightness b) { final isDark = b == Brightness.dark; final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF00D9FF), brightness: b); return ThemeData(useMaterial3: true, colorScheme: scheme, brightness: b, scaffoldBackgroundColor: isDark ? const Color(0xFF090D18) : null, cardTheme: CardThemeData(color: isDark ? const Color(0xFF121A2A) : null, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)))); }
}
class SplashScreen extends StatefulWidget { const SplashScreen({super.key}); @override State<SplashScreen> createState() => _SplashScreenState(); }
class _SplashScreenState extends State<SplashScreen> { @override void initState() { super.initState(); Timer(const Duration(milliseconds: 1700), () { if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const UnimateShell())); }); }
 @override Widget build(BuildContext context) => Scaffold(body: Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF071525), Color(0xFF1B1040), Color(0xFF090D18)])), child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.school_rounded, size: 96, color: Color(0xFF00E5FF)), SizedBox(height: 18), Text('Unimate', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800, letterSpacing: 1.5)), SizedBox(height: 8), Text('Your academic universe'), Spacer(), Padding(padding: EdgeInsets.only(bottom: 40), child: Text('Developed with 💻 by Ahmed Alaa', style: TextStyle(color: Colors.white70)))])))); }
}

