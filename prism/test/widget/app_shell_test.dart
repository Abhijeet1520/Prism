import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:prism/core/router/app_router.dart';

void main() {
  testWidgets('AppShell renders navigation destinations', (tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: appRouter));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Brain'), findsOneWidget);
    expect(find.text('Apps'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
