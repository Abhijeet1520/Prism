import 'package:flutter_test/flutter_test.dart';

import 'package:prism/core/ai/persona_manager.dart';

void main() {
  test('Persona import returns null for invalid JSON', () {
    final persona = Persona.import('not-json');
    expect(persona, isNull);
  });

  test('Persona export round-trips', () {
    const persona = Persona(id: 'p1', name: 'Test');
    final json = persona.export();
    final imported = Persona.import(json);

    expect(imported, isNotNull);
    expect(imported!.id, 'p1');
  });
}
