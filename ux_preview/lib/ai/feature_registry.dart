// Feature availability tracking for Prism.
//
// This file is loaded by the AI to understand which features are available,
// planned, or under development, so it can give clear messages to users.

enum FeatureStatus {
  available,    // Fully functional
  preview,      // Working but mock data only
  partial,      // Some aspects work
  planned,      // Designed but not implemented
  unavailable,  // Not yet started
}

class Feature {
  final String id;
  final String name;
  final String description;
  final FeatureStatus status;
  final String? version;       // When it's expected
  final String? statusMessage; // Human-readable explanation

  const Feature({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    this.version,
    this.statusMessage,
  });

  String get userMessage {
    if (statusMessage != null) return statusMessage!;
    return switch (status) {
      FeatureStatus.available => '$name is ready to use.',
      FeatureStatus.preview => '$name is available in preview mode with sample data.',
      FeatureStatus.partial => '$name is partially available. Some features are still being built.',
      FeatureStatus.planned => '$name is planned for ${version ?? "a future release"}. Stay tuned!',
      FeatureStatus.unavailable => '$name is not yet available. It\'s on our roadmap.',
    };
  }
}

/// Central registry of all features and their availability.
class FeatureRegistry {
  static final FeatureRegistry _instance = FeatureRegistry._();
  factory FeatureRegistry() => _instance;
  FeatureRegistry._();

  final _features = <String, Feature>{};

  void _register(Feature f) => _features[f.id] = f;

  Feature? getFeature(String id) => _features[id];
  List<Feature> get all => _features.values.toList();
  List<Feature> get available => all.where((f) => f.status == FeatureStatus.available).toList();
  List<Feature> get preview => all.where((f) => f.status == FeatureStatus.preview).toList();
  List<Feature> get planned => all.where((f) => f.status == FeatureStatus.planned).toList();

  bool isAvailable(String id) {
    final f = _features[id];
    return f != null && (f.status == FeatureStatus.available || f.status == FeatureStatus.preview);
  }

  String getMessage(String id) {
    return _features[id]?.userMessage ?? 'This feature is not recognized.';
  }

  /// Initialize with default feature set.
  void initialize() {
    // ── Available (Preview) ─────────────────────────────────
    _register(const Feature(
      id: 'daily_digest', name: 'Daily Digest',
      description: 'Home screen with weather, tasks, events, finance summary',
      status: FeatureStatus.preview, version: 'v0.1',
      statusMessage: 'Daily Digest is showing sample data. Connect your accounts in Settings to see real data.',
    ));
    _register(const Feature(
      id: 'chat', name: 'AI Chat',
      description: 'Conversational AI interface',
      status: FeatureStatus.preview, version: 'v0.1',
      statusMessage: 'Chat is in preview mode. Responses are simulated. Connect a real model in Settings > AI Providers for actual AI responses.',
    ));
    _register(const Feature(
      id: 'brain', name: 'Brain (Knowledge Base)',
      description: 'Personal knowledge management with documents, notes, snippets',
      status: FeatureStatus.preview, version: 'v0.1',
      statusMessage: 'Brain is showing sample documents. Your notes will be stored locally with full encryption.',
    ));
    _register(const Feature(
      id: 'tasks', name: 'Task Management',
      description: 'Todo lists, priorities, due dates',
      status: FeatureStatus.preview, version: 'v0.1',
    ));
    _register(const Feature(
      id: 'finance', name: 'Finance Tracker',
      description: 'Budget tracking, transactions, spending analysis',
      status: FeatureStatus.preview, version: 'v0.1',
    ));
    _register(const Feature(
      id: 'theme', name: 'Theme Customization',
      description: 'Accent colors, AMOLED mode, font scaling',
      status: FeatureStatus.available, version: 'v0.1',
    ));
    _register(const Feature(
      id: 'navigation', name: 'App Navigation',
      description: '5-tab layout with responsive desktop sidebar',
      status: FeatureStatus.available, version: 'v0.1',
    ));

    // ── Partial / In Progress ───────────────────────────────
    _register(const Feature(
      id: 'tools', name: 'AI Tools',
      description: 'Composable tools for task updates, finance logging, note creation',
      status: FeatureStatus.partial, version: 'v0.2',
      statusMessage: 'AI Tools are in early development. Basic tool matching works, but full function calling requires a connected AI model (v0.2).',
    ));
    _register(const Feature(
      id: 'soul_orb', name: 'Soul Orb',
      description: 'Animated ambient AI presence indicator',
      status: FeatureStatus.available, version: 'v0.1',
    ));

    // ── Planned ─────────────────────────────────────────────
    _register(const Feature(
      id: 'local_model', name: 'Local Model Loading',
      description: 'Download and run LLMs directly on device via llama.cpp',
      status: FeatureStatus.planned, version: 'v0.2',
      statusMessage: 'Local model loading is planned for v0.2. It will use llama.cpp to run models like Gemma 3 directly on your device. For now, you can connect to Ollama or cloud APIs.',
    ));
    _register(const Feature(
      id: 'voice_input', name: 'Voice Input',
      description: 'Speech-to-text for hands-free interaction',
      status: FeatureStatus.planned, version: 'v0.3',
      statusMessage: 'Voice input is planned for v0.3. It will process speech entirely on-device for privacy. Text input is available now.',
    ));
    _register(const Feature(
      id: 'voice_output', name: 'Voice Output',
      description: 'Text-to-speech for AI responses',
      status: FeatureStatus.planned, version: 'v0.3',
    ));
    _register(const Feature(
      id: 'rag', name: 'RAG (Retrieval Augmented Generation)',
      description: 'AI answers grounded in your Brain documents',
      status: FeatureStatus.planned, version: 'v0.3',
      statusMessage: 'RAG is planned for v0.3. It will let the AI reference your personal documents for more accurate, contextual answers.',
    ));
    _register(const Feature(
      id: 'calendar_sync', name: 'Calendar Sync',
      description: 'Sync with Google Calendar, Apple Calendar',
      status: FeatureStatus.planned, version: 'v0.4',
    ));
    _register(const Feature(
      id: 'wake_word', name: 'Wake Word Detection',
      description: 'Activate AI with a spoken keyword',
      status: FeatureStatus.planned, version: 'v0.4',
    ));
    _register(const Feature(
      id: 'widgets', name: 'Home Screen Widgets',
      description: 'Android/iOS home screen widgets for quick access',
      status: FeatureStatus.planned, version: 'v0.5',
    ));
    _register(const Feature(
      id: 'e2e_encryption', name: 'E2E Encryption',
      description: 'End-to-end encryption for all personal data',
      status: FeatureStatus.planned, version: 'v0.2',
    ));
    _register(const Feature(
      id: 'plugins', name: 'Plugin System',
      description: 'Third-party extensions and integrations',
      status: FeatureStatus.planned, version: 'v0.6',
    ));
  }
}
