import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:prism/features/settings/personas_section.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Personas section renders header', (tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(
        home: PersonasSection(
          cardColor: Colors.black,
          borderColor: Colors.grey,
          textPrimary: Colors.white,
          textSecondary: Colors.white70,
          accentColor: Colors.blue,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Personas'), findsOneWidget);
  });
}
