# 00 — Project Overview

## 1. Vision Statement

**Gemmie** is a privacy-first, cross-platform AI personal assistant that gives users full control over their AI experience. Users can run models locally on-device for maximum privacy, connect to cloud AI providers for enhanced capabilities, or blend both — all from a single unified interface. Gemmie goes beyond chat: it manages files with enterprise-grade encryption, executes code in multiple languages, maintains a customizable agent persona that evolves with the user, and provides a complete toolkit for AI-augmented productivity.

### Core Principles

| Principle | Description |
|-----------|-------------|
| **Privacy First** | Data stays on-device by default. Cloud features are opt-in with E2E encryption. |
| **User Sovereignty** | Users own their data, control AI access through multi-tier permissions, and can inspect every change via git-like diffs. |
| **Extensible by Design** | Plugin architecture for tools, providers, and code executors — easy to add new capabilities without touching core code. |
| **AI Transparency** | Every AI action is auditable. Permission requests explain *what* and *why*. File changes show clear diffs. |
| **Cross-Platform Consistency** | Same experience on Android, iOS, web, and desktop via Flutter. |

---

## 2. App Identity

| Field | Value |
|-------|-------|
| **Working Title** | Gemmie |
| **Name Status** | In progress — subject to change |
| **Tagline** | *Your AI, your rules.* |
| **Category** | Productivity / AI Assistant |
| **Target Audience** | Developers, power users, privacy-conscious individuals, AI enthusiasts |

---

## 3. Target Platforms

| Platform | Framework | Status |
|----------|-----------|--------|
| Android | Flutter | Primary |
| iOS | Flutter | Primary |
| Web | Flutter Web | Secondary |
| macOS | Flutter Desktop | Secondary |
| Windows | Flutter Desktop | Secondary |
| Linux | Flutter Desktop | Tertiary |

### Why Flutter?

- **Single codebase** for all platforms — reduces maintenance overhead
- **Rich UI toolkit** with Material 3, custom widgets, and smooth animations
- **Strong ecosystem** for file handling, encryption, and platform channels
- **Dart's performance** is sufficient for UI; heavy AI work offloaded to native code via platform channels or FFI
- **Existing Flutter expertise** in the workspace (multiple Flutter projects available as reference)

### Platform-Specific Considerations

- **Android/iOS:** Native AI runtime via platform channels (LiteRT/Core ML), local file storage, biometric authentication
- **Web:** WebAssembly for local model inference (limited), primarily cloud API mode, IndexedDB for storage
- **Desktop:** Full filesystem access, larger model support, GPU acceleration via native plugins

---

## 4. Tech Stack

### Core

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| **Language** | Dart 3.x | Flutter's native language; null safety, pattern matching, records |
| **UI Framework** | Flutter 3.x | Cross-platform UI with Material 3 |
| **State Management** | Riverpod 2.x | Compile-safe, testable, supports async; preferred over BLoC for new projects |
| **Navigation** | GoRouter | Declarative routing with deep link support |
| **Local Database** | Isar 4.x | High-performance embedded NoSQL DB with encryption support |
| **Encryption** | `encrypt` + platform keychain | AES-256-GCM for data at rest; platform keystore for key material |
| **Dependency Injection** | Riverpod (built-in) | Provider-based DI; no separate DI framework needed |

### AI & Models

| Component | Technology | Rationale |
|-----------|-----------|-----------|
| **Provider Framework** | LangChain.dart (`langchain_core`) | Proven Dart LLM framework with unified `BaseChatModel` abstraction, Runnable chains, agents, tools, embeddings, and 10+ provider integrations. Eliminates need for custom provider interface. |
| **OpenAI** | `langchain_openai` / `openai_dart` | Chat + streaming + tool calling + OpenAI-compatible endpoints (vLLM, LM Studio, etc.) |
| **Google Gemini** | `langchain_google` / `googleai_dart` | Native Gemini API with multimodal + function calling |
| **Anthropic Claude** | `langchain_anthropic` / `anthropic_sdk_dart` | Claude chat + streaming + tool use |
| **Ollama (Local)** | `langchain_ollama` / `ollama_dart` | Connect to local or LAN Ollama servers; supports 100+ models (Llama, Gemma, Phi, Mistral, Qwen, etc.) |
| **Mistral AI** | `langchain_mistralai` / `mistralai_dart` | Mistral + Mixtral models |
| **HuggingFace** | `langchain_huggingface` + HF Hub API | Inference API + model downloads with OAuth |
| **OpenRouter** | `langchain_openai` (compatible format) | Meta-provider routing to 200+ models via single API key |
| **Local Inference (GGUF)** | `llama_sdk` (wraps llama.cpp via FFI) | On-device GGUF model inference; conditional import for web |
| **Local Inference (LiteRT)** | LiteRT (via platform channels) | Google's on-device runtime for TFLite models; ported from Gallery |
| **Model Download** | HuggingFace Hub API + OAuth + Dio | Gated model support; token-based auth; download queue with progress |
| **Streaming** | Server-Sent Events / WebSocket | Real-time token streaming from all providers |
| **Agent Graphs** | `langgraph` (future) | Build resilient agent workflows as composable graphs |

