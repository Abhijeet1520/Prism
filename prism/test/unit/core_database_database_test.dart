import 'package:flutter_test/flutter_test.dart';

import 'package:prism/core/database/database.dart';
import '../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('create conversation and add message', () async {
    final db = createTestDatabase();
    addTearDown(db.close);

    final convId = await db.createConversation(uuid: 'c1', title: 'Test');
    await db.addMessage(
      uuid: 'm1',
      conversationId: convId,
      role: 'user',
      content: 'hello',
    );

    final messages = await db.getLastMessages(convId);
    expect(messages.length, 1);
    expect(messages.first.content, 'hello');
  });
}
