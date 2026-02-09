# prism/lib/main.dart

## Unit Scenarios
- When the splash completion callback fires, app switches from splash MaterialApp to router MaterialApp.
- System UI overlay configuration is applied without throwing.
- Theme mode honors `PrismThemeState.mode` for light and dark routes.

## Widget Scenarios
- App shows SplashScreen on first build, then renders AppShell after completion.
- Theme changes from `PrismThemeNotifier` update MaterialApp theme.
- Debug banner is disabled.

## Integration Scenarios
- Cold start -> splash -> home route reachable and stable.
- Returning from background preserves navigation state.
- Toggling theme in settings updates the entire app.
