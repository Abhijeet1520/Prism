# Research Findings

> Key discoveries, package evaluations, and technical decisions made during sessions.

---

## 2026-02-09

### Gallery App Splash Screen
- Uses Android SplashScreen API with animated vector drawable
- 4 colored shapes (Google brand colors) that scale-in, rotate, and fade out
- Total animation: ~2.6s + 300ms crossfade = ~3 seconds
- Background: white (light) / #131314 (dark)
- While splash shows: pre-loads model allowlist
- **Decision**: We'll create a Flutter-native splash with animated Prism logo (not Android-specific AVD)

### Maid Local Model Architecture
- Uses `llama_sdk: ^0.0.5` (llama.cpp FFI wrapper) for GGUF inference
- Abstract `AIController` hierarchy → `LlamaCppController` (local) + `RemoteAIController` (cloud)
- `ValueNotifier<AIController?>` singleton for global state
- Curated model catalog in YAML (`huggingface.yaml`) with quantization tags
- Download via Dio to app cache with `Stream<double>` progress
- Hash-based reload guard (only reinstantiate when model/params change)
- `.gguf` extension assertion on load
- Conditional web/native imports
- **Decision**: Adopt controller pattern + YAML catalog approach. Start with Ollama support, add llama_sdk later.

### Key Packages to Use
| Package | Purpose | Status |
|---------|---------|--------|
| `ollama_dart` | Local Ollama inference | Primary for v1 |
| `llama_sdk` | Direct GGUF via FFI | Future (needs native build) |
| `dio` | HTTP downloads, API calls | Add for model downloads |
| `file_picker` | GGUF file selection | Add for local model import |
| `path_provider` | App directories | Add |
| `speech_to_text` | Voice input | Evaluate |
| `flutter_tts` | Text-to-speech for AI responses | Evaluate |
| `shared_preferences` | Settings persistence | Add |
| `flutter_animate` | Smooth animations | Add for splash + orb |

### Moon Design Token Reference (from ux_preview)
```
piccolo  = #818CF8  (accent/primary)
goten    = #16162A  (surface/cards)
gohan    = #0C0C16  (scaffold bg)
bulma    = #E2E2EC  (text primary)
trunks   = #7A7A90  (text secondary)
beerus   = #252540  (border)
goku     = #060610  (deepest bg)
```

---

## 2026-02-09 — Deep Dive: Maid App Architecture

> Full reverse-engineering of `repos/maid/` — local GGUF inference, chat messages, cloud providers, UI patterns.

### 1. Project Structure Overview

