# 03 — Architecture

> This document defines the system architecture, module breakdown, provider abstraction patterns, plugin systems, storage engine, and diff engine for Prism. It serves as the technical blueprint for implementation.

---

## Table of Contents

- [1. Architecture Principles](#1-architecture-principles)
- [2. Layer Architecture](#2-layer-architecture)
- [3. Module Map](#3-module-map)
- [4. Provider Abstraction Layer](#4-provider-abstraction-layer)
- [5. Tool Plugin Architecture](#5-tool-plugin-architecture)
- [6. Storage Architecture](#6-storage-architecture)
- [7. Permission Engine](#7-permission-engine)
- [8. Diff Engine](#8-diff-engine)
- [9. Code Execution Architecture](#9-code-execution-architecture)
- [10. Agent Persona Architecture](#10-agent-persona-architecture)
- [11. Sync Architecture](#11-sync-architecture)
- [12. Navigation Architecture](#12-navigation-architecture)
- [13. Dependency Graph](#13-dependency-graph)

---

## 1. Architecture Principles

| Principle | Application |
|-----------|------------|
| **Clean Architecture** | Strict separation: Presentation → Domain → Data. Dependencies point inward. |
| **Dependency Inversion** | Domain defines interfaces; Data implements them. UI depends on abstractions, not concretions. |
| **Plugin-First** | AI providers, tools, and code executors are plugins — no core code changes to extend. |
| **Offline-First** | All local features work without network. Cloud features gracefully degrade. |
| **Encryption by Default** | Every write to persistent storage goes through the encryption layer. |
| **Reactive State** | UI reactively binds to state via Riverpod providers. No imperative UI updates. |
| **Package Isolation** | Features are extracted into independent packages with clear public APIs. |

---

## 2. Layer Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                            │
│                                                                      │
│  Screens (Widgets)  ←→  Controllers/Notifiers  ←→  Riverpod Providers│
│                                                                      │
│  • ChatScreen, BrainScreen, AppsHubScreen, SettingsScreen, etc.      │
│  • Widget-level state via StateNotifier / AsyncNotifier               │
│  • Navigation via GoRouter                                           │
│  • Theming via Moon Design tokens                                    │
├──────────────────────────────────────────────────────────────────────┤
│                          DOMAIN LAYER                                │
│                                                                      │
│  Use Cases / Services  ←→  Repository Interfaces  ←→  Entities       │
│                                                                      │
│  • ChatService, ModelService, FileService, PermissionEngine, etc.    │
│  • Business logic lives here — no Flutter/platform imports           │
│  • Repository interfaces (abstract classes) defined here             │
│  • Pure Dart — testable in isolation                                 │
├──────────────────────────────────────────────────────────────────────┤
│                           DATA LAYER                                 │
│                                                                      │
│  Repository Implementations  ←→  Data Sources  ←→  External APIs     │
│                                                                      │
│  • IsarRepository, SecureStorageSource, ProviderAdapters, etc.       │
│  • Platform channels for native AI runtime (LiteRT / Core ML)       │
│  • HTTP clients for cloud APIs                                       │
│  • Encryption/decryption happens at this layer boundary              │
└──────────────────────────────────────────────────────────────────────┘
```

### Layer Rules

| Rule | Description |
|------|-------------|
| **Presentation → Domain** | Screens access domain via Riverpod providers that expose domain services |
| **Domain → Data** | Domain defines repository interfaces; data layer provides concrete implementations |
| **No Skip** | Presentation never directly accesses data layer |
| **Domain is Pure** | Domain layer has zero dependencies on Flutter, platform, or data libraries |
| **Data Hides Implementation** | Whether data comes from Isar, secure storage, or network — domain doesn't know |

---

## 3. Module Map

```
lib/
├── core/                              # Shared utilities
│   ├── constants/                     #   App-wide constants, defaults
│   ├── errors/                        #   Error types, failure classes
│   ├── extensions/                    #   Dart/Flutter extension methods
│   ├── utils/                         #   Formatting, validation, helpers
│   └── theme/                         #   Moon Design theme data, colors, typography
│
├── features/                          # Feature modules (each follows Clean Architecture)
│   ├── chat/                          #   FR-01: Chat & Conversation
│   │   ├── data/                      #     repositories, data sources, DTOs
│   │   ├── domain/                    #     entities, use cases, repository interfaces
│   │   └── presentation/             #     screens, widgets, controllers
│   │
│   ├── brain/                         #   FR-13: PARA Knowledge Management
│   │   ├── data/                      #     repositories, data sources, DTOs
│   │   ├── domain/                    #     entities (Project, Area, Resource, Archive)
│   │   └── presentation/             #     screens, widgets, controllers
│   │
│   ├── models/                        #   FR-02: Model Management
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── providers/                     #   FR-03: Cloud AI API Integration
│   │   ├── data/
│   │   │   └── adapters/              #     LangChain.dart adapters: OpenAI, Gemini, Claude,
│   │   │                              #     Ollama, Mistral, HF, OpenRouter, local
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── tools/                         #   FR-04: Tools System
│   │   ├── data/
│   │   │   └── builtin/               #     Built-in tool implementations
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── settings/                      #   FR-05: Settings & Profiles
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── storage/                       #   FR-06: File Storage System
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── versioning/                    #   FR-07: File Versioning & Diff
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── permissions/                   #   FR-08: Multi-Tier Permissions
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── persona/                       #   FR-09: Agent Persona System
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── executor/                      #   FR-10: Code Execution Engine
│   │   ├── data/
│   │   │   └── runtimes/              #     Python, JS, TS, Dart runtime adapters
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── documents/                     #   FR-11: Sheets & Documents
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── sync/                          #   FR-12: Cloud Sync
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── shared/                            # Shared widgets and components
│   ├── widgets/                       #   Reusable UI components
│   ├── dialogs/                       #   Common dialogs (confirm, permission, error)
│   └── layouts/                       #   Adaptive layout scaffolds
│
├── routing/                           # GoRouter configuration
│   └── app_router.dart
│
├── di/                                # Dependency injection setup
│   └── providers.dart                 #   Top-level Riverpod providers
│
└── main.dart                          # App entry point
```

### Module Responsibility Matrix

| Module | Domain Entities | External Dependencies | Cross-Module Dependencies |
|--------|----------------|----------------------|--------------------------|
| **chat** | Conversation, Message, Attachment | None | providers, tools, persona, permissions |
| **brain** | Project, Area, Resource, ArchiveItem | None | storage, permissions, sync |
| **models** | AIModel, ModelConfig, DownloadState | llama_sdk (FFI), LiteRT (platform channels), Ollama (via `ollama_dart`), HuggingFace API | settings (tokens) |
| **providers** | Provider, ProviderConfig, TokenUsage | LangChain.dart (`langchain_openai`, `langchain_google`, `langchain_anthropic`, `langchain_ollama`, `langchain_mistralai`) | settings (API keys) |
| **tools** | Tool, ToolInvocation, ToolResult | Per-tool external deps | permissions, executor, storage |
| **settings** | UserProfile, AppPreferences, CredentialEntry | Platform Keystore | None (dependency of others) |
| **storage** | PrismFile, PrismFolder, FileMetadata | Isar DB | permissions, versioning |
| **versioning** | FileVersion, Diff, DiffHunk | None | storage |
| **permissions** | PermissionTier, PermissionRequest, AuditEntry | None | storage |
| **persona** | Persona, SoulConfig, PersonalityConfig, Memory | None | storage, versioning, permissions |
| **executor** | ExecutionRequest, ExecutionResult, Script | Python/JS runtimes, remote APIs | storage (scripts), permissions |
| **documents** | Document, Sheet, CSVData | None | storage, versioning |
| **sync** | SyncState, ConflictEntry | Firebase/Supabase | storage, settings |

---

## 4. Provider Abstraction Layer

Prism uses **LangChain.dart** (`langchain_core`) as its provider abstraction layer instead of a custom interface. This gives us battle-tested abstractions, 10+ pre-built provider integrations, and the `Runnable` composability pattern.

### Core Abstraction: BaseChatModel

LangChain.dart's `BaseChatModel` serves as the unified provider interface:

```dart
/// LangChain.dart provides this — we wrap it for Prism-specific concerns.
/// See: langchain_core/lib/src/chat_models/base.dart
///
/// Key methods:
///   invoke(PromptValue) → ChatResult
///   stream(PromptValue) → Stream<ChatResult>
///   bind(ChatModelOptions) → BaseChatModel (with options baked in)
///
/// Runnable composability:
///   final chain = promptTemplate | chatModel | outputParser;
///   final result = await chain.invoke('user query');
```

### Prism Provider Wrapper

```dart
/// Wraps a LangChain BaseChatModel with Prism-specific concerns:
/// credential management, rate limiting, cost tracking, health checks.
class PrismProvider {
  final String id;
  final String displayName;
  final BaseChatModel chatModel;
  final ProviderCapabilities capabilities;
  final ProviderConfig config;

  /// All providers use LangChain.dart under the hood
  factory PrismProvider.openai(ProviderConfig config) =>
    PrismProvider._(
      id: 'openai',
      displayName: 'OpenAI',
      chatModel: ChatOpenAI(apiKey: config.apiKey),
      // ...
    );

  factory PrismProvider.ollama(ProviderConfig config) =>
    PrismProvider._(
      id: 'ollama',
      displayName: 'Ollama',
      chatModel: ChatOllama(baseUrl: config.baseUrl),
      // ...
    );

  // ... factories for each provider
}
```

### Provider Registry

```dart
/// Registry for dynamically adding/removing providers
class ProviderRegistry {
  final Map<String, PrismProvider> _providers = {};

  void register(PrismProvider provider);
  void unregister(String providerId);
  PrismProvider? getProvider(String providerId);
  List<PrismProvider> get allProviders;
  List<PrismProvider> getProvidersWithCapability(Capability cap);
}
```

### Provider Adapter Map

```
┌──────────────────────────────────────────────────────────────────────┐
│                   PrismProvider (wrapper)                           │
├──────────┬──────────┬──────────┬──────────┬──────────┬──────────────┤
│ ChatOpenAI│ChatGoogle│ChatAnthr.│ChatOllama│ChatMistr.│  llama_sdk   │
│ (langchain│(langchain│(langchain│(langchain│(langchain│  (FFI)       │
│ _openai)  │_google)  │_anthropic│_ollama)  │_mistralai│              │
├──────────┴──────────┴──────────┴──────────┴──────────┴──────────────┤
│    openai_dart  googleai_dart  anthropic_sdk  ollama_dart           │
│                       (low-level API clients)                       │
└──────────────────────────────────────────────────────────────────────┘
```

### LangChain.dart Packages to Use

| Package | Purpose | Pub.dev |
|---------|---------|--------|
| `langchain_core` | Base abstractions, Runnable, ChatMessage, PromptTemplate | [![pub](https://img.shields.io/pub/v/langchain_core.svg)](https://pub.dev/packages/langchain_core) |
| `langchain` | Chains, agents, retrievers | [![pub](https://img.shields.io/pub/v/langchain.svg)](https://pub.dev/packages/langchain) |
| `langchain_openai` | OpenAI + compatible (OpenRouter, vLLM, LM Studio) | [![pub](https://img.shields.io/pub/v/langchain_openai.svg)](https://pub.dev/packages/langchain_openai) |
| `langchain_google` | Google AI / Gemini | [![pub](https://img.shields.io/pub/v/langchain_google.svg)](https://pub.dev/packages/langchain_google) |
| `langchain_anthropic` | Anthropic Claude | [![pub](https://img.shields.io/pub/v/langchain_anthropic.svg)](https://pub.dev/packages/langchain_anthropic) |
| `langchain_ollama` | Ollama (local/LAN) | [![pub](https://img.shields.io/pub/v/langchain_ollama.svg)](https://pub.dev/packages/langchain_ollama) |
| `langchain_mistralai` | Mistral AI | [![pub](https://img.shields.io/pub/v/langchain_mistralai.svg)](https://pub.dev/packages/langchain_mistralai) |
| `langchain_firebase` | Firebase Vertex AI | [![pub](https://img.shields.io/pub/v/langchain_firebase.svg)](https://pub.dev/packages/langchain_firebase) |

### Adding a New Provider

1. Check if LangChain.dart already has a package for it (likely yes)
2. If yes: add `langchain_<provider>` dependency, create `PrismProvider.<provider>()` factory
3. If no (custom/self-hosted): use `langchain_openai` with custom `baseUrl` (most self-hosted solutions are OpenAI-compatible)
4. Register in `ProviderRegistry` during app initialization
5. Add credentials schema to settings
6. **Zero changes to core code required**

---

## 5. Tool Plugin Architecture

### Interface

```dart
/// Core interface all tools must implement.
abstract class PrismTool {
  /// Unique tool identifier
  String get id;

  /// Human-readable name
  String get name;

  /// Tool description (shown to AI and user)
  String get description;

  /// Tool category for grouping in UI
  ToolCategory get category;

  /// Required permission tier for this tool
  PermissionTier get requiredPermission;

  /// JSON Schema describing the tool's input parameters
  Map<String, dynamic> get inputSchema;

  /// JSON Schema describing the tool's output
  Map<String, dynamic> get outputSchema;

  /// Execute the tool with given parameters
  Future<ToolResult> execute(Map<String, dynamic> params, ToolContext context);

  /// Whether the tool requires user confirmation before execution
  bool get requiresConfirmation;
}

/// Context provided to tool during execution
class ToolContext {
  final String conversationId;
  final PermissionEngine permissionEngine;
  final FileService fileService;
  final String requestingModelName;
}
```

### Tool Registry & Discovery

```
┌──────────────────────────────────────────┐
│              ToolRegistry                │
│                                          │
│  ┌─ Built-in Tools ─────────────────┐    │
│  │  CodeExecutionTool                │    │
│  │  FileReadTool                     │    │
│  │  FileWriteTool                    │    │
│  │  FileSearchTool                   │    │
│  │  WebSearchTool                    │    │
│  │  UrlFetchTool                     │    │
│  │  CalculatorTool                   │    │
│  │  CreateSheetTool                  │    │
│  │  CreateDocumentTool               │    │
│  └───────────────────────────────────┘    │
│                                          │
│  ┌─ User/Community Tools ───────────┐    │
│  │  (via plugin system — future)     │    │
│  └───────────────────────────────────┘    │
│                                          │
│  enable(toolId) / disable(toolId)        │
│  getEnabledTools() → for AI context      │
│  getToolsByCategory() → for Apps Hub     │
└──────────────────────────────────────────┘
```

### Tool Invocation Flow

```
User Message
    │
    ▼
AI Provider (with tool definitions in system prompt)
    │
    ▼
AI decides to use tool(s) → returns function_call
    │
    ▼
ToolInvocationHandler
    │
    ├── Check: Is tool enabled? ──No──→ Error: tool not available
    │
    ├── Check: Permission tier? ──Gated──→ Show permission dialog → User approves/rejects
    │
    ├── Check: Requires confirmation? ──Yes──→ Show confirmation dialog
    │
    ▼
tool.execute(params, context)
    │
    ▼
ToolResult (success/failure + data)
    │
    ▼
Result fed back to AI for follow-up reasoning
    │
    ▼
AI generates final response to user
```

---

## 6. Storage Architecture

### Layers

```
┌────────────────────────────────────────────────────────────┐
│               Virtual Filesystem API                       │
│   createFile / readFile / updateFile / deleteFile           │
│   createFolder / listFolder / moveItem / searchFiles       │
├────────────────────────────────────────────────────────────┤
│              Format Serialization Layer                     │
│   MarkdownSerializer   CSVSerializer   BinaryBlobHandler   │
│   (all text → MD)      (CSV ↔ MD)      (raw blob + meta)  │
├────────────────────────────────────────────────────────────┤
│              Versioning Integration                        │
│   createVersion() on every write                           │
│   computeDiff() between any two versions                   │
│   Permission check before every read/write                 │
├────────────────────────────────────────────────────────────┤
│              Encryption Layer                              │
│   AES-256-GCM encrypt on write / decrypt on read           │
│   Key from platform keystore                               │
├────────────────────────────────────────────────────────────┤
│              Isar Database                                 │
│   Collections: Files, Folders, Versions, Metadata          │
│   Indices: by path, by type, by modified date, full-text   │
└────────────────────────────────────────────────────────────┘
```

### Internal File Format

All text-based files are stored internally as Markdown with a YAML frontmatter header:

```markdown
---
id: "uuid-v4"
type: "document"          # document | sheet | script | persona | note
created: "2026-02-07T10:00:00Z"
modified: "2026-02-07T12:30:00Z"
author: "user"            # "user" or "ai:gemma-3b"
tags: ["project", "budget"]
permission: "gated"       # locked | gated | open
lock_pin: null            # optional user-set lock
---

# Document Title

Content here in standard Markdown...

<!-- csv:ref:budget_q1.csv -->
| Month | Revenue | Expenses |
|-------|---------|----------|
| Jan   | 10000   | 7500     |
| Feb   | 12000   | 8000     |
```

### File Type → Internal Representation

| User-Facing Type | Internal Format | Presentation |
|-----------------|-----------------|-------------|
| Text Note | Markdown body | Rich text viewer |
| Document | Markdown with headings, sections | Document editor with toolbar |
| Spreadsheet/CSV | CSV block within Markdown (with `csv:ref` comment) | Grid editor UI |
| Code Script | Fenced code block with language tag | Code editor with syntax highlighting |
| Persona File | Structured Markdown with YAML sections | Persona editor with sliders/toggles |
| Image | Binary blob in DB + Markdown metadata file | Image viewer |
| PDF | Binary blob in DB + Markdown metadata/summary | PDF viewer (if available) |

---

## 7. Permission Engine

### Architecture

```
┌──────────────────────────────────────────────────┐
│                Permission Engine                  │
│                                                  │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐ │
│  │  Policy    │  │  Runtime   │  │   Audit    │ │
│  │  Store     │  │  Evaluator │  │    Log     │ │
│  │            │  │            │  │            │ │
│  │ Per-file   │  │ checkRead  │  │ timestamp  │ │
│  │ Per-folder │  │ checkWrite │  │ file       │ │
│  │ Defaults   │  │ checkExec  │  │ operation  │ │
│  │ Overrides  │  │ → allow    │  │ requester  │ │
│  │            │  │ → deny     │  │ decision   │ │
│  │            │  │ → ask user │  │ reason     │ │
│  └────────────┘  └────────────┘  └────────────┘ │
└──────────────────────────────────────────────────┘
```

### Evaluation Flow

```dart
enum PermissionDecision { allow, deny, askUser }

class PermissionEvaluator {
  PermissionDecision evaluate({
    required String filePath,
    required OperationType operation,    // read, write, delete, execute
    required String requesterId,         // "user" or "ai:model-name"
  }) {
    // 1. If requester is "user" → always allow
    // 2. Get file's permission tier
    // 3. Locked → deny (always)
    // 4. Open → allow (always, but log)
    // 5. Gated → check session grants
    //    a. Session grant exists → allow
    //    b. Permanent grant exists → allow
    //    c. Neither → askUser
  }
}
```

### Session Grant Model

```
┌─ Permission Grant ────────────────┐
│ fileId:     "uuid"                │
│ operation:  "write"               │
│ scope:      "this_time" |         │
│             "this_session" |      │
│             "always"              │
│ grantedAt:  timestamp             │
│ expiresAt:  timestamp | null      │
│ grantedBy:  "user"                │
│ revokedAt:  null                  │
└───────────────────────────────────┘
```

---

## 8. Diff Engine

### Algorithm

The diff engine uses the **Myers Diff Algorithm** (same as git) for computing minimal edit sequences between two versions of a file.

### Architecture

```
┌─────────────────────────────────────────────────────┐
│                    Diff Engine                       │
│                                                     │
│  computeDiff(oldText, newText) → List<DiffHunk>     │
│                                                     │
│  ┌─────────────┐   ┌──────────────┐                │
│  │  Line-Level  │   │  Word-Level  │                │
│  │    Diff      │──→│  Refinement  │                │
│  │  (Myers)     │   │  (within     │                │
│  │              │   │   changed    │                │
│  │              │   │   lines)     │                │
│  └─────────────┘   └──────────────┘                │
│                                                     │
│  ┌──── DiffHunk ────┐                              │
│  │ type: add/del/mod│                              │
│  │ oldStart: int    │                              │
│  │ oldEnd: int      │                              │
│  │ newStart: int    │                              │
│  │ newEnd: int      │                              │
│  │ oldText: String  │                              │
│  │ newText: String  │                              │
│  │ wordDiffs: [...]│                              │
│  └──────────────────┘                              │
│                                                     │
│  Specialized Diff Modes:                            │
│  • Text diff  → line-by-line + word refinement      │
│  • CSV diff   → cell-by-cell comparison             │
│  • JSON diff  → key-path aware                      │
│  • YAML diff  → structure-aware frontmatter diff    │
└─────────────────────────────────────────────────────┘
```

### Version Storage Model

```
┌─ FileVersion ─────────────────────┐
│ versionId:   "uuid"               │
│ fileId:      "uuid"               │
│ content:     "encrypted blob"     │  ← Full snapshot (for restore)
│ diff:        "compressed diff"    │  ← Delta from previous (for display)
│ author:      "user" | "ai:model"  │
│ timestamp:   DateTime             │
│ summary:     "Added budget row"   │  ← Auto-generated or user-provided
│ parentId:    "uuid" | null        │  ← Previous version
└───────────────────────────────────┘
```

### Storage Strategy

- **Full Snapshots:** Every 10th version stores the complete file content (for fast restore)
- **Deltas:** All other versions store only the diff from the previous version (for storage efficiency)
- **Compression:** Both snapshots and deltas are compressed (zlib) before encryption

---

## 9. Code Execution Architecture

### Executor Interface

```dart
abstract class CodeExecutor {
  /// Language this executor handles
  String get language;

  /// Whether this executor runs locally or remotely
  ExecutionEnvironment get environment;

  /// Execute code and return result
  Future<ExecutionResult> execute(ExecutionRequest request);

  /// Stream output line by line during execution
  Stream<String> executeStreaming(ExecutionRequest request);

  /// Cancel a running execution
  Future<void> cancel(String executionId);

  /// Check if the executor is available and ready
  Future<bool> isAvailable();
}
```

### Architecture

```
┌──────────────────────────────────────────────────┐
│              Code Execution Engine                │
│                                                  │
│  ┌─────────────────────────────────────────────┐ │
│  │           ExecutorRegistry                   │ │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐       │ │
│  │  │ Python  │ │  JS/TS  │ │  Dart   │  ...  │ │
│  │  │Executor │ │Executor │ │Executor │       │ │
│  │  └────┬────┘ └────┬────┘ └────┬────┘       │ │
│  └───────┼───────────┼───────────┼─────────────┘ │
│          │           │           │                │
│  ┌───────▼───────────▼───────────▼─────────────┐ │
│  │           Sandbox Manager                    │ │
│  │  • Filesystem isolation (temp dir only)      │ │
│  │  • Memory limits (configurable)              │ │
│  │  • Execution timeout (configurable)          │ │
│  │  • Network policy (default: deny)            │ │
│  └─────────────────────────────────────────────┘ │
│                                                  │
│  ┌─────────────────────────────────────────────┐ │
│  │          Remote Execution Bridge             │ │
│  │  • Modal connector                           │ │
│  │  • Daytona connector                         │ │
│  │  • Custom SSH connector                      │ │
│  │  • Output streaming via WebSocket            │ │
│  └─────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────┘
```

### Local Execution Flow

```
User/AI triggers code execution
    │
    ▼
Permission check (FR-08)
    │
    ▼
Language detection (from code block tag or file extension)
    │
    ▼
ExecutorRegistry.getExecutor(language)
    │
    ▼
SandboxManager.createSandbox(config)
    │
    ├── Create temp directory
    ├── Write code to temp file
    ├── Set resource limits
    │
    ▼
executor.execute(request) within sandbox
    │
    ├── Capture stdout/stderr
    ├── Monitor timeout
    ├── Monitor memory
    │
    ▼
ExecutionResult { stdout, stderr, exitCode, executionTime, artifacts }
    │
    ▼
Cleanup sandbox
    │
    ▼
Display result in UI (chat inline or code editor output panel)
```

---

## 10. Agent Persona Architecture

### Persona File Structure

```
Agent (folder — Permission-Gated by default)
├── soul.md               # Core identity — rarely changes
├── personality.md         # Style and tone — evolves over time
├── memory.md              # User-specific memories
├── rules.md               # Behavioral rules
├── knowledge.md           # Domain-specific instructions
└── personas/              # Additional persona profiles
    ├── professional.md
    ├── creative.md
    └── tutor.md
```

### System Prompt Assembly

```
┌─────────────────────────────────────────┐
│        System Prompt Builder             │
│                                         │
│  1. Load active persona files            │
│  2. Assemble in order:                   │
│     a. Soul (core identity)              │
│     b. Personality (style params)        │
│     c. Rules (behavioral constraints)    │
│     d. Knowledge (domain context)        │
│     e. Memory (user-specific context)    │
│  3. Inject tool definitions              │
│  4. Inject permission context            │
│  5. Output: complete system prompt       │
└─────────────────────────────────────────┘
         │
         ▼
  Sent as `system` message to AI provider
```

### Persona Evolution Flow

```
During conversation, AI identifies relevant persona update
    │
    ▼
AI proposes change via special response format:
  "I'd like to remember that you prefer concise answers."
    │
    ▼
PersonaService creates a proposed edit to memory.md (or personality.md)
    │
    ▼
Diff is computed (FR-07) showing exact proposed change
    │
    ▼
Permission check (FR-08) — persona files are Tier 2 (gated)
    │
    ▼
User sees notification: "Prism wants to update its memory"
    │
    ▼
User reviews diff → Accept / Modify / Reject
    │
    ▼
If accepted: new version saved with author "ai:model-name"
```

---

## 11. Sync Architecture

### Design

```
┌──────────────────────────────────────────────────┐
│                 Sync Engine                       │
│                                                  │
│  ┌─────────────┐    ┌──────────────────────────┐ │
│  │  Change     │    │  Cloud Adapter           │ │
│  │  Tracker    │──→ │  (Firebase / Supabase)   │ │
│  │  (local)    │    │                          │ │
│  │  - watches  │    │  ┌──────────────────┐    │ │
│  │    Isar DB  │    │  │  E2E Encryption  │    │ │
│  │    for edits│    │  │  Layer           │    │ │
│  │             │    │  │  AES-256-GCM     │    │ │
│  └─────────────┘    │  │  Key: user       │    │ │
│                     │  │  passphrase      │    │ │
│  ┌─────────────┐    │  └──────────────────┘    │ │
│  │  Conflict   │    │                          │ │
│  │  Resolver   │    │  upload() / download()   │ │
│  │  - 3-way    │    │  listChanges()           │ │
│  │    merge    │    │  resolveConflict()       │ │
│  │  - manual   │    └──────────────────────────┘ │
│  │    resolve  │                                 │
│  └─────────────┘                                 │
└──────────────────────────────────────────────────┘
```

### Sync Flow

```
Local Change Detected
    │
    ▼
Is sync enabled for this file/folder? ──No──→ Skip
    │ Yes
    ▼
Encrypt content client-side (E2E)
    │
    ▼
Upload encrypted blob + sync metadata
    │
    ▼
Check for remote changes since last sync
    │
    ├── No remote changes → Done
    │
    ├── Remote changes, no conflict → Apply remote changes locally
    │
    └── Conflict detected →
        ├── Auto-merge (if changes in different sections)
        └── Manual resolution UI (side-by-side diff)
```

---

## 12. Navigation Architecture

### Screen Map

```
┌─────────────────────────────────────────────────────────────────┐
│                        App Shell                                │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                   Bottom Navigation                      │   │
│  │  [💬 Chat]  [🧠 Brain]  [🚀 Apps Hub]  [⚙ Settings]    │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Chat Tab                Brain Tab          Apps Hub Tab         │
│  ├─ ConversationList     ├─ BrainHome        ├─ AppsHubGrid     │
│  ├─ ChatScreen           ├─ ProjectsView     │  (launcher for:) │
│  │  └─ ModelSelector     ├─ AreasView        ├─ Tools           │
│  └─ ConversationSearch   ├─ ResourcesView    │  ├─ ToolsGrid    │
│                          └─ ArchiveView      │  ├─ ToolDetail   │
│  Settings Tab                                │  └─ ToolExec     │
│  ├─ SettingsHome          Overlays / Modals   ├─ Files           │
│  ├─ ProfileEditor         ├─ PermissionDialog │  ├─ FileBrowser  │
│  ├─ ProviderSetup         ├─ ConfirmDialog    │  ├─ FileViewer   │
│  ├─ TokenManager          ├─ DiffReviewDialog │  ├─ DiffViewer   │
│  ├─ PersonaEditor         ├─ ModelDownload    │  └─ FileHistory  │
│  ├─ SyncSettings          └─ ErrorDialog      ├─ Tasks           │
│  ├─ StorageManager                            ├─ Finance         │
│  └─ AboutPage                                 └─ Gateway         │
└─────────────────────────────────────────────────────────────────┘
```

### Adaptive Layout Strategy

| Screen Width | Layout | Navigation |
|-------------|--------|------------|
| < 600dp (Phone) | Single-pane | Bottom navigation bar |
| 600–839dp (Small tablet) | Optional split-pane | Navigation rail |
| ≥ 840dp (Large tablet / Desktop) | Split-pane (list + detail) | Navigation rail + persistent panel |

---

## 13. Dependency Graph

```
                    ┌──────────┐
                    │  core/   │
                    │ (shared) │
                    └────┬─────┘
                         │ depends on by all
        ┌────────┬───────┼────────┬────────────┐
        ▼        ▼       ▼        ▼            ▼
   ┌────────┐ ┌──────┐ ┌──────┐ ┌──────────┐ ┌──────┐
   │settings│ │perms │ │versn │ │ storage  │ │persona│
   │        │ │      │ │      │ │          │ │       │
   └───┬────┘ └──┬───┘ └──┬───┘ └────┬─────┘ └──┬────┘
       │         │        │          │           │
       │    ┌────┴────────┴──────────┤           │
       │    │    storage depends on  │           │
       │    │    perms + versioning  │           │
       │    │                        │           │
       ▼    ▼                        ▼           ▼
   ┌─────────────┐            ┌──────────┐  ┌────────┐
   │  providers  │            │  tools   │  │  chat  │
   │  (AI APIs)  │            │          │  │        │
   └──────┬──────┘            └────┬─────┘  └───┬────┘
          │                        │            │
          └────────────┬───────────┘            │
                       │                        │
                  ┌────▼────┐            ┌──────▼─────┐
                  │executor │            │ documents  │
                  │         │            │            │
                  └─────────┘            └────────────┘
                                               │
                                          ┌────▼────┐
                                          │  sync   │
                                          └─────────┘
```

### Package Extraction Strategy

For reusability and testability, these modules should be extracted into independent Dart packages under `packages/`:

| Package | Contains | Public API |
|---------|----------|-----------|
| `prism_ai_providers` | Provider interface + all adapters | `AIProvider`, `ProviderRegistry`, adapters |
| `prism_storage` | Virtual filesystem + encryption + Isar | `FileService`, `FolderService`, encryption utils |
| `prism_diff` | Diff engine (Myers + word-level) | `DiffEngine`, `DiffHunk`, `FileVersion` |
| `prism_executor` | Code execution sandbox + remote bridge | `CodeExecutor`, `SandboxManager`, `ExecutorRegistry` |
| `prism_brain` | PARA knowledge management (Projects, Areas, Resources, Archive) | `BrainService`, `ProjectRepository`, `AreaRepository` |
| `prism_persona` | Persona file management + system prompt builder | `PersonaService`, `SystemPromptBuilder` |
