# prism/lib/features/settings/voice_section.dart

## Unit Scenarios
- Toggle rows pass value and onChanged callbacks.
- Labels and subtitles render correctly.
- Default values are consistent with spec.

## Widget Scenarios
- All three toggles render with titles and subtitles.
- Toggle interaction updates state in parent (future wiring).
- Layout remains stable in narrow widths.

## Integration Scenarios
- Voice input enabled -> home screen uses microphone.
- Auto-send on Enter influences chat input behavior.
- Haptic toggle controls system haptics (future wiring).
