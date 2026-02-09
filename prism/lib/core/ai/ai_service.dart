/// Prism AI Service — unified provider abstraction for local + cloud inference.
///
/// Supports: Local GGUF (llama_sdk), Ollama, OpenAI-compatible APIs, Mock.
/// Provider-agnostic interface for chat, streaming, and tool calling.
library;

import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_ollama/langchain_ollama.dart';
import 'package:llama_sdk/llama_sdk.dart' as llama;
import 'package:shared_preferences/shared_preferences.dart';

import 'persona_manager.dart';
import 'soul_document.dart';

// ─── Provider Types ──────────────────────────────────

enum ProviderType { local, ollama, openai, gemini, custom, mock }

// ─── Model Config ────────────────────────────────────

class ModelConfig {
  final String id;
  final String name;
  final ProviderType provider;
  final String? filePath;
  final String? baseUrl;
  final String? apiKey;
  final int contextWindow;
  final double temperature;
  final double topP;
  final int maxTokens;
  final bool supportsVision;
  final bool supportsTools;

  const ModelConfig({
    required this.id,
    required this.name,
    required this.provider,
    this.filePath,
    this.baseUrl,
    this.apiKey,
    this.contextWindow = 4096,
    this.temperature = 0.7,
    this.topP = 0.9,
    this.maxTokens = 2048,
    this.supportsVision = false,
    this.supportsTools = false,
  });

  ModelConfig copyWith({
    String? id,
    String? name,
    ProviderType? provider,
    String? filePath,
    String? baseUrl,
    String? apiKey,
    int? contextWindow,
    double? temperature,
    double? topP,
    int? maxTokens,
    bool? supportsVision,
    bool? supportsTools,
  }) =>
      ModelConfig(
        id: id ?? this.id,
        name: name ?? this.name,
        provider: provider ?? this.provider,
        filePath: filePath ?? this.filePath,
        baseUrl: baseUrl ?? this.baseUrl,
        apiKey: apiKey ?? this.apiKey,
        contextWindow: contextWindow ?? this.contextWindow,
        temperature: temperature ?? this.temperature,
        topP: topP ?? this.topP,
        maxTokens: maxTokens ?? this.maxTokens,
        supportsVision: supportsVision ?? this.supportsVision,
        supportsTools: supportsTools ?? this.supportsTools,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'provider': provider.name,
        'filePath': filePath,
        'baseUrl': baseUrl,
        'apiKey': apiKey,
        'contextWindow': contextWindow,
        'temperature': temperature,
        'topP': topP,
        'maxTokens': maxTokens,
        'supportsVision': supportsVision,
        'supportsTools': supportsTools,
      };

  factory ModelConfig.fromJson(Map<String, dynamic> json) => ModelConfig(
        id: json['id'] as String,
        name: json['name'] as String,
        provider: ProviderType.values.byName(json['provider'] as String),
        filePath: json['filePath'] as String?,
        baseUrl: json['baseUrl'] as String?,
        apiKey: json['apiKey'] as String?,
        contextWindow: json['contextWindow'] as int? ?? 4096,
        temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
        topP: (json['topP'] as num?)?.toDouble() ?? 0.9,
        maxTokens: json['maxTokens'] as int? ?? 2048,
        supportsVision: json['supportsVision'] as bool? ?? false,
        supportsTools: json['supportsTools'] as bool? ?? false,
      );
}

// ─── Tool Stream Events ──────────────────────────────

/// Sealed type for events from streaming with tools.
sealed class ToolStreamEvent {}

/// A content token from the model (normal text streaming).
class ToolStreamContent extends ToolStreamEvent {
  final String content;
  ToolStreamContent(this.content);
}

/// The model is requesting a tool call — needs user approval.
class ToolCallRequest extends ToolStreamEvent {
  final String id;
  final String name;
  final Map<String, dynamic> arguments;
  /// Raw `tool_calls` array for sending back as the assistant message.
  final List<Map<String, dynamic>> rawToolCalls;

  ToolCallRequest({
    required this.id,
    required this.name,
    required this.arguments,
    required this.rawToolCalls,
  });
}

// ─── Chat Message ────────────────────────────────────

class PrismMessage {
  final String role;
  final String content;
  final DateTime timestamp;
  final Map<String, dynamic>? toolCalls;
  final String? toolCallId; // For role='tool' responses

  PrismMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
    this.toolCalls,
    this.toolCallId,
  }) : timestamp = timestamp ?? DateTime.now();

  static PrismMessage user(String content) =>
      PrismMessage(role: 'user', content: content);

  static PrismMessage assistant(String content) =>
      PrismMessage(role: 'assistant', content: content);

  static PrismMessage system(String content) =>
      PrismMessage(role: 'system', content: content);

  /// Create a tool result message (sent back to the model after tool execution).
  static PrismMessage tool(String content, {required String toolCallId}) =>
      PrismMessage(role: 'tool', content: content, toolCallId: toolCallId);
}

// ─── Service State ───────────────────────────────────

