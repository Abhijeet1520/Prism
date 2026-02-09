# prism/lib/core/ai/model_manager.dart

## Unit Scenarios
- Scanning models directory collects only `.gguf` files.
- Download state progresses from idle -> downloading -> completed.
- Cancel download sets status to idle and removes cancel token.
- Gated model download without token returns clear error message.
- Imported model registers with AI service.

## Widget Scenarios
- Download progress bar updates while downloading.
- Error state is visible with retry option.
- Local models list updates after download completes.

## Integration Scenarios
- Download model -> appears in local model list -> can be selected.
- Delete model removes local file and unregisters.
- Import model file path is copied into managed models directory.
