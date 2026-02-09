# prism/lib/core/ai/cloud_provider_service.dart

## Unit Scenarios
- Provider JSON loads and parsed models are mapped to `CloudProviderConfig`.
- Saved provider configs persist and restore API keys and model selections.
- Registering models uses selected models when set, otherwise catalog defaults.
- OpenRouter headers are added when fetching models.

## Widget Scenarios
- Provider tiles display configured state and masked key.
- Fetch models button updates model list and shows loading state.
- Enabling a provider registers models in `AIServiceNotifier`.

## Integration Scenarios
- Configure provider -> models appear in chat model selector.
- Invalid API key shows validation error and does not persist state.
- Switching provider in chat uses provider base URL and auth header.