```
lib/
├── main.dart                          # App entry + all `part` declarations (single-library pattern)
├── controllers/
│   ├── app_settings.dart              # User/assistant names, images, theme, system prompt
│   ├── artificial_intelligence_controller.dart  # AIController hierarchy (870 lines)
│   └── chat_controller.dart           # Chat tree management, persistence (241 lines)
├── utilities/
│   ├── chat_messages.dart             # ChatMessage model + tree structure (242 lines)
│   ├── chat_messages_extension.dart   # toXxxMessages() converters for each provider
│   ├── huggingface_manager.dart       # Model download via Dio + progress streams
│   ├── open_ai_utilities.dart         # OpenAI JSON import mapper
│   ├── string_extension.dart          # String utilities
│   ├── target_platform_extension.dart # Platform checks
│   └── theme_mode_extension.dart      # Theme mode helpers
└── widgets/
    ├── buttons/
    │   ├── load_model_button.dart      # GGUF file picker + model selector popup
    │   └── menu_button.dart            # App bar menu
    ├── chat/
    │   └── chat_tile.dart              # Chat list tile in drawer
    ├── dialogs/
    │   ├── error_dialog.dart           # Error display
    │   ├── nsfw_warning_dialog.dart    # NSFW model warning
    │   └── sharing_dialog.dart         # Shared image → user/assistant avatar
    ├── dropdowns/
    │   ├── artificial_intelligence_dropdown.dart  # Provider switcher
    │   ├── locale_dropdown.dart
    │   ├── remote_model_dropdown.dart  # Remote model picker with auto-fetch
    │   └── theme_mode_dropdown.dart
    ├── layout/
    │   └── main_drawer.dart            # Chat list + new/import/clear + login
    ├── listeners/
    │   └── artificial_intelligence_listener.dart  # Double-ListenableBuilder wrapper
    ├── message/
    │   ├── message.dart                # Message bubble with actions (333 lines)
    │   └── message_view.dart           # Scrollable message chain with pagination
    ├── pages/
    │   ├── home_page.dart              # Main screen: AppBar + MessageView + PromptField
    │   ├── huggingface_page.dart       # Model catalog grid from huggingface.yaml
    │   ├── settings_page.dart
    │   ├── about_page.dart
    │   ├── login_page.dart / registration_page.dart / reset_password_page.dart
    │   └── debug_page.dart
    ├── parameter/
    │   ├── parameter.dart              # Model parameter slider/input
    │   └── parameter_view.dart
    ├── settings/
    │   ├── artificial_intelligence_settings.dart  # Provider config UI
    │   ├── assistant_settings.dart     # Name, image, SillyTavern card import
    │   ├── system_settings.dart
    │   └── user_settings.dart
    ├── text_fields/
    │   ├── api_key_text_field.dart
    │   ├── base_url_text_field.dart
    │   ├── listenable_text_field.dart
    │   ├── prompt_field.dart           # Main chat input with send/stop (202 lines)
    │   └── remote_model_text_field.dart
    └── utilities/
        ├── code_box.dart               # Code block renderer
        └── huggingface_model.dart      # HF model card with download/delete/select (347 lines)
```

**Architecture pattern**: Single-library with `part`/`part of` — all files are parts of `main.dart`. No separate imports between files. Uses `ChangeNotifier` + `ListenableBuilder` throughout (no Provider/Riverpod/Bloc).

---

### 2. AI/LLM Packages (from pubspec.yaml)

| Package | Version | Purpose |
|---------|---------|---------|
| `llama_sdk` | `^0.0.5` | **Local GGUF inference** via FFI (llama.cpp wrapper) |
| `ollama_dart` | `^0.2.3` | Ollama server integration (local/network) |
| `openai_dart` | `^0.5.2` | OpenAI-compatible API (works with OpenRouter via base_url) |
| `mistralai_dart` | `^0.0.4` | Mistral AI API |
| `anthropic_sdk_dart` | `^0.2.1` | Anthropic Claude API |
| `file_picker` | `^9.2.1` | GGUF file selection + chat import/export |
| `dio` | `^5.8.0+1` | Model downloads from HuggingFace + Ollama discovery |
| `shared_preferences` | `^2.5.2` | All state persistence (models, chats, settings) |
| `path_provider` | `^2.1.5` | App cache directory for downloaded models |
| `supabase_flutter` | `^2.8.4` | Cloud sync for chat messages |
| `lan_scanner` | `^4.0.0+1` | Auto-discover Ollama on local network |
| `network_info_plus` | `^6.1.3` | Get device IP for LAN scanning |
| `receive_sharing_intent` | (git ref) | Handle shared files/text from other apps |

---

### 3. Local GGUF Model Loading — Complete Flow

#### 3.1 Controller Hierarchy

```
AIController (abstract, ChangeNotifier)
├── LlamaCppController          ← Local GGUF via llama_sdk
└── RemoteAIController (abstract)
    ├── OllamaController        ← Ollama server
    ├── OpenAIController         ← OpenAI / OpenRouter / any OpenAI-compatible
    ├── MistralController        ← Mistral AI
    └── AnthropicController      ← Anthropic Claude
```

Global singleton pattern:
```dart
static ValueNotifier<AIController?> notifier = ValueNotifier(null);
static AIController get instance => notifier.value ?? defaultController;
static AIController get defaultController => kIsWeb ? OpenAIController() : LlamaCppController();
```

