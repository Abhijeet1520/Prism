# Prism — API Integration Specification

## 1 Provider Integration Layer

### 1.1 LangChain.dart Adapter

All AI providers are accessed through a unified LangChain.dart adapter:

```dart
abstract class PrismAiProvider {
  String get providerId;
  String get displayName;
  bool get supportsStreaming;
  bool get supportsToolCalling;

  Future<BaseChatModel> getChatModel(ModelConfig config);
  Future<List<ModelInfo>> listModels();
  Future<bool> testConnection();
}
```

### 1.2 Provider Packages

| Provider | Package | Version | Notes |
|---|---|---|---|
| OpenAI | `langchain_openai` + `dart_openai` | latest | GPT-4o, GPT-4, GPT-3.5 |
| Google Gemini | `langchain_google` | latest | Gemini Pro, Flash |
| Ollama | `langchain_ollama` | latest | Local/LAN server |
| Mistral | `langchain_mistralai` | latest | Mistral Large/Medium/Small |
| Anthropic | REST via `http` | — | Claude 3.x (no langchain_anthropic yet) |
| Custom OpenAI | `dart_openai` | 6.1.1 | Any OpenAI-compatible endpoint |
| Local (llama.cpp) | `llama_cpp_dart` | 0.2.2 | GGUF via FFI |

---

## 2 OpenAI Integration

### 2.1 Configuration

```dart
// Via dart_openai for flexible base URL support
OpenAI.apiKey = apiKey;
OpenAI.baseUrl = baseUrl; // Custom endpoints (LM Studio, vLLM, etc.)

// Via langchain_openai for LangChain integration
final model = ChatOpenAI(
  apiKey: apiKey,
  baseUrl: baseUrl,
  defaultOptions: ChatOpenAIOptions(
    model: 'gpt-4o',
    temperature: 0.7,
    maxTokens: 4096,
  ),
);
```

### 2.2 Endpoints Used

| Endpoint | Use |
|---|---|
| `POST /v1/chat/completions` | Chat with streaming |
| `GET /v1/models` | List available models |
| `POST /v1/embeddings` | (Future) RAG embeddings |

### 2.3 Function Calling

```dart
// LangChain.dart tool binding
final tools = [
  ToolSpec(
    name: 'web_search',
    description: 'Search the web for information',
    inputJsonSchema: {
      'type': 'object',
      'properties': {
        'query': {'type': 'string', 'description': 'Search query'},
      },
      'required': ['query'],
    },
  ),
];

final response = await model.invoke(
  PromptValue.chat(messages),
  options: ChatOpenAIOptions(tools: tools),
);
```

---

## 3 Ollama Integration

### 3.1 Discovery

```dart
// mDNS/DNS-SD scan for Ollama instances
class OllamaDiscovery {
  /// Scan LAN for Ollama services
  Future<List<OllamaInstance>> scanNetwork({
    Duration timeout = const Duration(seconds: 5),
  });

  /// Check if Ollama is running at a specific host
  Future<bool> checkHost(String host, int port);
}
```

### 3.2 API Endpoints

| Endpoint | Use |
|---|---|
| `GET /api/tags` | List local models |
| `POST /api/pull` | Download model |
| `DELETE /api/delete` | Remove model |
| `POST /api/chat` | Chat completion (streaming) |
| `POST /api/generate` | Text completion |
| `GET /api/ps` | Running models |

### 3.3 LangChain Integration

```dart
final ollama = ChatOllama(
  baseUrl: 'http://192.168.1.100:11434',
  defaultOptions: ChatOllamaOptions(
    model: 'gemma2:9b',
    temperature: 0.7,
  ),
);
```

---

## 4 Local Inference (llama_cpp_dart)

### 4.1 Model Loading

