import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:prism/features/brain/brain_screen.dart';
import '../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Brain screen renders tabs', (tester) async {
    final db = createTestDatabase();
    addTearDown(db.close);

    await pumpWithDb(tester, const BrainScreen(), db: db);
    expect(find.text('Second Brain'), findsOneWidget);
    expect(find.text('Projects'), findsOneWidget);
    expect(find.text('Areas'), findsOneWidget);
    expect(find.text('Resources'), findsOneWidget);
    expect(find.text('Archives'), findsOneWidget);
  });
}
