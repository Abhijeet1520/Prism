import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:prism/features/settings/settings_shared_widgets.dart';

void main() {
  testWidgets('SectionHeader renders title and subtitle', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: SectionHeader(
        title: 'Title',
        subtitle: 'Subtitle',
        textPrimary: Colors.white,
        textSecondary: Colors.white70,
      ),
    ));

    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Subtitle'), findsOneWidget);
  });
}
