import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unimate/core/app_strings.dart';

void main() {
  testWidgets('custom app strings change with locale', (tester) async {
    await tester.pumpWidget(const MaterialApp(supportedLocales: [Locale('en'), Locale('ar')], home: _LocaleProbe()));
    expect(find.text('Schedule'), findsOneWidget);
    await tester.pumpWidget(const MaterialApp(locale: Locale('ar'), supportedLocales: [Locale('en'), Locale('ar')], home: _LocaleProbe()));
    expect(find.text('الجدول'), findsOneWidget);
  });
}

class _LocaleProbe extends StatelessWidget {
  const _LocaleProbe();
  @override
  Widget build(BuildContext context) => Text(context.t('schedule'));
}
