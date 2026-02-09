# Prism — AI Personal Assistant

Privacy-first AI assistant powered by local and cloud LLMs. Built with Flutter.

## Architecture

```
lib/
├── main.dart                         # App entry point (Riverpod + GoRouter)
├── core/
│   ├── ai/
│   │   ├── ai_service.dart           # LangChain.dart AI backend (Ollama, OpenAI, Mock)
│   │   └── tool_registry.dart        # Function calling tools (tasks, finance, search, weather)
│   ├── database/
│   │   ├── tables.dart               # Drift table definitions (6 tables)
│   │   ├── database.dart             # PrismDatabase with reactive queries + FTS5
│   │   ├── database.g.dart           # Generated code
│   │   └── queries.drift             # FTS5 search + custom SQL queries
│   ├── ml/
│   │   └── ml_kit_service.dart       # On-device ML Kit (OCR, Entity Extraction, Smart Reply, Language ID)
│   ├── theme/
│   │   └── prism_theme.dart          # Theme system (7 presets, AMOLED, Moon Design tokens)
│   └── router/
│       └── app_router.dart           # GoRouter with ShellRoute (5 tabs)
├── features/
│   ├── shell/
│   │   └── app_shell.dart            # 5-tab navigation (mobile + desktop)
│   ├── splash/
│   │   └── splash_screen.dart        # Animated splash with Soul Orb
│   └── chat/
│       └── chat_detail_screen.dart   # Real-time streaming chat UI
```

## Tech Stack

| Layer           | Technology                     |
|-----------------|--------------------------------|
| UI Framework    | Flutter + Moon Design 1.1.0    |
| State           | Riverpod 2.6                   |
| Routing         | GoRouter 14.8                  |
| AI Backend      | LangChain.dart + Ollama        |
| Database        | Drift (SQLite) + FTS5          |
| On-Device ML    | Google ML Kit                  |
| Function Calling| LangChain ToolSpec             |

## Key Features

### Working Now
- **AI Chat with Streaming** — Real-time token streaming via LangChain.dart chains
- **Multi-provider AI** — Ollama (local), OpenAI, Gemini, Mock backends
- **Tool Calling** — 4 tools (add_task, log_expense, search_notes, get_weather)
- **Drift Database** — 6 tables with reactive streams and FTS5 full-text search
- **ML Kit Services** — OCR, Entity Extraction, Smart Reply, Language ID
- **Theme System** — 7 accent presets, AMOLED mode, Moon Design tokens
- **Responsive Layout** — NavigationBar (mobile) + NavigationRail (desktop)
- **Natural Language Finance** — "Spent $42 on groceries" parsed by Entity Extraction

### Database Tables
| Table          | Purpose                        | Search |
|----------------|--------------------------------|--------|
| Conversations  | Chat sessions with AI          | —      |
| Messages       | Chat messages per conversation  | FTS5   |
| TaskEntries    | Tasks with priority & due date | —      |
| Transactions   | Income & expenses              | —      |
| Notes          | Knowledge base / brain         | FTS5   |
| AppSettings    | Key-value settings store       | —      |

## Getting Started

```bash
# Install dependencies
flutter pub get

# Generate Drift database code
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Ollama Setup (Local AI)
```bash
# Install Ollama (https://ollama.ai)
ollama pull gemma3:4b
ollama serve
# The app auto-connects to localhost:11434
```

## App Identity
- Package: `com.abhi1520.prism`
- Website: [prism.abhi1520.com](https://prism.abhi1520.com)

## References
Patterns extracted from these example codebases:
- **LangChain.dart** — Chain/streaming/tool-calling patterns
- **Drift examples** — Table definitions, FTS5, reactive queries, Riverpod integration
- **Maid** — Multi-provider AI controller hierarchy, model downloading
- **Google ML Kit** — OCR, Entity Extraction, Smart Reply, Language ID
