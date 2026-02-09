import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:prism/core/ai/cloud_provider_service.dart';
import 'package:prism/features/settings/cloud_provider_tile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Cloud provider tile expands on tap', (tester) async {
    const provider = CloudProviderConfig(
      id: 'openai',
      name: 'OpenAI',
      description: 'Test',
      baseUrl: 'https://api.openai.com/v1',
    );

    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(
        home: CloudProviderTile(
          provider: provider,
          isConfigured: false,
          maskedKey: 'sk-xxxx',
          cardColor: Colors.black,
          borderColor: Colors.grey,
          textPrimary: Colors.white,
          textSecondary: Colors.white70,
          accentColor: Colors.blue,
        ),
      ),
    ));

    expect(find.text('OpenAI'), findsOneWidget);
    await tester.tap(find.text('OpenAI'));
    await tester.pumpAndSettle();

    expect(find.text('API Key'), findsOneWidget);
  });
}
