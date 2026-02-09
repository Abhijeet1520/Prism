# prism/lib/features/brain/brain_screen.dart

## Unit Scenarios
- Category mapping for tabs is correct.
- Search query filters notes by title or content.
- New note creation writes to database.

## Widget Scenarios
- PARA tabs render and change selected category.
- Note grid shows empty state when no notes.
- Detail panel appears on wide layout.

## Integration Scenarios
- Create note -> appears in current category list.
- Switching tabs updates grid without losing selection.
- Search results remain scoped to category.
