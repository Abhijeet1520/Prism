# prism/lib/core/ai/ai_service.dart

## Unit Scenarios
- Selecting a local model with missing file path yields error and does not set loaded state.
- Selecting an Ollama model initializes `ChatOllama` with configured base URL.
- Persona system prompt is injected exactly once and not duplicated.
- `generateStream` sets `isGenerating` true at start and false on completion.
- `stopRequested` interrupts streaming and final state is consistent.

## Widget Scenarios
- Consumer widget listening to `aiServiceProvider` updates loading and error banners.
- Model selector UI uses `availableModels` and reflects active model.
- Streamed tokens append to response text progressively.

## Integration Scenarios
- Chat flow with streaming produces partial text and final message saved.
- Switching model mid-conversation uses the new provider for subsequent tokens.
- Persona enabled -> system prompt impacts provider request payload.
