<h1 align="center">Prism – Your Offline AI Hub</h1>

<p align="center">
  <strong>Download AI models once, use everywhere. Privacy-first assistant with inter-app AI hosting.</strong>
</p>

<p align="center">
  <a href="#the-problem">Problem</a> •
  <a href="#the-solution">Solution</a> •
  <a href="#features">Features</a> •
  <a href="#screenshots">Screenshots</a> •
  <a href="#tech-stack">Tech Stack</a> •
  <a href="#getting-started">Get Started</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.10.8-02569B?logo=flutter" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart" alt="Dart"/>
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License"/>
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?logo=android" alt="Android"/>
</p>

---

## The Problem

Today's mobile AI is **fragmented and wasteful**:

| Issue | Impact |
|-------|--------|
| 📦 **Redundant Downloads** | 5 AI apps = 5 copies of the same model (100MB-4GB each) |
| 🔋 **Battery Drain** | Multiple inference engines destroy battery life |
| 🚫 **No Interop** | Apps can't share AI – each reinvents the wheel |

---

## The Solution

**Prism** is a **centralized offline AI hub**:

| Feature | Benefit |
|---------|---------|
| 📁 **Single Model Repo** | Download once, use everywhere |
| 🔗 **Inter-App Hosting** | Other apps POST to `localhost:8080` |
| 🔒 **100% Privacy** | All inference on-device, no cloud |

```
Other Apps → POST /v1/chat/completions → Prism → Local GGUF Models
```

---

## Screenshots

### Home & Chat
<p>
  <img src="website/screenshots/Home section with welcome.jpg" alt="Home" width="240"/>
  <img src="website/screenshots/Chat with showcasing available tools reply from model and tool calling.jpg" alt="Chat" width="240"/>
  <img src="website/screenshots/Conversations with local model.jpg" alt="Local Model Chat" width="240"/>
</p>
<p>
  <img src="website/screenshots/Home section scrolled, showcasing tasks, ai status, schedule, finance.jpg" alt="Dashboard" width="240"/>
</p>

