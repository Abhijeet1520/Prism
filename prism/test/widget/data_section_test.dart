import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:prism/features/settings/data_section.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Data section renders storage list', (tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(
        home: DataSection(
          cardColor: Colors.black,
          borderColor: Colors.grey,
          textPrimary: Colors.white,
          textSecondary: Colors.white70,
          accentColor: Colors.blue,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Data & Storage'), findsOneWidget);
    expect(find.text('STORAGE'), findsOneWidget);
  });
}