#### 3.2 LlamaCppController — Key Code

**File**: `lib/controllers/artificial_intelligence_controller.dart` (lines 230-380)

```dart
class LlamaCppController extends AIController {
  llama.Llama? _llama;           // The loaded model instance
  String _loadedHash = '';        // Hash-based reload guard
  bool loading = false;           // Loading state for UI

  @override
  bool get canPrompt => _llama != null && !busy;

  // --- PROMPTING ---
  @override
  Stream<String> prompt() async* {
    busy = true;
    reloadModel();               // Ensure model is loaded/current
    yield* _llama!.prompt(ChatController.instance.root.toLlamaMessages());
    busy = false;
  }

  // --- MODEL RELOAD (hash-guarded) ---
  void reloadModel([bool force = false]) async {
    if ((hash == _loadedHash && !force) || _model == null) return;
    _llama = llama.Llama(
      llama.LlamaController.fromMap({
        'model_path': _model,
        'seed': math.Random().nextInt(1000000),
        'greedy': true,
        ..._parameters
      })
    );
    _loadedHash = hash;
  }

  // --- FILE PICKER ---
  void pickModel() async {
    _model = null;
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: "Load Model File",
      type: FileType.any,
      allowMultiple: false,
      allowCompression: false,
      onFileLoading: (status) {
        loading = status == FilePickerStatus.picking;
        super.notifyListeners();
      }
    );
    loading = false;
    if (result == null || result.files.isEmpty || result.files.single.path == null) {
      throw Exception('No file selected');
    }
    _model = result.files.single.path!;
    _modelOptions.removeWhere((model) => model == _model);
    _modelOptions.add(_model!);
    notifyListeners();
  }

  // --- DIRECT PATH LOAD ---
  void loadModelFile(String path, [bool notify = false]) async {
    assert(RegExp(r'\.gguf$', caseSensitive: false).hasMatch(path));
    _model = path;
    reloadModel();
    if (notify) notifyListeners();
  }

  // --- RECENTLY LOADED MODELS (persisted) ---
  void getLoadedModels() async {
    final prefs = await SharedPreferences.getInstance();
    _modelOptions = prefs.getStringList('loaded_models') ?? [];
  }

  void addModelFile(String path) async {
    assert(RegExp(r'\.gguf$', caseSensitive: false).hasMatch(path));
    _modelOptions.add(path);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('loaded_models', _modelOptions);
    reloadModel();
  }

  @override
  void stop() {
    _llama?.stop();
    busy = false;
  }
}
```

#### 3.3 llama_sdk Import (Conditional)

```dart
import 'package:llama_sdk/llama_sdk.dart'
    if (dart.library.html) 'package:llama_sdk/llama_sdk.web.dart' as llama;
```
Web gets a stub. Native gets full FFI.

#### 3.4 Model Download Flow (HuggingFace)

**HuggingfaceManager** (`lib/utilities/huggingface_manager.dart`):
```dart
class HuggingfaceManager {
  static final Map<String, StreamController<double>> downloadProgress = {};

  static Stream<double> download(String repo, String branch, String fileName, LlamaCppController llama) async* {
    final filePath = await getFilePath(fileName);  // → app cache dir
    downloadProgress[fileName] = StreamController<double>.broadcast();

    final future = Dio().download(
      "https://huggingface.co/$repo/resolve/$branch/$fileName?download=true",
      filePath,
      onReceiveProgress: (received, total) {
        final progress = received / total;
        downloadProgress[fileName]!.add(progress);  // Stream progress 0.0→1.0
      },
    );
    yield* downloadProgress[fileName]!.stream;
    await future;
    llama.addModelFile(filePath);  // Register downloaded model
  }
}
```

**Model Catalog** (`huggingface.yaml`):
```yaml
- name: Gemma 2 2B IT
  repo: bartowski/gemma-2-2b-it-GGUF
  branch: main
  parameters: 2.0
  tags:
    Q4_K_M: gemma-2-2b-it-Q4_K_M.gguf
    Q8_0: gemma-2-2b-it-Q8_0.gguf
    F32: gemma-2-2b-it-f32.gguf
```

