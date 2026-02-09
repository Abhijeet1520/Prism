import 'package:flutter_test/flutter_test.dart';

import 'package:prism/core/ai/cloud_provider_service.dart';

void main() {
  test('CloudProviderConfig fromJson loads defaults', () {
    final config = CloudProviderConfig.fromJson({
      'id': 'openai',
      'name': 'OpenAI',
      'baseUrl': 'https://api.openai.com/v1',
    });

    expect(config.id, 'openai');
    expect(config.authType, 'bearer');
    expect(config.authHeader, 'Authorization');
  });

  test('SavedProviderConfig copyWith retains providerId', () {
    const saved = SavedProviderConfig(providerId: 'openai');
    final updated = saved.copyWith(isEnabled: true);

    expect(updated.providerId, 'openai');
    expect(updated.isEnabled, isTrue);
  });
}
