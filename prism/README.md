<p align="center">
  <img src="assets/icons/prism_icon.png" alt="Prism Logo" width="120" height="120"/>
</p>

<h1 align="center">Prism — Your Offline AI Hub</h1>

<p align="center">
  <strong>A centralized, privacy-first AI platform for mobile — download models once, use everywhere.</strong>
</p>

<p align="center">
  <a href="#-key-features">Features</a> •
  <a href="#-the-problem">Problem</a> •
  <a href="#-our-solution">Solution</a> •
  <a href="#-tech-stack">Tech Stack</a> •
  <a href="#-getting-started">Getting Started</a> •
  <a href="#-architecture">Architecture</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.10.8-02569B?logo=flutter" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart" alt="Dart"/>
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License"/>
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?logo=android" alt="Android"/>
</p>

---

## 🎯 The Problem

Today's mobile AI landscape is **fragmented and wasteful**:

- **Redundant Downloads**: Every AI app downloads its own models (100MB-4GB each). Users with 5 AI apps may have 5 copies of the *same* model.
- **Storage Bloat**: Phones have limited storage, yet identical 4-bit quantized LLMs are duplicated across apps.
- **No Interoperability**: Apps can't share AI capabilities — each reinvents inference, chat history, and tooling.
- **Privacy Concerns**: Cloud AI requires sending personal data to external servers.
- **Battery Drain**: Multiple apps running separate inference engines = poor battery life.

## 💡 Our Solution

**Prism** is a **centralized offline AI hub** that:

1. **Single Model Repository**: Download models once, available to all compatible apps via a local API.
2. **Inter-App AI Hosting**: Apps can request inference from Prism instead of bundling their own models — powered by a local Shelf HTTP server.
3. **Privacy-First**: All inference runs 100% on-device. Your data never leaves your phone.
4. **Unified Chat & Tools**: One place for conversations, with function calling, second brain, and productivity tools.
5. **Efficient Resource Use**: Single inference engine, shared model weights, optimized battery.

### How It Works

```
┌─────────────────────────────────────────────────────────────────┐
│                         PRISM APP                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │   Chat UI    │  │  Second Brain│  │   Tools      │           │
│  └──────────────┘  └──────────────┘  └──────────────┘           │
│            │               │               │                     │
│            └───────────────┼───────────────┘                     │
│                            ▼                                     │
│                  ┌──────────────────┐                            │
│                  │   AI Service     │                            │
│                  │  (LangChain.dart)│                            │
│                  └────────┬─────────┘                            │
│                           │                                      │
│            ┌──────────────┼──────────────┐                       │
│            ▼              ▼              ▼                       │
│     ┌──────────┐   ┌──────────┐   ┌──────────┐                   │
│     │  Local   │   │  Cloud   │   │  Shelf   │  ◄── Other Apps  │
│     │  Models  │   │  APIs    │   │  Server  │      Request AI  │
│     │ (GGUF)   │   │(OpenAI)  │   │ (HTTP)   │                   │
│     └──────────┘   └──────────┘   └──────────┘                   │
└─────────────────────────────────────────────────────────────────┘
```

**Other apps** can simply `POST /v1/chat/completions` to `localhost:8080` to use Prism's models — no SDK needed!

---

## ✨ Key Features

### 🤖 Multi-Provider AI
| Provider | Status | Notes |
|----------|--------|-------|
| **Local GGUF** | ✅ | Gemma, Llama, Phi via llama_sdk FFI |
| **Ollama** | ✅ | Connect to local Ollama server |
| **OpenAI** | ✅ | GPT-4, GPT-4o via API |
| **Google Gemini** | ✅ | Gemini Pro, Flash |
| **OpenRouter** | ✅ | 100+ models via single API |
| **Hugging Face** | ✅ | Download models from HF Hub |

### 💬 Intelligent Chat
- **Real-time Streaming**: Token-by-token response streaming
- **Conversation Management**: Pin, archive, search, delete chats
- **Temporary Chats**: Ephemeral conversations that don't save to history
- **System Prompts**: Customizable AI personality per chat
- **Voice Input**: Speech-to-text via `speech_to_text`

### 🧠 Second Brain (Knowledge Base)
PARA methodology implementation:
- **Areas**: Life domains (Work, Health, Finance)
- **Resources**: Reference materials linked to areas
- **Notes**: Markdown notes with FTS5 full-text search
- **Personas**: Custom AI personalities with instructions
- **Soul Document**: Your values and preferences for AI alignment

### 🛠️ Function Calling Tools
| Tool | Function |
|------|----------|
| `add_task` | Create tasks with priority & due dates |
| `log_expense` | Track finances via natural language |
| `search_notes` | FTS5 search across knowledge base |
| `get_weather` | Weather data retrieval |
| `web_search` | Internet search integration |
| `file_ops` | Read/write virtual filesystem |

### 🔔 Smart Notifications (Android)
- Intercepts notifications from other apps
- AI summarization of notification batches
- Priority scoring and grouping

