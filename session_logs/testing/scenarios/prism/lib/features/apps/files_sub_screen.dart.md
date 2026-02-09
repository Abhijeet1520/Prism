# prism/lib/features/apps/files_sub_screen.dart

## Unit Scenarios
- JSON file tree parsing builds correct parent-child relationships.
- Breadcrumb navigation updates current folder state.
- File viewer edit saves content in-memory.

## Widget Scenarios
- Storage card renders usage bar.
- Breadcrumb shows path and allows navigation back.
- File viewer shows markdown rendering and edit toggle.

## Integration Scenarios
- Open folder -> open file -> edit -> save persists in session.
- Breadcrumb navigation returns to root without error.
- Loading invalid JSON shows error state.
