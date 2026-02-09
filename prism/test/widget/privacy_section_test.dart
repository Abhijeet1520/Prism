import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:prism/features/settings/privacy_section.dart';

void main() {
  testWidgets('Privacy section shows badge text', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: PrivacySection(
        cardColor: Colors.black,
        borderColor: Colors.grey,
        textPrimary: Colors.white,
        textSecondary: Colors.white70,
        accentColor: Colors.blue,
      ),
    ));

    expect(find.textContaining('All data is stored locally'), findsOneWidget);
  });
}
