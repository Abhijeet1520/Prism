/// Persona Manager — load, edit, import/export AI personas.
///
/// Personas are stored as JSON with system prompts, personality traits,
/// and metadata. Built-in personas load from assets, custom ones from prefs.
library;

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Persona Model ───────────────────────────────────

class PersonaTraits {
  final double tone;
  final double verbosity;
  final double humor;
  final double empathy;
  final double creativity;

  const PersonaTraits({
    this.tone = 0.5,
    this.verbosity = 0.5,
    this.humor = 0.3,
    this.empathy = 0.6,
    this.creativity = 0.5,
  });

  Map<String, dynamic> toJson() => {
        'tone': tone,
        'verbosity': verbosity,
        'humor': humor,
        'empathy': empathy,
        'creativity': creativity,
      };

  factory PersonaTraits.fromJson(Map<String, dynamic> json) => PersonaTraits(
        tone: (json['tone'] as num?)?.toDouble() ?? 0.5,
        verbosity: (json['verbosity'] as num?)?.toDouble() ?? 0.5,
        humor: (json['humor'] as num?)?.toDouble() ?? 0.3,
        empathy: (json['empathy'] as num?)?.toDouble() ?? 0.6,
        creativity: (json['creativity'] as num?)?.toDouble() ?? 0.5,
      );

  PersonaTraits copyWith({
    double? tone,
    double? verbosity,
    double? humor,
    double? empathy,
    double? creativity,
  }) =>
      PersonaTraits(
        tone: tone ?? this.tone,
        verbosity: verbosity ?? this.verbosity,
        humor: humor ?? this.humor,
        empathy: empathy ?? this.empathy,
        creativity: creativity ?? this.creativity,
      );
}

class Persona {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final String systemPrompt;
  final bool isBuiltIn;
  final PersonaTraits traits;

  const Persona({
    required this.id,
    required this.name,
    this.emoji = '🤖',
    this.description = '',
    this.systemPrompt = '',
    this.isBuiltIn = false,
    this.traits = const PersonaTraits(),
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'description': description,
        'systemPrompt': systemPrompt,
        'isBuiltIn': isBuiltIn,
        'traits': traits.toJson(),
      };

  factory Persona.fromJson(Map<String, dynamic> json) => Persona(
        id: json['id'] as String,
        name: json['name'] as String,
        emoji: json['emoji'] as String? ?? '🤖',
        description: json['description'] as String? ?? '',
        systemPrompt: json['systemPrompt'] as String? ?? '',
        isBuiltIn: json['isBuiltIn'] as bool? ?? false,
        traits: json['traits'] != null
            ? PersonaTraits.fromJson(json['traits'] as Map<String, dynamic>)
            : const PersonaTraits(),
      );

  Persona copyWith({
    String? id,
    String? name,
    String? emoji,
    String? description,
    String? systemPrompt,
    bool? isBuiltIn,
    PersonaTraits? traits,
  }) =>
      Persona(
        id: id ?? this.id,
        name: name ?? this.name,
        emoji: emoji ?? this.emoji,
        description: description ?? this.description,
        systemPrompt: systemPrompt ?? this.systemPrompt,
        isBuiltIn: isBuiltIn ?? this.isBuiltIn,
        traits: traits ?? this.traits,
      );

  /// Export persona as JSON string for sharing.
  String export() => const JsonEncoder.withIndent('  ').convert(toJson());

  /// Import persona from JSON string.
  static Persona? import(String jsonStr) {
    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      return Persona.fromJson(data).copyWith(isBuiltIn: false);
    } catch (_) {
      return null;
    }
  }
}

// ─── Persona Manager State ───────────────────────────

class PersonaManagerState {
  final List<Persona> personas;
  final String activePersonaId;
  final bool isLoaded;

  const PersonaManagerState({
    this.personas = const [],
    this.activePersonaId = 'default',
    this.isLoaded = false,
  });

  Persona? get activePersona =>
      personas.where((p) => p.id == activePersonaId).firstOrNull;

  PersonaManagerState copyWith({
    List<Persona>? personas,
    String? activePersonaId,
    bool? isLoaded,
  }) =>
      PersonaManagerState(
        personas: personas ?? this.personas,
        activePersonaId: activePersonaId ?? this.activePersonaId,
        isLoaded: isLoaded ?? this.isLoaded,
      );
}

