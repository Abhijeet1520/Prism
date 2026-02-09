# prism/lib/core/ai/persona_manager.dart

## Unit Scenarios
- Built-in personas load from assets and set `isLoaded` true.
- Import persona JSON returns false for invalid JSON.
- Removing built-in persona is a no-op.
- Active persona changes persist to SharedPreferences.

## Widget Scenarios
- Personas list renders active badge on selected persona.
- Edit dialog saves updated traits and prompt.
- Import dialog adds persona and list refreshes.

## Integration Scenarios
- Changing persona updates system prompt injected by AI service.
- Exported JSON can be imported and becomes selectable.
- Deleting active custom persona falls back to default.
