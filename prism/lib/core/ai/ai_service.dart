/// Prism AI Service Layer
///
/// Provides a unified interface for AI model interaction using LangChain.dart.
/// Supports multiple backends: Ollama (local network), OpenAI, Gemini, and
/// a mock controller for development/testing.
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_ollama/langchain_ollama.dart';

// ─── Model configuration ─────────────────────────────────────

enum AIProvider { ollama, openai, gemini, mock }

class AIModelConfig {
  final String id;
  final String name;
  final AIProvider provider;
  final String? baseUrl;
  final String? apiKey;
  final int contextWindow;
  final double temperature;

  const AIModelConfig({
    required this.id,
    required this.name,
    required this.provider,
    this.baseUrl,
    this.apiKey,
    this.contextWindow = 8192,
    this.temperature = 0.7,
  });

  AIModelConfig copyWith({
    String? id,
    String? name,
    AIProvider? provider,
    String? baseUrl,
    String? apiKey,
    int? contextWindow,
    double? temperature,
  }) {
    return AIModelConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      provider: provider ?? this.provider,
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      contextWindow: contextWindow ?? this.contextWindow,
      temperature: temperature ?? this.temperature,
    );
  }
}

// ─── Chat message model ──────────────────────────────────────

class PrismMessage {
  final String role; // 'user' | 'assistant' | 'system'
  final String content;
  final DateTime timestamp;
  final Map<String, dynamic>? toolCalls;

  const PrismMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.toolCalls,
  });
}

// ─── AI Service state ────────────────────────────────────────

class AIServiceState {
  final AIModelConfig? activeModel;
  final List<AIModelConfig> availableModels;
  final bool isGenerating;
  final String? error;

  const AIServiceState({
    this.activeModel,
    this.availableModels = const [],
    this.isGenerating = false,
    this.error,
  });

  AIServiceState copyWith({
    AIModelConfig? activeModel,
    List<AIModelConfig>? availableModels,
    bool? isGenerating,
    String? error,
  }) {
    return AIServiceState(
      activeModel: activeModel ?? this.activeModel,
      availableModels: availableModels ?? this.availableModels,
      isGenerating: isGenerating ?? this.isGenerating,
      error: error,
    );
  }
}

// ─── AI Service notifier ─────────────────────────────────────

class AIServiceNotifier extends Notifier<AIServiceState> {
  ChatOllama? _ollamaModel;
  final _streamController = StreamController<String>.broadcast();

  /// Exposes the token stream for UI consumption.
  Stream<String> get tokenStream => _streamController.stream;

  @override
  AIServiceState build() {
    ref.onDispose(() {
      _ollamaModel?.close();
      _streamController.close();
    });

    // Start with default models
    return AIServiceState(
      availableModels: [
        const AIModelConfig(
          id: 'gemma3:4b',
          name: 'Gemma 3 4B',
          provider: AIProvider.ollama,
          baseUrl: 'http://localhost:11434',
        ),
        const AIModelConfig(
          id: 'gemma3:12b',
          name: 'Gemma 3 12B',
          provider: AIProvider.ollama,
          baseUrl: 'http://localhost:11434',
        ),
        const AIModelConfig(
          id: 'mock',
          name: 'Mock (Development)',
          provider: AIProvider.mock,
        ),
      ],
      activeModel: const AIModelConfig(
        id: 'mock',
        name: 'Mock (Development)',
        provider: AIProvider.mock,
      ),
    );
  }

  /// Switch to a different model configuration.
  void selectModel(AIModelConfig config) {
    _ollamaModel?.close();
    _ollamaModel = null;

    if (config.provider == AIProvider.ollama) {
      _ollamaModel = ChatOllama(
        defaultOptions: ChatOllamaOptions(
          model: config.id,
          temperature: config.temperature,
          numCtx: config.contextWindow,
        ),
      );
      // Override base URL if provided
      // Note: ChatOllama uses baseUrl parameter in constructor
    }

    state = state.copyWith(activeModel: config);
  }

  /// Add a custom model (e.g., user adds their own Ollama model).
  void addModel(AIModelConfig model) {
    state = state.copyWith(
      availableModels: [...state.availableModels, model],
    );
  }

  /// Generate a complete response (non-streaming).
  Future<String> generate(List<PrismMessage> messages) async {
    final config = state.activeModel;
    if (config == null) return 'No model selected.';

    state = state.copyWith(isGenerating: true, error: null);

    try {
      if (config.provider == AIProvider.mock) {
        final response = _mockResponse(messages.last.content);
        state = state.copyWith(isGenerating: false);
        return response;
      }

      if (config.provider == AIProvider.ollama && _ollamaModel != null) {
        final chatMessages = messages.map(_toChatMessage).toList();
        final result = await _ollamaModel!.invoke(
          PromptValue.chat(chatMessages),
        );
        state = state.copyWith(isGenerating: false);
        return result.output.content;
      }

      state = state.copyWith(isGenerating: false);
      return 'Provider ${config.provider.name} not yet implemented.';
    } catch (e) {
      state = state.copyWith(isGenerating: false, error: e.toString());
      return 'Error: $e';
    }
  }