// ─── Persona Manager Notifier ────────────────────────

class PersonaManagerNotifier extends Notifier<PersonaManagerState> {
  @override
  PersonaManagerState build() {
    _init();
    return const PersonaManagerState();
  }

  Future<void> _init() async {
    await _loadBuiltInPersonas();
    await _loadCustomPersonas();
    await _loadActivePersona();
  }

  Future<void> _loadBuiltInPersonas() async {
    try {
      final jsonStr =
          await rootBundle.loadString('assets/config/personas.json');
      final list = (jsonDecode(jsonStr) as List)
          .map((e) => Persona.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(personas: list, isLoaded: true);
    } catch (_) {
      // Fallback default
      state = state.copyWith(
        personas: const [
          Persona(
            id: 'default',
            name: 'Default',
            emoji: '🤖',
            description: 'Balanced, helpful assistant',
            systemPrompt: 'You are Prism, a helpful AI assistant.',
            isBuiltIn: true,
          ),
        ],
        isLoaded: true,
      );
    }
  }

  Future<void> _loadCustomPersonas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('custom_personas');
      if (json != null) {
        final list = (jsonDecode(json) as List)
            .map((e) => Persona.fromJson(e as Map<String, dynamic>))
            .toList();
        state = state.copyWith(
          personas: [...state.personas, ...list],
        );
      }
    } catch (_) {}
  }

  Future<void> _loadActivePersona() async {
    final prefs = await SharedPreferences.getInstance();
    final activeId = prefs.getString('active_persona') ?? 'default';
    state = state.copyWith(activePersonaId: activeId);
  }

  Future<void> _saveCustomPersonas() async {
    final prefs = await SharedPreferences.getInstance();
    final custom = state.personas.where((p) => !p.isBuiltIn).toList();
    await prefs.setString(
      'custom_personas',
      jsonEncode(custom.map((p) => p.toJson()).toList()),
    );
  }

  /// Set the active persona.
  Future<void> setActive(String personaId) async {
    state = state.copyWith(activePersonaId: personaId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_persona', personaId);
  }

  /// Add a new custom persona.
  Future<void> addPersona(Persona persona) async {
    final newPersona = persona.copyWith(isBuiltIn: false);
    state = state.copyWith(
      personas: [...state.personas, newPersona],
    );
    await _saveCustomPersonas();
  }

  /// Update an existing persona.
  Future<void> updatePersona(Persona updated) async {
    state = state.copyWith(
      personas: state.personas
          .map((p) => p.id == updated.id ? updated : p)
          .toList(),
    );
    await _saveCustomPersonas();
  }

  /// Remove a persona (only custom ones).
  Future<void> removePersona(String personaId) async {
    final persona =
        state.personas.where((p) => p.id == personaId).firstOrNull;
    if (persona == null || persona.isBuiltIn) return;

    state = state.copyWith(
      personas: state.personas.where((p) => p.id != personaId).toList(),
      activePersonaId:
          state.activePersonaId == personaId ? 'default' : null,
    );
    await _saveCustomPersonas();
  }

  /// Import a persona from JSON string.
  Future<bool> importPersona(String jsonStr) async {
    final persona = Persona.import(jsonStr);
    if (persona == null) return false;

    // Ensure unique ID
    final uniqueId = state.personas.any((p) => p.id == persona.id)
        ? '${persona.id}_${DateTime.now().millisecondsSinceEpoch}'
        : persona.id;

    await addPersona(persona.copyWith(id: uniqueId));
    return true;
  }

  /// Export a persona as JSON string.
  String? exportPersona(String personaId) {
    final persona =
        state.personas.where((p) => p.id == personaId).firstOrNull;
    return persona?.export();
  }

  /// Get the system prompt for the active persona.
  String get activeSystemPrompt =>
      state.activePersona?.systemPrompt ?? '';
}

// ─── Riverpod Provider ───────────────────────────────

final personaManagerProvider =
    NotifierProvider<PersonaManagerNotifier, PersonaManagerState>(
  PersonaManagerNotifier.new,
);
