# prism/lib/core/router/app_router.dart

## Unit Scenarios
- Router returns correct widget for each base path.
- Apps hub query parameter selects correct tab.
- Unknown routes are rejected or redirected as designed.

## Widget Scenarios
- AppShell highlights active destination based on route.
- Navigation between tabs updates selected index.
- Back navigation from subroutes returns to home.

## Integration Scenarios
- Deep link to /apps?tab=1 opens Finance sub-screen.
- Deep link to /chat restores conversation list.
- Back button flow follows home-first rule.
