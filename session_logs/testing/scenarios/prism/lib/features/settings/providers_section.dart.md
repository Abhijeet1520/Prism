# prism/lib/features/settings/providers_section.dart

## Unit Scenarios
- Local models list uses `modelManagerProvider` paths.
- Download action triggers confirmation and enqueue.
- HuggingFace token set and cleared persists state.

## Widget Scenarios
- Local models show active badge on selected model.
- Download progress renders with label.
- Cloud provider tiles render list and action buttons.

## Integration Scenarios
- Import local model -> appears in list and selectable.
- Download model -> shows completed badge and can load.
- Cloud provider configured -> model list appears in selector.