Models listed: Phi 3 Mini, TinyLlama 1.1B, Gemma 2 2B, Gemma 3 1B, Llama 3.2 1B/3B, Mistral 7B, DeepSeek R1 1.5B/7B, and several NSFW models.

#### 3.5 LoadModelButton UI

Shows a popup menu with:
1. "Load Model" → `FilePicker` for any .gguf file
2. "Download Model" → navigates to HuggingFace catalog page
3. Previously loaded models (from `_modelOptions` list)

Text displays current model filename or "Load Model" placeholder. Shows "Loading..." during file pick.

---

### 4. Chat Message System

#### 4.1 Data Model — Tree Structure

**ChatMessage** (`lib/utilities/chat_messages.dart`) — a **tree node** with branching:

```dart
class ChatMessage extends ChangeNotifier {
  final ValueKey<String> id;            // UUID v7
  final ValueKey<String>? _parent;      // Parent node key
  final ChatMessageRole role;           // user | assistant | system
  final DateTime createdAt;
  String _content;                      // Mutable for streaming
  List<ValueKey<String>> _children;     // Multiple children = branches
  ValueKey<String>? _currentChild;      // Active branch selection

  // Tree navigation
  ChatMessage? get parent => ...;
  ChatMessage? get currentChild => ...;
  List<ChatMessage> get children => ...;
  ChatMessage get root => ...;          // Walk up to root
  ChatMessage get tail => ...;          // Walk down to leaf
  List<ChatMessage> get chain => ...;   // Full chain from this node down

  // Branch operations
  void nextChild() { ... }             // Switch to next sibling branch
  void previousChild() { ... }         // Switch to previous sibling branch
  void addChild(ChatMessage child) { ... }
  void removeChild(ChatMessage child) { ... }

  // Streaming support
  Future<void> listenToStream(Stream<String> stream) async {
    await for (final event in stream) {
      content += event;  // Appends and notifies listeners
    }
  }
}
```

**Key design**: Messages form a tree, not a flat list. Each node can have multiple children (branches). The `_currentChild` pointer selects which branch is active. This enables **conversation branching** — editing a user message or regenerating creates a new branch.

#### 4.2 ChatController — Persistence

```dart
class ChatController extends ChangeNotifier {
  Map<ValueKey<String>, ChatMessage> _mapping = {};  // Flat map of all messages
  ValueKey<String>? _rootKey;                         // Current chat root

  List<ValueKey<String>> get roots => ...;  // All root messages (= all chats)

  void newChat() { ... }
  void deleteChat(ChatMessage chat) { ... }
  void importChat() async { ... }    // FilePicker for JSON
  void exportChat(ChatMessage chat) async { ... }  // Save as JSON

  // Persistence: SharedPreferences + Supabase
  Future<void> save() async {
    // 1. Save to SharedPreferences as JSON string list
    // 2. If logged in, upsert to Supabase 'chat_messages' table
  }
  Future<void> load() async {
    // Try Supabase first, fallback to SharedPreferences
  }
}
```

#### 4.3 Message → Provider Format Conversion

**ChatMessagesExtension** (`lib/utilities/chat_messages_extension.dart`) converts the tree chain to provider-specific message formats:

```dart
extension ChatMessagesExtension on ChatMessage {
  List<llama.LlamaMessage> toLlamaMessages() { ... }
  List<ollama.Message> toOllamaMessages() { ... }
  List<open_ai.ChatCompletionMessage> toOpenAiMessages() { ... }
  List<mistral.ChatCompletionMessage> toMistralMessages() { ... }
  List<anthropic.Message> toAnthropicMessages() { ... }
}
```

Each walks the chain from root → tail, mapping `ChatMessageRole` to the provider's enum, and building the provider's message type.

---

### 5. Chat Message Actions — Edit, Delete, Regenerate, Branch

