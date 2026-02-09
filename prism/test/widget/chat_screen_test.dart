import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:prism/features/chat/chat_screen.dart';
import '../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Chat screen shows conversations header', (tester) async {
    final db = createTestDatabase();
    addTearDown(db.close);

    await pumpWithDb(tester, const ChatScreen(), db: db);
    expect(find.text('Chats'), findsOneWidget);
  });
}
