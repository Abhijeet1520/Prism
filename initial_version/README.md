# Prism — Initial Version (v0.2) Technical Plan

## Overview

This folder documents the transition from **UX Preview** (mock data, simulated AI) to **Initial Version** (real local models, live tools, voice input).

## Architecture

```
lib/
├── ai/
│   ├── ai_service.dart          # ✅ Created — AI controller abstraction
│   ├── tool_registry.dart       # ✅ Created — Composable tools
│   ├── feature_registry.dart    # ✅ Created — Feature availability
│   ├── feature_gate.dart        # ✅ Created — UI gating widget
│   ├── llama_controller.dart    # 🔧 v0.2 — llama.cpp FFI binding
│   ├── ollama_controller.dart   # 🔧 v0.2 — Ollama HTTP API
│   ├── cloud_controller.dart    # 🔧 v0.2 — OpenAI/Gemini/Anthropic APIs
│   └── intent_parser.dart       # 🔧 v0.2 — NL → tool call mapping
├── data/
│   ├── mock_data_service.dart   # ✅ Created — JSON asset loader
│   ├── local_db.dart            # 🔧 v0.2 — Drift/Hive local storage
│   └── sync_service.dart        # 📋 v0.3 — Cross-device sync
├── voice/
│   ├── stt_service.dart         # 📋 v0.3 — Speech-to-text
│   └── tts_service.dart         # 📋 v0.3 — Text-to-speech
└── ...
```

## Key Packages for v0.2

| Package | Purpose | Status |
|---------|---------|--------|
| `llama_sdk: ^0.0.5` | Local LLM inference via llama.cpp FFI | Planned |
| `ollama_dart: ^0.2.2` | Ollama API client | Planned |
| `dart_openai: ^5.1.0` | OpenAI-compatible APIs | Planned |
| `google_generative_ai: ^0.4.6` | Gemini API | Planned |
| `hive_ce: ^2.6.0` | Fast local key-value storage | Planned |
| `drift: ^2.22.0` | SQLite ORM for structured data | Planned |
| `dio: ^5.7.0` | HTTP client for model downloads | Planned |
| `path_provider: ^2.1.5` | File system paths | Planned |

## Local Model Loading Flow (Reference: Maid app)

```
1. User selects model in Settings → AI Providers → Local
2. Check if model file exists in app documents directory
3. If not: download via Dio with Stream<double> progress
4. Load model into llama.cpp via llama_sdk
5. Set as active controller in AIService
6. Ready for inference
```

### Key Implementation Details

- **Model catalog**: `assets/mock_data/models.json` defines available models
- **Download**: Use `Dio` with progress tracking, store in `getApplicationDocumentsDirectory()`
- **Hash verification**: Compare SHA-256 after download to prevent re-downloads
- **Memory management**: Only one model loaded at a time; unload before switching
- **Platform guards**: llama.cpp FFI not available on web — use `kIsWeb` to gate

## Tools System

Tools are composable — a tool can call other tools:

```dart
// Example: AI says "Mark task done and log 30 min work"
// → UpdateTaskTool + AddTransactionTool (via ToolRegistry)
```

Current tools:
- `update_task` — Change task status/details
- `add_transaction` — Log financial entry
- `create_note` — Add Brain document
- `schedule_event` — Calendar entry
- `edit_document` — Modify existing Brain doc
- `get_weather` — Weather information

## Feature Gating

The `FeatureGate` widget wraps screens/sections with status banners:
- **Preview**: Yellow banner — "Using sample data"
- **Partial**: Yellow banner — "Some features still building"
- **Planned**: Placeholder page with timeline
- **Available**: No banner, direct render

## Voice-First Design

The default input method is voice:
1. Home screen shows microphone as primary input
2. Text field is secondary (tap to switch)
3. Voice → STT → Intent parser → Tool or Chat
4. Response → TTS → Voice output

Voice processing chain (v0.3):
```
User speaks → speech_to_text (on-device) → text
text → AI intent parser → { tool_call | chat_response }
response → flutter_tts (on-device) → User hears
```
