# prism/lib/core/database/tables.dart

## Unit Scenarios
- Default values are applied for new rows.
- Primary keys and foreign keys enforce constraints.
- Enum-like fields accept only expected values.

## Widget Scenarios
- Not directly applicable; covered via database UI flows.

## Integration Scenarios
- Migration creates all tables and FTS indices.
- Foreign key cascade behaves as expected on delete.
- FTS tables exist after fresh install and upgrade.
