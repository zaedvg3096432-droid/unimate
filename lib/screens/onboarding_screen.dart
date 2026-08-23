import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_strings.dart';
import '../state/app_state.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final controller = PageController();
  int page = 0;
  final icons = const [Icons.school_rounded, Icons.calendar_month_rounded, Icons.bolt_rounded];
  final titles = const ['onboardingTitle1', 'onboardingTitle2', 'onboardingTitle3'];
  final bodies = const ['onboardingBody1', 'onboardingBody2', 'onboardingBody3'];

  @override
  void dispose() { controller.dispose(); super.dispose(); }

  void finish() { ref.read(settingsProvider.notifier).update(ref.read(settingsProvider).copyWith(onboardingSeen: true)); context.go('/home'); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: titles.length,
                onPageChanged: (value) => setState(() => page = value),
                itemBuilder: (_, index) => Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(width: 170, height: 170, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Theme.of(context).colorScheme.primary.withValues(alpha: .35), Colors.transparent])), child: Icon(icons[index], size: 70, color: Theme.of(context).colorScheme.primary)),
                    const SizedBox(height: 30),
                    Text(context.t(titles[index]), textAlign: TextAlign.center, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(context.t(bodies[index]), textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ]),
                ),
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [for (var i = 0; i < titles.length; i++) AnimatedContainer(duration: const Duration(milliseconds: 180), margin: const EdgeInsets.all(4), width: page == i ? 24 : 7, height: 7, decoration: BoxDecoration(color: page == i ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline, borderRadius: BorderRadius.circular(6)))]),
            if (page == titles.length - 1) Padding(padding: const EdgeInsets.fromLTRB(20, 22, 20, 8), child: Column(children: [Row(children: [Expanded(child: _choice(context, context.t('dark'), ThemeMode.dark)), Expanded(child: _choice(context, context.t('system'), ThemeMode.system)), Expanded(child: _choice(context, context.t('light'), ThemeMode.light))]), const SizedBox(height: 10), Row(children: [Expanded(child: _language(context, 'en', context.t('english'))), Expanded(child: _language(context, 'ar', context.t('arabic')))])])) else const SizedBox(height: 88),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: SizedBox(width: double.infinity, child: FilledButton(onPressed: () { if (page < titles.length - 1) { controller.nextPage(duration: const Duration(milliseconds: 240), curve: Curves.easeOut); } else { finish(); } }, child: Text(page == titles.length - 1 ? context.t('getStarted') : context.t('continue'))))),
            TextButton(onPressed: finish, child: Text(context.t('skip'))),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _choice(BuildContext context, String label, ThemeMode mode) { final selected = ref.watch(settingsProvider).themeMode == mode; return GestureDetector(onTap: () => ref.read(settingsProvider.notifier).update(ref.read(settingsProvider).copyWith(themeMode: mode)), child: Container(margin: const EdgeInsets.all(3), padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: selected ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)), child: Center(child: Text(label, style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.normal))))); }
  Widget _language(BuildContext context, String code, String label) { final selected = ref.watch(settingsProvider).locale.languageCode == code; return GestureDetector(onTap: () => ref.read(settingsProvider.notifier).update(ref.read(settingsProvider).copyWith(locale: Locale(code))), child: Container(margin: const EdgeInsets.all(3), padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: selected ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)), child: Center(child: Text(label, style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.normal))))); }
}
