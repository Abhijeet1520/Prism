import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:prism/features/apps/gateway_sub_screen.dart';
import '../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Gateway sub-screen shows server status', (tester) async {
    final db = createTestDatabase();
    addTearDown(db.close);

    await pumpWithDb(
      tester,
      GatewaySubScreen(
        isDark: true,
        cardColor: const Color(0xFF16162A),
        borderColor: const Color(0xFF252540),
        textPrimary: const Color(0xFFE2E2EC),
        textSecondary: const Color(0xFF7A7A90),
      ),
      db: db,
    );

    expect(find.textContaining('Server'), findsOneWidget);
    expect(find.text('About Gateway'), findsOneWidget);
  });
}
