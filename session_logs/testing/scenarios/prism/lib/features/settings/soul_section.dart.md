# prism/lib/features/settings/soul_section.dart

## Unit Scenarios
- Toggle updates enabled state and persists.
- Add section creates custom section with unique id.
- Remove section does nothing for default sections.

## Widget Scenarios
- Section cards show preview and edit icon.
- Editing a section shows input field and save/cancel.
- Export copies JSON and shows snackbar.

## Integration Scenarios
- Soul document enabled -> system prompt includes context.
- Import merges sections without losing defaults.
- Reset to defaults clears custom sections.