class AIServiceState {
  final ModelConfig? activeModel;
  final List<ModelConfig> availableModels;
  final bool isGenerating;
  final bool isModelLoaded;
  final String? error;
  final double? loadProgress;
  final ModelConfig? favouriteFastModel;
  final ModelConfig? favouriteGoodModel;

  const AIServiceState({
    this.activeModel,
    this.availableModels = const [],
    this.isGenerating = false,
    this.isModelLoaded = false,
    this.error,
    this.loadProgress,
    this.favouriteFastModel,
    this.favouriteGoodModel,
  });

  AIServiceState copyWith({
    ModelConfig? activeModel,
    List<ModelConfig>? availableModels,
    bool? isGenerating,
    bool? isModelLoaded,
    String? error,
    double? loadProgress,
    ModelConfig? favouriteFastModel,
    ModelConfig? favouriteGoodModel,
    bool clearError = false,
    bool clearActiveModel = false,
    bool clearFastModel = false,
    bool clearGoodModel = false,
  }) =>
      AIServiceState(
        activeModel: clearActiveModel ? null : (activeModel ?? this.activeModel),
        availableModels: availableModels ?? this.availableModels,
        isGenerating: isGenerating ?? this.isGenerating,
        isModelLoaded: isModelLoaded ?? this.isModelLoaded,
        error: clearError ? null : (error ?? this.error),
        loadProgress: loadProgress ?? this.loadProgress,
        favouriteFastModel: clearFastModel ? null : (favouriteFastModel ?? this.favouriteFastModel),
        favouriteGoodModel: clearGoodModel ? null : (favouriteGoodModel ?? this.favouriteGoodModel),
      );
}

// ─── AI Service Notifier ─────────────────────────────

class AIServiceNotifier extends Notifier<AIServiceState> {
  llama.Llama? _llamaModel;
  ChatOllama? _ollamaModel;
  final _streamController = StreamController<String>.broadcast();
  Stream<String> get tokenStream => _streamController.stream;
  bool _stopRequested = false;

  @override
  AIServiceState build() {
    ref.onDispose(() {
      _llamaModel?.stop();
      _ollamaModel?.close();
      _streamController.close();
    });
    _loadSavedModels();
    return const AIServiceState(
      availableModels: [
        ModelConfig(
          id: 'mock',
          name: 'Prism (Demo)',
          provider: ProviderType.mock,
          contextWindow: 4096,
        ),
      ],
      activeModel: ModelConfig(
        id: 'mock',
        name: 'Prism (Demo)',
        provider: ProviderType.mock,
        contextWindow: 4096,
      ),
      isModelLoaded: true,
    );
  }

  Future<void> _loadSavedModels() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modelsJson = prefs.getString('saved_models');
      if (modelsJson != null) {
        final list = (jsonDecode(modelsJson) as List)
            .map((e) => ModelConfig.fromJson(e as Map<String, dynamic>))
            .toList();
        state = state.copyWith(
          availableModels: [
            ...state.availableModels,
            ...list.where(
                (m) => !state.availableModels.any((e) => e.id == m.id)),
          ],
        );
      }

