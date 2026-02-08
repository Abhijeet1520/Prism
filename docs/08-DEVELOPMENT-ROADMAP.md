# Prism — Development Roadmap

## Overview

Prism is developed in 4 phases, progressing from core AI chat to a full Second Brain with advanced integrations. Each phase builds on the previous, ensuring a functional app at every milestone.

**Primary Platform**: Android
**Secondary**: Desktop (Windows, Linux, macOS)
**Tertiary**: Web
**CI/CD**: GitHub Actions
**Distribution**: GitHub Releases, F-Droid

---

## Phase 1 — Foundation (Weeks 1–8)

> **Goal**: Working AI chat app with local + cloud providers, basic file management, and Second Brain skeleton.

### P1.1 Project Setup (Week 1)

- [ ] Initialize Flutter project with `moon_design` and `Riverpod`
- [ ] Set up project directory structure (feature-first modules)
- [ ] Configure Drift database with initial schema (conversations, messages, providers, personas)
- [ ] Set up GoRouter with shell route (app scaffold + navigation)
- [ ] Configure GitHub Actions CI pipeline (lint → test → build)
- [ ] Set up Moon Design theming (MoonTokens dark, indigo accent)

### P1.2 AI Engine Core (Weeks 2–3)

- [ ] Implement `AiEngine` and `ProviderManager` abstractions
- [ ] LangChain.dart adapter for OpenAI (`langchain_openai`)
- [ ] LangChain.dart adapter for Ollama (`langchain_ollama`)
- [ ] Local inference service with `llama_cpp_dart` (GGUF loading, generation)
- [ ] dart_openai integration for custom OpenAI-compatible endpoints
- [ ] Streaming token output (SSE for cloud, callback for local)
- [ ] Provider configuration CRUD (Drift persistence)
- [ ] Connection testing per provider

### P1.3 Chat Module (Weeks 3–5)

- [ ] Conversation list UI (`TreeView`, search, context menu)
- [ ] Chat view UI (`ChatGroup`, `ChatBubble`, streaming display)
- [ ] Chat input bar (`TextField`, model selector `Select`, send button)
- [ ] Message persistence (Drift, branching with `parentMessageId`)
- [ ] Branch navigation UI (← 1/3 → buttons)
- [ ] Conversation create/rename/delete/pin/archive
- [ ] Persona system (CRUD, assignment to conversations)
- [ ] Token count display and cost estimation
- [ ] Copy message, export conversation as Markdown

### P1.4 File Management (Weeks 5–6)

- [ ] File explorer with `TreeView` (hierarchical folders/files)
- [ ] File/folder CRUD operations
- [ ] Rich text editor integration (`appflowy_editor` for Markdown)
- [ ] Code editor integration (`re_editor` for code files)
- [ ] File metadata tracking in Drift
- [ ] File locking system (advisory locks)
- [ ] File search by name and content

### P1.5 Tools Foundation (Weeks 6–7)

- [ ] Tool definition schema and registry
- [ ] Built-in tools: calculator, date/time
- [ ] Tool call detection from model output
- [ ] Tool execution pipeline with result injection
- [ ] Tools grid UI (`Card` grid with enable/disable `Switch`)

### P1.6 Second Brain Skeleton (Weeks 7–8)

- [ ] PARA data model (Drift tables: ParaItems, ParaNotes, NoteLinks)
- [ ] PARA dashboard UI with `Tabs` (Projects, Areas, Resources, Archives)
- [ ] Note creation with `appflowy_editor`
- [ ] Basic task creation (title, description, due date, status)
- [ ] Task list view (`Table` with sort/filter)
- [ ] Link tasks to PARA projects

### P1.7 Settings (Week 8)

- [ ] Settings screen with `NavigationSidebar` sections
- [ ] Provider configuration UI (`Accordion` per provider)
- [ ] Inference settings (temperature, top-p, max tokens sliders)
- [ ] Appearance settings (theme mode, accent color)
- [ ] Privacy settings (data retention, export)
- [ ] About screen with version info

### P1 Deliverable

- Android APK via GitHub Releases
- Functional AI chat with OpenAI, Ollama, and local llama.cpp
- File management with Markdown and code editing
- Basic Second Brain with PARA + tasks
- 5 built-in personas
- Command palette (Ctrl+K)

---

## Phase 2 — Intelligence (Weeks 9–16)

> **Goal**: Full Second Brain, financial tracker, MCP support, AI Gateway, cloud sync, and smart notifications.

### P2.1 MCP Integration (Weeks 9–10)

- [ ] MCP host service (`mcp_dart` — connect to external servers)
- [ ] MCP server management UI (add/edit/remove, transport config)
- [ ] Tool discovery from connected MCP servers
- [ ] Tool invocation with parameter marshalling
- [ ] MCP tool display in Tools grid with `Badge` source indicator
- [ ] MCP client service (expose Prism tools to other hosts)

### P2.2 Second Brain — Full (Weeks 10–12)

