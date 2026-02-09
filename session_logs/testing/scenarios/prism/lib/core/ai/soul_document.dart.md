# prism/lib/core/ai/soul_document.dart

## Unit Scenarios
- Default sections are created on first launch with isLoaded true.
- Update section modifies content and updates lastModified.
- Export produces JSON with version, enabled, and sections.
- Import merge updates existing and adds new sections.
- Word count returns accurate total across sections.

## Widget Scenarios
- Toggle disables soul injection and reflects state.
- Editing a section saves content and updates preview.
- Export copies JSON to clipboard and shows snackbar.

## Integration Scenarios
- Enabling soul document injects context into AI prompt.
- Import replace resets sections and preserves enabled state.
- Clear all removes content without deleting sections.