### Storage & Files

| Component | Technology | Rationale |
|-----------|-----------|-----------|
| **Database** | Isar (encrypted) | Structured data with encryption at rest |
| **File Representation** | Markdown (internal) | Universal format; easy for AI to read/write; rich rendering |
| **Diff Engine** | Custom (dart_diff / Myers algorithm) | Git-like diffing for all file changes |
| **CSV/Sheets** | csv package + custom grid renderer | Parse/edit CSV; render as spreadsheet UI |

### Code Execution

| Component | Technology | Rationale |
|-----------|-----------|-----------|
| **Python** | Embedded CPython via FFI / remote | Sandboxed local or send to remote executor |
| **JavaScript/TypeScript** | QuickJS via FFI / remote | Lightweight JS engine for local execution |
| **Dart/Flutter** | dart_eval / isolates | In-process Dart execution in isolates |
| **Remote Execution** | Modal / Daytona / custom server | User-configured remote environments |

### Networking & Sync

| Component | Technology | Rationale |
|-----------|-----------|-----------|
| **HTTP** | dio | Interceptors, cancellation, streaming support |
| **Cloud Sync** | Supabase (`supabase_flutter`) | E2E encrypted sync; Maid reference app proves this works well with Flutter for chat sync + storage policies |
| **Auth** | AppAuth (OAuth 2.0) | HuggingFace and provider authentication |
| **LAN Discovery** | `lan_scanner` + `network_info_plus` | Auto-discover Ollama instances on local network (pattern from Maid) |

---

## 5. High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                       │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐          │
│  │   Chat   │ │  Tools   │ │  Files   │ │ Settings │  ...      │
│  │  Screen  │ │   Tab    │ │ Explorer │ │  Screen  │          │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘          │
│       │             │            │             │                │
│  ┌────▼─────────────▼────────────▼─────────────▼────────────┐  │
│  │              STATE MANAGEMENT (Riverpod)                  │  │
│  │  Providers · Notifiers · AsyncValues · StateControllers   │  │
│  └────┬──────────────────────────────────────────────────┬──┘  │
└───────┼──────────────────────────────────────────────────┼─────┘
        │                                                  │
┌───────▼──────────────────────────────────────────────────▼─────┐
│                         DOMAIN LAYER                           │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐  │
│  │    Chat    │ │   Model    │ │   File     │ │  Permission│  │
│  │  Service   │ │  Service   │ │  Service   │ │   Engine   │  │
│  └─────┬──────┘ └─────┬──────┘ └─────┬──────┘ └─────┬──────┘  │
│  ┌─────┴──────┐ ┌─────┴──────┐ ┌─────┴──────┐ ┌─────┴──────┐  │
│  │   Tool     │ │  Persona   │ │    Diff    │ │    Code    │  │
│  │  Service   │ │  Service   │ │   Engine   │ │  Executor  │  │
│  └────────────┘ └────────────┘ └────────────┘ └────────────┘  │
└───────┬──────────────────────────────────────────────────┬─────┘
        │                                                  │
