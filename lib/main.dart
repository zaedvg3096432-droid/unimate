import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/platform_services.dart';
import 'state/app_state.dart';
import 'widgets/unimate_shell.dart';
import 'core/app_strings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();
  runApp(const ProviderScope(child: UnimateApp()));
}

class UnimateApp extends ConsumerWidget {
  const UnimateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final dark = ThemeData.dark(useMaterial3: true);
    final light = ThemeData.light(useMaterial3: true);
    return MaterialApp(
      onGenerateTitle: (context) => context.t('appTitle'),
      debugShowCheckedModeBanner: false,
      locale: settings.locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: settings.themeMode,
      theme: light.copyWith(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5548D9))),
      darkTheme: dark.copyWith(
        scaffoldBackgroundColor: const Color(0xFF090D18),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00D9FF), brightness: Brightness.dark),
        cardTheme: CardThemeData(color: const Color(0xFF121A2A), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
      ),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(settings.textScale)),
        child: Directionality(
          textDirection: settings.locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1700), () {
      if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const UnimateShell()));
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF071525), Color(0xFF1B1040), Color(0xFF090D18)])),
          child: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.school_rounded, size: 96, color: Color(0xFF00E5FF)),
              const SizedBox(height: 18),
              const Text('Unimate', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Text(context.t('academicUniverse'), style: const TextStyle(color: Colors.white)),
              const Spacer(),
              Padding(padding: const EdgeInsets.only(bottom: 40), child: Text(context.t('developed'), style: const TextStyle(color: Colors.white70))),
            ]),
          ),
        ),
      );
}