**MessageWidget** (`lib/widgets/message/message.dart`) — 333 lines, handles all message interactions:

#### 5.1 Action Handlers

```dart
class MessageWidgetState extends State<MessageWidget> {
  bool editing = false;
  final TextEditingController controller = TextEditingController();

  // DELETE — removes current child from parent's children list
  void onDelete() {
    setState(() => widget.node.removeChild(widget.node.currentChild!));
    ChatController.instance.save();
  }

  // EDIT — enters edit mode with TextField
  void onEdit() {
    controller.text = widget.message.content;
    setState(() => editing = true);
  }

  // SUBMIT EDIT — creates NEW branch (doesn't mutate original)
  void onSubmitEdit() {
    final editedMessage = ChatMessage(content: controller.text, role: ChatMessageRole.user);
    widget.node.addChild(editedMessage);     // Adds as new child = new branch
    tryRegenerate(widget.node.currentChild!); // Auto-regenerates response
    setState(() => editing = false);
  }

  // REGENERATE — creates new assistant response branch
  void onRegenerate() => tryRegenerate(widget.node);

  void tryRegenerate(ChatMessage node) async {
    if (LlamaCppController.instance != null) {
      LlamaCppController.instance!.reloadModel(true);
    }
    Stream<String> stream = AIController.instance.prompt();
    final newMessage = ChatMessage(content: '', role: ChatMessageRole.assistant);
    node.addChild(newMessage);               // New branch for regenerated response
    await newMessage.listenToStream(stream);  // Stream tokens into message
    await ChatController.instance.save();
  }

  // BRANCH SWITCH — swipe left/right or arrow buttons
  void onNext() {
    setState(() => widget.node.nextChild());
    ChatController.instance.save();
  }
  void onPrevious() {
    setState(() => widget.node.previousChild());
    ChatController.instance.save();
  }

  // SWIPE GESTURE for branch switching
  void onHorizontalDragEnd(DragEndDetails details) {
    if (AIController.instance.busy) return;
    if (details.primaryVelocity! > 80) onPrevious();
    else if (details.primaryVelocity! < -80) onNext();
  }
}
```

#### 5.2 UI Structure

```
MessageWidget (per message node)
├── buildCurrentMessage()
│   ├── [if editing] buildMessageEditingColumn()
│   │   ├── buildEditingTopRow()
│   │   │   ├── buildRole()         → User/Assistant name + avatar
│   │   │   └── buildEditingActions()
│   │   │       ├── IconButton(done) → onSubmitEdit
│   │   │       └── IconButton(close) → cancel edit
│   │   └── TextField (multiline, autofocus)
│   │
│   └── [if not editing] GestureDetector(onHorizontalDragEnd)
│       └── buildMessageColumn()
│           ├── buildTopRow()
│           │   ├── buildRole()         → User/Assistant name + avatar
│           │   └── buildActions()      → AIListener wrapper
│           │       └── buildActionsRow()
│           │           ├── buildRoleSpecificButton()
│           │           │   ├── [user msg]  IconButton(edit)  → onEdit
│           │           │   └── [asst msg]  IconButton(refresh) → onRegenerate
│           │           ├── buildBranchSwitcher()
│           │           │   ├── IconButton(arrow_left)  → onPrevious
│           │           │   ├── Text("2 / 3")           → branch indicator
│           │           │   └── IconButton(arrow_right) → onNext
│           │           └── buildDeleteButton()
│           │               └── IconButton(delete) → onDelete
│           ├── [content sections — split by ``` for code blocks]
│           │   ├── SelectableText(plain text sections)
│           │   └── CodeBox(code sections)
│           └── buildTime() → "02:30 PM, Feb 9 2026"
│
└── [if buildChild] MessageWidget(child node, chainPosition - 1)  ← Recursive
```

**Key observations**:
- **No copy button** — messages use `SelectableText` so users can manually select/copy
- **No image sending** — the `ChatMessage` model has no image/attachment field; the `SharingDialog` only handles setting user/assistant **avatars**, not sending images in chat
- **Branch indicator** shows "N / M" with left/right arrows
- **Swipe gestures** switch branches on mobile
- **Edit creates new branch** — original message preserved, edited version becomes new sibling
- All actions disabled when `AIController.instance.busy` is true

#### 5.3 MessageView — Pagination

```dart
class MessageViewState extends State<MessageView> {
  static const int maxMessages = 50;  // Render cap per view
  int rootPosition = 0;

