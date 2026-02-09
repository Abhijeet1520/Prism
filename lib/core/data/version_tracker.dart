/// Git-like version tracking for Prism data.
///
/// Tracks changes to notes, tasks, conversations, and settings
/// with lightweight snapshots stored in SharedPreferences.
/// Enables undo, change history, and data recovery.
library;

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Snapshot Entry ──────────────────────────────────

class DataSnapshot {
  final String id;
  final DateTime timestamp;
  final String action; // 'create' | 'update' | 'delete' | 'import' | 'export'
  final String entityType; // 'note' | 'task' | 'transaction' | 'conversation' | 'settings'
  final String entityId;
  final String summary;
  final String? previousData; // JSON of the entity before the change (for undo)

  const DataSnapshot({
    required this.id,
    required this.timestamp,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.summary,
    this.previousData,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'action': action,
        'entityType': entityType,
        'entityId': entityId,
        'summary': summary,
        'previousData': previousData,
      };

  factory DataSnapshot.fromJson(Map<String, dynamic> json) => DataSnapshot(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        action: json['action'] as String,
        entityType: json['entityType'] as String,
        entityId: json['entityId'] as String,
        summary: json['summary'] as String,
        previousData: json['previousData'] as String?,
      );

  String get actionIcon => switch (action) {
        'create' => '+',
        'update' => '~',
        'delete' => '-',
        'import' => '↓',
        'export' => '↑',
        _ => '•',
      };

  String get actionLabel => switch (action) {
        'create' => 'Created',
        'update' => 'Updated',
        'delete' => 'Deleted',
        'import' => 'Imported',
        'export' => 'Exported',
        _ => action,
      };
}

// ─── Version Tracker State ───────────────────────────

class VersionTrackerState {
  final List<DataSnapshot> history;
  final bool isLoaded;

  const VersionTrackerState({
    this.history = const [],
    this.isLoaded = false,
  });

  VersionTrackerState copyWith({
    List<DataSnapshot>? history,
    bool? isLoaded,
  }) =>
      VersionTrackerState(
        history: history ?? this.history,
        isLoaded: isLoaded ?? this.isLoaded,
      );

  /// Recent history (last 50 entries).
  List<DataSnapshot> get recent => history.take(50).toList();

  /// History grouped by date.
  Map<String, List<DataSnapshot>> get groupedByDate {
    final grouped = <String, List<DataSnapshot>>{};
    for (final snap in history) {
      final dateKey = '${snap.timestamp.year}-'
          '${snap.timestamp.month.toString().padLeft(2, '0')}-'
          '${snap.timestamp.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(dateKey, () => []).add(snap);
    }
    return grouped;
  }

  /// Stats summary.
  Map<String, int> get stats {
    final counts = <String, int>{};
    for (final snap in history) {
      counts[snap.action] = (counts[snap.action] ?? 0) + 1;
    }
    return counts;
  }
}

// ─── Version Tracker Notifier ────────────────────────

class VersionTrackerNotifier extends Notifier<VersionTrackerState> {
  static const _storageKey = 'prism_version_history';
  static const _maxHistory = 500;

  @override
  VersionTrackerState build() {
    _load();
    return const VersionTrackerState();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey);
    if (jsonStr != null) {
      try {
        final list = (jsonDecode(jsonStr) as List)
            .map((e) => DataSnapshot.fromJson(e as Map<String, dynamic>))
            .toList();
        state = state.copyWith(history: list, isLoaded: true);
      } catch (_) {
        state = state.copyWith(isLoaded: true);
      }
    } else {
      state = state.copyWith(isLoaded: true);
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(state.history.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, jsonStr);
  }

  /// Record a data change.
  Future<void> record({
    required String action,
    required String entityType,
    required String entityId,
    required String summary,
    String? previousData,
  }) async {
    final snapshot = DataSnapshot(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      action: action,
      entityType: entityType,
      entityId: entityId,
      summary: summary,
      previousData: previousData,
    );

    // Prepend new entry, trim to max
    final updated = [snapshot, ...state.history];
    if (updated.length > _maxHistory) {
      updated.removeRange(_maxHistory, updated.length);
    }

    state = state.copyWith(history: updated);
    await _save();
  }

  /// Clear all history.
  Future<void> clearHistory() async {
    state = state.copyWith(history: []);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  /// Export history as JSON string.
  String exportHistory() {
    return const JsonEncoder.withIndent('  ')
        .convert(state.history.map((e) => e.toJson()).toList());
  }
}

// ─── Riverpod Provider ───────────────────────────────

final versionTrackerProvider =
    NotifierProvider<VersionTrackerNotifier, VersionTrackerState>(
  VersionTrackerNotifier.new,
);
