# prism/lib/features/apps/tasks_sub_screen.dart

## Unit Scenarios
- Add task writes to database and clears input.
- Status filter returns only todo or done tasks.
- Drag-and-drop toggles completion status.

## Widget Scenarios
- List view shows tasks with priority and status chips.
- Kanban view renders two columns with counts.
- Empty state appears when no tasks exist.

## Integration Scenarios
- Create task -> appears in list and Kanban.
- Toggle completion -> task moves between columns.
- Filter updates list without losing selection.