  // Virtualizes long chains by only rendering maxMessages at a time
  // Scroll-to-edge triggers loading more messages (rootPosition shifts)
}
```

---

### 6. Prompt Input — PromptField

**File**: `lib/widgets/text_fields/prompt_field.dart`

```dart
void onSubmit() async {
  final prompt = controller.text;
  controller.clear();

  // 1. Create user message, attach to tail of current chain
  final userMessage = ChatMessage(
    parent: ChatController.instance.root.tail.id,
    content: prompt,
    role: ChatMessageRole.user,
  );
  ChatController.instance.root.tail.addChild(userMessage);

  // 2. Call AIController.instance.prompt() → returns Stream<String>
  Stream<String> stream = AIController.instance.prompt();

  // 3. Create empty assistant message, attach to user message
  final assistantMessage = ChatMessage(
    parent: userMessage.id,
    content: '',
    role: ChatMessageRole.assistant
  );
  userMessage.addChild(assistantMessage);

  // 4. Stream tokens into assistant message (notifies UI on each chunk)
  await assistantMessage.listenToStream(stream);
  await ChatController.instance.save();
}
```

**Additional features**:
- Handles shared files via `receive_sharing_intent` (Android only)
- Auto-detects `.gguf` files shared to the app → loads as model
- Stop button switches to red `Icons.stop_circle_sharp` during streaming
- Send button disabled when `!canPrompt` (no model loaded)
- Alt key detection for desktop to allow Enter vs Alt+Enter behavior

---

### 7. Cloud Provider Integration

#### 7.1 OpenAI-Compatible (OpenRouter works here)

```dart
class OpenAIController extends RemoteAIController {
  @override
  Stream<String> prompt() async* {
    _openAiClient = open_ai.OpenAIClient(
      apiKey: _apiKey!,
      baseUrl: _baseUrl,  // Default: 'https://api.openai.com/v1'
                           // Set to 'https://openrouter.ai/api/v1' for OpenRouter
    );
    final completionStream = _openAiClient.createChatCompletionStream(
      request: open_ai.CreateChatCompletionRequest(
        messages: ChatController.instance.root.toOpenAiMessages(),
        model: open_ai.ChatCompletionModel.modelId(_model!),
        stream: true,
        temperature: _parameters['temperature'],
        topP: _parameters['top_p'],
        maxTokens: _parameters['max_tokens'],
        frequencyPenalty: _parameters['frequency_penalty'],
        presencePenalty: _parameters['presence_penalty'],
      )
    );
    await for (final completion in completionStream) {
      yield completion.choices.first.delta?.content ?? '';
    }
  }

  @override
  Future<bool> getModelOptions() async {
    _openAiClient = open_ai.OpenAIClient(apiKey: _apiKey!, baseUrl: _baseUrl);
    final modelsResponse = await _openAiClient.listModels();
    _modelOptions = modelsResponse.data.map((model) => model.id).toList();
    return true;
  }
}
```

**OpenRouter integration**: Not explicit — but works via the `baseUrl` field. User enters `https://openrouter.ai/api/v1` as base URL and their OpenRouter API key. The `openai_dart` client handles it since OpenRouter is OpenAI-compatible. **No special OpenRouter headers** (HTTP-Referer, X-Title) are added.

#### 7.2 Ollama (Local Network Discovery)

