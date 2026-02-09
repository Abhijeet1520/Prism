import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:prism/features/splash/splash_screen.dart';

void main() {
  testWidgets('Splash renders title and subtitle', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: SplashScreen(onComplete: _noop),
    ));

    expect(find.text('Prism'), findsOneWidget);
    expect(find.text('Your AI companion'), findsOneWidget);
  });
}

void _noop() {}
