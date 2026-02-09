import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:prism/features/apps/files_sub_screen.dart';
import '../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Files sub-screen shows storage card', (tester) async {
    final db = createTestDatabase();
    addTearDown(db.close);

    await pumpWithDb(
      tester,
      FilesSubScreen(
        isDark: true,
        cardColor: const Color(0xFF16162A),
        borderColor: const Color(0xFF252540),
        textPrimary: const Color(0xFFE2E2EC),
        textSecondary: const Color(0xFF7A7A90),
      ),
      db: db,
    );

    expect(find.text('Storage'), findsOneWidget);
  });
}
