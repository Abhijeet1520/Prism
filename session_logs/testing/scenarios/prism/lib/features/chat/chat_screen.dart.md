# prism/lib/features/chat/chat_screen.dart

## Unit Scenarios
- Creating a new chat inserts a conversation and selects it.
- Search query filters conversations by title.
- Time-ago formatting returns expected strings.

## Widget Scenarios
- Wide layout shows conversation list and chat area.
- Mobile layout switches between list and chat view.
- Empty state renders when no conversations exist.

## Integration Scenarios
- Send message -> streaming response -> message saved.
- Stop streaming keeps partial response.
- Model selector changes provider for next message.
