import 'package:flutter_test/flutter_test.dart';

import 'package:prism/core/data/version_tracker.dart';

void main() {
  test('DataSnapshot labels map to actions', () {
    const snap = DataSnapshot(
      id: '1',
      timestamp: DateTime(2024),
      action: 'create',
      entityType: 'note',
      entityId: 'n1',
      summary: 'Created note',
    );

    expect(snap.actionLabel, 'Created');
    expect(snap.actionIcon, '+');
  });

  test('groupedByDate buckets entries', () {
    final state = VersionTrackerState(history: [
      DataSnapshot(
        id: '1',
        timestamp: DateTime(2024, 1, 1, 10),
        action: 'create',
        entityType: 'note',
        entityId: 'n1',
        summary: 'Created',
      ),
      DataSnapshot(
        id: '2',
        timestamp: DateTime(2024, 1, 1, 12),
        action: 'update',
        entityType: 'note',
        entityId: 'n1',
        summary: 'Updated',
      ),
    ]);

    expect(state.groupedByDate.length, 1);
  });
}