```dart
import 'package:llama_cpp_dart/llama_cpp_dart.dart';

class LocalInferenceService {
  LlamaModel? _model;

  Future<void> loadModel(String ggufPath, {
    int nCtx = 4096,
    int nGpuLayers = 35,
    bool useMmap = true,
  }) async {
    _model = await LlamaModel.load(
      ggufPath,
      params: ModelParams(
        nCtx: nCtx,
        nGpuLayers: nGpuLayers,
        useMmap: useMmap,
      ),
    );
  }

  Stream<String> generate(String prompt, {
    double temperature = 0.7,
    int maxTokens = 2048,
  }) async* {
    // Runs in isolate to prevent UI jank
    yield* _model!.generate(prompt,
      samplingParams: SamplingParams(
        temperature: temperature,
        maxTokens: maxTokens,
      ),
    );
  }
}
```

### 4.2 Supported Model Formats

| Format | Extension | Notes |
|---|---|---|
| GGUF | `.gguf` | Primary format, all quantizations |
| Quantizations | Q4_0, Q4_K_M, Q5_K_M, Q8_0 | Smaller = faster, larger = better quality |

### 4.3 Platform Support

| Platform | GPU Acceleration |
|---|---|
| Android | Vulkan (where available) |
| Windows | CUDA, Vulkan |
| macOS | Metal |
| Linux | CUDA, Vulkan |
| Web | Not supported (requires FFI) |

---

## 5 Google Gemini Integration

### 5.1 Configuration

```dart
final gemini = ChatGoogleGenerativeAI(
  apiKey: apiKey,
  defaultOptions: ChatGoogleGenerativeAIOptions(
    model: 'gemini-1.5-flash',
    temperature: 0.7,
    maxOutputTokens: 8192,
  ),
);
```

### 5.2 Endpoints

- Google AI Studio API: `https://generativelanguage.googleapis.com/v1beta/`
- Vertex AI (self-hosted): configurable base URL.

---

## 6 Mistral Integration

### 6.1 Configuration

```dart
final mistral = ChatMistralAI(
  apiKey: apiKey,
  defaultOptions: ChatMistralAIOptions(
    model: 'mistral-large-latest',
    temperature: 0.7,
    maxTokens: 4096,
  ),
);
```

---

## 7 Anthropic Claude Integration

### 7.1 REST API (No LangChain adapter yet)

```dart
class AnthropicProvider extends PrismAiProvider {
  final _client = http.Client();

  Future<ChatResponse> chat(List<ChatMessage> messages, {
    String model = 'claude-3-5-sonnet-20241022',
    double temperature = 0.7,
    int maxTokens = 4096,
  }) async {
    final response = await _client.post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'model': model,
        'max_tokens': maxTokens,
        'temperature': temperature,
        'messages': messages.map((m) => m.toJson()).toList(),
      }),
    );
    // Parse response...
  }
}
```

---

## 8 Model Context Protocol (MCP)

### 8.1 MCP Host (Connecting to External Servers)

```dart
import 'package:mcp_dart/mcp_dart.dart';

class McpHostService {
  final Map<String, McpClient> _clients = {};

  /// Connect to an MCP server via stdio
  Future<void> connectStdio(McpServerConfig config) async {
    final transport = StdioTransport(
      command: config.command,
      args: config.args,
    );
    final client = McpClient(transport);
    await client.connect();
    _clients[config.id] = client;
  }

  /// Connect to an MCP server via SSE
  Future<void> connectSse(McpServerConfig config) async {
    final transport = SseTransport(url: config.url);
    final client = McpClient(transport);
    await client.connect();
    _clients[config.id] = client;
  }

  /// List tools from a connected server
  Future<List<ToolInfo>> listTools(String serverId) async {
    return await _clients[serverId]!.listTools();
  }

  /// Invoke a tool on a connected server
  Future<ToolResult> invokeTool(String serverId, String toolName, Map<String, dynamic> args) async {
    return await _clients[serverId]!.callTool(toolName, args);
  }
}
```

### 8.2 MCP Client (Exposing Prism's Tools)

