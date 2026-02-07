# 01 — Functional Requirements

> This document specifies every user-facing feature of Gemmie. Each requirement has a unique ID, priority (MoSCoW), status, and acceptance criteria. Requirements are grouped by feature domain.

---

## Table of Contents

- [FR-01: AI Chat & Conversation](#fr-01-ai-chat--conversation)
- [FR-02: Model Management](#fr-02-model-management)
- [FR-03: Cloud AI API Integration](#fr-03-cloud-ai-api-integration)
- [FR-04: Tools System](#fr-04-tools-system)
- [FR-05: Settings & Profiles](#fr-05-settings--profiles)
- [FR-06: File Storage System](#fr-06-file-storage-system)
- [FR-07: File Versioning & Diff](#fr-07-file-versioning--diff)
- [FR-08: Multi-Tier Permissions & Locks](#fr-08-multi-tier-permissions--locks)
- [FR-09: Agent Persona System](#fr-09-agent-persona-system)
- [FR-10: Code Execution Engine](#fr-10-code-execution-engine)
- [FR-11: Sheets & Documents](#fr-11-sheets--documents)
- [FR-12: Cloud Sync](#fr-12-cloud-sync)

---

## FR-01: AI Chat & Conversation

**Priority:** Must
**Status:** Draft
**Module:** Chat Module
**UI:** Chat Screen

### Description

The core interaction paradigm. Users converse with the AI assistant in a multi-turn chat interface with streaming responses, multi-modal input, and rich content rendering.

### Sub-Requirements

#### FR-01.1: Multi-Turn Conversation

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-01.1.1 | User can send text messages and receive AI responses in a sequential chat thread | Must | Draft |
| FR-01.1.2 | Conversation maintains context across turns within a session | Must | Draft |
| FR-01.1.3 | User can create multiple separate conversations | Must | Draft |
| FR-01.1.4 | Conversations are persisted across app restarts | Must | Draft |
| FR-01.1.5 | User can rename, archive, and delete conversations | Must | Draft |
| FR-01.1.6 | User can search across all conversations by keyword | Should | Draft |
| FR-01.1.7 | Conversations can be organized into folders/categories | Could | Draft |
| FR-01.1.8 | User can pin important conversations to the top | Could | Draft |

#### FR-01.2: Streaming & Real-Time Responses

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-01.2.1 | AI responses stream token-by-token as they are generated | Must | Draft |
| FR-01.2.2 | User can cancel/stop an in-progress response at any time | Must | Draft |
| FR-01.2.3 | Streaming works for both local models and cloud APIs | Must | Draft |
| FR-01.2.4 | Visual typing indicator shown while AI is processing before first token | Should | Draft |
| FR-01.2.5 | Network interruptions during streaming are handled gracefully with partial response preservation | Must | Draft |

#### FR-01.3: Multi-Modal Input

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-01.3.1 | User can type text messages via keyboard | Must | Draft |
| FR-01.3.2 | User can input via voice (speech-to-text) | Should | Draft |
| FR-01.3.3 | User can attach images from camera or gallery for vision-capable models | Should | Draft |
| FR-01.3.4 | User can attach files (PDF, MD, CSV, etc.) for context | Should | Draft |
| FR-01.3.5 | User can paste clipboard content (text, images) directly into chat | Must | Draft |
| FR-01.3.6 | User can reference files from Gemmie's storage in chat messages | Should | Draft |

#### FR-01.4: Rich Content Rendering

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-01.4.1 | AI responses render Markdown (headings, bold, italic, lists, links, blockquotes) | Must | Draft |
| FR-01.4.2 | Code blocks render with syntax highlighting for common languages | Must | Draft |
| FR-01.4.3 | Inline code renders with monospace formatting | Must | Draft |
| FR-01.4.4 | Tables in AI responses render as formatted tables | Should | Draft |
| FR-01.4.5 | Math equations render via LaTeX/KaTeX | Could | Draft |
| FR-01.4.6 | AI responses can include interactive elements (buttons for tool confirmation, file previews) | Should | Draft |
| FR-01.4.7 | Code blocks include a "Copy" button and optional "Run" button (connected to FR-10) | Must | Draft |

#### FR-01.5: Conversation Management

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-01.5.1 | User can regenerate the last AI response | Must | Draft |
| FR-01.5.2 | User can edit a previously sent message and get a new response from that point | Should | Draft |
| FR-01.5.3 | User can branch a conversation from any message (creating a fork) | Could | Draft |
| FR-01.5.4 | User can export a conversation as Markdown or PDF | Should | Draft |
| FR-01.5.5 | User can share a conversation via platform sharing | Could | Draft |
| FR-01.5.6 | User can switch the AI model mid-conversation (response uses new model from that point) | Must | Draft |

### Acceptance Criteria

- [ ] A new user can start a conversation, send a message, and receive a streamed response within 3 seconds (cloud) or 5 seconds (local model cold-start)
- [ ] Conversations persist and are fully restored after app restart
- [ ] Markdown in AI responses renders correctly including code blocks with syntax highlighting
- [ ] Cancelling a streaming response preserves the partial response in the conversation
- [ ] Model switching mid-conversation is seamless with no loss of chat history

---

## FR-02: Model Management

**Priority:** Must
**Status:** Draft
**Module:** Models Module
**UI:** Model Manager, Settings > Models

### Description

Users can discover, download, manage, and configure local AI models for on-device inference. Models are sourced primarily from HuggingFace with OAuth authentication for gated models.

### Sub-Requirements

#### FR-02.1: Model Discovery & Download

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-02.1.1 | App displays a curated list of compatible models from a model allowlist | Must | Draft |
| FR-02.1.2 | User can browse models by category (LLM, vision, code, etc.) | Must | Draft |
| FR-02.1.3 | Each model shows: name, size, description, capabilities, and compatibility status | Must | Draft |
| FR-02.1.4 | User can download a model with progress tracking (%, speed, ETA) | Must | Draft |
| FR-02.1.5 | Downloads continue in background and survive app backgrounding | Must | Draft |
| FR-02.1.6 | User can pause and resume downloads | Should | Draft |
| FR-02.1.7 | User can cancel an in-progress download | Must | Draft |
| FR-02.1.8 | Gated models require HuggingFace authentication (OAuth token from FR-05) | Must | Draft |
| FR-02.1.9 | User can import a local model file from device storage | Should | Draft |
| FR-02.1.10 | Model allowlist is updatable without app update (remote JSON fetch) | Should | Draft |

#### FR-02.2: Model Lifecycle

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-02.2.1 | Downloaded models are stored in app-managed encrypted storage | Must | Draft |
| FR-02.2.2 | User can delete downloaded models to free storage | Must | Draft |
| FR-02.2.3 | Model initialization (loading into memory) happens on demand before first inference | Must | Draft |
| FR-02.2.4 | Model is automatically unloaded when switching to another model or on memory pressure | Must | Draft |
| FR-02.2.5 | App displays current model status: Not Downloaded / Downloading / Ready / Loaded / Error | Must | Draft |
| FR-02.2.6 | User can update a model to a newer version (new commit hash) | Should | Draft |

#### FR-02.3: Model Configuration

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-02.3.1 | User can adjust inference parameters: temperature, topK, topP, max tokens | Must | Draft |
| FR-02.3.2 | Each model has sensible default configuration values | Must | Draft |
| FR-02.3.3 | Configuration changes take effect on next inference (no restart needed) | Should | Draft |
| FR-02.3.4 | User can save named configuration presets per model | Could | Draft |
| FR-02.3.5 | Configuration UI uses appropriate controls: sliders for numeric, toggles for boolean, segmented for enum | Must | Draft |

### Acceptance Criteria

- [ ] User can browse the model list, download a model, and run inference end-to-end
- [ ] Background download survives app backgrounding and shows notification progress
- [ ] Gated models correctly require and use HuggingFace OAuth token
- [ ] Deleting a model frees the expected disk space
- [ ] Adjusting temperature/topK/topP visibly changes inference behavior

---

## FR-03: Cloud AI API Integration

**Priority:** Must
**Status:** Draft
**Module:** Provider Module
**UI:** Settings > Providers, Chat Screen (model selector)

### Description

Users can connect to cloud AI providers as an alternative or supplement to local models. The system uses a pluggable provider architecture making it easy to add new providers without modifying core code.

### Sub-Requirements

#### FR-03.1: Provider Management

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-03.1.1 | User can add, configure, and remove AI providers | Must | Draft |
| FR-03.1.2 | Supported providers at launch: OpenAI, Google Gemini, Anthropic Claude, HuggingFace Inference, OpenRouter | Must | Draft |
| FR-03.1.3 | Each provider requires an API key (securely stored — see FR-05) | Must | Draft |
| FR-03.1.4 | Provider connection is validated on setup (test API call) | Should | Draft |
| FR-03.1.5 | User can set a default provider and model for new conversations | Must | Draft |
| FR-03.1.6 | System supports adding custom providers via configuration (base URL + API key + model list) | Could | Draft |
| FR-03.1.7 | Provider status is visible: Connected / Error / Rate Limited / Quota Exceeded | Must | Draft |

#### FR-03.2: Provider Capabilities

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-03.2.1 | All providers support text chat (multi-turn) | Must | Draft |
| FR-03.2.2 | Providers that support streaming deliver token-by-token responses | Must | Draft |
| FR-03.2.3 | Providers that support vision accept image inputs | Should | Draft |
| FR-03.2.4 | Providers that support function calling integrate with Gemmie's tools system | Should | Draft |
| FR-03.2.5 | Provider capabilities are auto-detected or declared in configuration | Must | Draft |
| FR-03.2.6 | System prompt / persona (FR-09) is sent to cloud providers as system message | Must | Draft |

#### FR-03.3: Usage & Cost Management

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-03.3.1 | Token usage (input + output) is tracked per conversation and per provider | Should | Draft |
| FR-03.3.2 | Estimated cost is displayed based on provider pricing (user-configurable rates) | Could | Draft |
| FR-03.3.3 | User can set usage limits/alerts per provider (e.g., monthly budget) | Could | Draft |
| FR-03.3.4 | Rate limit errors trigger automatic retry with exponential backoff | Must | Draft |
| FR-03.3.5 | User can configure fallback provider if primary is unavailable | Could | Draft |

#### FR-03.4: Router Integration

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-03.4.1 | OpenRouter is supported as a meta-provider (routes to multiple backends) | Must | Draft |
| FR-03.4.2 | User can browse available models through OpenRouter's model list | Should | Draft |
| FR-03.4.3 | System supports adding future routers (not hardcoded to OpenRouter) | Should | Draft |

### Acceptance Criteria

- [ ] User can configure at least 3 different providers and switch between them in chat
- [ ] Streaming works identically for local and cloud providers from the user's perspective
- [ ] API key validation prevents saving invalid credentials
- [ ] Token usage is accurately tracked and displayed per conversation
- [ ] Rate limit errors are retried automatically without user intervention

---

## FR-04: Tools System

**Priority:** Must
**Status:** Draft
**Module:** Tools Module
**UI:** Tools Tab, Chat (inline tool invocations)

### Description

A dedicated tools ecosystem allowing the AI to interact with external services, device capabilities, and internal Gemmie features. Tools are browsable in a dedicated tab and invocable by the AI during conversations.

### Sub-Requirements

#### FR-04.1: Tool Registry & Discovery

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-04.1.1 | Dedicated "Tools" tab showing all available tools organized by category | Must | Draft |
| FR-04.1.2 | Tool categories: Code Execution, File Operations, Web/API, Device, Productivity, Custom | Must | Draft |
| FR-04.1.3 | Each tool displays: name, description, required permissions, input/output types | Must | Draft |
| FR-04.1.4 | User can enable/disable individual tools | Must | Draft |
| FR-04.1.5 | Tool availability is scoped per conversation (user selects which tools the AI can use) | Should | Draft |
| FR-04.1.6 | Plugin system for adding custom tools | Should | Draft |

#### FR-04.2: Built-In Tools

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-04.2.1 | **Code Execution:** Run Python, JS/TS, Dart code (delegates to FR-10) | Must | Draft |
| FR-04.2.2 | **File Read:** Read contents of user files (respects FR-08 permissions) | Must | Draft |
| FR-04.2.3 | **File Write:** Create or modify user files (respects FR-08 permissions, triggers diff) | Must | Draft |
| FR-04.2.4 | **File Search:** Search across user files by content or name | Must | Draft |
| FR-04.2.5 | **Web Search:** Search the web for information (via API) | Should | Draft |
| FR-04.2.6 | **URL Fetch:** Retrieve and summarize web page content | Should | Draft |
| FR-04.2.7 | **Calculator:** Perform mathematical calculations | Must | Draft |
| FR-04.2.8 | **Calendar/Reminders:** Access device calendar and set reminders | Could | Draft |
| FR-04.2.9 | **Create Sheet:** Generate a spreadsheet/CSV file (delegates to FR-11) | Should | Draft |
| FR-04.2.10 | **Create Document:** Generate a Markdown document (delegates to FR-11) | Should | Draft |
| FR-04.2.11 | **Shell/Terminal:** Execute shell commands on remote connected environments | Could | Draft |

#### FR-04.3: Tool Invocation Flow

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-04.3.1 | AI can autonomously decide to invoke tools based on user request | Must | Draft |
| FR-04.3.2 | Tool invocations show in chat with clear visual formatting (tool name, inputs, outputs) | Must | Draft |
| FR-04.3.3 | User can approve or reject tool invocations before execution (configurable per tool) | Must | Draft |
| FR-04.3.4 | Tool execution results are fed back to the AI for follow-up reasoning | Must | Draft |
| FR-04.3.5 | Multiple tools can be chained in sequence within a single AI response | Should | Draft |
| FR-04.3.6 | Tool execution errors are displayed clearly and the AI can retry or suggest alternatives | Must | Draft |
| FR-04.3.7 | Tool invocation history is saved as part of the conversation | Must | Draft |

### Acceptance Criteria

- [ ] Tools tab displays all available tools organized by category
- [ ] AI can invoke a tool (e.g., code execution) during a conversation with visible output
- [ ] Tool invocation requiring elevated permissions triggers the approval dialog
- [ ] Disabling a tool prevents the AI from invoking it
- [ ] Tool results display inline in the chat with appropriate formatting

---

## FR-05: Settings & Profiles

**Priority:** Must
**Status:** Draft
**Module:** Settings Module
**UI:** Settings Screen

### Description

Centralized configuration for user profiles, authentication tokens, AI provider credentials, theme preferences, and app behavior. All sensitive data is securely stored using platform keychain/keystore.

### Sub-Requirements

#### FR-05.1: User Profiles

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-05.1.1 | User can create and manage their profile (name, avatar, preferences) | Must | Draft |
| FR-05.1.2 | Profile supports multiple personas/identities (e.g., work vs personal) | Could | Draft |
| FR-05.1.3 | Profile preferences affect AI behavior (language, formality, response length) | Should | Draft |
| FR-05.1.4 | Profile data is stored locally and encrypted | Must | Draft |

#### FR-05.2: Token & Key Management

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-05.2.1 | Secure storage for HuggingFace access tokens (OAuth flow) | Must | Draft |
| FR-05.2.2 | Secure storage for AI provider API keys (OpenAI, Gemini, Claude, etc.) | Must | Draft |
| FR-05.2.3 | Secure storage for OpenRouter API key | Must | Draft |
| FR-05.2.4 | Tokens/keys are stored in platform keychain/keystore, never in plain text | Must | Draft |
| FR-05.2.5 | User can view (masked), update, and delete stored tokens/keys | Must | Draft |
| FR-05.2.6 | Token validity is periodically checked and user is notified on expiry | Should | Draft |
| FR-05.2.7 | Support for custom API endpoints (self-hosted providers) | Should | Draft |

#### FR-05.3: App Preferences

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-05.3.1 | Theme selection: Light, Dark, System-default, and custom accent colors | Must | Draft |
| FR-05.3.2 | Default AI model/provider selection for new conversations | Must | Draft |
| FR-05.3.3 | Notification preferences (download complete, sync status, etc.) | Should | Draft |
| FR-05.3.4 | Auto-save interval for unsaved work | Should | Draft |
| FR-05.3.5 | Language/locale selection | Could | Draft |
| FR-05.3.6 | Data usage preferences (Wi-Fi only downloads, data saver mode) | Should | Draft |
| FR-05.3.7 | Privacy settings (analytics opt-in/out, crash reporting) | Must | Draft |

#### FR-05.4: Storage Management

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-05.4.1 | Display total storage used by Gemmie (models, files, cache) | Must | Draft |
| FR-05.4.2 | Breakdown of storage by category (models, conversations, files, cache) | Should | Draft |
| FR-05.4.3 | User can clear cache and temporary files | Must | Draft |
| FR-05.4.4 | User can export all data (data portability) | Should | Draft |
| FR-05.4.5 | User can delete all data and reset app (with confirmation) | Must | Draft |

### Acceptance Criteria

- [ ] All tokens and API keys are stored in platform keychain — never readable in logs or in plain local storage
- [ ] Theme changes apply immediately across the entire app
- [ ] Storage breakdown accurately reflects actual disk usage
- [ ] Data export produces a complete, re-importable backup
- [ ] Deleting all data leaves no traces in app storage

---

## FR-06: File Storage System

**Priority:** Must
**Status:** Draft
**Module:** Storage Module
**UI:** File Explorer

### Description

An encrypted, organized file storage system that serves as the user's personal knowledge base. Files are stored encrypted in a local database with a virtual folder structure, internally represented in Markdown format for AI consumption, and presented to users in their native format (CSV as spreadsheets, docs as rich text, etc.).

### Sub-Requirements

#### FR-06.1: Virtual Filesystem

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-06.1.1 | Hierarchical folder structure with unlimited nesting depth | Must | Draft |
| FR-06.1.2 | User can create, rename, move, and delete folders | Must | Draft |
| FR-06.1.3 | User can create, rename, move, copy, and delete files | Must | Draft |
| FR-06.1.4 | File browser with tree view and breadcrumb navigation | Must | Draft |
| FR-06.1.5 | Search files by name, content, tags, or file type | Must | Draft |
| FR-06.1.6 | Sort files by name, date modified, date created, size, or type | Must | Draft |
| FR-06.1.7 | Default folder structure provided on first launch (Documents, Notes, Scripts, Templates, Agent) | Should | Draft |
| FR-06.1.8 | Drag-and-drop for moving files and folders | Should | Draft |
| FR-06.1.9 | File/folder bookmarks for quick access | Could | Draft |

#### FR-06.2: File Types & Internal Representation

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-06.2.1 | All text-based files are stored internally as Markdown in the encrypted database | Must | Draft |
| FR-06.2.2 | CSV data is stored as Markdown tables or embedded CSV blocks within MD | Must | Draft |
| FR-06.2.3 | Spreadsheet data maintains references to CSV within MD for easy validation | Should | Draft |
| FR-06.2.4 | Documents (rich text) are stored as Markdown | Must | Draft |
| FR-06.2.5 | Code files are stored as fenced code blocks within MD with language tags | Must | Draft |
| FR-06.2.6 | Binary files (images, PDFs) are stored as blobs with MD metadata files | Should | Draft |
| FR-06.2.7 | File type is presented to user in native format regardless of internal storage | Must | Draft |
| FR-06.2.8 | Metadata per file: created date, modified date, author (user/AI), tags, lock status | Must | Draft |

#### FR-06.3: Encryption & Security

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-06.3.1 | All file data is encrypted at rest using AES-256-GCM | Must | Draft |
| FR-06.3.2 | Encryption key is derived from user credentials and stored in platform keystore | Must | Draft |
| FR-06.3.3 | File content is never written to disk in unencrypted form | Must | Draft |
| FR-06.3.4 | Optional biometric lock for accessing file storage | Should | Draft |
| FR-06.3.5 | Temporary decrypted content in memory is zeroed after use | Should | Draft |

#### FR-06.4: File Operations

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-06.4.1 | Import files from device storage (txt, md, csv, pdf, images) | Must | Draft |
| FR-06.4.2 | Export files to device storage in native format | Must | Draft |
| FR-06.4.3 | Share files via platform sharing mechanism | Should | Draft |
| FR-06.4.4 | Bulk operations: select multiple files for move/delete/export | Should | Draft |
| FR-06.4.5 | File preview without full open (quick look) | Could | Draft |
| FR-06.4.6 | Recently accessed files list | Should | Draft |
| FR-06.4.7 | Storage quota display and management | Must | Draft |

### Acceptance Criteria

- [ ] User can create a nested folder structure and navigate it fluently in the file browser
- [ ] A CSV file imported from device appears as a spreadsheet in the UI but is stored as MD internally
- [ ] All file data is encrypted — verified by inspecting raw database contents
- [ ] Search returns results from file content, not just file names
- [ ] Files created by the AI are properly attributed and visible in the file browser

---

## FR-07: File Versioning & Diff

**Priority:** Must
**Status:** Draft
**Module:** Diff Engine
**UI:** Diff Viewer, File History

### Description

Every change to every file is tracked in a git-like version history. Users can view diffs, revert changes, and maintain a complete audit trail of who changed what (user vs. AI). Users have full control including the ability to permanently delete file history.

### Sub-Requirements

#### FR-07.1: Version Tracking

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-07.1.1 | Every file save creates a new version entry with timestamp, author, and change summary | Must | Draft |
| FR-07.1.2 | Author is tracked: "user" for manual edits, "AI:model-name" for AI-generated changes | Must | Draft |
| FR-07.1.3 | User can view complete version history for any file | Must | Draft |
| FR-07.1.4 | Version history shows timeline with author icons and change summaries | Should | Draft |
| FR-07.1.5 | Automatic version grouping for rapid sequential saves (debounce within 30s) | Should | Draft |
| FR-07.1.6 | Storage impact of version history is visible; user can set retention policy | Should | Draft |

#### FR-07.2: Diff Viewer

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-07.2.1 | Side-by-side diff view showing additions (green), deletions (red), and modifications (yellow) | Must | Draft |
| FR-07.2.2 | Inline/unified diff view as alternative | Should | Draft |
| FR-07.2.3 | User can compare any two versions of a file | Must | Draft |
| FR-07.2.4 | Diff view for CSV/sheet data shows cell-level changes | Should | Draft |
| FR-07.2.5 | Word-level diff highlighting within changed lines | Should | Draft |
| FR-07.2.6 | Navigation between diff hunks (next/previous change) | Must | Draft |

#### FR-07.3: Version Operations

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-07.3.1 | User can revert a file to any previous version | Must | Draft |
| FR-07.3.2 | Reverting creates a new version (non-destructive) | Must | Draft |
| FR-07.3.3 | User can cherry-pick specific changes from a version | Could | Draft |
| FR-07.3.4 | User can permanently delete specific versions or entire history (with double confirmation popup) | Must | Draft |
| FR-07.3.5 | Permanent deletion is irreversible and the UI warns accordingly | Must | Draft |
| FR-07.3.6 | User can restore (un-delete) recently deleted files within a grace period (trash bin) | Should | Draft |

#### FR-07.4: AI Change Tracking

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-07.4.1 | When AI modifies a file, the exact changes are shown to user in diff format before applying | Must | Draft |
| FR-07.4.2 | User can accept all, reject all, or selectively accept/reject individual changes | Must | Draft |
| FR-07.4.3 | AI change requests show *why* the change is proposed (context from conversation) | Should | Draft |
| FR-07.4.4 | Rejected changes are logged for the AI's context (it knows what was rejected) | Should | Draft |
| FR-07.4.5 | Notification badge shows pending AI changes requiring review | Must | Draft |

### Acceptance Criteria

- [ ] Every file edit (manual or AI) creates a tracked version entry
- [ ] Diff viewer correctly shows additions, deletions, and modifications with syntax highlighting
- [ ] Reverting to a previous version creates a new version (never destroys history except explicit permanent delete)
- [ ] AI-proposed changes appear in diff format with accept/reject controls before being applied
- [ ] Permanent delete of history requires double confirmation and is irreversible

---

## FR-08: Multi-Tier Permissions & Locks

**Priority:** Must
**Status:** Draft
**Module:** Permission Engine
**UI:** Permission Dialogs, File Explorer (lock indicators), Settings > Permissions

### Description

A granular permission system controlling what the AI can read, modify, or execute. Three tiers provide a balance between security and usability. Permissions apply to both files and folders, with folder permissions cascading to children.

### Sub-Requirements

#### FR-08.1: Permission Tiers

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-08.1.1 | **Locked (Tier 1):** AI cannot read or modify. Used for system files, encryption keys, API credentials, and user-designated sensitive files | Must | Draft |
| FR-08.1.2 | **Permission-Gated (Tier 2):** AI must request access; user approves per-action or per-session. Shows what access is needed and why | Must | Draft |
| FR-08.1.3 | **Open (Tier 3):** AI can freely read and modify within conversation context. Still tracked via versioning | Must | Draft |
| FR-08.1.4 | Default tier is assigned based on file type and location (see FR-08.2) | Must | Draft |
| FR-08.1.5 | User can change the permission tier of any file or folder | Must | Draft |

#### FR-08.2: Default Lock Assignments

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-08.2.1 | System configuration files → Locked (Tier 1) | Must | Draft |
| FR-08.2.2 | API keys and tokens → Locked (Tier 1) | Must | Draft |
| FR-08.2.3 | Agent persona files (soul, personality) → Permission-Gated (Tier 2) | Must | Draft |
| FR-08.2.4 | User documents and notes → Permission-Gated (Tier 2) | Must | Draft |
| FR-08.2.5 | Scratch/temp files and AI-created content → Open (Tier 3) | Should | Draft |
| FR-08.2.6 | New folders inherit parent folder's permission tier | Must | Draft |

#### FR-08.3: Permission Request Flow

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-08.3.1 | Permission request dialog shows: file name, requested operation (read/write/execute), reason, and the requesting model name | Must | Draft |
| FR-08.3.2 | User can approve: "This time only", "For this session", "Always" (with ability to revoke) | Must | Draft |
| FR-08.3.3 | User can deny with optional feedback to the AI | Must | Draft |
| FR-08.3.4 | Batch permission requests: if AI needs access to multiple files, show a consolidated dialog | Should | Draft |
| FR-08.3.5 | Permission audit log: all requests and decisions are recorded | Must | Draft |

#### FR-08.4: Visual Indicators & Navigation

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-08.4.1 | Files and folders show lock icons based on their permission tier (🔒 Locked, 🔐 Gated, 🔓 Open) | Must | Draft |
| FR-08.4.2 | File explorer has a filter to show only locked/gated/open files | Should | Draft |
| FR-08.4.3 | Settings page shows a summary of all permission assignments | Should | Draft |
| FR-08.4.4 | Quick-action menu on files includes "Change Permission Tier" option | Must | Draft |
| FR-08.4.5 | Attempting to change a Locked file to Open requires elevated confirmation (popup explaining risks) | Must | Draft |

### Acceptance Criteria

- [ ] Locked files cannot be accessed by the AI under any circumstances
- [ ] Permission-Gated files trigger a clear approval dialog before AI access
- [ ] Open files allow AI modification with full version tracking
- [ ] Default assignments match the documented tier rules
- [ ] Permission audit log captures all access requests and decisions

---

## FR-09: Agent Persona System

**Priority:** Must
**Status:** Draft
**Module:** Persona Module
**UI:** Persona Editor, Settings > Agent

### Description

Gemmie features a full agent persona system where the AI assistant's identity is defined by editable "soul" files. The agent's personality, tone, behavioral rules, and memory preferences are stored as structured files that the agent can self-modify with user approval, enabling persona evolution over time.

### Sub-Requirements

#### FR-09.1: Persona Files

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-09.1.1 | **Soul File:** Core identity document defining the agent's fundamental character, values, and immutable behavioral constraints | Must | Draft |
| FR-09.1.2 | **Personality File:** Tone, communication style, humor level, formality, verbosity, emoji usage, and other style parameters | Must | Draft |
| FR-09.1.3 | **Memory File:** What the agent remembers about the user — preferences, past interactions, relationship context | Should | Draft |
| FR-09.1.4 | **Rules File:** Explicit behavioral rules — things the agent should always/never do | Must | Draft |
| FR-09.1.5 | **Knowledge File:** Domain-specific knowledge or instructions the user wants the agent to always have | Should | Draft |
| FR-09.1.6 | All persona files are stored as structured Markdown in the Agent folder | Must | Draft |
| FR-09.1.7 | Persona files are Permission-Gated (Tier 2) by default — AI can request to modify, user approves | Must | Draft |

#### FR-09.2: Persona Evolution

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-09.2.1 | Agent can propose changes to its own personality/memory files based on interactions | Must | Draft |
| FR-09.2.2 | Proposed changes appear as diffs for user review (leverages FR-07) | Must | Draft |
| FR-09.2.3 | User can accept, modify, or reject persona update proposals | Must | Draft |
| FR-09.2.4 | Evolution history is tracked via version control (who changed what, when) | Must | Draft |
| FR-09.2.5 | User can revert persona to any previous state | Must | Draft |
| FR-09.2.6 | User can lock specific parts of personality (e.g., "always be concise" is immutable) | Should | Draft |

#### FR-09.3: Multiple Personas

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-09.3.1 | User can create multiple persona profiles (e.g., "Professional", "Creative", "Tutor") | Should | Draft |
| FR-09.3.2 | User can switch between personas (affects system prompt sent to AI) | Should | Draft |
| FR-09.3.3 | Conversations can be associated with a specific persona | Should | Draft |
| FR-09.3.4 | User can duplicate, export, and import persona profiles | Could | Draft |
| FR-09.3.5 | Community-shared persona templates (future) | Won't | Draft |

#### FR-09.4: Persona Editor

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-09.4.1 | Visual editor for each persona file with appropriate input controls | Must | Draft |
| FR-09.4.2 | Personality parameters displayed as sliders/toggles (e.g., Formal ↔ Casual, Concise ↔ Verbose) | Should | Draft |
| FR-09.4.3 | Raw Markdown editor available for advanced users | Must | Draft |
| FR-09.4.4 | Preview mode: test the persona with a sample conversation before applying | Could | Draft |
| FR-09.4.5 | Reset to default persona option with confirmation | Must | Draft |

### Acceptance Criteria

- [ ] Default persona files are created on first launch with sensible defaults
- [ ] AI system prompt accurately reflects the current persona configuration
- [ ] Agent-proposed persona changes appear as reviewable diffs
- [ ] Switching personas changes AI behavior noticeably in the next message
- [ ] Persona files are version-controlled — full history is browseable

---

## FR-10: Code Execution Engine

**Priority:** Must
**Status:** Draft
**Module:** Execution Module
**UI:** Code Editor, Chat (inline code blocks with Run button)

### Description

Execute code in multiple programming languages either locally (sandboxed) or remotely via user-configured servers. Users can create, save, and manage scripts for recurring use cases. Code execution integrates with the chat interface and the tools system.

### Sub-Requirements

#### FR-10.1: Supported Languages

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-10.1.1 | **Python 3.x:** Full support including standard library and user-installable packages | Must | Draft |
| FR-10.1.2 | **JavaScript (ES2020+):** Full support via embedded engine | Must | Draft |
| FR-10.1.3 | **TypeScript:** Support via transpilation to JS before execution | Must | Draft |
| FR-10.1.4 | **Dart:** Support via dart_eval or isolate-based execution | Should | Draft |
| FR-10.1.5 | **Shell/Bash:** Support for remote execution environments only | Could | Draft |
| FR-10.1.6 | Language detection from code block syntax or file extension | Must | Draft |
| FR-10.1.7 | Architecture supports adding new languages via executor plugins | Must | Draft |

#### FR-10.2: Local Execution (Sandboxed)

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-10.2.1 | Code runs in an isolated sandbox with no filesystem access outside designated temp directory | Must | Draft |
| FR-10.2.2 | Execution timeout configurable (default: 30 seconds) | Must | Draft |
| FR-10.2.3 | Memory limit configurable (default: 256MB) | Must | Draft |
| FR-10.2.4 | Network access is disabled by default but can be enabled by user per-script | Must | Draft |
| FR-10.2.5 | Standard output and standard error are captured and displayed | Must | Draft |
| FR-10.2.6 | Execution results (text, images, tables) display inline in chat or code editor | Must | Draft |
| FR-10.2.7 | User can interrupt a running execution at any time | Must | Draft |

#### FR-10.3: Remote Execution

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-10.3.1 | User can configure remote execution endpoints (server URL + auth) | Must | Draft |
| FR-10.3.2 | Support for Modal as a remote execution provider | Should | Draft |
| FR-10.3.3 | Support for Daytona as a remote execution provider | Should | Draft |
| FR-10.3.4 | Support for custom SSH-accessible servers | Should | Draft |
| FR-10.3.5 | Remote execution results stream back in real-time | Must | Draft |
| FR-10.3.6 | Remote environments support package installation | Should | Draft |
| FR-10.3.7 | Connection status and latency displayed for remote endpoints | Should | Draft |

#### FR-10.4: Script Management

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-10.4.1 | User can save code snippets as reusable scripts | Must | Draft |
| FR-10.4.2 | Scripts are stored in the file storage system (FR-06) under a Scripts folder | Must | Draft |
| FR-10.4.3 | Scripts support parameters (user-defined inputs at runtime) | Should | Draft |
| FR-10.4.4 | AI can suggest and create scripts based on user requests | Must | Draft |
| FR-10.4.5 | Script templates for common use cases (data processing, file conversion, API calls) | Should | Draft |
| FR-10.4.6 | One-click run for saved scripts | Must | Draft |
| FR-10.4.7 | Script execution history with inputs and outputs | Should | Draft |

#### FR-10.5: Code Editor

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-10.5.1 | Syntax highlighting for all supported languages | Must | Draft |
| FR-10.5.2 | Line numbers | Must | Draft |
| FR-10.5.3 | Auto-indentation | Must | Draft |
| FR-10.5.4 | Basic autocomplete (keyword-based) | Should | Draft |
| FR-10.5.5 | Find and replace within code | Should | Draft |
| FR-10.5.6 | Output panel below editor showing stdout, stderr, and return values | Must | Draft |
| FR-10.5.7 | Split view: code editor + output | Must | Draft |

### Acceptance Criteria

- [ ] Python code executes locally and produces correct output in the chat
- [ ] JavaScript execution via embedded engine works offline
- [ ] Sandbox prevents filesystem access outside designated directory
- [ ] Execution timeout kills long-running code after the configured limit
- [ ] Remote execution via user-configured server works end-to-end
- [ ] Saved scripts appear in the Scripts folder and can be re-run

---

## FR-11: Sheets & Documents

**Priority:** Should
**Status:** Draft
**Module:** Docs Module
**UI:** Sheets Editor, Document Editor

### Description

Create and edit spreadsheets (CSV-based with grid UI) and rich documents (Markdown with live preview). Both formats integrate with the storage system, support AI generation, and maintain version history.

### Sub-Requirements

#### FR-11.1: Spreadsheet / Sheets

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-11.1.1 | Grid-based spreadsheet editor for CSV data | Must | Draft |
| FR-11.1.2 | Cell editing with keyboard navigation (Tab, Enter, arrow keys) | Must | Draft |
| FR-11.1.3 | Column resize, row resize | Should | Draft |
| FR-11.1.4 | Sort by column (ascending/descending) | Must | Draft |
| FR-11.1.5 | Filter rows by column value | Should | Draft |
| FR-11.1.6 | Basic formulas (SUM, AVG, COUNT, MIN, MAX) | Could | Draft |
| FR-11.1.7 | CSV import and export | Must | Draft |
| FR-11.1.8 | AI can generate, populate, and modify sheet data | Must | Draft |
| FR-11.1.9 | Sheet data stored as CSV blocks within Markdown (internal representation) | Must | Draft |
| FR-11.1.10 | Changes tracked via diff system (FR-07) at cell level | Should | Draft |

#### FR-11.2: Documents

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-11.2.1 | Rich Markdown editor with toolbar (bold, italic, headings, lists, links, images) | Must | Draft |
| FR-11.2.2 | Live preview or WYSIWYG editing mode | Must | Draft |
| FR-11.2.3 | Raw Markdown source editing mode | Must | Draft |
| FR-11.2.4 | Document templates (meeting notes, project plan, journal entry, etc.) | Should | Draft |
| FR-11.2.5 | AI can generate, edit, and summarize documents | Must | Draft |
| FR-11.2.6 | Embedded CSV references render as inline tables within documents | Should | Draft |
| FR-11.2.7 | Document outline / table of contents auto-generated from headings | Should | Draft |
| FR-11.2.8 | Print / export to PDF | Could | Draft |

#### FR-11.3: Cross-Format Features

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-11.3.1 | Convert between CSV and Markdown table formats | Should | Draft |
| FR-11.3.2 | Embed sheets within documents as referenced CSV blocks | Should | Draft |
| FR-11.3.3 | Changes to referenced CSV update the embedded view in the document | Should | Draft |
| FR-11.3.4 | All documents and sheets are stored in the file system with full versioning | Must | Draft |

### Acceptance Criteria

- [ ] User can create a CSV sheet, edit cells in a grid UI, and save to storage
- [ ] A Markdown document renders headings, lists, code blocks, and embedded tables
- [ ] AI can generate a sheet from a user request ("create a budget spreadsheet")
- [ ] CSV references in Markdown render as inline tables that update when the CSV changes
- [ ] All changes to sheets and documents appear in version history

---

## FR-12: Cloud Sync

**Priority:** Could
**Status:** Draft
**Module:** Sync Module
**UI:** Settings > Sync

### Description

Optional cloud backup and synchronization with end-to-end encryption. Users choose what to sync and can use Gemmie fully offline without any cloud dependency.

### Sub-Requirements

#### FR-12.1: Sync Configuration

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-12.1.1 | Cloud sync is off by default — explicitly opt-in | Must | Draft |
| FR-12.1.2 | User can select which folders/files to sync | Must | Draft |
| FR-12.1.3 | Sync provider options: Firebase, Supabase, or custom (TBD) | Should | Draft |
| FR-12.1.4 | Sync requires user authentication (app-level account) | Must | Draft |
| FR-12.1.5 | Sync status indicator: Synced / Syncing / Pending / Error / Offline | Must | Draft |

#### FR-12.2: End-to-End Encryption

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-12.2.1 | All data is encrypted client-side before upload — server never sees plaintext | Must | Draft |
| FR-12.2.2 | Encryption key derived from user passphrase (not stored on server) | Must | Draft |
| FR-12.2.3 | Key rotation mechanism for compromised passphrases | Should | Draft |
| FR-12.2.4 | Recovery mechanism (e.g., recovery key generated at setup) | Should | Draft |

#### FR-12.3: Conflict Resolution

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-12.3.1 | Conflicts detected when same file modified on multiple devices | Must | Draft |
| FR-12.3.2 | User presented with conflict resolution UI: keep local, keep remote, or merge | Must | Draft |
| FR-12.3.3 | Merge shows diff between conflicting versions | Should | Draft |
| FR-12.3.4 | Auto-resolve option for non-conflicting changes (different sections of file) | Could | Draft |

#### FR-12.4: Multi-Device

| ID | Requirement | Priority | Status |
|----|-------------|----------|--------|
| FR-12.4.1 | Conversations sync across devices | Should | Draft |
| FR-12.4.2 | Persona files sync across devices | Should | Draft |
| FR-12.4.3 | Settings sync across devices (with device-specific overrides) | Could | Draft |
| FR-12.4.4 | Local models are NOT synced (too large) — only model metadata and preferences | Must | Draft |

### Acceptance Criteria

- [ ] Sync is completely disabled by default — no data leaves device without user action
- [ ] Enabling sync encrypted a test file client-side — server-side storage contains only ciphertext
- [ ] Conflicting edits on two devices trigger conflict resolution UI
- [ ] Sync continues to work seamlessly after network interruptions
- [ ] Disabling sync removes data from cloud storage (with confirmation)