      // Load favourite models
      final fastJson = prefs.getString('favourite_fast_model');
      final goodJson = prefs.getString('favourite_good_model');
      if (fastJson != null) {
        state = state.copyWith(
            favouriteFastModel: ModelConfig.fromJson(
                jsonDecode(fastJson) as Map<String, dynamic>));
      }
      if (goodJson != null) {
        state = state.copyWith(
            favouriteGoodModel: ModelConfig.fromJson(
                jsonDecode(goodJson) as Map<String, dynamic>));
      }
    } catch (_) {}
  }

  Future<void> _saveModels() async {
    final prefs = await SharedPreferences.getInstance();
    final saveable = state.availableModels
        .where((m) => m.provider != ProviderType.mock)
        .map((m) => m.toJson())
        .toList();
    await prefs.setString('saved_models', jsonEncode(saveable));
  }

  /// Set favourite fast model (lightweight, quick responses).
  Future<void> setFavouriteFastModel(ModelConfig? model) async {
    final prefs = await SharedPreferences.getInstance();
    if (model != null) {
      await prefs.setString('favourite_fast_model', jsonEncode(model.toJson()));
      state = state.copyWith(favouriteFastModel: model);
    } else {
      await prefs.remove('favourite_fast_model');
      state = state.copyWith(clearFastModel: true);
    }
  }

  /// Set favourite good model (higher quality, may be slower).
  Future<void> setFavouriteGoodModel(ModelConfig? model) async {
    final prefs = await SharedPreferences.getInstance();
    if (model != null) {
      await prefs.setString('favourite_good_model', jsonEncode(model.toJson()));
      state = state.copyWith(favouriteGoodModel: model);
    } else {
      await prefs.remove('favourite_good_model');
      state = state.copyWith(clearGoodModel: true);
    }
  }

  // ─── Model Management ──────────────────────────────

  void addModel(ModelConfig model) {
    final models = [...state.availableModels];
    models.removeWhere((m) => m.id == model.id);
    models.add(model);
    state = state.copyWith(availableModels: models);
    _saveModels();
  }

  void removeModel(String modelId) {
    state = state.copyWith(
      availableModels:
          state.availableModels.where((m) => m.id != modelId).toList(),
    );
    if (state.activeModel?.id == modelId) {
      _unloadModel();
      state = state.copyWith(clearActiveModel: true);
    }
    _saveModels();
  }

  Future<void> selectModel(ModelConfig config) async {
    _unloadModel();
    state = state.copyWith(
        activeModel: config,
        isModelLoaded: false,
        clearError: true);

    switch (config.provider) {
      case ProviderType.local:
        await _loadLocalModel(config);
      case ProviderType.ollama:
        _initOllama(config);
      case ProviderType.openai:
      case ProviderType.gemini:
      case ProviderType.custom:
        state = state.copyWith(isModelLoaded: true);
      case ProviderType.mock:
        state = state.copyWith(isModelLoaded: true);
    }
  }

  Future<void> _loadLocalModel(ModelConfig config) async {
    if (config.filePath == null) {
      state = state.copyWith(error: 'No model file path specified');
      return;
    }
    try {
      state = state.copyWith(loadProgress: 0.0);
      // Keep params minimal — matches Maid's proven approach.
      // Only model_path, seed, and greedy are needed.
      // n_ctx/temperature/top_p passed to LlamaController can conflict
      // with greedy sampling and cause silent failures on small models.
      _llamaModel = llama.Llama(
        llama.LlamaController.fromMap({
          'model_path': config.filePath!,
          'seed': DateTime.now().millisecondsSinceEpoch % 1000000,
          'n_ctx': config.contextWindow,
          'greedy': true,
        }),
      );
      state = state.copyWith(isModelLoaded: true, loadProgress: 1.0);
    } catch (e) {
      state = state.copyWith(
          error: 'Failed to load model: $e', loadProgress: null);
    }
  }

  void _initOllama(ModelConfig config) {
    _ollamaModel = ChatOllama(
      defaultOptions: ChatOllamaOptions(
        model: config.id,
        temperature: config.temperature,
        numCtx: config.contextWindow,
      ),
      baseUrl: config.baseUrl ?? 'http://localhost:11434/api',
    );
    state = state.copyWith(isModelLoaded: true);
  }

  void _unloadModel() {
    try {
      // reload() frees native FFI resources and kills the isolate.
      // stop() alone only halts generation but leaves stale resources.
      _llamaModel?.reload();
    } catch (_) {}
    _llamaModel = null;
    _ollamaModel?.close();
    _ollamaModel = null;
    state = state.copyWith(isModelLoaded: false, loadProgress: null);
  }

  // ─── Inference ─────────────────────────────────────

  Stream<String> generateStream(List<PrismMessage> messages) async* {
    final config = state.activeModel;
    if (config == null) {
      yield 'No model selected. Go to Settings > AI Providers to configure.';
      return;
    }

    state = state.copyWith(isGenerating: true, clearError: true);
    _stopRequested = false;

    // Inject persona system prompt if not already present
    final messagesWithPersona = _injectPersonaPrompt(messages);

    try {
      switch (config.provider) {
        case ProviderType.local:
          yield* _generateLocal(messagesWithPersona);
        case ProviderType.ollama:
          yield* _generateOllama(messagesWithPersona);
        case ProviderType.mock:
          yield* _generateMock(messagesWithPersona);
        case ProviderType.openai:
        case ProviderType.gemini:
        case ProviderType.custom:
          yield* _generateAPI(messagesWithPersona, config);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      yield '\n\n⚠️ Error: $e';
    } finally {
      state = state.copyWith(isGenerating: false);
    }
  }

  /// Inject the active persona's system prompt and soul document into the message list.
  List<PrismMessage> _injectPersonaPrompt(List<PrismMessage> messages) {
    try {
      final personaState = ref.read(personaManagerProvider);
      final systemPrompt = personaState.activePersona?.systemPrompt ?? '';

      // Build soul context
      String soulContext = '';
      try {
        final soulState = ref.read(soulDocumentProvider);
        soulContext = soulState.toContextString();
      } catch (_) {}

      final fullSystemPrompt = [
        if (systemPrompt.isNotEmpty) systemPrompt,
        if (soulContext.isNotEmpty) soulContext,
      ].join('\n\n');

      if (fullSystemPrompt.isEmpty) return messages;

      // Don't double-inject if there's already a system message
      if (messages.isNotEmpty && messages.first.role == 'system') {
        return messages;
      }

      return [PrismMessage.system(fullSystemPrompt), ...messages];
    } catch (_) {
      // Persona manager not yet initialized
      return messages;
    }
  }

  Future<String> generate(List<PrismMessage> messages) async {
    final buffer = StringBuffer();
    await for (final token in generateStream(messages)) {
      buffer.write(token);
    }
    return buffer.toString();
  }

  void stopGeneration() {
    _stopRequested = true;
    try {
      _llamaModel?.stop();
    } catch (_) {}
  }

  // ─── Streaming with Tools (OpenAI function calling) ───

  /// A sealed result type for streaming with tools.
  /// Yields either content tokens (String) or a tool call request.
  Stream<ToolStreamEvent> generateStreamWithTools(
    List<PrismMessage> messages, {
    List<Map<String, dynamic>>? tools,
  }) async* {
    final config = state.activeModel;
    if (config == null) {
      yield ToolStreamContent('No model selected.');
      return;
    }

    state = state.copyWith(isGenerating: true, clearError: true);
    _stopRequested = false;

    final messagesWithPersona = _injectPersonaPrompt(messages);

    try {
      // For API providers that support native tool calling
      if ((config.provider == ProviderType.openai ||
              config.provider == ProviderType.gemini ||
              config.provider == ProviderType.custom) &&
          tools != null &&
          tools.isNotEmpty) {
        yield* _generateAPIWithTools(messagesWithPersona, config, tools);
      } else if (config.provider == ProviderType.mock) {
        // Mock: simulate tool calling
        yield* _generateMockWithTools(messagesWithPersona, tools);
      } else {
        // Fallback: no tool calling, just stream content
        await for (final token in generateStream(messages)) {
          yield ToolStreamContent(token);
        }
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      yield ToolStreamContent('\n\n⚠️ Error: $e');
    } finally {
      state = state.copyWith(isGenerating: false);
    }
  }

  /// Stream from an OpenAI-compatible API with tools support.
  /// Parses both content deltas and tool_calls deltas from SSE.
  Stream<ToolStreamEvent> _generateAPIWithTools(
    List<PrismMessage> messages,
    ModelConfig config,
    List<Map<String, dynamic>> tools,
  ) async* {
    final baseUrl = config.baseUrl;
    if (baseUrl == null || baseUrl.isEmpty) {
      yield ToolStreamContent('No API endpoint configured.');
      return;
    }

    final isOpenRouter = baseUrl.contains('openrouter.ai');
    String modelId = config.id;
    if (isOpenRouter) {
      if (modelId.startsWith('openrouter/')) {
        modelId = modelId.substring('openrouter/'.length);
      }
    } else {
      final parts = modelId.split('/');
      if (parts.length == 2 &&
          ['openai', 'gemini', 'anthropic', 'mistral', 'custom']
              .contains(parts[0])) {
        modelId = parts[1];
      }
    }

    final dio = Dio();
    try {
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
      };

      if (config.apiKey != null && config.apiKey!.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${config.apiKey}';
        if (isOpenRouter) {
          headers['HTTP-Referer'] = 'https://prism.app';
          headers['X-Title'] = 'Prism AI';
        }
        if (baseUrl.contains('anthropic.com')) {
          headers.remove('Authorization');
          headers['x-api-key'] = config.apiKey;
          headers['anthropic-version'] = '2023-06-01';
        }
      }

      // Build message objects — handle tool role and tool_calls
      final apiMessages = messages.map((m) {
        final msg = <String, dynamic>{
          'role': m.role,
          'content': m.content,
        };
        // If assistant message had tool_calls, include them
        if (m.role == 'assistant' && m.toolCalls != null) {
          msg['tool_calls'] = m.toolCalls!['tool_calls'];
          // Content can be null for pure tool-call assistant messages
          if (m.content.isEmpty) msg['content'] = null;
        }
        // Tool result messages need tool_call_id
        if (m.role == 'tool' && m.toolCallId != null) {
          msg['tool_call_id'] = m.toolCallId;
        }
        return msg;
      }).toList();

      final body = <String, dynamic>{
        'model': modelId,
        'messages': apiMessages,
        'temperature': config.temperature,
        'max_tokens': config.maxTokens,
        'stream': true,
        'tools': tools,
      };

      final response = await dio.post(
        '$baseUrl/chat/completions',
        data: body,
        options: Options(
          headers: headers,
          responseType: ResponseType.stream,
          validateStatus: (s) => s != null && s < 500,
        ),
      );

      if (response.statusCode != null && response.statusCode! >= 400) {
        try {
          final errorStream = response.data?.stream as Stream<List<int>>?;
          if (errorStream != null) {
            final errorBytes = <int>[];
            await for (final chunk in errorStream) {
              errorBytes.addAll(chunk);
            }
            final errorBody = utf8.decode(errorBytes);
            yield ToolStreamContent('\n\n⚠️ API Error (${response.statusCode}): $errorBody');
          }
        } catch (_) {
          yield ToolStreamContent('\n\n⚠️ API Error: HTTP ${response.statusCode}');
        }
        return;
      }

      final stream = response.data?.stream as Stream<List<int>>?;
      if (stream == null) {
        yield ToolStreamContent('No response stream from API.');
        return;
      }

      String buffer = '';
      // Accumulated tool calls from streaming deltas
      final toolCallsAccumulator = <int, Map<String, dynamic>>{};
      bool hasToolCalls = false;

      await for (final chunk in stream) {
        if (_stopRequested) break;
        buffer += utf8.decode(chunk);
        final lines = buffer.split('\n');
        buffer = lines.removeLast();

        for (final line in lines) {
          if (line.startsWith(':')) continue;
          if (!line.startsWith('data: ')) continue;
          final data = line.substring(6).trim();
          if (data == '[DONE]') continue;
          if (data.isEmpty) continue;
          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            final error = json['error'] as Map<String, dynamic>?;
            if (error != null) {
              yield ToolStreamContent('\n\n⚠️ ${error['message']}');
              return;
            }
            final choices = json['choices'] as List?;
            if (choices != null && choices.isNotEmpty) {
              final delta = choices[0]['delta'] as Map<String, dynamic>?;
              if (delta == null) continue;

              // Stream content
              final content = delta['content'] as String?;
              if (content != null) {
                _streamController.add(content);
                yield ToolStreamContent(content);
              }

              // Accumulate tool_calls deltas
              final toolCalls = delta['tool_calls'] as List?;
              if (toolCalls != null) {
                hasToolCalls = true;
                for (final tc in toolCalls) {
                  final tcMap = tc as Map<String, dynamic>;
                  final idx = tcMap['index'] as int? ?? 0;
                  if (!toolCallsAccumulator.containsKey(idx)) {
                    toolCallsAccumulator[idx] = {
                      'id': tcMap['id'] ?? '',
                      'type': 'function',
                      'function': {'name': '', 'arguments': ''},
                    };
                  }
                  final existing = toolCallsAccumulator[idx]!;
                  if (tcMap['id'] != null) {
                    existing['id'] = tcMap['id'];
                  }
                  final fn = tcMap['function'] as Map<String, dynamic>?;
                  if (fn != null) {
                    final eFn = existing['function'] as Map<String, dynamic>;
                    if (fn['name'] != null) {
                      eFn['name'] = (eFn['name'] as String) + (fn['name'] as String);
                    }
                    if (fn['arguments'] != null) {
                      eFn['arguments'] = (eFn['arguments'] as String) + (fn['arguments'] as String);
                    }
                  }
                }
              }

              // Check for finish_reason
              final finishReason = choices[0]['finish_reason'] as String?;
              if (finishReason == 'tool_calls' && hasToolCalls) {
                // Emit all accumulated tool calls
                final allCalls = toolCallsAccumulator.entries.toList()
                  ..sort((a, b) => a.key.compareTo(b.key));
                for (final entry in allCalls) {
                  final tc = entry.value;
                  final fn = tc['function'] as Map<String, dynamic>;
                  Map<String, dynamic> parsedArgs = {};
                  try {
                    parsedArgs = jsonDecode(fn['arguments'] as String) as Map<String, dynamic>;
                  } catch (_) {}
                  yield ToolCallRequest(
                    id: tc['id'] as String,
                    name: fn['name'] as String,
                    arguments: parsedArgs,
                    rawToolCalls: allCalls.map((e) => e.value).toList(),
                  );
                }
              }
            }
          } catch (_) {}
        }
      }
    } on DioException catch (e) {
      yield ToolStreamContent('\n\n⚠️ API error: ${e.message}');
    } finally {
      dio.close();
    }
  }

  /// Mock tool calling for demo mode.
  Stream<ToolStreamEvent> _generateMockWithTools(
    List<PrismMessage> messages,
    List<Map<String, dynamic>>? tools,
  ) async* {
    final lastMsg = messages.lastWhere(
      (m) => m.role == 'user',
      orElse: () => PrismMessage.user('hello'),
    );

    // Check if this looks like a tool-result follow-up (has tool messages)
    final hasToolResults = messages.any((m) => m.role == 'tool');
    if (hasToolResults) {
      // Generate a natural response after tool execution
      const reply = 'Done! I\'ve completed the action for you. '
          'Is there anything else you\'d like me to help with?';
      for (final char in reply.split('')) {
        if (_stopRequested) break;
        await Future.delayed(const Duration(milliseconds: 12));
        yield ToolStreamContent(char);
      }
      return;
    }

    final lower = lastMsg.content.toLowerCase();
    // Check if AI should call a tool
    if (tools != null && tools.isNotEmpty) {
      if (lower.contains('task') || lower.contains('todo')) {
        yield ToolCallRequest(
          id: 'call_mock_1',
          name: 'add_task',
          arguments: {'title': 'New task from AI', 'priority': 'medium'},
          rawToolCalls: [
            {
              'id': 'call_mock_1',
              'type': 'function',
              'function': {
                'name': 'add_task',
                'arguments': '{"title":"New task from AI","priority":"medium"}',
              },
            }
          ],
        );
        return;
      }
      if (lower.contains('expense') || lower.contains('spent')) {
        yield ToolCallRequest(
          id: 'call_mock_2',
          name: 'log_expense',
          arguments: {'amount': 25.0, 'category': 'food', 'type': 'expense'},
          rawToolCalls: [
            {
              'id': 'call_mock_2',
              'type': 'function',
              'function': {
                'name': 'log_expense',
                'arguments': '{"amount":25.0,"category":"food","type":"expense"}',
              },
            }
          ],
        );
        return;
      }
      if (lower.contains('note') || lower.contains('remember')) {
        yield ToolCallRequest(
          id: 'call_mock_3',
          name: 'create_note',
          arguments: {'title': 'Note from AI', 'content': lastMsg.content},
          rawToolCalls: [
            {
              'id': 'call_mock_3',
              'type': 'function',
              'function': {
                'name': 'create_note',
                'arguments': jsonEncode({
                  'title': 'Note from AI',
                  'content': lastMsg.content,
                }),
              },
            }
          ],
        );
        return;
      }
    }

    // No tool needed — stream normal response
    await for (final token in _generateMock(messages)) {
      yield ToolStreamContent(token);
    }
  }

  // ─── Local Model (llama_sdk) ───────────────────────

  Stream<String> _generateLocal(List<PrismMessage> messages) async* {
    if (_llamaModel == null) {
      yield 'Model not loaded. Please select a local model first.';
      return;
    }

    // Filter out tool-related messages that confuse local models.
    // Only keep system, user, and assistant messages with actual content.
    final cleanMessages = messages.where((m) {
      // Skip tool call metadata, tool results, and empty messages
      if (m.role == 'tool' || m.role == 'tool_call') return false;
      if (m.content.trim().isEmpty && m.toolCalls == null) return false;
      // Skip assistant messages that only had tool calls (no text)
      if (m.role == 'assistant' && m.content.trim().isEmpty) return false;
      return true;
    }).toList();

    // For small models (<=4B), trim the system prompt to save context
    final config = state.activeModel;
    final isSmallModel = (config?.contextWindow ?? 8192) <= 8192;
    final trimmedMessages = isSmallModel
        ? _trimSystemPromptForLocalModel(cleanMessages)
        : cleanMessages;

    final llamaMessages = trimmedMessages
        .map((m) => llama.LlamaMessage.withRole(
              role: switch (m.role) {
                'assistant' => 'assistant',
                'system' => 'system',
                _ => 'user',
              },
              content: m.content,
            ))
        .toList();

    // Ensure we have at least one user message
    if (llamaMessages.isEmpty ||
        !llamaMessages.any((m) => m.role == 'user')) {
      yield 'No message to process.';
      return;
    }

    bool hasOutput = false;
    try {
      await for (final token in _llamaModel!.prompt(llamaMessages)) {
        if (_stopRequested) break;
        hasOutput = true;
        _streamController.add(token);
        yield token;
      }
    } catch (e) {
      yield '\n\n⚠️ Local model error: $e';
      return;
    }

    if (!hasOutput) {
      yield 'The model did not generate a response. This can happen if:\n'
          '- The model file is corrupted or incompatible\n'
          '- The context window is full — try a shorter conversation\n'
          '- Try restarting the app or re-selecting the model.';
    }
  }

  /// Trim system prompt for local models to leave enough context for conversation.
  /// Caps the system prompt at ~1000 chars to reserve context for user messages.
  List<PrismMessage> _trimSystemPromptForLocalModel(
      List<PrismMessage> messages) {
    if (messages.isEmpty || messages.first.role != 'system') return messages;

    final systemMsg = messages.first;
    var systemContent = systemMsg.content;

    // Cap system prompt at 1000 chars for local models
    const maxSystemLen = 1000;
    if (systemContent.length > maxSystemLen) {
      // Keep the persona instructions, trim the soul document
      final soulStart = systemContent.indexOf('=== USER CONTEXT');
      if (soulStart > 0 && soulStart < maxSystemLen) {
        // Keep persona part + abbreviated soul context
        systemContent = '${systemContent.substring(0, soulStart)}'
            '[User context available but trimmed for context window efficiency]';
      } else {
        systemContent = '${systemContent.substring(0, maxSystemLen)}...';
      }
    }

    return [
      PrismMessage.system(systemContent),
      ...messages.skip(1),
    ];
  }

  // ─── Ollama ────────────────────────────────────────

  Stream<String> _generateOllama(List<PrismMessage> messages) async* {
    if (_ollamaModel == null) {
      yield 'Ollama not configured.';
      return;
    }
    final chatMessages = messages.map(_toChatMessage).toList();
    final stream =
        _ollamaModel!.pipe(const StringOutputParser()).stream(
      PromptValue.chat(chatMessages),
    );
    await for (final chunk in stream) {
      if (_stopRequested) break;
      _streamController.add(chunk);
      yield chunk;
    }
  }

  // ─── API Providers (OpenAI-compatible) ─────────────

  Stream<String> _generateAPI(
      List<PrismMessage> messages, ModelConfig config) async* {
    final baseUrl = config.baseUrl;
    if (baseUrl == null || baseUrl.isEmpty) {
      yield 'No API endpoint configured for this provider.';
      return;
    }

    // For OpenRouter, keep the full model ID (e.g. "google/gemma-2-9b-it")
    // For other providers, strip provider prefix if present (e.g. "openai/gpt-4o" → "gpt-4o")
    final isOpenRouter = baseUrl.contains('openrouter.ai');
    String modelId = config.id;
    // Strip our internal provider prefix (e.g. "openrouter/google/gemma-2-9b-it" → "google/gemma-2-9b-it")
    if (isOpenRouter) {
      if (modelId.startsWith('openrouter/')) {
        modelId = modelId.substring('openrouter/'.length);
      }
    } else {
      // For non-OpenRouter, strip any provider prefix
      final parts = modelId.split('/');
      if (parts.length == 2 &&
          ['openai', 'gemini', 'anthropic', 'mistral', 'custom']
              .contains(parts[0])) {
        modelId = parts[1];
      }
    }

    final dio = Dio();
    try {
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
      };

      // Add auth headers based on provider
      if (config.apiKey != null && config.apiKey!.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${config.apiKey}';
        // OpenRouter requires HTTP-Referer and X-Title
        if (isOpenRouter) {
          headers['HTTP-Referer'] = 'https://prism.app';
          headers['X-Title'] = 'Prism AI';
        }
        // Anthropic uses x-api-key
        if (baseUrl.contains('anthropic.com')) {
          headers.remove('Authorization');
          headers['x-api-key'] = config.apiKey;
          headers['anthropic-version'] = '2023-06-01';
        }
      }

      final body = <String, dynamic>{
        'model': modelId,
        'messages': messages.map((m) => <String, dynamic>{
              'role': m.role,
              'content': m.content,
            }).toList(),
        'temperature': config.temperature,
        'max_tokens': config.maxTokens,
        'stream': true,
      };

      final response = await dio.post(
        '$baseUrl/chat/completions',
        data: body,
        options: Options(
          headers: headers,
          responseType: ResponseType.stream,
          validateStatus: (s) => s != null && s < 500,
        ),
      );

      // Handle non-200 responses (e.g. 400, 401, 402, 429)
      if (response.statusCode != null && response.statusCode! >= 400) {
        // Try to read the error body
        try {
          final errorStream = response.data?.stream as Stream<List<int>>?;
          if (errorStream != null) {
            final errorBytes = <int>[];
            await for (final chunk in errorStream) {
              errorBytes.addAll(chunk);
            }
            final errorBody = utf8.decode(errorBytes);
            try {
              final errJson = jsonDecode(errorBody) as Map<String, dynamic>;
              final errMsg = errJson['error'] is Map
                  ? (errJson['error'] as Map)['message'] ?? errorBody
                  : errJson['error'] ?? errorBody;
              yield '\n\n⚠️ API Error (${response.statusCode}): $errMsg';
            } catch (_) {
              yield '\n\n⚠️ API Error (${response.statusCode}): $errorBody';
            }
          } else {
            yield '\n\n⚠️ API Error: HTTP ${response.statusCode}';
          }
        } catch (_) {
          yield '\n\n⚠️ API Error: HTTP ${response.statusCode}';
        }
        return;
      }

      final stream = response.data?.stream as Stream<List<int>>?;
      if (stream == null) {
        yield 'No response stream from API.';
        return;
      }

      String buffer = '';
      await for (final chunk in stream) {
        if (_stopRequested) break;
        buffer += utf8.decode(chunk);
        final lines = buffer.split('\n');
        buffer = lines.removeLast(); // keep incomplete line

        for (final line in lines) {
          // Skip SSE comments (OpenRouter sends these)
          if (line.startsWith(':')) continue;
          if (!line.startsWith('data: ')) continue;
          final data = line.substring(6).trim();
          if (data == '[DONE]') continue;
          if (data.isEmpty) continue;
          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            // Check for error in response
            final error = json['error'] as Map<String, dynamic>?;
            if (error != null) {
              yield '\n\n⚠️ ${error['message'] ?? 'Unknown error'}';
              return;
            }
            final choices = json['choices'] as List?;
            if (choices != null && choices.isNotEmpty) {
              final delta = choices[0]['delta'] as Map<String, dynamic>?;
              final content = delta?['content'] as String?;
              if (content != null) {
                _streamController.add(content);
                yield content;
              }
            }
          } catch (_) {}
        }
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        yield '\n\n⚠️ Authentication failed. Check your API key in Settings > AI Providers.';
      } else if (e.response?.statusCode == 402) {
        yield '\n\n⚠️ Insufficient credits. Please check your account balance.';
      } else if (e.response?.statusCode == 429) {
        yield '\n\n⚠️ Rate limit exceeded. Please wait and try again.';
      } else {
        final responseBody = e.response?.data;
        String detail = e.message ?? 'Connection failed';
        if (responseBody is Map) {
          final errObj = responseBody['error'];
          if (errObj is Map) {
            detail = errObj['message']?.toString() ?? detail;
          } else if (errObj is String) {
            detail = errObj;
          }
        }
        yield '\n\n⚠️ API error: $detail';
      }
    } finally {
      dio.close();
    }
  }

  // ─── Mock ──────────────────────────────────────────

  Stream<String> _generateMock(List<PrismMessage> messages) async* {
    final lastMsg = messages.lastWhere((m) => m.role == 'user',
        orElse: () => PrismMessage.user('hello'));
    final response = _mockResponse(lastMsg.content);
    for (final char in response.split('')) {
      if (_stopRequested) break;
      await Future.delayed(const Duration(milliseconds: 12));
      _streamController.add(char);
      yield char;
    }
  }

  // ─── Tool Calling ──────────────────────────────────

  Future<String> generateWithTools(
    List<PrismMessage> messages,
    List<ToolSpec> tools,
  ) async {
    final config = state.activeModel;
    if (config == null) return 'No model selected.';

    if (config.provider == ProviderType.mock) {
      return _mockToolResponse(messages.last.content, tools);
    }

    // Build tool description for prompt-based tool calling
    final toolDesc = tools.map((t) {
      final params = t.inputJsonSchema;
      return '- **${t.name}**: ${t.description}\n'
          '  Parameters: ${jsonEncode(params)}';
    }).join('\n');

    final systemMsg = PrismMessage.system(
      'You have access to the following tools:\n$toolDesc\n\n'
      'When you need to use a tool, respond with ONLY a JSON object:\n'
      '{"tool": "tool_name", "args": {"param": "value"}}\n\n'
      'If no tool is needed, respond normally to the user.',
    );

    if (config.provider == ProviderType.ollama && _ollamaModel != null) {
      try {
        final allMessages = [systemMsg, ...messages];
        final chatMessages = allMessages.map(_toChatMessage).toList();
        final result = await _ollamaModel!
            .invoke(PromptValue.chat(chatMessages));
        return result.output.content;
      } catch (e) {
        return 'Tool calling error: $e';
      }
    }

    // All other providers: prompt-based tool calling
    return generate([systemMsg, ...messages]);
  }

  // ─── Ollama Discovery ──────────────────────────────

  Future<List<String>> discoverOllamaModels({
    String baseUrl = 'http://localhost:11434',
  }) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        '$baseUrl/api/tags',
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
        ),
      );
      dio.close();

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final models = (data['models'] as List<dynamic>?)
            ?.map((m) => (m as Map<String, dynamic>)['name'] as String)
            .toList();
        return models ?? [];
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ─── Helpers ───────────────────────────────────────

  ChatMessage _toChatMessage(PrismMessage msg) => switch (msg.role) {
        'system' => ChatMessage.system(msg.content),
        'assistant' => ChatMessage.ai(msg.content),
        _ => ChatMessage.humanText(msg.content),
      };

  String _mockResponse(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('weather')) {
      return '☀️ It\'s currently 24°C and sunny. Perfect day to stay productive! '
          'Would you like me to add an outdoor activity to your tasks?';
    }
    if (lower.contains('task') ||
        lower.contains('todo') ||
        lower.contains('plan')) {
      return '📋 Here\'s a suggested plan:\n\n'
          '1. **Morning** — Review pending tasks and prioritize\n'
          '2. **Midday** — Focus on the highest priority item\n'
          '3. **Afternoon** — Handle secondary tasks\n'
          '4. **Evening** — Review progress and plan tomorrow\n\n'
          'Want me to create these as tasks?';
    }
    if (lower.contains('expense') ||
        lower.contains('finance') ||
        lower.contains('money')) {
      return '💰 I can help track expenses! Tell me:\n\n'
          '- **Amount** and **category** (food, transport, etc.)\n'
          '- Or say "log \$25 for lunch" and I\'ll parse it\n\n'
          'Check the Finance section in Apps Hub for your spending.';
    }
    if (lower.contains('note') ||
        lower.contains('brain') ||
        lower.contains('remember')) {
      return '🧠 I\'ll save that to your Brain! Organize using PARA:\n\n'
          '- **Projects** — Active goals with deadlines\n'
          '- **Areas** — Ongoing responsibilities\n'
          '- **Resources** — Reference material\n'
          '- **Archives** — Completed or inactive\n\n'
          'What would you like to save?';
    }
    if (lower.contains('hello') ||
        lower.contains('hi') ||
        lower.contains('hey')) {
      return 'Hello! 👋 I\'m Prism, your AI assistant.\n\n'
          '- 💬 **Chat** — Ask me anything\n'
          '- 📋 **Tasks** — Manage your to-do list\n'
          '- 💰 **Finance** — Track expenses\n'
          '- 🧠 **Brain** — Save and organize knowledge\n'
          '- 🔧 **Tools** — OCR, language detection, and more\n\n'
          'What would you like to do?';
    }
    return 'I understand your question about "$input". '
        'I\'m currently in demo mode.\n\n'
        'To get real AI responses:\n'
        '1. **Local Model** — Download a GGUF model in Settings\n'
        '2. **Ollama** — Connect to a local Ollama instance\n'
        '3. **Cloud API** — Add an API key (OpenAI, Gemini, etc.)\n\n'
        'Go to **Settings > AI Providers** to get started!';
  }

  String _mockToolResponse(String input, List<ToolSpec> tools) {
    final lower = input.toLowerCase();
    if (lower.contains('task') && tools.any((t) => t.name == 'add_task')) {
      return '{"tool": "add_task", "args": {"title": "New task from AI", "priority": "medium"}}';
    }
    if (lower.contains('expense') &&
        tools.any((t) => t.name == 'log_expense')) {
      return '{"tool": "log_expense", "args": {"amount": 25.0, "category": "food"}}';
    }
    return 'No matching tool for this request.';
  }
}

// ─── Riverpod Provider ───────────────────────────────

final aiServiceProvider = NotifierProvider<AIServiceNotifier, AIServiceState>(
  AIServiceNotifier.new,
);
