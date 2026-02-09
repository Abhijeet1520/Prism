# prism/lib/features/settings/personas_section.dart

## Unit Scenarios
- Activate persona updates state and persists.
- Import JSON validates and adds custom persona.
- Delete built-in persona is disabled.

## Widget Scenarios
- Persona list renders emoji, name, description.
- Edit dialog updates fields and saves changes.
- Export option copies JSON to clipboard.

## Integration Scenarios
- Active persona changes AI prompt in chat.
- Create custom persona -> appears in list and can be activated.
- Delete active custom persona falls back to default.