**Home** – Daily digest with AI status, tasks, and finance summary.
**Chat** – Real-time streaming with function calling (add tasks, log expenses).
**Local Model** – Fully offline conversations powered by on-device GGUF models.
→ Source: [`lib/features/home/`](https://github.com/Abhijeet1520/Prism/tree/main/lib/features/home), [`lib/features/chat/`](https://github.com/Abhijeet1520/Prism/tree/main/lib/features/chat)

### Second Brain
<p>
  <img src="website/screenshots/Brain with notes section.jpg" alt="Notes" width="240"/>
  <img src="website/screenshots/Knowledge section open note showcasing editor.jpg" alt="Editor" width="240"/>
  <img src="website/screenshots/Brain Persona section.jpg" alt="Personas" width="240"/>
</p>

**Notes** – Search, tag filters, FTS5 full-text search.
**Editor** – Inline editing with timestamps.
**Personas** – Custom AI personalities for different use cases.
→ Source: [`lib/features/brain/`](https://github.com/Abhijeet1520/Prism/tree/main/lib/features/brain)

<details>
<summary><strong>📱 Apps Hub</strong> (click to expand)</summary>

<p>
  <img src="website/screenshots/Apps screen showcasing tasks, finance and other options.jpg" alt="Apps" width="240"/>
  <img src="website/screenshots/Tasks section under apps with item moved in kanbanboard.jpg" alt="Kanban" width="240"/>
  <img src="website/screenshots/Finance page showcasing transactions.jpg" alt="Finance" width="240"/>
</p>

**Apps** – Central hub for Tasks, Finance, Files, Tools.
**Kanban** – Drag-and-drop task board.
**Finance** – Expense tracking with categories.
→ Source: [`lib/features/apps/`](https://github.com/Abhijeet1520/Prism/tree/main/lib/features/apps)

</details>

<details>
<summary><strong>🛠️ Tools & Gateway</strong> (click to expand)</summary>

<p>
  <img src="website/screenshots/Tools under Apps showcasing tools available for llm.jpg" alt="Tools" width="240"/>
  <img src="website/screenshots/Gateway option enabled under app showcasing the server running.jpg" alt="Gateway" width="240"/>
  <img src="website/screenshots/Prism API via localhost.jpg" alt="API Playground" width="240"/>
</p>
<p>
  <img src="website/screenshots/MCP Servers under Tools in Apps.jpg" alt="MCP" width="240"/>
</p>

**Tools** – Function calling registry (add_task, log_expense, search_notes).
**Gateway** – Local HTTP server for inter-app AI.
**API Playground** – Swagger-like UI to test the local API with auth & streaming.
**MCP** – Model Context Protocol server config.
→ Source: [`lib/features/apps/tools_sub_screen.dart`](https://github.com/Abhijeet1520/Prism/blob/main/lib/features/apps/tools_sub_screen.dart), [`lib/features/apps/gateway_sub_screen.dart`](https://github.com/Abhijeet1520/Prism/blob/main/lib/features/apps/gateway_sub_screen.dart)

</details>

<details>
<summary><strong>⚙️ Settings</strong> (click to expand)</summary>

<p>
  <img src="website/screenshots/SettingsPage.jpg" alt="Settings" width="240"/>
  <img src="website/screenshots/SettingsPage2-with data & storage.jpg" alt="Data" width="240"/>
</p>

**Settings** – Providers, themes, privacy.
**Data** – Export/import, storage management.
→ Source: [`lib/features/settings/`](https://github.com/Abhijeet1520/Prism/tree/main/lib/features/settings)

</details>

---

## Features

| Category | Features | Status |
|----------|----------|--------|
| **AI Providers** | Local GGUF, Ollama, OpenAI, Gemini, OpenRouter | ✅ Ready |
| **Chat** | Streaming, history, temporary chats, voice input | ✅ Ready |
| **Tools** | add_task, log_expense, search_notes, get_weather | ✅ Ready |
| **Brain** | Notes with tags, FTS5 search, personas, soul doc | ✅ Ready |
| **Apps** | Tasks (Kanban), Finance, Files, Gateway | ✅ Ready |
| **ML Kit** | OCR, entity extraction, smart reply, language ID | ✅ Ready |
| **Inter-App** | Shelf server at localhost:8080 | 🔄 Preview |

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter 3.10.8 + Dart 3 |
| State | Riverpod 2.6 |
| Database | Drift (SQLite) + FTS5 |
| AI | LangChain.dart + llama_sdk (FFI) |
| Inter-App | Shelf (localhost HTTP) |
| ML | Google ML Kit |

---

## Getting Started

```bash
# Clone
git clone https://github.com/Abhijeet1520/Prism.git
cd Prism

# Install
flutter pub get

# Generate DB code
dart run build_runner build --delete-conflicting-outputs

# Run
flutter run
```

### Download Models

1. Settings → Providers → Enter Hugging Face token
2. Download **Gemma 3 1B** or **Phi-4 Mini**
3. Start chatting – 100% on-device!

---

## Architecture

```
lib/
├── core/
│   ├── ai/           # LangChain.dart, tool registry
│   ├── database/     # Drift tables, FTS5 search
│   └── ml/           # ML Kit service
├── features/
│   ├── chat/         # AI chat interface
│   ├── brain/        # Notes, personas, soul
│   ├── home/         # Dashboard
│   ├── apps/         # Tasks, finance, files
│   └── settings/     # Providers, themes
```

---

## Privacy

- **100% Offline** – Local models, no cloud uploads
- **No Telemetry** – Zero analytics or tracking
- **Open Source** – Fully auditable

---

## Roadmap

- [x] Multi-provider AI
- [x] Chat with tools
- [x] Second Brain (PARA)
- [x] Theme customization
- [ ] RAG for knowledge base
- [ ] Voice input/output
- [ ] iOS support

---

## License

MIT – see [LICENSE](LICENSE)

---

<p align="center">
  Made with ❤️ by <a href="https://abhi1520.com">Abhijeet1520</a>
</p>
