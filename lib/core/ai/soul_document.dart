/// Soul Document — persistent user context & memory for AI personalization.
///
/// A user-editable document containing personal info, preferences, goals,
/// and context that gets injected into every AI conversation. Think of it
/// as the AI's "knowledge base" about the user. Stored locally, never uploaded.
library;

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Soul Section ────────────────────────────────────

/// A named section within the Soul Document.
class SoulSection {
  final String id;
  final String title;
  final String icon;
  final String content;
  final bool isDefault;
  final DateTime lastModified;

  const SoulSection({
    required this.id,
    required this.title,
    this.icon = '📝',
    this.content = '',
    this.isDefault = false,
    required this.lastModified,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'icon': icon,
        'content': content,
        'isDefault': isDefault,
        'lastModified': lastModified.toIso8601String(),
      };

  factory SoulSection.fromJson(Map<String, dynamic> json) => SoulSection(
        id: json['id'] as String,
        title: json['title'] as String,
        icon: json['icon'] as String? ?? '📝',
        content: json['content'] as String? ?? '',
        isDefault: json['isDefault'] as bool? ?? false,
        lastModified: DateTime.tryParse(json['lastModified'] as String? ?? '') ??
            DateTime.now(),
      );

  SoulSection copyWith({
    String? title,
    String? icon,
    String? content,
    DateTime? lastModified,
  }) =>
      SoulSection(
        id: id,
        title: title ?? this.title,
        icon: icon ?? this.icon,
        content: content ?? this.content,
        isDefault: isDefault,
        lastModified: lastModified ?? this.lastModified,
      );
}

// ─── Soul Document State ─────────────────────────────

class SoulDocumentState {
  final List<SoulSection> sections;
  final bool isLoaded;
  final bool isEnabled;

  const SoulDocumentState({
    this.sections = const [],
    this.isLoaded = false,
    this.isEnabled = true,
  });

  /// Build the full soul context string for AI injection.
  String toContextString() {
    if (!isEnabled || sections.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln('=== USER CONTEXT (Soul Document) ===');
    buffer.writeln(
        'The following is personal information the user has shared about themselves. '
        'Use this to personalize your responses, remember their preferences, '
        'and provide contextually relevant assistance. Do not repeat this info '
        'back to the user unless they ask.\n');

    for (final section in sections) {
      if (section.content.trim().isEmpty) continue;
      buffer.writeln('## ${section.title}');
      buffer.writeln(section.content.trim());
      buffer.writeln();
    }

    buffer.writeln('=== END USER CONTEXT ===');
    return buffer.toString();
  }

  /// Word count across all sections.
  int get totalWords => sections.fold(
      0,
      (sum, s) =>
          sum +
          s.content.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length);

  SoulDocumentState copyWith({
    List<SoulSection>? sections,
    bool? isLoaded,
    bool? isEnabled,
  }) =>
      SoulDocumentState(
        sections: sections ?? this.sections,
        isLoaded: isLoaded ?? this.isLoaded,
        isEnabled: isEnabled ?? this.isEnabled,
      );
}

// ─── Default Sections ────────────────────────────────

List<SoulSection> _defaultSections() {
  final now = DateTime.now();
  return [
    SoulSection(
      id: 'about_me',
      title: 'About Me',
      icon: '👤',
      content: '',
      isDefault: true,
      lastModified: now,
    ),
    SoulSection(
      id: 'preferences',
      title: 'Preferences & Style',
      icon: '⚙️',
      content: '',
      isDefault: true,
      lastModified: now,
    ),
    SoulSection(
      id: 'goals',
      title: 'Current Goals',
      icon: '🎯',
      content: '',
      isDefault: true,
      lastModified: now,
    ),
    SoulSection(
      id: 'work',
      title: 'Work & Projects',
      icon: '💼',
      content: '',
      isDefault: true,
      lastModified: now,
    ),
    SoulSection(
      id: 'routines',
      title: 'Routines & Habits',
      icon: '🔄',
      content: '',
      isDefault: true,
      lastModified: now,
    ),
    SoulSection(
      id: 'important_notes',
      title: 'Important Notes',
      icon: '📌',
      content: '',
      isDefault: true,
      lastModified: now,
    ),
  ];
}

// ─── Soul Document Notifier ──────────────────────────

class SoulDocumentNotifier extends Notifier<SoulDocumentState> {
  static const _storageKey = 'soul_document';
  static const _enabledKey = 'soul_document_enabled';

