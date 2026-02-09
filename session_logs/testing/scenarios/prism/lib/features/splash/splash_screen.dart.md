# prism/lib/features/splash/splash_screen.dart

## Unit Scenarios
- Animation controllers start and dispose without leaks.
- Completion callback fires after minimum delay.
- Painter should repaint when rotation or entrance changes.

## Widget Scenarios
- Splash screen shows title and subtitle text.
- Progress indicator is visible during splash.
- Fade transition reduces opacity to zero before completing.

## Integration Scenarios
- Cold start shows splash then transitions to home.
- Splash does not block navigation beyond timeout.
- Hot reload maintains splash state until completion.
