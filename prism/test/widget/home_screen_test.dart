import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:prism/features/home/home_screen.dart';
import '../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Home screen renders greeting and orb', (tester) async {
    mockSpeechToTextChannel();
    final db = createTestDatabase();
    addTearDown(db.close);

    await pumpWithDb(tester, const HomeScreen(), db: db);
    expect(find.textContaining('Good'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });
}
