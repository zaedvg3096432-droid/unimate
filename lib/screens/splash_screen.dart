import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/app_strings.dart';
import '../state/app_state.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      context.go(ref.read(settingsProvider).onboardingSeen ? '/home' : '/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF071525), Color(0xFF1B1040), Color(0xFF090D18)])),
      child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.school_rounded, size: 96, color: Color(0xFF00E5FF)),
        const SizedBox(height: 18),
        const Text('My Routine', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        Text(context.t('academicUniverse'), style: const TextStyle(color: Colors.white)),
        const Spacer(),
        Padding(padding: const EdgeInsets.only(bottom: 40), child: Text(context.t('developed'), style: const TextStyle(color: Colors.white70))),
      ])),
    ),
  );
}
