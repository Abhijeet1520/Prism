import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:prism/features/apps/apps_hub_screen.dart';
import '../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Apps hub shows app tiles', (tester) async {
    final db = createTestDatabase();
    addTearDown(db.close);

    await pumpWithDb(tester, const AppsHubScreen(), db: db);
    expect(find.text('Apps'), findsOneWidget);
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Finance'), findsOneWidget);
    expect(find.text('Files'), findsOneWidget);
    expect(find.text('Tools'), findsOneWidget);
    expect(find.text('Gateway'), findsOneWidget);
  });
}
