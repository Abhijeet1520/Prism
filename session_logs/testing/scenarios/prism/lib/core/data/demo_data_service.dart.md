# prism/lib/core/data/demo_data_service.dart

## Unit Scenarios
- Loading demo data inserts expected counts per table.
- Demo data removal deletes only demo-tagged rows.
- Has demo data returns true when demo settings key exists.
- Failures in one table do not prevent others from loading.

## Widget Scenarios
- Data section shows demo data counts after load.
- Loading state shows spinner and disables actions.
- Removal confirmation dialog renders counts.

## Integration Scenarios
- Load demo data -> tasks, notes, transactions visible in UI.
- Remove demo data -> UI lists are empty (or only real data).
- Demo data load is idempotent or safely additive.
