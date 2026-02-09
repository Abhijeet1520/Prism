import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:prism/features/apps/tools_sub_screen.dart';
import '../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Tools sub-screen renders tabs', (tester) async {
    final db = createTestDatabase();
    addTearDown(db.close);

    await pumpWithDb(
      tester,
      ToolsSubScreen(
        isDark: true,
        cardColor: const Color(0xFF16162A),
        borderColor: const Color(0xFF252540),
        textPrimary: const Color(0xFFE2E2EC),
        textSecondary: const Color(0xFF7A7A90),
      ),
      db: db,
    );

    expect(find.text('Tools'), findsOneWidget);
    expect(find.text('MCP Servers'), findsOneWidget);
  });
}
