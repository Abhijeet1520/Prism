# Prism — Functional Requirements

## FR-01 Multi-Provider AI Chat

### FR-01.1 Provider Abstraction (LangChain.dart)

- Unified `BaseChatModel` interface across all providers.
- Supported providers:
  - **Local**: llama_cpp_dart (GGUF models via FFI)
  - **Ollama**: LAN/localhost discovery, model pull, OpenAI-compatible API
  - **OpenAI**: GPT-4o, GPT-4, GPT-3.5 via langchain_openai + dart_openai
  - **Google Gemini**: Gemini Pro, Gemini Flash via langchain_google
  - **Anthropic Claude**: Claude 3.x via langchain_anthropic (hypothetical; fallback to REST)
  - **Mistral**: Mistral Large, Medium, Small via langchain_mistralai
  - **Custom OpenAI-compatible**: Any endpoint via dart_openai with custom `baseUrl`
- Provider configuration stored in Drift database.
- Runtime provider switching without app restart.

### FR-01.2 Conversation Management

- Create, rename, delete, pin, archive conversations.
- **Branching threads**: Fork a conversation at any message to explore alternatives (inspired by Maid).
- Message tree structure stored in Drift; each message references `parentMessageId`.
- Conversation search (full-text via Drift/SQLite FTS5).
- Export conversations as Markdown or JSON.

### FR-01.3 Streaming & Token Display

- SSE-based streaming for cloud providers, callback-based for local inference.
- Real-time token count display (prompt + completion).
- Estimated cost display for paid cloud providers.
- Stop generation button.

### FR-01.4 Persona System

- Named personas with system prompts, default model, temperature, and top-p.
- Persona-per-conversation assignment.
- Pre-built personas: General Assistant, Code Helper, Writer, Analyst, Researcher.
- Custom persona creation with prompt templating (mustache syntax).

### FR-01.5 Context & Memory

- Sliding window context management with configurable token budget.
- Conversation summarization for long threads (using AI or google_mlkit_genai_summarization on Android).
- Optional RAG: embed files/notes into conversation context via vector similarity.

---

## FR-02 File Management

### FR-02.1 File Storage

- App-scoped file storage using platform file system APIs.
- Markdown (`.md`) as primary format for notes and documents.
- Support for `.txt`, `.json`, `.yaml`, `.dart`, `.py`, `.js`, `.ts`, `.csv` and other code/text formats.
- File metadata (created, modified, size, tags) tracked in Drift.

### FR-02.2 Rich Text Editing (AppFlowy Editor)

- Notion-style block-based editor for Markdown files.
- Supports headings, lists, checkboxes, tables, code blocks, callouts, images.
- Slash-command menu for block insertion.
- Real-time Markdown preview toggle.

### FR-02.3 Code Editing (re_editor)

- Syntax highlighting for 100+ languages.
- Code folding, line numbers, minimap.
- Find and replace with regex support.
- Keyboard shortcuts (Ctrl+S save, Ctrl+Z undo, etc.).
- Web-compatible.

### FR-02.4 File Locking

- Advisory lock system to prevent concurrent AI and user edits.
- Lock status indicator in file explorer.
- Lock owner tracking (user vs. AI agent vs. tool).
- Auto-release locks after configurable timeout.

### FR-02.5 File Explorer

- Hierarchical folder/file tree view.
- Create, rename, move, delete files and folders.
- Drag-and-drop reordering.
- File search by name, content, and tags.
- Recent files list.

---

## FR-03 Model Management

### FR-03.1 Local Model Management

- Download GGUF models from Hugging Face (URL-based).
- Model file browser with size, quantization info, and compatibility check.
- Delete downloaded models to free storage.
- Model performance benchmarking (tokens/sec on device).

### FR-03.2 Ollama Integration

- **LAN Discovery**: mDNS/DNS-SD scan for Ollama instances on local network.
- Manual host:port configuration.
- List, pull, delete models on remote Ollama server.
- Tag-based model selection.

### FR-03.3 Model Allowlist

- Curated list of recommended models per provider.
- Community-contributed model recommendations.
- Compatibility metadata (min RAM, quantization, context length).

---

## FR-04 Tools System

### FR-04.1 Built-in Tools

- **Web Search**: DuckDuckGo/Google search with result summarization.
- **Calculator**: Math expression evaluation.
- **Code Executor**: Execute code snippets (see FR-12).
- **File Reader/Writer**: Read from and write to local files.
- **URL Fetcher**: Fetch and parse web page content.
- **Date/Time**: Current time, timezone conversions, date math.
- **Image Generator**: Integration with DALL-E, Stable Diffusion APIs.

### FR-04.2 Tool Execution Pipeline

- Tool call detection from model output (function calling format).
- Parameter validation and type checking.
- Execution sandbox with timeout.
- Result injection back into conversation context.
- Tool call history log.

### FR-04.3 Custom Tool Creation

- User-defined tools via JSON schema definition.
- Tool = name + description + input schema + execution handler.
- Tools can invoke shell commands (desktop) or HTTP endpoints.

---

