import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:prism/features/settings/voice_section.dart';

void main() {
  testWidgets('Voice section renders toggles', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: VoiceSection(
        cardColor: Colors.black,
        borderColor: Colors.grey,
        textPrimary: Colors.white,
        textSecondary: Colors.white70,
        accentColor: Colors.blue,
      ),
    ));

    expect(find.text('Voice Input'), findsOneWidget);
    expect(find.text('Haptic Feedback'), findsOneWidget);
    expect(find.text('Auto-send on Enter'), findsOneWidget);
  });
}
