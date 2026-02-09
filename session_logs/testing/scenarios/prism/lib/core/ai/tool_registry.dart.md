# prism/lib/core/ai/tool_registry.dart

## Unit Scenarios
- Built-in ToolSpec list includes all hardcoded tools.
- JSON skills load merges tools while skipping duplicates.
- Execute routes to correct tool handler based on tool name.
- Tool result JSON contains success shape and required fields.

## Widget Scenarios
- Tools screen shows enabled state for implemented tool IDs.
- Tool description and provider tags render correctly.
- Toggle disabled tools remain off with visual disabled state.

## Integration Scenarios
- Tool call in chat writes to database and returns result.
- Tool execution failure returns error JSON in chat output.
- Skills JSON add-on tool appears in tools list.
