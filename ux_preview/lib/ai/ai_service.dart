import 'dart:async';
import 'package:flutter/foundation.dart';

/// Status of an AI model.
enum ModelStatus { idle, downloading, loading, ready, error }

/// Represents a locally available or remote AI model.
class AIModel {
  final String id;
  final String name;
  final String provider; // 'local' | 'ollama' | 'openai' | 'gemini' | 'anthropic'
  final String size;
  final int contextWindow;
  final bool isLocal;
  ModelStatus status;
  double downloadProgress; // 0.0-1.0

  AIModel({
    required this.id,
    required this.name,
    required this.provider,
    required this.size,
    required this.contextWindow,
    required this.isLocal,
    this.status = ModelStatus.idle,
    this.downloadProgress = 0.0,
  });
}

/// A chat message for AI inference.
class AIMessage {
  final String role; // 'user' | 'assistant' | 'system'
  final String content;
  final DateTime timestamp;

  const AIMessage({required this.role, required this.content, required this.timestamp});
}

/// Abstract AI controller — same pattern as Maid's AIController hierarchy.
abstract class AIController {
  String get providerId;
  Future<void> initialize();
  Future<String> generate(List<AIMessage> messages, {int maxTokens = 512});
  Stream<String> generateStream(List<AIMessage> messages, {int maxTokens = 512});
  Future<void> dispose();
}

/// Mock AI controller for the UX preview — simulates responses.
class MockAIController extends AIController {
  @override
  String get providerId => 'mock';

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<String> generate(List<AIMessage> messages, {int maxTokens = 512}) async {
    await Future.delayed(const Duration(seconds: 1));
    final lastMsg = messages.lastWhere((m) => m.role == 'user', orElse: () => messages.last);
    return _mockResponse(lastMsg.content);
  }

  @override
  Stream<String> generateStream(List<AIMessage> messages, {int maxTokens = 512}) async* {
    final response = await generate(messages, maxTokens: maxTokens);
    final words = response.split(' ');
    for (final word in words) {
      await Future.delayed(const Duration(milliseconds: 40));
      yield '$word ';
    }
  }

  @override
  Future<void> dispose() async {}

  String _mockResponse(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('weather')) {
      return 'Currently 24°C and sunny in your area. The forecast shows clear skies through the afternoon with a slight chance of rain this evening.';
    }
    if (lower.contains('task') || lower.contains('todo')) {
      return 'You have 3 tasks due today: Review project proposal (high priority), Update budget spreadsheet, and Schedule team standup. Would you like me to help with any of these?';
    }
    if (lower.contains('finance') || lower.contains('money') || lower.contains('budget')) {
      return 'Your current balance is \$4,280.50. This month you\'ve spent \$1,450 so far, which is 62% of your monthly budget. Your largest expense category is groceries at \$380.';
    }
    if (lower.contains('schedule') || lower.contains('calendar') || lower.contains('event')) {
      return 'You have 3 events today: Team standup at 10:00 AM, Lunch with Sarah at 12:30 PM, and Dentist appointment at 3:00 PM.';
    }
    return 'I understand you\'re asking about "$input". In the full version, I\'ll process this through a local LLM. For now, I can help navigate you to the right section of the app. Try asking about tasks, weather, finances, or your schedule!';
  }
}

/// Central AI service that manages models and controllers.
class AIService extends ChangeNotifier {
  static final AIService _instance = AIService._();
  factory AIService() => _instance;
  AIService._();

  final List<AIModel> _models = [];
  AIController? _activeController;
  String? _activeModelId;

  List<AIModel> get models => List.unmodifiable(_models);
  AIController? get activeController => _activeController;
  String? get activeModelId => _activeModelId;
  bool get isReady => _activeController != null;

  /// Initialize with available models from mock data.
  Future<void> initialize(List<Map<String, dynamic>> modelData) async {
    _models.clear();
    for (final m in modelData) {
      _models.add(AIModel(
        id: m['id'] as String,
        name: m['name'] as String,
        provider: m['provider'] as String,
        size: m['size'] as String? ?? 'unknown',
        contextWindow: m['context_window'] as int? ?? 8192,
        isLocal: m['provider'] == 'local' || m['provider'] == 'ollama',
      ));
    }
    // Auto-activate mock controller for UX preview
    _activeController = MockAIController();
    await _activeController!.initialize();
    _activeModelId = 'mock';
    notifyListeners();
  }

  /// Simulate downloading a model.
  Stream<double> downloadModel(String modelId) async* {
    final model = _models.firstWhere((m) => m.id == modelId);
    model.status = ModelStatus.downloading;
    notifyListeners();

    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 100));
      model.downloadProgress = i / 100;
      notifyListeners();
      yield model.downloadProgress;
    }

    model.status = ModelStatus.ready;
    notifyListeners();
  }

  /// Switch to a specific model.
  Future<void> activateModel(String modelId) async {
    _activeModelId = modelId;
    // In the real version, this would load the model into memory
    // For now, keep mock controller
    notifyListeners();
  }

  /// Send a message and get a response.
  Future<String> chat(String userMessage, {List<AIMessage>? history}) async {
    if (_activeController == null) {
      return 'No AI model is active. Please select a model in Settings > AI Providers.';
    }

    final messages = [
      ...?history,
      AIMessage(role: 'user', content: userMessage, timestamp: DateTime.now()),
    ];

    return _activeController!.generate(messages);
  }

  /// Send a message and get a streaming response.
  Stream<String> chatStream(String userMessage, {List<AIMessage>? history}) {
    if (_activeController == null) {
      return Stream.value('No AI model is active.');
    }

    final messages = [
      ...?history,
      AIMessage(role: 'user', content: userMessage, timestamp: DateTime.now()),
    ];

    return _activeController!.generateStream(messages);
  }
}
