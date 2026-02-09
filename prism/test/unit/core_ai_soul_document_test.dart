import 'package:flutter_test/flutter_test.dart';

import 'package:prism/core/ai/soul_document.dart';

void main() {
  test('SoulDocumentState totalWords counts words', () {
    final state = SoulDocumentState(sections: [
      SoulSection(
        id: 'a',
        title: 'A',
        content: 'one two three',
        lastModified: DateTime(2024),
      ),
      SoulSection(
        id: 'b',
        title: 'B',
        content: 'four',
        lastModified: DateTime(2024),
      ),
    ]);

    expect(state.totalWords, 4);
  });

  test('toContextString returns empty when disabled', () {
    final state = SoulDocumentState(isEnabled: false, sections: [
      SoulSection(
        id: 'a',
        title: 'A',
        content: 'hello',
        lastModified: DateTime(2024),
      ),
    ]);

    expect(state.toContextString(), '');
  });
}
