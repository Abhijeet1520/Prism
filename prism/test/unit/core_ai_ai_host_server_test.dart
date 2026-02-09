import 'package:flutter_test/flutter_test.dart';

import 'package:prism/core/ai/ai_host_server.dart';

void main() {
  test('AIHostState copyWith updates fields', () {
    const state = AIHostState();
    final updated = state.copyWith(isRunning: true, port: 9000);

    expect(updated.isRunning, isTrue);
    expect(updated.port, 9000);
  });
}
