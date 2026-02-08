# Prism — Glossary

## A

**AGPL (Affero General Public License)** — Open-source license used by Prism. Requires source code distribution, including for network-accessible services (AI Gateway).

**AI Gateway** — Prism's built-in local HTTP server (shelf) that exposes OpenAI-compatible API endpoints, allowing other applications on the device or LAN to use Prism's AI capabilities.

**AppFlowy Editor** — Notion-style block-based rich text editor (`appflowy_editor` 6.2.0) used for Markdown editing in files and PARA notes.

**AsyncNotifierProvider** — Riverpod provider type for managing asynchronous state with built-in loading/error handling.

## B

**Branching** — Conversation feature allowing users to fork a message thread at any point, creating alternative response paths. Implemented via `parentMessageId` in the Messages table.

## C

**ChatBubble** — Custom widget styled with MoonSquircleBorder for rendering individual chat messages.

**ChatGroup** — Widget that groups consecutive messages from the same sender with MoonAvatar display.

**Command Palette** — Keyboard-triggered searchable action list (Ctrl+K / Cmd+K). Custom overlay widget.

## D

**DAO (Data Access Object)** — Drift pattern for encapsulating database queries per table/feature. e.g., `ConversationDao`, `TaskDao`.

**dart_openai** — Dart package (6.1.1) for OpenAI API integration. Supports custom `baseUrl` for connecting to any OpenAI-compatible endpoint (LM Studio, vLLM, text-generation-webui).

**Drift** — Type-safe, reactive SQLite database layer for Flutter (2.31.0). Flutter Favorite. Replaces Isar (discontinued). Supports web via sql.js, schema migrations, FTS5 full-text search.

## F

**F-Droid** — Open-source Android app repository. Distribution channel for Prism alongside GitHub Releases.

**Firecrawl** — Web scraping and crawling API service. No Dart package; integrated via direct REST API calls.

**FTS5** — SQLite full-text search extension. Used via Drift virtual tables for searching conversations, files, notes, and tasks.

**flutter_secure_storage** — Package for storing sensitive data (API keys, tokens) in OS-level secure storage (Android Keystore, iOS Keychain).

## G

**GGUF** — Model file format used by llama.cpp. Supports various quantization levels (Q4_0, Q4_K_M, Q5_K_M, Q8_0).

**GoRouter** — Declarative navigation package for Flutter. Handles deep linking, shell routes, and nested navigation.

**GitHub Actions** — CI/CD platform used for Prism's automated build, test, and release pipeline.

## I

**Isolate** — Dart mechanism for running code in parallel threads. Used for local inference to prevent UI jank.

## K

**Kanban** — Task management view showing tasks as cards in columns (Backlog → To Do → In Progress → Done).

## L

**LangChain.dart** — Dart port of the LangChain framework. Provides unified `BaseChatModel` interface across providers (OpenAI, Ollama, Gemini, Mistral). Core abstraction layer for Prism's AI engine.

**llama_cpp_dart** — Dart FFI bindings for llama.cpp (0.2.2). Enables on-device GGUF model inference with GPU acceleration.

**MoonIcons** — Primary icon set used in Prism's UI (from moon_icons package).

## M

**MCP (Model Context Protocol)** — Open protocol for connecting AI models to external tools and data sources. Prism acts as both MCP Host (connecting to external servers) and MCP Client (exposing its tools). Implemented via `mcp_dart` (1.2.2).

**mmap** — Memory-mapped file I/O. Used by llama_cpp_dart to load large GGUF models without consuming full RAM.

## N

**NavigationSidebar** — Custom sidebar using MoonMenuItem for vertical navigation with labels and dividers.

**notification_listener_service** — Android-only package (0.3.5) for reading notifications from other apps. Used for financial transaction capture.

## O

**Ollama** — Local/LAN AI model server with OpenAI-compatible API. Prism supports auto-discovery via mDNS, model pulling, and inference.

## P

**PARA Method** — Knowledge organization system: **P**rojects (active with goals), **A**reas (ongoing responsibilities), **R**esources (reference material), **A**rchives (completed/inactive). Core of Prism's Second Brain feature.

**Persona** — Named AI personality configuration including system prompt, default model, temperature, and avatar. Assigned per-conversation.

**Prism** — The application name. "The central hub for your intelligence."

**Provider** — An AI service that Prism can connect to for inference (OpenAI, Gemini, Ollama, local llama.cpp, Mistral, Anthropic, custom).

**Puppeteer** — Dart package (3.20.0) for controlling headless Chrome. Desktop-only browser automation.

## Q

**QuickJS** — Lightweight JavaScript engine used for sandboxed mobile code execution via `flutter_js`.

## R

**re_editor** — Code editor package (0.8.0) supporting 100+ languages with syntax highlighting, code folding, and minimap. Web-compatible.

**Riverpod** — State management and dependency injection framework for Flutter (2.x). Uses code generation via `@riverpod` annotations. Chosen over BLoC for less boilerplate and better testability.

## S

**moon_design** — Moon Design System (1.1.0) for Flutter. Themable, extensible widgets with squircle borders and token-based styling. Uses MaterialApp with MoonTheme as ThemeExtension.

**shelf** — Official Dart HTTP server package (1.4.2). Used for Prism's AI Gateway with composable middleware pipeline.

**Skillset** — Community-contributed AI capability package containing a system prompt, tool definitions, and example conversations. e.g., "Code Reviewer", "SQL Expert", "Research Assistant".

**Supabase** — Open-source Firebase alternative. Used for cloud sync (authentication, real-time database, file storage). Free tier for MVP.

**SQLCipher** — SQLite extension providing AES-256-CBC encryption. Optional for Drift database encryption at rest.

## T

**Tool** — A function that an AI model can invoke during a conversation. Examples: web search, calculator, file reader. Defined by name, description, input JSON schema, and execution handler.

**TreeView** — Hierarchical tree display widget. Used for file explorer and conversation list grouping.

## W

**WAL (Write-Ahead Logging)** — SQLite journal mode enabling concurrent reads and writes. Default mode for Prism's Drift database.

---

## Acronym Reference

| Acronym | Expansion |
|---|---|
| AGPL | Affero General Public License |
| API | Application Programming Interface |
| CI/CD | Continuous Integration / Continuous Deployment |
| CRUD | Create, Read, Update, Delete |
| DAO | Data Access Object |
| FFI | Foreign Function Interface |
| FTS | Full-Text Search |
| GGUF | GPT-Generated Unified Format |
| HTTP | HyperText Transfer Protocol |
| JWT | JSON Web Token |
| LAN | Local Area Network |
| MCP | Model Context Protocol |
| mDNS | Multicast Domain Name System |
| ML | Machine Learning |
| ORM | Object-Relational Mapping |
| PARA | Projects, Areas, Resources, Archives |
| PWA | Progressive Web App |
| RAG | Retrieval-Augmented Generation |
| REST | Representational State Transfer |
| SSE | Server-Sent Events |
| TLS | Transport Layer Security |
| UPI | Unified Payments Interface |
| UX | User Experience |
| WAL | Write-Ahead Logging |
| WCAG | Web Content Accessibility Guidelines |
