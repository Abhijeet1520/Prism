import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prism/core/database/database.dart';

PrismDatabase createTestDatabase() {
  return PrismDatabase(NativeDatabase.memory());
}

Widget wrapWithProviders(Widget child, {PrismDatabase? db}) {
  return ProviderScope(
    overrides: [
      if (db != null) databaseProvider.overrideWithValue(db),
    ],
    child: MaterialApp(home: child),
  );
}

Future<void> setupSharedPreferences() async {
  SharedPreferences.setMockInitialValues({});
}

void mockSpeechToTextChannel() {
  const channel = MethodChannel('speech_to_text');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async {
    switch (call.method) {
      case 'initialize':
        return true;
      case 'listen':
      case 'stop':
      case 'cancel':
        return null;
      default:
        return null;
    }
  });
}

Future<void> pumpWithDb(
  WidgetTester tester,
  Widget child, {
  PrismDatabase? db,
}) async {
  await tester.pumpWidget(wrapWithProviders(child, db: db));
  await tester.pumpAndSettle();
}
