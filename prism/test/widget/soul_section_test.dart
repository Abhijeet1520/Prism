import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:prism/features/settings/soul_section.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Soul document section shows description', (tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(
        home: SoulDocumentSection(
          cardColor: Colors.black,
          borderColor: Colors.grey,
          textPrimary: Colors.white,
          textSecondary: Colors.white70,
          accentColor: Colors.blue,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Soul Document'), findsOneWidget);
  });
}
