# prism/lib/features/apps/tools_sub_screen.dart

## Unit Scenarios
- Tools and server lists load from JSON.
- Implemented tool IDs are enabled by default only when supported.
- Server status colors map to expected values.

## Widget Scenarios
- Tools tab shows list with expand/collapse behavior.
- MCP Servers tab shows server cards with auto-connect toggle.
- Coming soon tools render disabled badge.

## Integration Scenarios
- Switching tabs preserves tool toggle state.
- Tool enable changes propagate to tool registry (future wiring).
- MCP server error displays last error message.
