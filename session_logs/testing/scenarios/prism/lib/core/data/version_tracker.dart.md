# prism/lib/core/data/version_tracker.dart

## Unit Scenarios
- Record inserts new snapshot at top of history.
- History trims to max length.
- Grouping by date buckets correctly.
- Export returns valid JSON array.
- Clear history removes storage key.

## Widget Scenarios
- Version history list renders recent entries and action icons.
- Clear history button prompts and clears list.
- Stats summary counts actions accurately.

## Integration Scenarios
- Editing a note records update snapshot.
- Deleting a task records delete snapshot.
- Importing data records import snapshot.
