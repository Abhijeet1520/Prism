import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:prism/features/settings/about_section.dart';

void main() {
  testWidgets('About section shows app name and version', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: AboutSection(
        cardColor: Colors.black,
        borderColor: Colors.grey,
        textPrimary: Colors.white,
        textSecondary: Colors.white70,
        accentColor: Colors.blue,
      ),
    ));

    expect(find.text('Prism'), findsOneWidget);
    expect(find.textContaining('v0.2.0-alpha'), findsOneWidget);
  });
}
