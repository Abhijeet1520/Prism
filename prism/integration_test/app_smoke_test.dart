import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:prism/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App launches and shows home', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PrismApp()));

    // Allow splash to complete
    await tester.pump(const Duration(milliseconds: 3200));
    await tester.pumpAndSettle();

    expect(find.textContaining('Good'), findsOneWidget);
  });
}
