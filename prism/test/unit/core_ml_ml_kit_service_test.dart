import 'package:flutter_test/flutter_test.dart';

import 'package:prism/core/ml/ml_kit_service.dart';

void main() {
  test('ExtractedEntity toString includes type', () {
    const entity = ExtractedEntity(
      text: '42',
      start: 0,
      end: 2,
      type: 'money',
      rawValue: 42,
    );

    expect(entity.toString(), contains('money'));
  });
}