- [ ] AI-assisted PARA categorization (suggest placement for new notes)
- [ ] Bi-directional note linking with link picker UI
- [ ] Quick capture (text → note with auto-tagging)
- [ ] Daily notes / journal view
- [ ] Task management: Kanban view with drag-and-drop (`SortableLayer`)
- [ ] Task management: Calendar view with `Calendar` component
- [ ] Recurring tasks (daily/weekly/monthly/cron)
- [ ] AI task prioritization scoring
- [ ] Task dependency chains
- [ ] Skillset system (import, enable/disable, marketplace placeholder)
- [ ] Global search (FTS5 across conversations, files, notes, tasks)

### P2.3 Financial Tracker (Weeks 12–14)

- [ ] Notification listener service integration (Android)
- [ ] Transaction parsing (regex patterns for banking apps)
- [ ] App allowlist configuration UI
- [ ] Manual transaction entry (`Dialog` form)
- [ ] AI categorization (auto-categorize by merchant)
- [ ] Category management (built-in + custom)
- [ ] Finance dashboard (`NumberTicker`, `Progress` bars, `Tracker` heatmap)
- [ ] Budget management per category
- [ ] Transaction list with filters and search
- [ ] AI spending insights
- [ ] Export transactions as CSV

### P2.4 AI Gateway (Weeks 14–15)

- [ ] shelf HTTP server with OpenAI-compatible endpoints
- [ ] `GET /v1/models` — list available models
- [ ] `POST /v1/chat/completions` — chat with streaming SSE
- [ ] Token-based authentication middleware
- [ ] Rate limiting middleware
- [ ] Request logging to Drift
- [ ] Gateway dashboard UI (start/stop, status, stats)
- [ ] API token management UI (create, revoke, view usage)
- [ ] Model routing / aliasing
- [ ] Request logs viewer with pagination

### P2.5 Cloud Sync — Supabase (Week 15)

- [ ] Supabase authentication (email/password, OAuth)
- [ ] Bidirectional sync for conversations, messages, files, notes, tasks
- [ ] Conflict resolution (last-write-wins)
- [ ] Selective sync (choose categories)
- [ ] Sync status UI indicator
- [ ] Offline queue with background sync

### P2.6 Smart Notifications (Week 16)

- [ ] Procrastination detection (task inactivity monitoring)
- [ ] Motivational nudges (configurable tone and frequency)
- [ ] Daily checklist generation (AI-based, morning/evening)
- [ ] Break reminders for long work sessions
- [ ] Notification settings UI (`Accordion` with toggles and sliders)
- [ ] Quiet hours configuration

### P2 Deliverable

- Full Second Brain with PARA, tasks, notes
- Financial tracker with auto-capture (Android)
- MCP host + client
- AI Gateway (localhost HTTP server)
- Cloud sync via Supabase
- Smart notifications
- Skillset system
- GitHub Release: APK + Windows installer

---

## Phase 3 — Expansion (Weeks 17–24)

> **Goal**: Desktop polish, code execution, GitHub integration, browser automation, advanced ML.

### P3.1 Desktop Platform Support (Weeks 17–18)

- [ ] Windows build optimization and testing
- [ ] macOS build and notarization
- [ ] Linux AppImage packaging
- [ ] Desktop-specific UI adaptations (window management, tray icon)
- [ ] Keyboard-first UX refinement
- [ ] System tray with quick actions

### P3.2 Code Execution (Weeks 18–19)

- [ ] Remote execution service integration
- [ ] QuickJS executor for mobile (JavaScript)
- [ ] Docker executor for desktop (Python, Node.js, Dart)
- [ ] Code runner UI sheet in code editor
- [ ] Output streaming display
- [ ] Execution history

### P3.3 GitHub Integration (Weeks 19–20)

- [ ] GitHub authentication (personal access token)
- [ ] Repository browser UI
- [ ] Issue list and detail view
- [ ] Create/edit issues
- [ ] Pull request list and detail
- [ ] File browser for repo contents
- [ ] AI-assisted issue creation from conversation context

### P3.4 Browser Automation (Weeks 20–21)

- [ ] Firecrawl REST API integration (scrape, crawl)
- [ ] URL fetcher tool enhancement with Firecrawl
- [ ] Puppeteer integration for desktop (headless Chrome)
- [ ] Screenshot capture
- [ ] Web content → Markdown conversion
- [ ] "Research" tool combining search + scrape + summarize

### P3.5 On-Device ML (Week 21)

- [ ] google_mlkit_genai_summarization integration (Android)
- [ ] Conversation summarization for context management
- [ ] File preview generation via on-device summarization
- [ ] Cloud fallback for non-Android platforms

### P3.6 Advanced Features (Weeks 22–24)

- [ ] Ollama LAN discovery (mDNS/DNS-SD scanning)
- [ ] Google Gemini adapter (`langchain_google`)
- [ ] Mistral adapter (`langchain_mistralai`)
- [ ] Anthropic Claude REST adapter
- [ ] RAG prototype (embed files → vector search → context injection)
- [ ] Sheets/documents: CSV import, table view, AI analysis
- [ ] Advanced search: search suggestions, result ranking, saved searches

