# prism/lib/features/settings/settings_screen.dart

## Unit Scenarios
- Expanded sections set defaults to include providers section.
- Section routing returns correct widget for index.
- Side nav toggle updates expanded sections set.

## Widget Scenarios
- Mobile renders accordion list of sections.
- Wide layout shows side nav and content panel.
- Expanded sections show content and divider styling.

## Integration Scenarios
- Open settings -> change theme -> UI updates.
- Open providers section -> configure provider -> model list updates.
- Expand/collapse sections retains state on orientation change.
