import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:prism/features/settings/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Settings screen shows section headers', (tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: SettingsScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('AI Providers'), findsOneWidget);
  });
}
