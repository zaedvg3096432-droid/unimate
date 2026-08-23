import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/platform_services.dart';
import 'state/app_state.dart';
import 'core/app_strings.dart';
import 'core/app_router.dart';

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
    final light = ThemeData.light(useMaterial3: true).copyWith(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7C4DFF)), scaffoldBackgroundColor: const Color(0xFFF7F8FC), cardTheme: CardThemeData(color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))));
    final dark = ThemeData.dark(useMaterial3: true).copyWith(scaffoldBackgroundColor: const Color(0xFF090D18), colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00E5FF), brightness: Brightness.dark), cardTheme: CardThemeData(color: const Color(0xFF121A2A), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))));
    return MaterialApp.router(
      onGenerateTitle: (context) => context.t('appTitle'),
      debugShowCheckedModeBanner: false,
      locale: settings.locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      themeMode: settings.themeMode,
      theme: light,
      darkTheme: dark,
      routerConfig: appRouter,
      builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(settings.textScale)), child: Directionality(textDirection: settings.locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr, child: child ?? const SizedBox.shrink())),
    );
  }
}
