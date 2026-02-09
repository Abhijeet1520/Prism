# prism/lib/features/settings/data_section.dart

## Unit Scenarios
- Demo data load shows counts and sets state.
- Remove demo data clears demo keys and updates state.
- Storage list renders expected entries.

## Widget Scenarios
- Load demo data dialog renders items.
- Remove demo data dialog shows counts and warning.
- Loading spinner shows during operations.

## Integration Scenarios
- Load demo data -> tasks, notes, transactions visible.
- Remove demo data -> items removed from lists.
- Load then remove is reversible and safe.
