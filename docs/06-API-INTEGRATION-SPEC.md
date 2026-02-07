# 06 — API Integration Specification

> This document details the integration contracts, request/response formats, authentication mechanisms, error handling, and provider-specific implementation notes for each supported AI API provider. It also defines the unified provider interface and strategies for adding future providers.

---

## Table of Contents

- [1. Unified Provider Interface](#1-unified-provider-interface)
- [2. Request & Response Contracts](#2-request--response-contracts)
- [3. OpenAI Integration](#3-openai-integration)
- [4. Google Gemini Integration](#4-google-gemini-integration)
- [5. Anthropic Claude Integration](#5-anthropic-claude-integration)
- [6. HuggingFace Integration](#6-huggingface-integration)
- [7. OpenRouter Integration](#7-openrouter-integration)
- [8. Local Model Integration](#8-local-model-integration)
- [9. Custom Provider Integration](#9-custom-provider-integration)
- [10. Error Handling & Retry Strategy](#10-error-handling--retry-strategy)
- [11. Rate Limiting & Quotas](#11-rate-limiting--quotas)
- [12. Token Counting & Cost Estimation](#12-token-counting--cost-estimation)
- [13. Adding a New Provider Guide](#13-adding-a-new-provider-guide)

---

## 1. Unified Provider Interface

All AI provider adapters implement the same `AIProvider` interface (see [Architecture § Provider Abstraction](./03-ARCHITECTURE.md#4-provider-abstraction-layer)). The interface ensures:

- **Consistent API** for the chat module regardless of backend
- **Hot-swappable** providers mid-conversation
- **Capability-aware** feature toggling (vision, streaming, function calling)

### Key Interface Methods

| Method | Purpose | Return |
|--------|---------|--------|
| `getAvailableModels()` | List models offered by this provider | `List<ProviderModel>` |
| `sendMessage(request)` | Send chat and get complete response | `ChatResponse` |
| `streamMessage(request)` | Send chat and stream tokens | `Stream<ChatStreamEvent>` |
| `cancel()` | Cancel in-progress request | `void` |
| `validateCredentials(creds)` | Test if API key is valid | `bool` |
| `estimateTokens(text)` | Approximate token count | `int` |

---

## 2. Request & Response Contracts

### ChatRequest

```yaml
ChatRequest:
  messages:          List<ChatMessage>         # Conversation history
  model:             String                    # Model ID (e.g., "gpt-4o")
  systemPrompt:      String?                   # System message (from persona)
  temperature:       double?                   # 0.0 - 2.0
  topP:              double?                   # 0.0 - 1.0
  maxTokens:         int?                      # Maximum response tokens
  stopSequences:     List<String>?             # Custom stop tokens
  tools:             List<ToolDefinition>?      # Available tools for function calling
  toolChoice:        String?                   # "auto", "none", or specific tool
  responseFormat:    String?                   # "text" or "json_object"
  stream:            bool                      # Whether to stream response
  metadata:          Map<String, dynamic>?     # Provider-specific options
```

### ChatMessage

```yaml
ChatMessage:
  role:              String                    # "system", "user", "assistant", "tool"
  content:           dynamic                   # String or List<ContentPart>
  toolCalls:         List<ToolCall>?           # Function calls in this message
  toolCallId:        String?                   # For tool result messages
  name:              String?                   # Optional name for multi-party
```

### ContentPart (for multi-modal messages)

```yaml
ContentPart:
  type:              String                    # "text" or "image_url"
  text:              String?                   # If type == "text"
  imageUrl:          ImageUrl?                 # If type == "image_url"

ImageUrl:
  url:               String                    # Data URL (base64) or HTTP URL
  detail:            String?                   # "low", "high", "auto"
```

### ChatResponse

```yaml
ChatResponse:
  id:                String                    # Provider-assigned response ID
  content:           String                    # Response text
  model:             String                    # Model that generated response
  finishReason:      String                    # "stop", "length", "tool_calls", "error"
  toolCalls:         List<ToolCall>?           # Requested function calls
  usage:             TokenUsage                # Token counts
  latencyMs:         int                       # Total response time
```

### ChatStreamEvent

```yaml
ChatStreamEvent:
  type:              StreamEventType           # token | toolCall | done | error
  token:             String?                   # New token (if type == token)
  toolCall:          ToolCall?                 # Tool call chunk (if type == toolCall)
  usage:             TokenUsage?               # Final usage (if type == done)
  error:             String?                   # Error message (if type == error)
  finishReason:      String?                   # Set on final event
```

### ToolDefinition (for function calling)

```yaml
ToolDefinition:
  type:              String                    # Always "function"
  function:
    name:            String                    # Tool ID (e.g., "code_execute")
    description:     String                    # What the tool does
    parameters:      Map<String, dynamic>      # JSON Schema for parameters
```

### ToolCall

```yaml
ToolCall:
  id:                String                    # Unique call ID
  type:              String                    # Always "function"
  function:
    name:            String                    # Tool name
    arguments:       String                    # JSON string of arguments
```

---

## 3. OpenAI Integration

### Provider Details

| Field | Value |
|-------|-------|
| **Provider ID** | `openai` |
| **Base URL** | `https://api.openai.com/v1` |
| **Auth** | Bearer token (`Authorization: Bearer sk-...`) |
| **Streaming** | SSE via `POST /chat/completions` with `stream: true` |
| **Function Calling** | ✅ Full support via `tools` parameter |
| **Vision** | ✅ Models with vision capability (gpt-4o, gpt-4-turbo) |
| **JSON Mode** | ✅ `response_format: {"type": "json_object"}` |

### Endpoints Used

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/v1/chat/completions` | POST | Chat completion (streaming and non-streaming) |
| `/v1/models` | GET | List available models |

### Request Mapping

```
ChatRequest → OpenAI API
─────────────────────────
messages       → messages (direct map)
model          → model
systemPrompt   → Prepended as messages[0] with role: "system"
temperature    → temperature
topP           → top_p
maxTokens      → max_tokens
stopSequences  → stop
tools          → tools (direct map — OpenAI's schema matches our contract)
toolChoice     → tool_choice
responseFormat → response_format
stream         → stream
```

### Supported Models

| Model | Context | Vision | Function Calling | Notes |
|-------|---------|--------|-----------------|-------|
| gpt-4o | 128K | ✅ | ✅ | Flagship |
| gpt-4o-mini | 128K | ✅ | ✅ | Cost-effective |
| gpt-4-turbo | 128K | ✅ | ✅ | Previous generation |
| o1 | 200K | ✅ | ✅ | Reasoning model |
| o1-mini | 128K | ❌ | ✅ | Lightweight reasoning |
| o3-mini | 200K | ❌ | ✅ | Fast reasoning |

> Model list is fetched dynamically via `/v1/models` and filtered against known-compatible models.

### Error Mapping

| OpenAI Error | HTTP Code | Gemmie Handling |
|-------------|-----------|-----------------|
| `invalid_api_key` | 401 | Prompt user to update API key |
| `rate_limit_exceeded` | 429 | Auto-retry with backoff |
| `model_not_found` | 404 | Remove from model list, notify user |
| `context_length_exceeded` | 400 | Truncate messages, retry |
| `server_error` | 500 | Retry up to 3 times |

---

## 4. Google Gemini Integration

### Provider Details

| Field | Value |
|-------|-------|
| **Provider ID** | `gemini` |
| **Base URL** | `https://generativelanguage.googleapis.com/v1beta` |
| **Auth** | API key as query parameter (`?key=AI...`) |
| **Streaming** | SSE via `POST /models/{model}:streamGenerateContent` |
| **Function Calling** | ✅ Via `tools` in request body |
| **Vision** | ✅ Inline data with `inlineData` parts |

### Endpoints Used

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/models/{model}:generateContent` | POST | Non-streaming completion |
| `/models/{model}:streamGenerateContent` | POST | Streaming completion |
| `/models` | GET | List available models |

### Request Mapping

```
ChatRequest → Gemini API
─────────────────────────
messages       → contents[] (role mapping: "user"→"user", "assistant"→"model")
systemPrompt   → systemInstruction.parts[0].text
temperature    → generationConfig.temperature
topP           → generationConfig.topP
maxTokens      → generationConfig.maxOutputTokens
tools          → tools[].functionDeclarations (schema conversion required)
```

### Key Differences from OpenAI

| Aspect | OpenAI | Gemini |
|--------|--------|--------|
| Auth | Header bearer token | Query parameter |
| Role names | assistant | model |
| System prompt | First message with role: system | Separate `systemInstruction` field |
| Image format | URL or base64 data URL | `inlineData` with mimeType + base64 |
| Tool schema | JSON Schema | Subset of JSON Schema (no `$ref`) |
| Streaming format | SSE with `data: ` prefix | SSE with JSON chunks |

### Supported Models

| Model | Context | Vision | Function Calling |
|-------|---------|--------|-----------------|
| gemini-2.0-flash | 1M | ✅ | ✅ |
| gemini-2.0-pro | 1M | ✅ | ✅ |
| gemini-1.5-flash | 1M | ✅ | ✅ |
| gemini-1.5-pro | 2M | ✅ | ✅ |

---

## 5. Anthropic Claude Integration

### Provider Details

| Field | Value |
|-------|-------|
| **Provider ID** | `claude` |
| **Base URL** | `https://api.anthropic.com/v1` |
| **Auth** | `x-api-key` header + `anthropic-version` header |
| **Streaming** | SSE via `POST /messages` with `stream: true` |
| **Function Calling** | ✅ Via `tools` in request body |
| **Vision** | ✅ Via `image` content blocks |

### Endpoints Used

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/v1/messages` | POST | Chat completion (streaming and non-streaming) |

### Request Mapping

```
ChatRequest → Claude API
─────────────────────────
messages       → messages (role mapping mostly compatible)
systemPrompt   → system (top-level field, not in messages)
model          → model
temperature    → temperature
maxTokens      → max_tokens (REQUIRED in Claude API)
tools          → tools (input_schema instead of parameters)
stream         → stream
```

### Key Differences

| Aspect | OpenAI | Claude |
|--------|--------|--------|
| System prompt | In messages array | Top-level `system` field |
| Max tokens | Optional | Required |
| Streaming events | `data: {"choices": [...]}` | Multiple event types: `message_start`, `content_block_delta`, `message_stop` |
| Tool schema field | `parameters` | `input_schema` |
| API version | Implicit | `anthropic-version: 2024-01-01` header required |
| Image format | URL | base64 with `source.type: "base64"` |

### Supported Models

| Model | Context | Vision | Function Calling |
|-------|---------|--------|-----------------|
| claude-sonnet-4-20250514 | 200K | ✅ | ✅ |
| claude-3-5-haiku-20241022 | 200K | ✅ | ✅ |
| claude-3-opus-20240229 | 200K | ✅ | ✅ |

### Streaming Event Types

```
event: message_start     → Initialize response
event: content_block_start → New content block
event: content_block_delta → Token or tool input delta
event: content_block_stop  → Block complete
event: message_delta      → Usage, stop reason
event: message_stop       → Stream complete
```

---

## 6. HuggingFace Integration

HuggingFace serves **two purposes** in Gemmie:

### 6A. Model Downloads

| Field | Value |
|-------|-------|
| **Purpose** | Download local models for on-device inference |
| **Auth** | OAuth 2.0 (via AppAuth) or Bearer token |
| **Base URL** | `https://huggingface.co` |

#### OAuth Flow

```
1. User taps "Login with HuggingFace"
2. App opens browser to HF authorization endpoint:
   GET https://huggingface.co/oauth/authorize
   ?client_id={PROJECT_CONFIG_CLIENT_ID}
   &redirect_uri={PROJECT_CONFIG_REDIRECT_URI}
   &response_type=code
   &scope=openid%20profile%20read-repos
3. User authorizes in browser
4. Browser redirects to app with authorization code
5. App exchanges code for access token:
   POST https://huggingface.co/oauth/token
6. Token stored in secure keystore
```

#### Download Endpoints

| Endpoint | Purpose |
|----------|---------|
| `GET /api/models/{model_id}` | Fetch model metadata |
| `GET /{model_id}/resolve/{commit}/{filename}` | Download model file |
| `GET /api/models/{model_id}/tree/{commit}` | List model files |

### 6B. HuggingFace Inference API

| Field | Value |
|-------|-------|
| **Provider ID** | `huggingface` |
| **Base URL** | `https://api-inference.huggingface.co` |
| **Auth** | Bearer token (`Authorization: Bearer hf_...`) |
| **Streaming** | SSE support for text generation models |

#### Endpoints

| Endpoint | Purpose |
|----------|---------|
| `POST /models/{model_id}` | Run inference on hosted model |
| `GET /models/{model_id}` | Check model status |

#### Request Format

```json
{
  "inputs": "Complete conversation as formatted text",
  "parameters": {
    "max_new_tokens": 2048,
    "temperature": 0.7,
    "top_p": 0.95,
    "return_full_text": false
  },
  "stream": true
}
```

> Note: HF Inference API uses a different request format than chat-based providers. The adapter must convert `ChatRequest` messages into the appropriate prompt format for the specific model.

---

## 7. OpenRouter Integration

### Provider Details

| Field | Value |
|-------|-------|
| **Provider ID** | `openrouter` |
| **Base URL** | `https://openrouter.ai/api/v1` |
| **Auth** | Bearer token (`Authorization: Bearer sk-or-...`) |
| **Streaming** | SSE (OpenAI-compatible format) |
| **Function Calling** | ✅ Via selected models |

### Key Advantage

OpenRouter acts as a **meta-provider**, routing to 200+ models across multiple providers. This lets users access models from OpenAI, Anthropic, Google, Meta, Mistral, and others through a single API key.

### Endpoints Used

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/v1/chat/completions` | POST | Chat completion (OpenAI-compatible) |
| `/api/v1/models` | GET | List all available models |
| `/api/v1/auth/key` | GET | Validate API key and check credits |

### Request Mapping

OpenRouter uses the **OpenAI-compatible format** with additional headers:

```
Additional headers:
  HTTP-Referer: https://gemmie.app (or app identifer)
  X-Title: Gemmie

Additional body fields:
  transforms: ["middle-out"]    # Optional: context compression
  route: "fallback"             # Optional: automatic fallback routing
```

### Model Selection

```json
{
  "model": "anthropic/claude-sonnet-4-20250514",
  "messages": [...]
}
```

Models are namespaced by provider: `openai/gpt-4o`, `anthropic/claude-sonnet-4-20250514`, `google/gemini-2.0-flash`, etc.

---

## 8. Local Model Integration

### Provider Details

| Field | Value |
|-------|-------|
| **Provider ID** | `local` |
| **Runtime** | LiteRT (via platform channels / FFI) |
| **Auth** | None (on-device) |
| **Streaming** | Token-by-token via callback |

### Architecture

```
Dart (AIProvider interface)
    │
    ▼
Platform Channel / FFI
    │
    ▼
LiteRT-LM Engine (native C++)
    │
    ├── EngineConfig (model path, GPU delegation)
    ├── ConversationConfig (system prompt, history)
    └── SamplerConfig (temperature, topK, topP)
```

### Request Mapping

```
ChatRequest → LiteRT Engine
─────────────────────────────
messages       → Formatted as conversation turns for the model's chat template
systemPrompt   → ConversationConfig.systemPrompt
temperature    → SamplerConfig.temperature
topK           → SamplerConfig.topK
topP           → SamplerConfig.topP
maxTokens      → SamplerConfig.maxTokens
```

### Local-Specific Considerations

| Consideration | Handling |
|--------------|---------|
| Model not loaded | Trigger model load on first request; show loading state |
| OOM during inference | Catch native exception, unload model, notify user |
| GPU delegation | Enable by default on supported devices; fallback to CPU |
| Battery impact | Throttle inference speed on low battery |
| Concurrent requests | Queue requests — only one inference at a time |
| Function calling | Not natively supported by most local models; parse output for tool call patterns |

---

## 9. Custom Provider Integration

For self-hosted or non-standard providers:

### Configuration Schema

```yaml
CustomProvider:
  displayName:     String                     # User-defined name
  baseUrl:         String                     # API endpoint
  apiKeyHeader:    String                     # Header name for API key (default: "Authorization")
  apiKeyPrefix:    String                     # Prefix before key (default: "Bearer ")
  chatEndpoint:    String                     # Path for chat (default: "/chat/completions")
  modelsEndpoint:  String?                    # Path for model list (optional)
  format:          String                     # "openai" | "anthropic" | "raw"
  models:          List<ManualModel>          # Manually configured models
  extraHeaders:    Map<String, String>?       # Custom headers
```

### Usage

Custom providers that follow OpenAI's API format (many self-hosted solutions like vLLM, Ollama, LM Studio) can be configured by simply changing the `baseUrl` and providing the model list.

---

## 10. Error Handling & Retry Strategy

### Error Categories

| Category | Examples | Handling |
|----------|----------|---------|
| **Auth Error** (401/403) | Invalid API key, expired token | Prompt user to update credentials; do NOT retry |
| **Rate Limit** (429) | Requests per minute exceeded | Auto-retry with exponential backoff |
| **Server Error** (500/502/503) | Provider outage | Retry up to 3 times; then offer fallback provider |
| **Client Error** (400) | Invalid request, context too long | Parse error, apply fix (truncate), retry once |
| **Network Error** | No connectivity, timeout, DNS failure | Check connectivity; retry with backoff if intermittent |
| **Stream Error** | Connection dropped during streaming | Preserve partial response; offer to retry from last token |

### Retry Configuration

```yaml
RetryConfig:
  maxRetries:        3
  initialDelay:      1000ms
  maxDelay:          30000ms
  backoffMultiplier: 2.0
  retryableStatuses: [429, 500, 502, 503, 504]
  nonRetryableStatuses: [400, 401, 403, 404]
```

### Error Response Contract

```yaml
ProviderError:
  code:              String                   # "auth_error", "rate_limit", "server_error", etc.
  message:           String                   # Human-readable error message
  provider:          String                   # Which provider
  httpStatus:        int?                     # HTTP status code
  retryable:         bool                     # Whether this can be retried
  retryAfterMs:      int?                     # Suggested retry delay
  suggestion:        String                   # User-facing suggestion ("Check your API key", etc.)
```

---

## 11. Rate Limiting & Quotas

### Per-Provider Rate Limiting

| Provider | Default RPM | Default TPM | Configurable |
|----------|------------|------------|--------------|
| OpenAI | Follows API tier | Follows API tier | No (server-enforced) |
| Gemini | 60 RPM (free), higher on paid | 1M TPM | No |
| Claude | Follows API tier | Follows API tier | No |
| HuggingFace | 300 RPM (free) | — | No |
| OpenRouter | Follows model limits | Follows model limits | No |
| Local | Unlimited | N/A | N/A |

### Client-Side Rate Limiting

Gemmie implements client-side rate limiting as a politeness layer:

```yaml
ClientRateLimit:
  minRequestIntervalMs:  500                  # Minimum gap between requests
  maxConcurrentRequests: 1                    # One request at a time per provider
  burstLimit:            5                    # Max requests in a 10-second window
```

### Budget Management

```
User sets monthly budget ($10/mo for OpenAI)
    │
    ▼
Each request → estimate cost from token usage
    │
    ▼
Running total tracked in ProviderConfig.rateLimits.currentMonthSpend
    │
    ├── < 80% budget → Normal operation
    ├── 80-99% budget → Warning notification
    └── ≥ 100% budget → Block requests, offer to increase limit
```

---

## 12. Token Counting & Cost Estimation

### Token Estimation

Since exact token counting requires provider-specific tokenizers:

| Provider | Estimation Method |
|----------|------------------|
| OpenAI | `tiktoken` (if available) or approximation: chars / 4 |
| Gemini | Approximation: chars / 4 |
| Claude | Approximation: chars / 4 (Anthropic doesn't publish tokenizer) |
| Local | Model-specific tokenizer via LiteRT |

### Cost Calculation

```
cost = (inputTokens / 1_000_000) * inputPricePerMT
     + (outputTokens / 1_000_000) * outputPricePerMT
```

Prices are stored per-model in `ProviderModel.inputPricePerMT` / `outputPricePerMT` and user-configurable.

---

## 13. Adding a New Provider Guide

### Step-by-Step

1. **Create adapter file:**
   ```
   lib/features/providers/data/adapters/new_provider_adapter.dart
   ```

2. **Implement `AIProvider` interface:**
   - Map `ChatRequest` → provider-specific format
   - Map provider response → `ChatResponse`
   - Implement streaming (parse SSE or WebSocket events)
   - Handle authentication (key format, headers)

3. **Define provider type:**
   Add new enum value to `ProviderType` in data models.

4. **Register provider:**
   Add to `ProviderRegistry` initialization in DI setup.

5. **Create configuration UI:**
   Add provider setup card in Settings > AI Providers.

6. **Add credential schema:**
   Define what credentials are needed (API key, OAuth, etc.).

7. **Write tests:**
   - Unit tests for request/response mapping
   - Integration tests with mock HTTP responses
   - Streaming tests with mock SSE events

### Estimated Effort

| Task | Lines of Code | Time Estimate |
|------|--------------|---------------|
| Adapter implementation | 100-200 | 1-2 days |
| UI configuration | 50-100 | 0.5 days |
| Tests | 100-150 | 0.5-1 day |
| **Total** | **250-450** | **2-3.5 days** |

### Zero Core Changes Required

The adapter pattern ensures that adding `NewProviderAdapter` requires:
- ✅ New files only (adapter, tests, UI card)
- ❌ No changes to chat module
- ❌ No changes to streaming logic
- ❌ No changes to tool invocation
- ❌ No changes to conversation persistence
