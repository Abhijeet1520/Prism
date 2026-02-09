# prism/lib/core/theme/prism_theme.dart

## Unit Scenarios
- Accent preset updates `PrismThemeState.accent`.
- AMOLED toggle updates background colors.
- Dark theme uses Moon token overrides for primary colors.

## Widget Scenarios
- Appearance section updates theme mode and accent chips.
- Navigation bar uses selected and unselected styles.
- App background changes when AMOLED enabled.

## Integration Scenarios
- User selects preset -> persists through app restart.
- Theme mode respects system setting.
- Accent updates propagate to splash and buttons.