┌───────▼──────────────────────────────────────────────────▼─────┐
│                          DATA LAYER                            │
│  ┌─────────────┐ ┌──────────────┐ ┌──────────────────────────┐ │
│  │  Encrypted  │ │   Provider   │ │    Platform Channels     │ │
│  │  Isar DB    │ │  Adapters    │ │  (LiteRT, Keychain, FS)  │ │
│  └─────────────┘ │ (LangChain.  │ ├──────────────────────────┤ │
│                  │   dart)      │ │   Local Inference        │ │
│                  │ ┌──────────┐ │ │  ┌─────────────────────┐ │ │
│                  │ │  OpenAI  │ │ │  │  llama_sdk (GGUF)   │ │ │
│                  │ │  Gemini  │ │ │  │  LiteRT (TFLite)    │ │ │
│                  │ │  Claude  │ │ │  └─────────────────────┘ │ │
│                  │ │  Ollama  │ │ └──────────────────────────┘ │
│                  │ │ Mistral  │ │                              │
│                  │ │Hugging F.│ │                              │
│                  │ │OpenRouter│ │                              │
│                  │ └──────────┘ │                              │
│                  └──────────────┘                              │
└────────────────────────────────────────────────────────────────┘
```

---

## 6. Repository Structure (Planned)

```
gennie/
├── docs/                          # ← You are here
│   ├── README.md                  # Documentation index
│   ├── 00-PROJECT-OVERVIEW.md     # This file
│   ├── 01-FUNCTIONAL-REQUIREMENTS.md
│   ├── 02-NON-FUNCTIONAL-REQUIREMENTS.md
│   ├── 03-ARCHITECTURE.md
│   ├── 04-DATA-MODELS.md
│   ├── 05-UI-UX-SPEC.md
│   ├── 06-API-INTEGRATION-SPEC.md
│   ├── 07-SECURITY-SPEC.md
│   ├── 08-DEVELOPMENT-ROADMAP.md
│   └── 09-GLOSSARY.md
│
├── app/                           # Flutter application (future)
│   ├── lib/
│   │   ├── core/                  # Core utilities, constants, extensions
│   │   ├── data/                  # Data layer — models, repos, sources
│   │   ├── domain/                # Domain layer — services, use cases
│   │   ├── presentation/         # UI layer — screens, widgets, controllers
│   │   ├── providers/            # Riverpod providers
│   │   └── main.dart
│   ├── test/
│   ├── assets/
│   ├── pubspec.yaml
│   └── analysis_options.yaml
│
├── packages/                      # Extracted packages (future)
│   ├── gemmie_ai_providers/       # AI provider abstraction & adapters
│   ├── gemmie_storage/            # Encrypted storage & virtual filesystem
│   ├── gemmie_diff/               # Diff engine
│   ├── gemmie_executor/           # Code execution engine
│   └── gemmie_persona/            # Agent persona system
│
└── tools/                         # Build tools, scripts, CI config (future)
```

---

## 7. Reference: AI Edge Gallery

The [AI Edge Gallery](../gallery/Android/) is a production-quality Android app by Google for on-device GenAI model inference. Key modules targeted for future porting to Gemmie:

| Gallery Module | Purpose | Porting Priority |
|---------------|---------|-----------------|
| Model Download & Lifecycle | HuggingFace OAuth, WorkManager downloads, model init/cleanup | High |
| LiteRT Integration | On-device inference via LiteRT-LM engine | High |
| Chat UI Components | 30+ Compose chat composables (bubbles, streaming, markdown rendering) | Medium — will adapt to Flutter equivalents |
| Config System | Runtime-adjustable model configs (topK, topP, temperature) | High |
| Custom Task Plugin System | `CustomTask` interface for extensible tasks | Medium — will inform Gemmie's tool plugin design |
| Model Allowlist | JSON-based model registry with metadata | High |
| Theme System | Material 3 theming with dynamic color | Low — Flutter has equivalent support |

> **Note:** Gallery is Kotlin/Compose. Porting to Flutter/Dart means re-implementing patterns, not direct code translation. The architecture and data models are the primary value to carry over.

---

## 8. Key Decisions Log

| Decision | Choice | Rationale | Date |
|----------|--------|-----------|------|
| Platform framework | Flutter | Cross-platform reach; user preference; strong ecosystem | 2026-02-07 |
| Start fresh vs fork Gallery | Fresh project with future module porting | Different platform (Flutter vs Android-native); cleaner architecture | 2026-02-07 |
| State management | Riverpod | Modern, compile-safe, better async support than BLoC | 2026-02-07 |
| Storage backend | Encrypted Isar DB | High-performance, encryption support, NoSQL flexibility for MD storage | 2026-02-07 |
| Provider framework | LangChain.dart (`langchain_core`) | Proven framework with 10+ provider integrations; Runnable composability; eliminates need for custom AIProvider interface | 2026-02-07 |
| Local inference | llama_sdk (GGUF) + LiteRT (TFLite) | Dual runtime: llama.cpp FFI for GGUF models (proven in Maid), LiteRT for TFLite (from Gallery) | 2026-02-07 |
| Ollama support | First-class via `langchain_ollama` | Ollama wraps llama.cpp with easy model management; LAN discovery from Maid enables mobile-to-desktop connectivity | 2026-02-07 |
| File format (internal) | Markdown | Universal; AI-readable; supports embedded references (CSV, etc.) | 2026-02-07 |
| Permission model | Multi-tier (Locked/Gated/Open) | Balances security with usability; git-like audit trail | 2026-02-07 |
| Agent persona | Full persona system with soul files | Differentiator feature; enables personalized AI experience | 2026-02-07 |
| Cloud sync | Supabase (`supabase_flutter`) | Proven in Maid for chat sync; supports RLS policies, storage, auth; optional with E2E encryption | 2026-02-07 |
| Code execution | Local sandboxed + remote | Flexibility: quick local runs + powerful remote environments | 2026-02-07 |
| Release scope | Full feature set (phased implementation) | All features designed upfront; implementation phases for delivery | 2026-02-07 |
| Branching conversations | Tree structure (from Maid) | Support conversation forking with parent/children message nodes | 2026-02-07 |