  /// Generate a streaming response. Returns a [Stream] of token chunks.
  Stream<String> generateStream(List<PrismMessage> messages) async* {
    final config = state.activeModel;
    if (config == null) {
      yield 'No model selected.';
      return;
    }

    state = state.copyWith(isGenerating: true, error: null);

    try {
      if (config.provider == AIProvider.mock) {
        final response = _mockResponse(messages.last.content);
        for (final word in response.split(' ')) {
          await Future.delayed(const Duration(milliseconds: 35));
          yield '$word ';
          _streamController.add('$word ');
        }
        state = state.copyWith(isGenerating: false);
        return;
      }

      if (config.provider == AIProvider.ollama && _ollamaModel != null) {
        final chatMessages = messages.map(_toChatMessage).toList();
        final prompt = PromptValue.chat(chatMessages);

        final chain = _ollamaModel!.pipe(const StringOutputParser());
        final stream = chain.stream(prompt);

        await for (final chunk in stream) {
          yield chunk;
          _streamController.add(chunk);
        }
        state = state.copyWith(isGenerating: false);
        return;
      }

      yield 'Provider ${config.provider.name} not yet implemented.';
      state = state.copyWith(isGenerating: false);
    } catch (e) {
      state = state.copyWith(isGenerating: false, error: e.toString());
      yield 'Error: $e';
    }
  }

  /// Generate with tool calling support.
  Future<String> generateWithTools(
    List<PrismMessage> messages,
    List<ToolSpec> tools,
  ) async {
    final config = state.activeModel;
    if (config == null) return 'No model selected.';
    if (config.provider != AIProvider.ollama || _ollamaModel == null) {
      return 'Tool calling requires an Ollama model.';
    }

    state = state.copyWith(isGenerating: true, error: null);

    try {
      final chatMessages = messages.map(_toChatMessage).toList();
      final model = _ollamaModel!.bind(
        ChatOllamaOptions(model: config.id, tools: tools),
      );

      final result = await model.invoke(PromptValue.chat(chatMessages));
      final aiMessage = result.output;

      // Check if the model wants to call a tool
      if (aiMessage.toolCalls.isNotEmpty) {
        state = state.copyWith(isGenerating: false);
        // Return a JSON-like representation of tool calls for the caller to handle
        final toolCallsStr = aiMessage.toolCalls
            .map((tc) => '${tc.name}(${tc.arguments})')
            .join(', ');
        return '[TOOL_CALL] $toolCallsStr';
      }

      state = state.copyWith(isGenerating: false);
      return aiMessage.content;
    } catch (e) {
      state = state.copyWith(isGenerating: false, error: e.toString());
      return 'Error: $e';
    }
  }

  /// Discover models available on an Ollama server.
  Future<List<String>> discoverOllamaModels({
    String baseUrl = 'http://localhost:11434',
  }) async {
    try {
      // Use ollama_dart client to list models
      final client = ChatOllama(
        defaultOptions: const ChatOllamaOptions(model: 'dummy'),
      );
      // For now, return common models. Real discovery needs the Ollama REST API.
      client.close();
      return ['gemma3:4b', 'gemma3:12b', 'llama3.2:3b', 'phi4-mini'];
    } catch (e) {
      return [];
    }
  }

  // ── Helpers ──────────────────────────────────────

  ChatMessage _toChatMessage(PrismMessage msg) {
    return switch (msg.role) {
      'system' => ChatMessage.system(msg.content),
      'user' => ChatMessage.humanText(msg.content),
      'assistant' => ChatMessage.ai(msg.content),
      _ => ChatMessage.humanText(msg.content),
    };
  }

  String _mockResponse(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('weather')) {
      return 'Currently 24°C and sunny. Clear skies through the afternoon with a slight chance of rain this evening.';
    }
    if (lower.contains('task') || lower.contains('todo')) {
      return 'You have 3 tasks due today: Review project proposal (high), Update budget spreadsheet, Schedule team standup. Want help with any?';
    }
    if (lower.contains('finance') || lower.contains('money') || lower.contains('budget')) {
      return 'Current balance: \$4,280.50. This month: \$1,450 spent (62% of budget). Largest category: groceries at \$380.';
    }
    return 'I understand you\'re asking about "$input". In the real version, I\'ll process this through a local LLM. Try asking about tasks, weather, or finances!';
  }
}

// ── Provider ───────────────────────────────────────

final aiServiceProvider = NotifierProvider<AIServiceNotifier, AIServiceState>(
  AIServiceNotifier.new,
);
