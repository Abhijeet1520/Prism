# prism/lib/core/database/database.dart

## Unit Scenarios
- Create conversation inserts with default values.
- Add message links to conversation and stores content.
- Task toggle flips completion and updates completedAt.
- Notes search returns matches via FTS or fallback.
- Transactions duplicate copies fields with new UUID.

## Widget Scenarios
- Chat list reacts to conversation stream updates.
- Tasks list updates when toggling completion.
- Finance view updates totals when transactions change.

## Integration Scenarios
- App restart restores conversations and messages.
- Full-text search surfaces messages in chat list.
- Demo data load uses database queries without errors.