```dart
class OllamaController extends RemoteAIController {
  bool? _searchLocalNetwork;

  Future<bool> searchForOllama() async {
    // 1. Check current URL
    // 2. Check localhost:11434
    // 3. Get device WiFi IP, scan C-subnet
    // 4. Probe each host on port 11434
    // Sets _baseUrl to first found Ollama instance
  }

  @override
  Stream<String> prompt() async* {
    _ollamaClient = ollama.OllamaClient(
      baseUrl: "${_baseUrl ?? 'http://localhost:11434'}/api",
    );
    final completionStream = _ollamaClient.generateChatCompletionStream(
      request: ollama.GenerateChatCompletionRequest(
        model: _model!,
        messages: ChatController.instance.root.toOllamaMessages(),
        options: ollama.RequestOptions.fromJson(_parameters),
        stream: true
      )
    );
    await for (final completion in completionStream) {
      yield completion.message.content;
    }
  }
}
```

#### 7.3 Provider Switching

```dart
// In settings, user picks from dropdown:
static Map<String, String> getTypes(BuildContext context) {
  types['llama_cpp'] = 'LlamaCpp';
  types['ollama'] = 'Ollama';
  types['open_ai'] = 'OpenAI';
  types['mistral'] = 'Mistral';
  types['anthropic'] = 'Anthropic';
}

// Load persists/restores via SharedPreferences:
static Future<void> load([String? type]) async {
  final prefs = await SharedPreferences.getInstance();
  type ??= prefs.getString('ai_type') ?? (kIsWeb ? 'ollama' : 'llama_cpp');
  switch (type) {
    case 'llama_cpp': instance = LlamaCppController()..fromMap(contextMap);
    case 'ollama':    instance = OllamaController()..fromMap(contextMap);
    case 'open_ai':   instance = OpenAIController()..fromMap(contextMap);
    // ...
  }
}
```

---

### 8. State Management Pattern

**No Provider/Riverpod/Bloc** — pure `ChangeNotifier` + `ValueNotifier` + `ListenableBuilder`:

```dart
// Global singleton with ValueNotifier for type changes:
class AIController extends ChangeNotifier {
  static ValueNotifier<AIController?> notifier = ValueNotifier(null);
}

// AIListener widget wraps double-listening (type change + instance change):
class AIListener extends StatelessWidget {
  Widget build(context) => ListenableBuilder(
    listenable: AIController.notifier,      // Fires when provider type changes
    builder: (ctx, _) => ListenableBuilder(
      listenable: AIController.instance,    // Fires when model/busy/etc changes
      builder: builder,
    ),
  );
}
```

**Persistence**: Everything goes to `SharedPreferences` as JSON strings. Chat messages additionally sync to Supabase when user is logged in.

---

### 9. What Maid Does NOT Have

| Feature | Status |
|---------|--------|
| Image sending in chat | ❌ Not implemented — no multimodal support |
| Copy message button | ❌ Uses `SelectableText` instead |
| Message search | ❌ Not present |
| Tool/function calling | ❌ Not implemented |
| Streaming token count | ❌ Not tracked |
| Model parameter presets | ❌ Manual only |
| OpenRouter-specific headers | ❌ Uses generic OpenAI client |
| Chat message reactions | ❌ Not present |
| Markdown rendering | ❌ Only code block splitting (no `flutter_markdown`) |

---

### 10. Key Takeaways for Gemmie

1. **llama_sdk** package is the simplest Flutter GGUF path — FFI wrapper, just provide model_path + params, get `Stream<String>` back
2. **Tree-based chat model** is excellent for branching — adopt this pattern for edit/regenerate
3. **Hash-guarded reload** prevents unnecessary model re-initialization — smart optimization
4. **HuggingFace YAML catalog** is a good curated model list approach
5. **OpenRouter works via openai_dart** by just changing `baseUrl` — no special package needed
6. **No Riverpod/Bloc** — proves `ChangeNotifier` + `ListenableBuilder` is sufficient for this scale
7. **Message actions are inline** (same row as role name) — no popup menu, no long-press menu
8. **Branch switching via swipe** is a clever mobile UX pattern
