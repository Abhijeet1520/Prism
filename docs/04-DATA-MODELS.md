# 04 — Data Models

> This document defines all data structures, schemas, and entity relationships used in Prism. Each schema maps to a domain entity in the architecture and may have corresponding Isar collections, DTOs, or API request/response models.

---

## Table of Contents

- [1. User & Profile](#1-user--profile)
- [2. Conversation & Messages](#2-conversation--messages)
- [3. AI Models](#3-ai-models)
- [4. AI Providers](#4-ai-providers)
- [5. Virtual Filesystem](#5-virtual-filesystem)
- [6. Versioning & Diff](#6-versioning--diff)
- [7. Permissions & Locks](#7-permissions--locks)
- [8. Agent Persona](#8-agent-persona)
- [9. Tools](#9-tools)
- [10. Code Execution](#10-code-execution)
- [11. Sync](#11-sync)
- [12. Entity Relationship Diagram](#12-entity-relationship-diagram)

---

## 1. User & Profile

### UserProfile

```yaml
UserProfile:
  id:               String (UUID v4)           # Unique identifier
  displayName:      String                     # User's display name
  avatarPath:       String?                    # Path to avatar image in storage
  email:            String?                    # Optional email (for sync)
  createdAt:        DateTime                   # Profile creation time
  updatedAt:        DateTime                   # Last modification time
  preferences:      UserPreferences            # App-wide preferences
  activePersonaId:  String?                    # Currently active persona profile
```

### UserPreferences

```yaml
UserPreferences:
  theme:                ThemeMode              # light | dark | system
  accentColor:          int                    # Material color seed value
  locale:               String                 # e.g., "en_US", "es_ES"
  defaultProviderId:    String?                # Default AI provider for new chats
  defaultModelId:       String?                # Default model within provider
  autoSaveIntervalSec:  int                    # Default: 5
  downloadOnWifiOnly:   bool                   # Default: true
  analyticsOptIn:       bool                   # Default: false
  crashReportingOptIn:  bool                   # Default: false
  dataSaverMode:        bool                   # Default: false
  fontSize:             double                 # Text scale factor (1.0 = default)
  reducedMotion:        bool                   # Follow system or override
```

---

## 2. Conversation & Messages

### Conversation

```yaml
Conversation:
  id:              String (UUID v4)
  title:           String                     # User-set or auto-generated from first message
  createdAt:       DateTime
  updatedAt:       DateTime                   # Last message timestamp
  providerId:      String                     # AI provider used ("local", "openai", etc.)
  modelId:         String                     # Specific model used
  personaId:       String?                    # Associated persona profile
  folderId:        String?                    # Optional folder grouping
  isPinned:        bool                       # Pinned to top
  isArchived:      bool                       # Archived (hidden from main list)
  messageCount:    int                        # Cached count for display
  tokenUsage:      TokenUsage                 # Cumulative token tracking
  metadata:        Map<String, dynamic>       # Extensible metadata
```

### Message

```yaml
Message:
  id:              String (UUID v4)
  conversationId:  String                     # FK to Conversation
  role:            MessageRole                # user | assistant | system | tool
  content:         String                     # Message text (Markdown)
  createdAt:       DateTime
  attachments:     List<Attachment>           # Images, files, etc.
  toolInvocations: List<ToolInvocation>       # Tools called during this message
  modelId:         String?                    # Model that generated this (for assistant)
  parentId:        String?                    # For branching conversations (FK to parent Message)
  childrenIds:     List<String>               # Child branch message IDs (tree structure)
  currentChildId:  String?                    # Active branch child (for navigation)
  isEdited:        bool                       # Whether user edited after sending
  tokenCount:      int?                       # Token count for this message
  status:          MessageStatus              # sending | streaming | complete | error | cancelled
  errorMessage:    String?                    # Error details if status == error
```

### MessageRole (Enum)

```yaml
MessageRole:
  - user          # User-sent message
  - assistant     # AI response
  - system        # System prompt (not displayed to user)
  - tool          # Tool invocation result
```

### MessageStatus (Enum)

```yaml
MessageStatus:
  - sending       # User message being sent to provider
  - streaming     # AI response being streamed
  - complete      # Fully received/sent
  - error         # Failed to send or generate
  - cancelled     # User cancelled during streaming
```

### Attachment

```yaml
Attachment:
  id:              String (UUID v4)
  messageId:       String                     # FK to Message
  type:            AttachmentType             # image | file | audio
  fileName:        String                     # Original file name
  mimeType:        String                     # e.g., "image/png", "text/csv"
  sizeBytes:       int
  storagePath:     String                     # Path in Prism's storage
  thumbnailPath:   String?                    # Thumbnail for images
```

### TokenUsage

```yaml
TokenUsage:
  inputTokens:     int                        # Total input/prompt tokens
  outputTokens:    int                        # Total output/completion tokens
  totalTokens:     int                        # inputTokens + outputTokens
  estimatedCost:   double?                    # In USD, based on provider rates
```

---

## 3. AI Models

### AIModel

```yaml
AIModel:
  id:              String                     # Unique identifier (e.g., "gemma-3b-it")
  source:          ModelSource                # local | huggingface | provider
  name:            String                     # Display name
  description:     String                     # Model description
  publisher:       String                     # Model publisher (e.g., "Google")
  category:        ModelCategory              # llm | vision | code | multimodal
  sizeBytes:       int                        # Model file size
  parameterCount:  String?                    # e.g., "3B", "7B", "70B"
  quantization:    String?                    # e.g., "Q4_0", "F16"
  commitHash:      String?                    # HuggingFace commit hash
  modelFile:       String                     # Primary model filename
  extraFiles:      List<String>               # Additional required files
  taskTypes:       List<String>               # Compatible task types
  gated:           bool                       # Requires HF authentication
  downloadState:   DownloadState              # Current download status
  config:          ModelConfig                # Inference configuration
  localPath:       String?                    # Path on device (when downloaded)
  downloadedAt:    DateTime?                  # When download completed
  lastUsedAt:      DateTime?                  # Last inference time
```

### ModelConfig

```yaml
ModelConfig:
  temperature:     double                     # 0.0 - 2.0, default: 0.7
  topK:            int                        # Default: 40
  topP:            double                     # 0.0 - 1.0, default: 0.95
  maxTokens:       int                        # Default: 2048
  repeatPenalty:   double                     # Default: 1.1
  systemPrompt:    String?                    # Override (usually from persona)
  stopSequences:   List<String>               # Custom stop tokens
```

### DownloadState

```yaml
DownloadState:
  status:          DownloadStatus             # notStarted | queued | downloading | paused | completed | error
  progress:        double                     # 0.0 - 1.0
  downloadedBytes: int                        # Bytes received
  totalBytes:      int                        # Total file size
  speedBps:        int?                       # Current download speed
  eta:             Duration?                  # Estimated time remaining
  errorMessage:    String?                    # Error details
  resumeToken:     String?                    # For resuming interrupted downloads
```

### ModelCategory (Enum)

```yaml
ModelCategory:
  - llm           # Text generation / chat
  - vision        # Image understanding
  - code          # Code generation / completion
  - multimodal    # Multiple input/output modalities
  - embedding     # Text embeddings
```

---

## 4. AI Providers

### ProviderConfig

```yaml
ProviderConfig:
  id:              String (UUID v4)
  type:            ProviderType               # openai | gemini | claude | huggingface | openrouter | custom
  displayName:     String                     # User-facing name (can be customized)
  isEnabled:       bool                       # Whether provider is active
  baseUrl:         String                     # API base URL
  apiKeyRef:       String                     # Reference to key in secure storage
  defaultModelId:  String?                    # Default model for this provider
  models:          List<ProviderModel>        # Available models
  capabilities:    ProviderCapabilities       # What this provider supports
  rateLimits:      RateLimitConfig?           # Rate limit settings
  createdAt:       DateTime
  updatedAt:       DateTime
```

### ProviderModel

```yaml
ProviderModel:
  id:              String                     # Model identifier (e.g., "gpt-4o")
  name:            String                     # Display name
  contextWindow:   int                        # Max context tokens
  maxOutputTokens: int                        # Max completion tokens
  inputPricePerMT: double?                    # Price per million input tokens (USD)
  outputPricePerMT: double?                   # Price per million output tokens (USD)
  capabilities:    ModelCapabilities          # vision, function_calling, etc.
  isDefault:       bool                       # Default model for provider
```

### ProviderCapabilities

```yaml
ProviderCapabilities:
  streaming:         bool
  vision:            bool
  functionCalling:   bool
  systemMessage:     bool
  jsonMode:          bool
  maxContextTokens:  int
  supportedMediaTypes: List<String>           # ["image/png", "image/jpeg", ...]
```

### ProviderType (Enum)

```yaml
ProviderType:
  - openai         # OpenAI API (GPT models) — via langchain_openai
  - gemini         # Google Gemini API — via langchain_google
  - claude         # Anthropic Claude API — via langchain_anthropic
  - huggingface    # HuggingFace Inference API — via langchain_huggingface
  - openrouter     # OpenRouter (meta-provider) — via langchain_openai (custom baseUrl)
  - ollama         # Ollama (local/LAN, no API key) — via langchain_ollama
  - mistral        # Mistral AI — via langchain_mistralai
  - local          # Local on-device model via llama_sdk / LiteRT
  - custom         # User-configured custom endpoint
```

### RateLimitConfig

```yaml
RateLimitConfig:
  requestsPerMinute:  int?
  tokensPerMinute:    int?
  monthlyBudgetUSD:   double?                 # User-set spending limit
  currentMonthSpend:  double                  # Tracked spending
  alertThreshold:     double?                 # Alert at this % of budget
```

### OllamaServerConfig

```yaml
OllamaServerConfig:
  id:              String (UUID v4)
  host:            String                     # Hostname or IP address
  port:            int                        # Default: 11434
  displayName:     String                     # User-friendly name (e.g., "Desktop PC")
  isDiscovered:    bool                       # Found via LAN scan vs manually added
  lastSeen:        DateTime?                  # Last successful health check
  isOnline:        bool                       # Current reachability status
  models:          List<String>               # Cached list of available model tags
  createdAt:       DateTime
  updatedAt:       DateTime
```

---

## 5. Virtual Filesystem

### PrismFile

```yaml
PrismFile:
  id:              String (UUID v4)
  folderId:        String                     # FK to PrismFolder (parent)
  name:            String                     # File name with extension
  type:            FileType                   # document | sheet | script | persona | note | image | binary
  content:         Uint8List                  # Encrypted content blob
  mimeType:        String                     # "text/markdown", "text/csv", etc.
  sizeBytes:       int                        # Decrypted content size
  createdAt:       DateTime
  updatedAt:       DateTime
  createdBy:       String                     # "user" or "ai:model-name"
  updatedBy:       String                     # Who last modified
  permissionTier:  PermissionTier             # locked | gated | open
  tags:            List<String>               # User-defined tags
  isTrashed:       bool                       # Soft-deleted (in trash)
  trashedAt:       DateTime?                  # When trashed
  isBookmarked:    bool                       # Quick-access bookmark
  versionCount:    int                        # Cached count of versions
  checksum:        String                     # SHA-256 of decrypted content (for sync)
```

### PrismFolder

```yaml
PrismFolder:
  id:              String (UUID v4)
  parentId:        String?                    # FK to parent PrismFolder (null = root)
  name:            String                     # Folder name
  createdAt:       DateTime
  updatedAt:       DateTime
  permissionTier:  PermissionTier             # Inherited by children unless overridden
  isSystem:        bool                       # System folder (can't be deleted)
  icon:            String?                    # Optional custom icon
  sortOrder:       int                        # Position within parent
  fileCount:       int                        # Cached count (files only, not recursive)
```

### FileType (Enum)

```yaml
FileType:
  - note           # Simple text note
  - document       # Rich document with headings, etc.
  - sheet          # Spreadsheet/CSV data
  - script         # Code file (Python, JS, TS, Dart)
  - persona        # Agent persona file
  - image          # Image file (stored as blob)
  - binary         # Other binary file
  - template       # Reusable template
```

### Default Folder Structure

```yaml
RootFolders:
  - name: "Documents"
    isSystem: true
    permissionTier: gated
    icon: "📄"

  - name: "Notes"
    isSystem: true
    permissionTier: gated
    icon: "📝"

  - name: "Scripts"
    isSystem: true
    permissionTier: gated
    icon: "💻"

  - name: "Templates"
    isSystem: true
    permissionTier: open
    icon: "📋"

  - name: "Agent"
    isSystem: true
    permissionTier: gated
    icon: "🤖"
    children:
      - name: "Personas"
        permissionTier: gated
    files:
      - soul.md
      - personality.md
      - memory.md
      - rules.md
      - knowledge.md

  - name: "Trash"
    isSystem: true
    permissionTier: locked
    icon: "🗑️"
```

---

## 6. Versioning & Diff

### FileVersion

```yaml
FileVersion:
  id:              String (UUID v4)
  fileId:          String                     # FK to PrismFile
  versionNumber:   int                        # Sequential (1, 2, 3, ...)
  content:         Uint8List?                 # Full snapshot (every 10th version) — encrypted
  delta:           Uint8List?                 # Compressed diff from previous version — encrypted
  isSnapshot:      bool                       # true if this is a full snapshot
  author:          String                     # "user" or "ai:model-name"
  summary:         String?                    # Change summary (auto-generated or user-provided)
  createdAt:       DateTime
  parentVersionId: String?                    # FK to previous FileVersion
  sizeBytes:       int                        # Size of this version's storage
```

### DiffResult

```yaml
DiffResult:
  hunks:           List<DiffHunk>             # Ordered list of change hunks
  stats:           DiffStats                  # Summary statistics
  fileId:          String                     # Which file
  fromVersion:     int                        # Compare from
  toVersion:       int                        # Compare to
```

### DiffHunk

```yaml
DiffHunk:
  type:            DiffType                   # add | delete | modify | unchanged
  oldStart:        int                        # Start line in old version
  oldEnd:          int                        # End line in old version
  newStart:        int                        # Start line in new version
  newEnd:          int                        # End line in new version
  oldContent:      String                     # Content in old version
  newContent:      String                     # Content in new version
  wordDiffs:       List<WordDiff>?            # Word-level diffs within this hunk
```

### WordDiff

```yaml
WordDiff:
  type:            DiffType                   # add | delete | modify
  oldText:         String
  newText:         String
  oldOffset:       int                        # Character offset in old line
  newOffset:       int                        # Character offset in new line
```

### DiffStats

```yaml
DiffStats:
  linesAdded:      int
  linesDeleted:    int
  linesModified:   int
  linesUnchanged:  int
```

### DiffType (Enum)

```yaml
DiffType:
  - add            # New content added
  - delete         # Content removed
  - modify         # Content changed
  - unchanged      # Context line (no change)
```

---

## 7. Permissions & Locks

### PermissionTier (Enum)

```yaml
PermissionTier:
  - locked         # Tier 1: AI cannot access under any circumstances
  - gated          # Tier 2: AI must request, user approves
  - open           # Tier 3: AI can freely access (still tracked)
```

### PermissionGrant

```yaml
PermissionGrant:
  id:              String (UUID v4)
  fileId:          String                     # FK to PrismFile
  operation:       OperationType              # read | write | delete | execute
  scope:           GrantScope                 # thisTime | thisSession | always
  grantedAt:       DateTime
  expiresAt:       DateTime?                  # null for "always" scope
  grantedBy:       String                     # Always "user"
  requestedBy:     String                     # AI model that requested ("ai:gemma-3b")
  reason:          String                     # Why access was requested
  isRevoked:       bool                       # User revoked this grant
  revokedAt:       DateTime?
```

### PermissionRequest

```yaml
PermissionRequest:
  id:              String (UUID v4)
  fileId:          String                     # FK to PrismFile
  fileName:        String                     # Display name (for UI)
  filePath:        String                     # Full virtual path
  operation:       OperationType              # What operation is requested
  requestedBy:     String                     # AI model ID
  reason:          String                     # AI-generated explanation of why
  conversationId:  String                     # Which conversation triggered this
  createdAt:       DateTime
  status:          RequestStatus              # pending | approved | denied
  resolvedAt:      DateTime?
  grantScope:      GrantScope?                # If approved, what scope was granted
  userFeedback:    String?                    # Optional feedback if denied
```

### AuditLogEntry

```yaml
AuditLogEntry:
  id:              String (UUID v4)
  timestamp:       DateTime
  fileId:          String?                    # Which file (null for non-file operations)
  operation:       String                     # "read", "write", "permission_change", "key_access", etc.
  actor:           String                     # "user" or "ai:model-name"
  decision:        String                     # "allowed", "denied", "asked"
  details:         Map<String, dynamic>       # Additional context
  conversationId:  String?                    # Which conversation (if applicable)
```

### OperationType (Enum)

```yaml
OperationType:
  - read           # Read file content
  - write          # Create or modify file content
  - delete         # Delete file
  - execute        # Execute as code
```

### GrantScope (Enum)

```yaml
GrantScope:
  - thisTime       # One-time access, expires immediately after use
  - thisSession    # Valid until app restart or conversation ends
  - always         # Permanent until explicitly revoked
```

---

## 8. Agent Persona

### Persona

```yaml
Persona:
  id:              String (UUID v4)
  name:            String                     # e.g., "Professional", "Creative", "Default"
  isDefault:       bool                       # Is this the default persona
  isActive:        bool                       # Currently selected
  soulFileId:      String                     # FK to PrismFile (soul.md)
  personalityFileId: String                   # FK to PrismFile (personality.md)
  memoryFileId:    String                     # FK to PrismFile (memory.md)
  rulesFileId:     String                     # FK to PrismFile (rules.md)
  knowledgeFileId: String?                    # FK to PrismFile (knowledge.md) — optional
  createdAt:       DateTime
  updatedAt:       DateTime
```

### SoulConfig (structured content of soul.md)

```yaml
SoulConfig:
  agentName:       String                     # Default: "Prism"
  coreIdentity:    String                     # Free-text identity statement
  values:          List<String>               # Core values (helpfulness, honesty, etc.)
  constraints:     List<String>               # Hard constraints (never share user data, etc.)
  purpose:         String                     # What this agent is for
```

### PersonalityConfig (structured content of personality.md)

```yaml
PersonalityConfig:
  tone:            double                     # 0.0 (formal) → 1.0 (casual)
  verbosity:       double                     # 0.0 (concise) → 1.0 (verbose)
  humor:           double                     # 0.0 (serious) → 1.0 (humorous)
  empathy:         double                     # 0.0 (neutral) → 1.0 (empathetic)
  creativity:      double                     # 0.0 (factual) → 1.0 (creative)
  emojiUsage:      EmojiLevel                 # none | minimal | moderate | frequent
  codeStyle:       CodeStylePreference        # commented | minimal | verbose
  responseFormat:  ResponseFormatPreference   # prose | bullets | structured
  customTraits:    Map<String, String>        # User-defined key-value traits
```

### MemoryEntry (structured content of memory.md)

```yaml
MemoryEntry:
  id:              String (UUID v4)
  content:         String                     # What to remember
  category:        MemoryCategory             # preference | fact | context | instruction
  source:          String                     # "user" or "ai:model-name" (who added it)
  createdAt:       DateTime
  confidence:      double                     # 0.0 - 1.0 (how sure is this correct)
  isActive:        bool                       # Whether to include in system prompt
```

### MemoryCategory (Enum)

```yaml
MemoryCategory:
  - preference     # User prefers X over Y
  - fact           # User's name is X, works at Y
  - context        # User is working on project X
  - instruction    # Always do X when asked about Y
```

---

## 9. Tools

### Tool (Registry Entry)

```yaml
Tool:
  id:              String                     # e.g., "code_execute", "file_read"
  name:            String                     # Display name
  description:     String                     # For AI and user
  category:        ToolCategory               # code | file | web | device | productivity | custom
  requiredPermission: PermissionTier          # Minimum tier for invocation
  requiresConfirmation: bool                  # User confirmation before execution
  isEnabled:       bool                       # User toggle
  inputSchema:     Map<String, dynamic>       # JSON Schema for inputs
  outputSchema:    Map<String, dynamic>       # JSON Schema for outputs
  version:         String                     # Tool version
```

### ToolInvocation

```yaml
ToolInvocation:
  id:              String (UUID v4)
  messageId:       String                     # FK to Message that triggered this
  toolId:          String                     # FK to Tool
  input:           Map<String, dynamic>       # Input parameters
  output:          ToolResult?                # Result (null if pending/cancelled)
  status:          InvocationStatus           # pending | approved | running | completed | failed | rejected
  createdAt:       DateTime
  completedAt:     DateTime?
  executionTimeMs: int?                       # How long execution took
  wasAutoApproved: bool                       # true if tool doesn't require confirmation
```

### ToolResult

```yaml
ToolResult:
  success:         bool
  data:            dynamic                    # Output data (string, map, list, etc.)
  displayType:     ResultDisplayType          # text | code | table | image | error
  errorMessage:    String?                    # If success == false
  artifacts:       List<ToolArtifact>?        # Files created, etc.
```

### ToolArtifact

```yaml
ToolArtifact:
  type:            ArtifactType               # file | image | download
  name:            String
  path:            String?                    # Path in Prism storage
  mimeType:        String
  sizeBytes:       int
```

### ToolCategory (Enum)

```yaml
ToolCategory:
  - code           # Code execution tools
  - file           # File read/write/search tools
  - web            # Web search, URL fetch tools
  - device         # Calendar, notifications, etc.
  - productivity   # Calculator, sheet creation, doc creation
  - custom         # User/community-added tools
```

---

## 10. Code Execution

### ExecutionRequest

```yaml
ExecutionRequest:
  id:              String (UUID v4)
  code:            String                     # Source code to execute
  language:        String                     # "python", "javascript", "typescript", "dart"
  environment:     ExecutionEnvironment       # local | remote
  remoteEndpointId: String?                   # If remote, which endpoint
  timeout:         Duration                   # Max execution time
  memoryLimitMB:   int                        # Max memory
  networkEnabled:  bool                       # Whether to allow network access
  inputs:          Map<String, String>?       # Script parameters (if saved script)
  workingDir:      String?                    # Working directory in sandbox
```

### ExecutionResult

```yaml
ExecutionResult:
  requestId:       String                     # FK to ExecutionRequest
  status:          ExecutionStatus            # running | completed | error | timeout | killed
  stdout:          String                     # Standard output
  stderr:          String                     # Standard error
  exitCode:        int?                       # Process exit code
  executionTimeMs: int                        # Wall-clock time
  memoryUsedMB:    double?                    # Peak memory usage
  artifacts:       List<ExecutionArtifact>    # Generated files, images, etc.
  error:           String?                    # Error description
```

### Script

```yaml
Script:
  id:              String (UUID v4)
  fileId:          String                     # FK to PrismFile (stored in Scripts folder)
  name:            String                     # Script name
  description:     String?                    # What this script does
  language:        String                     # Programming language
  parameters:      List<ScriptParameter>      # User-configurable inputs
  lastRunAt:       DateTime?
  runCount:        int                        # How many times executed
  isTemplate:      bool                       # Whether this is a template
  tags:            List<String>
```

### ScriptParameter

```yaml
ScriptParameter:
  name:            String                     # Parameter name
  type:            String                     # "string", "int", "double", "bool", "file"
  description:     String                     # What this parameter does
  defaultValue:    String?                    # Default value
  isRequired:      bool
  validation:      String?                    # Regex or validation rule
```

### RemoteEndpoint

```yaml
RemoteEndpoint:
  id:              String (UUID v4)
  name:            String                     # User-defined name
  type:            RemoteType                 # modal | daytona | ssh | custom
  url:             String                     # Connection URL
  authKeyRef:      String                     # Reference to key in secure storage
  isConnected:     bool                       # Current connection status
  lastPingMs:      int?                       # Last latency measurement
  supportedLanguages: List<String>            # What languages this endpoint supports
  createdAt:       DateTime
```

### ExecutionEnvironment (Enum)

```yaml
ExecutionEnvironment:
  - local          # On-device sandboxed execution
  - remote         # Remote server execution
```

---

## 11. Sync

### SyncConfig

```yaml
SyncConfig:
  isEnabled:       bool                       # Master sync toggle (default: false)
  provider:        SyncProvider               # firebase | supabase | custom
  lastSyncAt:      DateTime?                  # Last successful sync
  syncedFolderIds: List<String>               # Which folders to sync
  autoSync:        bool                       # Sync automatically on change
  syncIntervalMin: int                        # Auto-sync interval (default: 15)
  encryptionKeyRef: String                    # Reference to E2E encryption key
```

### SyncState

```yaml
SyncState:
  fileId:          String                     # FK to PrismFile
  localVersion:    int                        # Local version number
  remoteVersion:   int                        # Remote version number
  status:          SyncStatus                 # synced | pending | uploading | downloading | conflict | error
  lastSyncedAt:    DateTime?
  errorMessage:    String?
```

### ConflictEntry

```yaml
ConflictEntry:
  id:              String (UUID v4)
  fileId:          String                     # FK to PrismFile
  localContent:    Uint8List                  # Local version content (encrypted)
  remoteContent:   Uint8List                  # Remote version content (encrypted)
  localModifiedAt: DateTime
  remoteModifiedAt: DateTime
  localAuthor:     String
  remoteAuthor:    String
  status:          ConflictStatus             # pending | resolvedLocal | resolvedRemote | resolvedMerge
  resolvedAt:      DateTime?
  createdAt:       DateTime
```

### SyncStatus (Enum)

```yaml
SyncStatus:
  - synced         # Local and remote are in sync
  - pending        # Local changes not yet uploaded
  - uploading      # Currently uploading
  - downloading    # Currently downloading remote changes
  - conflict       # Both local and remote changed
  - error          # Sync failed
```

---

## 12. Entity Relationship Diagram

```
┌──────────────┐    1    ┌───────────────┐    *    ┌──────────────┐
│  UserProfile │────────→│  Conversation │────────→│   Message    │
└──────────────┘         └───────────────┘         └──────┬───────┘
       │                        │                         │
       │ 1                      │ *                       │ *
       ▼                        ▼                         ▼
┌──────────────┐         ┌───────────────┐         ┌──────────────┐
│   Persona    │         │  TokenUsage   │         │  Attachment  │
└──────────────┘         └───────────────┘         └──────────────┘
       │                                                  │
       │ 5 (soul, personality, memory, rules, knowledge)  │
       ▼                                                  │
┌──────────────┐←─────────────────────────────────────────┘
│  PrismFile  │←─────────┐
└──────┬───────┘          │
       │                  │ (file in folder)
       │ *                │
       ▼                  │
┌──────────────┐    *     │
│ FileVersion  │          │
└──────────────┘          │
       │                  │
       │                  │
       ▼                  │
┌──────────────┐    ┌─────┴────────┐
│  DiffResult  │    │ PrismFolder │──→ (self: parent)
└──────────────┘    └──────────────┘
                          │
                          │
                    ┌─────▼──────────┐
                    │PermissionGrant │
                    └────────────────┘
                          │
                    ┌─────▼──────────┐
                    │ AuditLogEntry  │
                    └────────────────┘

┌──────────────┐    ┌───────────────┐    ┌────────────────┐
│ProviderConfig│───→│ ProviderModel │    │ RemoteEndpoint │
└──────────────┘    └───────────────┘    └────────────────┘

┌──────────────┐    ┌───────────────┐    ┌────────────────┐
│    Tool      │───→│ToolInvocation │───→│   ToolResult   │
└──────────────┘    └───────────────┘    └────────────────┘

┌──────────────┐    ┌───────────────┐
│   Script     │───→│ExecutionResult│
└──────────────┘    └───────────────┘

┌──────────────┐    ┌───────────────┐
│  SyncConfig  │───→│  SyncState    │
└──────────────┘    └───────────────┘
```