```dart
class McpClientService {
  late McpServer _server;

  Future<void> startServer({int port = 3000}) async {
    _server = McpServer(
      name: 'prism',
      version: '1.0.0',
      tools: _getExposedTools(),
    );

    final transport = SseServerTransport(port: port);
    await _server.serve(transport);
  }

  List<ToolDefinition> _getExposedTools() {
    return [
      ToolDefinition(
        name: 'prism_search',
        description: 'Search across Prism conversations, files, and notes',
        inputSchema: {/*...*/},
        handler: (args) => _handleSearch(args),
      ),
      ToolDefinition(
        name: 'prism_create_note',
        description: 'Create a new note in Prism Second Brain',
        inputSchema: {/*...*/},
        handler: (args) => _handleCreateNote(args),
      ),
    ];
  }
}
```

### 8.3 MCP Protocol Details

| Transport | Use Case |
|---|---|
| stdio | Local MCP servers (CLI tools, scripts) |
| SSE | Remote MCP servers (networked services) |

| MCP Method | Direction | Purpose |
|---|---|---|
| `tools/list` | Host → Server | Discover available tools |
| `tools/call` | Host → Server | Invoke a tool |
| `resources/list` | Host → Server | List available resources |
| `resources/read` | Host → Server | Read a resource |
| `prompts/list` | Host → Server | List prompt templates |
| `prompts/get` | Host → Server | Get a prompt template |

---

## 9 AI Gateway — shelf HTTP Server

### 9.1 Server Setup

```dart
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

class GatewayServer {
  HttpServer? _server;

  Future<void> start({int port = 8080}) async {
    final router = Router();

    // OpenAI-compatible endpoints
    router.get('/v1/models', _handleListModels);
    router.post('/v1/chat/completions', _handleChatCompletion);

    // Health check
    router.get('/health', (req) => Response.ok('{"status":"ok"}'));

    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(_authMiddleware())
        .addMiddleware(_rateLimitMiddleware())
        .addHandler(router.call);

    _server = await io.serve(handler, 'localhost', port);
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }
}
```

### 9.2 OpenAI-Compatible API Surface

#### `GET /v1/models`

```json
{
  "object": "list",
  "data": [
    {
      "id": "local-gemma-2-9b",
      "object": "model",
      "created": 1700000000,
      "owned_by": "prism-local"
    },
    {
      "id": "ollama-llama3.1",
      "object": "model",
      "created": 1700000000,
      "owned_by": "prism-ollama"
    }
  ]
}
```

#### `POST /v1/chat/completions`

Request:
```json
{
  "model": "local-gemma-2-9b",
  "messages": [
    {"role": "system", "content": "You are a helpful assistant."},
    {"role": "user", "content": "Hello!"}
  ],
  "temperature": 0.7,
  "max_tokens": 2048,
  "stream": true
}
```

Response (streaming SSE):
```
data: {"id":"chatcmpl-xxx","object":"chat.completion.chunk","choices":[{"delta":{"content":"Hi"},"index":0}]}
data: {"id":"chatcmpl-xxx","object":"chat.completion.chunk","choices":[{"delta":{"content":" there!"},"index":0}]}
data: [DONE]
```

### 9.3 Authentication Middleware

```dart
Middleware _authMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final auth = request.headers['authorization'];
      if (auth == null || !auth.startsWith('Bearer ')) {
        return Response(401, body: '{"error":"Missing API key"}');
      }
      final token = auth.substring(7);
      final isValid = await _validateToken(token);
      if (!isValid) {
        return Response(403, body: '{"error":"Invalid API key"}');
      }
      return innerHandler(request);
    };
  };
}
```

---

## 10 Supabase Cloud Sync

### 10.1 Authentication

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

// Initialize
await Supabase.initialize(
  url: supabaseUrl,
  anonKey: supabaseAnonKey,
);

// Auth
final response = await supabase.auth.signInWithPassword(
  email: email,
  password: password,
);