  @override
  SoulDocumentState build() {
    _init();
    return const SoulDocumentState();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_enabledKey) ?? true;
    final json = prefs.getString(_storageKey);

    if (json != null) {
      try {
        final list = (jsonDecode(json) as List)
            .map((e) => SoulSection.fromJson(e as Map<String, dynamic>))
            .toList();
        state = SoulDocumentState(
          sections: list,
          isLoaded: true,
          isEnabled: enabled,
        );
        return;
      } catch (_) {}
    }

    // First launch — create default sections
    state = SoulDocumentState(
      sections: _defaultSections(),
      isLoaded: true,
      isEnabled: enabled,
    );
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(state.sections.map((s) => s.toJson()).toList()),
    );
    await prefs.setBool(_enabledKey, state.isEnabled);
  }

  /// Update a section's content.
  Future<void> updateSection(String sectionId, String content) async {
    state = state.copyWith(
      sections: state.sections
          .map((s) => s.id == sectionId
              ? s.copyWith(content: content, lastModified: DateTime.now())
              : s)
          .toList(),
    );
    await _save();
  }

  /// Update a section's title.
  Future<void> updateSectionTitle(String sectionId, String title) async {
    state = state.copyWith(
      sections: state.sections
          .map((s) => s.id == sectionId
              ? s.copyWith(title: title, lastModified: DateTime.now())
              : s)
          .toList(),
    );
    await _save();
  }

  /// Add a custom section.
  Future<void> addSection({
    required String title,
    String icon = '📝',
    String content = '',
  }) async {
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    state = state.copyWith(
      sections: [
        ...state.sections,
        SoulSection(
          id: id,
          title: title,
          icon: icon,
          content: content,
          isDefault: false,
          lastModified: DateTime.now(),
        ),
      ],
    );
    await _save();
  }

  /// Remove a custom section (default sections cannot be removed).
  Future<void> removeSection(String sectionId) async {
    final section =
        state.sections.where((s) => s.id == sectionId).firstOrNull;
    if (section == null || section.isDefault) return;

    state = state.copyWith(
      sections: state.sections.where((s) => s.id != sectionId).toList(),
    );
    await _save();
  }

  /// Toggle soul document on/off.
  Future<void> setEnabled(bool enabled) async {
    state = state.copyWith(isEnabled: enabled);
    await _save();
  }

  /// Export the entire soul document as JSON.
  String export() =>
      const JsonEncoder.withIndent('  ').convert({
        'version': 1,
        'enabled': state.isEnabled,
        'exportedAt': DateTime.now().toIso8601String(),
        'sections': state.sections.map((s) => s.toJson()).toList(),
      });

  /// Import soul document from JSON, merging or replacing.
  Future<bool> importDocument(String jsonStr, {bool replace = false}) async {
    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final imported = (data['sections'] as List)
          .map((e) => SoulSection.fromJson(e as Map<String, dynamic>))
          .toList();

      if (replace) {
        state = state.copyWith(sections: imported);
      } else {
        // Merge: update existing, append new
        final merged = [...state.sections];
        for (final section in imported) {
          final idx = merged.indexWhere((s) => s.id == section.id);
          if (idx >= 0) {
            merged[idx] = section;
          } else {
            merged.add(section);
          }
        }
        state = state.copyWith(sections: merged);
      }
      await _save();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Clear all content but keep structure.
  Future<void> clearAll() async {
    state = state.copyWith(
      sections: state.sections
          .map((s) => s.copyWith(content: '', lastModified: DateTime.now()))
          .toList(),
    );
    await _save();
  }

  /// Reset to default sections.
  Future<void> resetToDefaults() async {
    state = state.copyWith(sections: _defaultSections());
    await _save();
  }
}

// ─── Provider ────────────────────────────────────────

final soulDocumentProvider =
    NotifierProvider<SoulDocumentNotifier, SoulDocumentState>(
  SoulDocumentNotifier.new,
);