### P3 Deliverable

- Full desktop support (Windows, macOS, Linux)
- Code execution (remote + local)
- GitHub integration
- Browser automation
- On-device ML (Android)
- 6 AI providers fully supported
- Distribution: GitHub Releases (all platforms), F-Droid (Android)

---

## Phase 4 — Polish & Scale (Weeks 25–32)

> **Goal**: Web support, accessibility, i18n, optimization, community features.

### P4.1 Web Platform (Weeks 25–26)

- [ ] Web build with Drift (sql.js backend)
- [ ] Web-specific UI adaptations
- [ ] Disable local inference features (no FFI on web)
- [ ] AI Gateway not available on web
- [ ] PWA configuration

### P4.2 Accessibility (Weeks 26–27)

- [ ] Screen reader audit and Semantics widget coverage
- [ ] Keyboard navigation audit (all screens)
- [ ] High contrast mode testing
- [ ] Font scaling edge cases
- [ ] Reduced motion implementation
- [ ] WCAG 2.1 AA compliance verification

### P4.3 Internationalization (Weeks 27–28)

- [ ] ARB file setup for all user-facing strings
- [ ] English (en) complete translation
- [ ] RTL layout testing and fixes
- [ ] Community translation infrastructure
- [ ] Date/number/currency formatting per locale

### P4.4 Performance Optimization (Weeks 28–29)

- [ ] Database query optimization and index review
- [ ] Memory profiling and leak detection
- [ ] Cold start time optimization
- [ ] Lazy loading for all feature modules
- [ ] Image/asset caching optimization
- [ ] Battery usage profiling on Android

### P4.5 Community & Ecosystem (Weeks 30–32)

- [ ] Skillset registry / marketplace
- [ ] Public MCP server directory
- [ ] Plugin documentation and developer guide
- [ ] Contribution guidelines (CONTRIBUTING.md)
- [ ] F-Droid submission
- [ ] User feedback system (GitHub Issues templates)
- [ ] Documentation site

### P4 Deliverable

- Web support (progressive)
- Full accessibility (WCAG 2.1 AA)
- i18n infrastructure with English complete
- Performance-optimized across all platforms
- Skillset marketplace (basic)
- F-Droid listing

---

## Dependency Installation Timeline

### Phase 1 Packages

```yaml
dependencies:
  flutter:
    sdk: flutter
  moon_design: ^1.1.0
  flutter_riverpod: ^2.0.0
  riverpod_annotation: ^2.0.0
  go_router: ^14.0.0
  drift: ^2.31.0
  sqlite3_flutter_libs: latest
  langchain: latest
  langchain_openai: latest
  langchain_ollama: latest
  dart_openai: ^6.1.1
  llama_cpp_dart: ^0.2.2
  flutter_secure_storage: latest
  re_editor: ^0.8.0
  appflowy_editor: ^6.2.0
  path_provider: latest
  uuid: latest

dev_dependencies:
  riverpod_generator: ^2.0.0
  build_runner: latest
  drift_dev: latest
```

### Phase 2 Packages (Added)

```yaml
dependencies:
  mcp_dart: ^1.2.2
  shelf: ^1.4.2
  shelf_router: ^1.1.4
  notification_listener_service: ^0.3.5
  supabase_flutter: latest
```

### Phase 3 Packages (Added)

```yaml
dependencies:
  github: ^9.25.0
  puppeteer: ^3.20.0
  flutter_js: latest
  google_mlkit_genai_summarization: ^0.1.0
  langchain_google: latest
  langchain_mistralai: latest
```

---

## CI/CD Pipeline (GitHub Actions)

```yaml
name: Prism CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: dart run build_runner build
      - run: flutter analyze
      - run: flutter test

  build-android:
    needs: analyze
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v4
        with:
          name: android-apk
          path: build/app/outputs/flutter-apk/app-release.apk

  build-windows:
    needs: analyze
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter build windows --release

  build-linux:
    needs: analyze
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: |
          sudo apt-get update -y
          sudo apt-get install -y ninja-build libgtk-3-dev
      - run: flutter build linux --release

  release:
    if: startsWith(github.ref, 'refs/tags/v')
    needs: [build-android, build-windows, build-linux]
    runs-on: ubuntu-latest
    steps:
      - uses: softprops/action-gh-release@v2
        with:
          files: |
            android-apk/app-release.apk
```

---

## Milestone Summary

| Phase | Duration | Key Deliverables | Status |
|---|---|---|---|
| **Phase 1** | Weeks 1–8 | AI Chat, Files, Second Brain skeleton, Settings | Not started |
| **Phase 2** | Weeks 9–16 | MCP, Full Brain, Finance, Gateway, Sync, Notifications | Not started |
| **Phase 3** | Weeks 17–24 | Desktop, Code Exec, GitHub, Browser, ML | Not started |
| **Phase 4** | Weeks 25–32 | Web, A11y, i18n, Performance, Community | Not started |