### 📱 On-Device ML Kit
- **OCR**: Extract text from images
- **Entity Extraction**: Parse dates, money, addresses
- **Smart Reply**: Context-aware response suggestions
- **Language ID**: Detect text language

### 🎨 Beautiful Theming
- 7 accent color presets
- AMOLED dark mode
- Moon Design system components
- Responsive layout (mobile + tablet)

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter 3.10.8 + Dart 3 |
| **UI Library** | Moon Design 1.1.0 |
| **State Management** | Riverpod 2.6 |
| **Routing** | GoRouter 14.8 |
| **Database** | Drift (SQLite) + FTS5 full-text search |
| **AI/LLM** | LangChain.dart + llama_sdk (FFI) |
| **Inter-App Server** | Shelf (localhost HTTP) |
| **ML Kit** | Google ML Kit (OCR, Entity, Smart Reply) |
| **Model Format** | GGUF quantized models |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.10.8+
- Android Studio / VS Code
- Android device or emulator (API 24+)

### Installation

```bash
# Clone the repository
git clone https://github.com/Abhijeet1520/prism.git
cd prism

# Install dependencies
flutter pub get

# Generate Drift database code
dart run build_runner build --delete-conflicting-outputs

# Run on device
flutter run
```

### Download Models

1. Open Prism → Settings → Providers
2. Enter your Hugging Face token (for gated models)
3. Browse the model catalog and download:
   - **Gemma 3 1B** (recommended for mobile)
   - **Phi-4 Mini**
   - **TinyLlama 1.1B**

### First Chat

1. Tap "+" to create a new conversation
2. Select your downloaded local model
3. Start chatting — all processing happens on-device!

---

## 🏗️ Architecture

```
lib/
├── main.dart                         # App entry (Riverpod + GoRouter)
├── core/
│   ├── ai/
│   │   ├── ai_service.dart           # LangChain.dart AI backend
│   │   └── tool_registry.dart        # Function calling tools
│   ├── database/
│   │   ├── tables.dart               # Drift table definitions (10 tables)
│   │   ├── database.dart             # PrismDatabase with FTS5
│   │   └── queries.drift             # Custom SQL queries
│   ├── ml/
│   │   └── ml_kit_service.dart       # On-device ML Kit
│   └── theme/
│       └── prism_theme.dart          # Theme system
├── features/
│   ├── chat/                         # AI chat interface
│   ├── brain/                        # Second brain (PARA)
│   ├── home/                         # Dashboard
│   ├── apps/                         # Tools, Files, Finance
│   └── settings/                     # Providers, Theme, About
```

### Database Schema

| Table | Purpose |
|-------|---------|
| `conversations` | Chat sessions with model/provider |
| `messages` | Messages with FTS5 search |
| `task_entries` | Tasks with priority & due dates |
| `transactions` | Income & expenses |
| `areas` | PARA areas of responsibility |
| `resources` | Reference materials |
| `notes` | Knowledge base with FTS5 |
| `resource_areas` | Area ↔ Resource junction |
| `note_resources` | Note ↔ Resource junction |
| `app_settings` | Key-value settings |

---

## 📱 Building for Release

### Debug APK
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### App Bundle (Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### GitHub Release
```bash
# Tag version
git tag -a v0.2.0 -m "Release v0.2.0"
git push origin v0.2.0

# Create release via GitHub CLI
gh release create v0.2.0 build/app/outputs/flutter-apk/app-release.apk \
  --title "Prism v0.2.0" \
  --notes "See CHANGELOG.md for details"
```

Or manually:
1. Go to your repo → Releases → "Create new release"
2. Choose tag `v0.2.0`
3. Upload `app-release.apk` as binary
4. Publish release

---

## 🔒 Privacy & Security

- **100% Offline**: Local models run entirely on-device
- **No Telemetry**: Zero data collection or analytics
- **Local Storage**: All data in SQLite, never synced
- **Open Source**: Fully auditable codebase

---

## 🗺️ Roadmap

- [x] Multi-provider AI (Local, Ollama, Cloud)
- [x] Chat with streaming & history
- [x] Second Brain with PARA methodology
- [x] Function calling tools
- [x] Theme customization
- [x] Model download from Hugging Face
- [ ] Inter-app AI API (Shelf server)
- [ ] iOS support
- [ ] Desktop (Windows, macOS)
- [ ] Model fine-tuning interface
- [ ] Plugin system for custom tools

---

## 👨‍💻 Developer

**Abhijeet**
- Portfolio: [abhi1520.com](https://abhi1520.com)
- GitHub: [@Abhijeet1520](https://github.com/Abhijeet1520)

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [LangChain.dart](https://github.com/davidmigloz/langchain_dart) — AI chain patterns
- [Drift](https://drift.simonbinder.eu/) — Reactive SQLite for Flutter
- [Moon Design](https://moon.io/) — Beautiful UI components
- [llama.cpp](https://github.com/ggerganov/llama.cpp) — GGUF inference engine
- [Google ML Kit](https://developers.google.com/ml-kit) — On-device ML

---
