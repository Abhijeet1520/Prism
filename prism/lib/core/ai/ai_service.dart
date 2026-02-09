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
        contextWindow: json['contextWindow'] as int? ?? 4096,
        temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
        topP: (json['topP'] as num?)?.toDouble() ?? 0.9,
        maxTokens: json['maxTokens'] as int? ?? 2048,
        supportsVision: json['supportsVision'] as bool? ?? false,
        supportsTools: json['supportsTools'] as bool? ?? false,
      );
}

// ─── Chat Message ────────────────────────────────────

class PrismMessage {
  final String role;
  final String content;
  final DateTime timestamp;
  final Map<String, dynamic>? toolCalls;

  PrismMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
    this.toolCalls,
  }) : timestamp = timestamp ?? DateTime.now();

  static PrismMessage user(String content) =>
      PrismMessage(role: 'user', content: content);

  static PrismMessage assistant(String content) =>
      PrismMessage(role: 'assistant', content: content);

  static PrismMessage system(String content) =>
      PrismMessage(role: 'system', content: content);
}

// ─── Service State ───────────────────────────────────

class AIServiceState {
  final ModelConfig? activeModel;
  final List<ModelConfig> availableModels;
  final bool isGenerating;
  final bool isModelLoaded;
  final String? error;
  final double? loadProgress;

  const AIServiceState({
    this.activeModel,
    this.availableModels = const [],
    this.isGenerating = false,
    this.isModelLoaded = false,
    this.error,
    this.loadProgress,
  });

  AIServiceState copyWith({
    ModelConfig? activeModel,
    List<ModelConfig>? availableModels,
    bool? isGenerating,
    bool? isModelLoaded,
    String? error,
    double? loadProgress,
    bool clearError = false,
    bool clearActiveModel = false,
  }) =>
      AIServiceState(
        activeModel: clearActiveModel ? null : (activeModel ?? this.activeModel),
        availableModels: availableModels ?? this.availableModels,
        isGenerating: isGenerating ?? this.isGenerating,
        isModelLoaded: isModelLoaded ?? this.isModelLoaded,
        error: clearError ? null : (error ?? this.error),
        loadProgress: loadProgress ?? this.loadProgress,
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
      _llamaModel = llama.Llama(
        llama.LlamaController.fromMap({
          'model_path': config.filePath!,
          'seed': DateTime.now().millisecondsSinceEpoch % 1000000,
          'n_ctx': config.contextWindow,
          'temperature': config.temperature,
          'top_p': config.topP,
          'n_predict': config.maxTokens,
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
      _llamaModel?.stop();
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

  // ─── Local Model (llama_sdk) ───────────────────────

  Stream<String> _generateLocal(List<PrismMessage> messages) async* {
    if (_llamaModel == null) {
      yield 'Model not loaded. Please select a local model first.';
      return;
    }

    // Build prompt for local models — format as chat template
    // Many small GGUF models work better with a single formatted prompt
    final llamaMessages = messages
        .map((m) => llama.LlamaMessage.withRole(
              role: switch (m.role) {
                'assistant' => 'assistant',
                'system' => 'system',
                _ => 'user',
              },
              content: m.content,
            ))
        .toList();

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

    // If model produced no output, it may be a format issue
    if (!hasOutput) {
      yield 'The model did not generate a response. This can happen if:\n'
          '- The model file is corrupted or incompatible\n'
          '- The context window is too small\n'
          '- Try a different model or increase context size in Settings.';
    }
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

    // Extract model ID (strip provider prefix like "openai/gpt-4o")
    final modelId = config.id.contains('/')
        ? config.id.split('/').last
        : config.id;

    final dio = Dio();
    try {
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
      };

      // Add auth headers based on provider
      if (config.apiKey != null && config.apiKey!.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${config.apiKey}';
        // Anthropic uses x-api-key
        if (baseUrl.contains('anthropic.com')) {
          headers.remove('Authorization');
          headers['x-api-key'] = config.apiKey;
          headers['anthropic-version'] = '2023-06-01';
        }
      }

      final body = {
        'model': modelId,
        'messages': messages.map((m) => {
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
        ),
      );

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
          if (!line.startsWith('data: ')) continue;
          final data = line.substring(6).trim();
          if (data == '[DONE]') continue;
          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
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
      } else if (e.response?.statusCode == 429) {
        yield '\n\n⚠️ Rate limit exceeded. Please wait and try again.';
      } else {
        yield '\n\n⚠️ API error: ${e.message}';
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