## FR-05 Settings & Configuration

### FR-05.1 App Settings

- Theme: Light / Dark / System (Moon Design theming with MoonTokens customization).
- Language / locale selection.
- Default model and provider selection.
- Data storage location (Android: app-scoped, Desktop: user-configurable).
- Notification preferences (Smart Notifications toggles).

### FR-05.2 Provider Settings

- Per-provider API key management (encrypted storage via flutter_secure_storage).
- Base URL configuration for self-hosted providers.
- Connection testing (ping/health check).
- Usage tracking and quota display.

### FR-05.3 Inference Settings

- Default temperature, top-p, top-k, repeat penalty.
- Max token limit (per model).
- Context window size.
- System prompt template.
- GPU layer offloading count (llama_cpp_dart).

### FR-05.4 Privacy Settings

- Telemetry opt-in/out.
- Conversation data retention policy (auto-delete after N days).
- Export all data as ZIP.
- Delete all data ("nuclear" option).

---

## FR-06 Cloud Sync (Supabase)

### FR-06.1 Authentication

- Email/password authentication via Supabase Auth.
- OAuth providers (Google, GitHub) for convenience.
- JWT token management with auto-refresh.

### FR-06.2 Data Sync

- Bidirectional sync of conversations, files, settings, tasks, PARA notes.
- Conflict resolution: last-write-wins with manual merge option.
- Selective sync (choose which data categories to sync).
- Sync status indicator in UI.

### FR-06.3 Offline Support

- Full offline functionality; sync queues changes for later upload.
- Drift database is the source of truth.
- Background sync when connectivity resumes.

---

## FR-07 Sheets & Documents

### FR-07.1 Spreadsheet View

- CSV/TSV import and display in table view.
- Column sorting, filtering, and basic formulas.
- AI-assisted data analysis ("summarize this data", "find anomalies").
- Export as CSV.

### FR-07.2 AI Document Generation

- Generate reports, summaries, and structured documents from conversation context.
- Template-based generation (meeting notes, research summaries, etc.).
- Export as Markdown or PDF.

---

## FR-08 Notifications & Background

### FR-08.1 Background Processing

- Background model inference for scheduled tasks (Android WorkManager).
- Notification for completed background tasks.
- Battery-aware scheduling (defer heavy work on low battery).

### FR-08.2 Push-like Notifications

- Local notification scheduling for reminders, task deadlines.
- AI-generated daily briefing notification (morning summary).

---

## FR-09 Accessibility & i18n

### FR-09.1 Accessibility

- Screen reader support (Semantics widgets).
- High contrast mode support.
- Keyboard navigation (desktop).
- Font size scaling.
- Reduced motion option.

### FR-09.2 Internationalization

- English as primary language.
- i18n infrastructure via flutter_localizations + arb files.
- RTL layout support.
- Community translations welcome.

---

## FR-10 Search

### FR-10.1 Global Search

- Unified search across conversations, files, tasks, PARA notes, financial records.
- SQLite FTS5 full-text search via Drift.
- Search result ranking and categorization.
- Recent searches and search suggestions.

### FR-10.2 Command Palette

- Keyboard-triggered command palette (Ctrl+K / Cmd+K).
- Quick actions: switch conversation, open file, run tool, change model.
- Fuzzy matching.
- Custom command palette overlay widget.

---

## FR-11 On-Device ML (Android)

### FR-11.1 Summarization

- On-device text summarization via google_mlkit_genai_summarization.
- Used for conversation summaries, file previews, notification digests.
- Android only; cloud fallback on other platforms.

### FR-11.2 Future ML Features (Deferred)

- On-device OCR for document scanning.
- On-device translation.
- Image classification for file organization.

---

## FR-12 Code Execution

### FR-12.1 Remote Execution (Primary)

- Cloud-hosted sandboxed execution environment.
- Support for Python, JavaScript, Dart, Shell.
- WebSocket-based real-time output streaming.
- Timeout and resource limits.

### FR-12.2 Local Execution — Mobile (QuickJS)

- JavaScript execution via flutter_js / QuickJS.
- Sandboxed with no file system or network access.
- Suitable for calculations, data transformations, simple scripts.

### FR-12.3 Local Execution — Desktop (Docker)

- Docker container-based execution for full language support.
- Pre-built container images for Python, Node.js, Dart.
- File system mounting for input/output.
- Network isolation by default.

---

## FR-13 Model Context Protocol (MCP)

### FR-13.1 MCP Host

- Prism acts as an MCP host, connecting to external MCP tool servers.
- Discover and list available tools from connected servers.
- Tool invocation with parameter marshalling.
- Support for stdio and SSE transport (mcp_dart).
- MCP server management UI (add, remove, configure servers).

### FR-13.2 MCP Client (Tool Provider)

- Prism exposes its built-in tools as an MCP server.
- Other MCP hosts can connect to Prism and invoke its tools.
- Tool registration with JSON Schema descriptions.
- Authentication for incoming MCP connections.

### FR-13.3 MCP Tool Discovery

