import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:prism/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Apps hub lists tiles', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PrismApp()));
    await tester.pump(const Duration(milliseconds: 3200));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Apps'));
    await tester.pumpAndSettle();

    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Finance'), findsOneWidget);
    expect(find.text('Files'), findsOneWidget);
  });
}
