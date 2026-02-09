# prism/lib/features/shell/app_shell.dart

## Unit Scenarios
- Selected index resolves to correct tab for each route.
- Back press on non-home navigates to home.
- Back press on home triggers confirm dialog.

## Widget Scenarios
- NavigationBar renders 5 destinations on mobile width.
- NavigationRail renders on wide layout with logo.
- Selected destination styling updates on route change.

## Integration Scenarios
- Back button from settings returns to home without exit.
- Navigation persists across orientation changes.
- Desktop width uses rail and content remains visible.
