import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:prism/features/settings/providers_section.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Providers section renders headers', (tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(
        home: ProvidersSection(
          cardColor: Colors.black,
          borderColor: Colors.grey,
          textPrimary: Colors.white,
          textSecondary: Colors.white70,
          accentColor: Colors.blue,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('AI Providers'), findsOneWidget);
    expect(find.text('LOCAL MODELS'), findsOneWidget);
  });
}