- Browse available MCP tool servers (community registry).
- One-click install of MCP server configurations.
- Tool capability preview before connection.

---

## FR-14 Second Brain & Task Management

### FR-14.1 PARA Method Knowledge Base

- **Projects**: Active projects with goals, deadlines, and linked resources.
- **Areas**: Ongoing areas of responsibility (health, finance, career, etc.).
- **Resources**: Reference material organized by topic.
- **Archives**: Completed projects and inactive items.
- AI-assisted categorization: drag a note in, AI suggests PARA placement.
- Cross-linking between PARA items and conversations, files, tasks.

### FR-14.2 Smart Notes

- Quick capture (text, voice transcript, image → text via OCR).
- AI-powered tagging and summarization.
- Bi-directional links between notes.
- Daily notes / journal with AI reflections.
- Markdown format with AppFlowy Editor.

### FR-14.3 Task Management

- Create tasks with title, description, due date, priority, tags.
- Recurring tasks (daily, weekly, monthly, custom cron).
- AI task prioritization: suggest what to work on next based on deadlines, importance, and context.
- Task dependency chains.
- Kanban view (backlog → in progress → done).
- Calendar view with task timeline.
- Integration with PARA projects (tasks belong to projects).

### FR-14.4 Skillsets

- Community-contributed AI skill packages.
- Each skillset = system prompt + tool definitions + example conversations.
- Install from skillset registry or import from file.
- Skillset marketplace (future).
- Examples: "Code Reviewer", "Meeting Summarizer", "Research Assistant", "SQL Expert".

---

## FR-15 Financial Tracker

### FR-15.1 Notification-Based Transaction Capture (Android)

- Listen to notifications from banking/payment apps via notification_listener_service.
- Regex-based parsing of transaction notifications (amount, merchant, type).
- Configurable app allowlist for notification capture.
- Manual transaction entry as fallback (all platforms).

### FR-15.2 AI Categorization

- Auto-categorize transactions (groceries, transport, entertainment, bills, etc.).
- Learn from user corrections to improve categorization.
- Custom category creation.
- Merchant recognition and normalization.

### FR-15.3 Budget & Insights

- Monthly budget setting per category.
- Spending vs. budget progress bars.
- AI-generated spending insights ("You spent 30% more on dining this month").
- Trend analysis over time.
- Expense forecasting.

### FR-15.4 Reports

- Monthly/weekly/yearly spending reports.
- Category breakdown charts.
- Export as CSV or Markdown.
- AI narrative summary of financial health.

---

## FR-16 AI Gateway

### FR-16.1 Local HTTP Server

- Run an HTTP server on localhost using shelf + shelf_router.
- OpenAI-compatible API endpoints (`/v1/chat/completions`, `/v1/models`).
- Allow other apps on the device to send requests to Prism's AI.
- Configurable port number.
- Start/stop server from Settings.

### FR-16.2 Authentication

- Token-based authentication for API access.
- Generate and revoke API tokens from Prism UI.
- Rate limiting per token.
- Request logging and audit trail.

### FR-16.3 Model Routing

- Route incoming requests to any configured provider (local or cloud).
- Model aliasing (map custom names to specific provider+model combos).
- Fallback chains (try local first, fall back to cloud).
- Load balancing across multiple Ollama instances.

---

## FR-17 Smart Notifications

### FR-17.1 Procrastination Breaker

- Detect user inactivity on tasks (no progress updates).
- Send motivational nudges based on user's persona/tone preferences.
- Escalating urgency as deadlines approach.
- Configurable quiet hours.

### FR-17.2 Contextual Checklist

- AI-generated daily checklist based on tasks, calendar, habits.
- Morning briefing notification with today's priorities.
- Evening review prompt with accomplishments summary.
- Smart rescheduling suggestions for missed items.

### FR-17.3 Motivational & Wellness

- Positive reinforcement for completed tasks.
- Break reminders for long work sessions.
- Customizable notification tone and style.
- Integration with task management (FR-14.3) for trigger data.

---

## FR Summary Matrix

| FR | Feature | Phase | Platform |
|---|---|---|---|
| FR-01 | Multi-Provider AI Chat | 1 | All |
| FR-02 | File Management | 1 | All |
| FR-03 | Model Management | 1 | All |
| FR-04 | Tools System | 1 | All |
| FR-05 | Settings & Configuration | 1 | All |
| FR-06 | Cloud Sync (Supabase) | 2 | All |
| FR-07 | Sheets & Documents | 2 | All |
| FR-08 | Notifications & Background | 2 | Android (primary) |
| FR-09 | Accessibility & i18n | 2 | All |
| FR-10 | Search | 1 | All |
| FR-11 | On-Device ML | 2 | Android |
| FR-12 | Code Execution | 2 | All |
| FR-13 | MCP (Model Context Protocol) | 1 | All |
| FR-14 | Second Brain & Tasks | 1 | All |
| FR-15 | Financial Tracker | 2 | Android (notification), All (manual) |
| FR-16 | AI Gateway | 2 | Android, Desktop |
| FR-17 | Smart Notifications | 2 | Android (primary) |