// OAuth
await supabase.auth.signInWithOAuth(OAuthProvider.google);
```

### 10.2 Sync Strategy

```dart
class SyncService {
  /// Bidirectional sync with last-write-wins conflict resolution
  Future<SyncResult> sync() async {
    final lastSyncTime = await _getLastSyncTime();

    // 1. Push local changes since last sync
    final localChanges = await _getLocalChangesSince(lastSyncTime);
    await _pushToSupabase(localChanges);

    // 2. Pull remote changes since last sync
    final remoteChanges = await _pullFromSupabase(lastSyncTime);
    await _applyLocally(remoteChanges);

    // 3. Resolve conflicts (last-write-wins)
    await _resolveConflicts();

    await _updateLastSyncTime();
    return SyncResult(pushed: localChanges.length, pulled: remoteChanges.length);
  }
}
```

### 10.3 Supabase Tables

| Local (Drift) | Remote (Supabase) | Sync | Notes |
|---|---|---|---|
| Conversations | conversations | Yes | |
| Messages | messages | Yes | |
| Personas | personas | Yes | |
| PrismFiles (metadata) | files | Yes | Content synced via Storage |
| ParaItems | para_items | Yes | |
| ParaNotes | para_notes | Yes | |
| Tasks | tasks | Yes | |
| Transactions | transactions | Optional | Excluded by default (privacy) |
| AppSettings | settings | Yes | |
| Providers | — | No | Contains API keys |
| GatewayTokens | — | No | Local-only |
| McpServers | — | No | Local configuration |

---

## 11 GitHub Integration

### 11.1 Configuration

```dart
import 'package:github/github.dart';

class GitHubService {
  late GitHub _github;

  void configure(String token) {
    _github = GitHub(auth: Authentication.withToken(token));
  }

  Future<List<Repository>> listRepos() async {
    return await _github.repositories.listRepositories().toList();
  }

  Future<List<Issue>> listIssues(RepositorySlug slug) async {
    return await _github.issues.listByRepo(slug).toList();
  }

  Future<Issue> createIssue(RepositorySlug slug, IssueRequest request) async {
    return await _github.issues.create(slug, request);
  }

  Future<PullRequest> createPR(RepositorySlug slug, CreatePullRequest request) async {
    return await _github.pullRequests.create(slug, request);
  }
}
```

### 11.2 Capabilities

| Feature | API | Method |
|---|---|---|
| List repos | `GET /user/repos` | `repositories.listRepositories()` |
| Browse files | `GET /repos/:owner/:repo/contents/:path` | `repositories.getContents()` |
| List issues | `GET /repos/:owner/:repo/issues` | `issues.listByRepo()` |
| Create issue | `POST /repos/:owner/:repo/issues` | `issues.create()` |
| List PRs | `GET /repos/:owner/:repo/pulls` | `pullRequests.list()` |
| Create PR | `POST /repos/:owner/:repo/pulls` | `pullRequests.create()` |
| Gists | `GET /gists` | `gists.listGists()` |

---

## 12 Browser Automation

### 12.1 Firecrawl (All Platforms)

```dart
// REST API — no Dart package, direct HTTP calls
class FirecrawlService {
  final String apiKey;
  final String baseUrl;

  FirecrawlService({
    required this.apiKey,
    this.baseUrl = 'https://api.firecrawl.dev',
  });

  /// Scrape a single URL
  Future<ScrapedPage> scrape(String url) async {
    final response = await http.post(
      Uri.parse('$baseUrl/v1/scrape'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'url': url, 'formats': ['markdown']}),
    );
    return ScrapedPage.fromJson(jsonDecode(response.body));
  }

  /// Crawl a website
  Future<String> crawl(String url, {int maxPages = 10}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/v1/crawl'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'url': url, 'limit': maxPages}),
    );
    return jsonDecode(response.body)['id'];  // Job ID for status polling
  }
}
```

### 12.2 Puppeteer (Desktop Only)

```dart
import 'package:puppeteer/puppeteer.dart';

