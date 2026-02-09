# prism/lib/features/apps/apps_hub_screen.dart

## Unit Scenarios
- Initial tab selection respects query parameter.
- Back navigation from sub-screen returns to grid.
- App definitions are ordered and rendered as expected.

## Widget Scenarios
- Grid view shows five app tiles.
- Sub-screen header shows app title and emoji.
- PopScope intercepts back to grid instead of exit.

## Integration Scenarios
- Deep link to /apps?tab=1 opens Finance sub-screen.
- Selecting app card shows corresponding sub-screen.
- Back to grid preserves current app state.
