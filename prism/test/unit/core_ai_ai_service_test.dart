import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:prism/core/ai/ai_service.dart';
import '../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await setupSharedPreferences();
  });

  test('default state uses mock model', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(aiServiceProvider);
    expect(state.activeModel, isNotNull);
    expect(state.activeModel!.provider, ProviderType.mock);
    expect(state.isModelLoaded, isTrue);
  });

  test('selecting mock model sets loaded state', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(aiServiceProvider.notifier);
    await notifier.selectModel(const ModelConfig(
      id: 'mock2',
      name: 'Mock 2',
      provider: ProviderType.mock,
    ));

    final state = container.read(aiServiceProvider);
    expect(state.activeModel!.id, 'mock2');
    expect(state.isModelLoaded, isTrue);
  });
}