class BrowserAutomationService {
  /// Available only on desktop platforms
  Future<String> getPageContent(String url) async {
    final browser = await puppeteer.launch(headless: true);
    final page = await browser.newPage();
    await page.goto(url, wait: Until.networkIdle);
    final content = await page.content;
    await browser.close();
    return content;
  }

  /// Take screenshot of a page
  Future<Uint8List> screenshot(String url) async {
    final browser = await puppeteer.launch(headless: true);
    final page = await browser.newPage();
    await page.goto(url, wait: Until.networkIdle);
    final bytes = await page.screenshot();
    await browser.close();
    return bytes;
  }
}
```

---

## 13 On-Device ML (Android)

### 13.1 Summarization

```dart
import 'package:google_mlkit_genai_summarization/google_mlkit_genai_summarization.dart';

class OnDeviceSummarizer {
  final _summarizer = GenAiSummarization();

  /// Summarize text on-device (Android only)
  Future<String> summarize(String text) async {
    final result = await _summarizer.summarize(text);
    return result.summary;
  }

  /// Used for:
  /// - Conversation summary when exceeding context window
  /// - File preview generation
  /// - Notification digest
  /// - Daily briefing content
}
```

---

## 14 Notification Listener (Android)

### 14.1 Service Setup

```dart
import 'package:notification_listener_service/notification_listener_service.dart';

class NotificationBridge {
  StreamSubscription? _subscription;

  Future<void> startListening({
    required List<String> allowedPackages,
    required Function(TransactionData) onTransaction,
  }) async {
    // Check permission
    final hasPermission = await NotificationListenerService.isPermissionGranted();
    if (!hasPermission) {
      await NotificationListenerService.requestPermission();
    }

    _subscription = NotificationListenerService.notificationsStream.listen(
      (event) {
        if (allowedPackages.contains(event.packageName)) {
          final transaction = _parseTransaction(event);
          if (transaction != null) {
            onTransaction(transaction);
          }
        }
      },
    );
  }

  TransactionData? _parseTransaction(ServiceNotificationEvent event) {
    final text = event.content ?? '';
    // Regex patterns for common banking apps
    // e.g., "Debited INR 500.00 from A/c XX1234 to Merchant Name"
    final patterns = [
      RegExp(r'(?:debited|spent|paid)\s*(?:INR|Rs\.?|₹)\s*([\d,.]+)', caseSensitive: false),
      RegExp(r'(?:credited|received)\s*(?:INR|Rs\.?|₹)\s*([\d,.]+)', caseSensitive: false),
    ];
    // Parse and return TransactionData...
  }
}
```

---

## 15 Code Execution

### 15.1 Remote Execution API

```dart
class RemoteExecutor {
  final String serverUrl;

  Future<ExecutionResult> execute(String code, String language) async {
    final response = await http.post(
      Uri.parse('$serverUrl/execute'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'code': code,
        'language': language,
        'timeout': 30000,  // 30 seconds
      }),
    );
    return ExecutionResult.fromJson(jsonDecode(response.body));
  }

  /// WebSocket for streaming output
  Stream<String> executeStreaming(String code, String language) async* {
    final ws = await WebSocket.connect('$serverUrl/execute/stream');
    ws.add(jsonEncode({'code': code, 'language': language}));
    await for (final message in ws) {
      yield message;
    }
    ws.close();
  }
}
```

### 15.2 Local Execution (QuickJS)

```dart
import 'package:flutter_js/flutter_js.dart';

class QuickJsExecutor {
  final _runtime = getJavascriptRuntime();

  Future<String> executeJs(String code) async {
    final result = _runtime.evaluate(code);
    if (result.isError) {
      throw ExecutionError(result.stringResult);
    }
    return result.stringResult;
  }
}
```
