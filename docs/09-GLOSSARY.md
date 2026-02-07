# 09 — Glossary

> Definitions of terms, abbreviations, and concepts used across the Gemmie documentation suite.

---

## A

| Term | Definition |
|------|-----------|
| **Adapter Pattern** | Design pattern where each AI provider implements a common interface (`AIProvider`), allowing Gemmie to swap providers without changing calling code. |
| **AES-256-GCM** | Advanced Encryption Standard with 256-bit keys in Galois/Counter Mode. Authenticated encryption providing both confidentiality and integrity. Used for all data at rest in Gemmie. |
| **AI Provider** | An external (cloud) or local service that performs AI inference. Examples: OpenAI, Gemini, Claude, HuggingFace, OpenRouter, local LiteRT. |
| **Audit Log** | Append-only record of all security-relevant events (file access, permission grants, code executions) for user review. |

## B

| Term | Definition |
|------|-----------|
| **BIP39** | Bitcoin Improvement Proposal 39 — standard for encoding cryptographic seeds as human-readable word lists. Used for Gemmie's sync recovery key. |
| **Bottom Sheet** | A Material Design component that slides up from the bottom of the screen. Used in Gemmie for model selection, file actions, and tool previews. |

## C

| Term | Definition |
|------|-----------|
| **Chat Completion** | An AI API endpoint that takes a conversation history (list of messages) and returns the next assistant message. Core API pattern used by all Gemmie providers. |
| **Clean Architecture** | Software architecture with strict separation: Presentation → Domain → Data. Each layer depends only on inner layers. |
| **Cloud Sync** | Optional feature to synchronize encrypted data across multiple devices via a cloud backend. |
| **Code Execution Sandbox** | An isolated environment where user/AI code runs with restricted filesystem, network, and system access. |
| **Content Part** | A segment of a chat message: text, image, file reference, or tool call result. Messages contain one or more content parts. |
| **CRDT** | Conflict-free Replicated Data Type — a data structure that can be merged across devices without conflicts. Considered for cloud sync. |
| **CPython** | The reference implementation of Python, written in C. Gemmie embeds CPython via FFI for local Python execution. |

## D

| Term | Definition |
|------|-----------|
| **dart_eval** | A Dart package that evaluates Dart code at runtime without compilation. Used for local Dart code execution in Gemmie. |
| **Daytona** | A cloud development environment platform. Supported as a remote code execution backend in Gemmie. |
| **DEK** | Data Encryption Key — the AES-256 key used to encrypt all user data. Itself encrypted by the KEK. |
| **Diff** | The set of changes between two versions of a file. Gemmie uses Myers algorithm with word-level refinement. |
| **DiffHunk** | A contiguous block of changes within a diff result, containing old and new line ranges plus word-level diffs. |

## E

| Term | Definition |
|------|-----------|
| **E2E Encryption** | End-to-End Encryption — data encrypted on the client before transmission; the server never has access to plaintext. Used for cloud sync. |
| **Emergency Lockdown** | A one-tap security action that immediately revokes all AI permissions, cancels pending operations, and logs the event. |

## F

| Term | Definition |
|------|-----------|
| **FFI** | Foreign Function Interface — a mechanism for Dart to call native C/C++ libraries. Used for LiteRT inference and CPython embedding. |
| **File Version** | A snapshot of a file at a specific point in time, stored with diff data and metadata (who changed it, why). |
| **Flutter** | Google's cross-platform UI framework using Dart. The development platform for Gemmie. |
| **Function Calling** | An AI capability where the model outputs structured tool invocations instead of (or alongside) text responses. |

## G

| Term | Definition |
|------|-----------|
| **Gated** | The default permission tier. AI can access the file/folder only after explicit user approval (per-request, per-session, or permanent grant). |
| **GCM** | Galois/Counter Mode — an authenticated encryption mode that provides both encryption and integrity verification. |
| **GGUF** | GGML Universal Format — the file format for quantized LLM models used by llama.cpp and Ollama. Gemmie loads .gguf files for on-device inference via `llama_sdk`. |
| **GemmieProvider** | Wrapper around LangChain.dart's `BaseChatModel` that adds Gemmie-specific concerns: credential management, rate limiting, cost tracking, and health checks. |
| **GemmieFolder** | A virtual folder organizing GemmieFiles. Can have permission overrides that cascade to children. |
| **GoRouter** | A declarative routing package for Flutter. Used for Gemmie's navigation with deep link support. |
| **Grant** | A permission approval from the user to the AI for a specific file/operation, with an expiration scope (this time / session / always). |

## H

| Term | Definition |
|------|-----------|
| **HuggingFace** | An AI platform providing model hosting, downloads, and inference APIs. Gemmie uses HuggingFace for model downloads (with OAuth) and cloud inference. |
| **Hunk** | See DiffHunk. |

## I

| Term | Definition |
|------|-----------|
| **Isar** | A fast, embedded NoSQL database for Flutter/Dart. Version 4.x used as Gemmie's local storage engine. |

## K

| Term | Definition |
|------|-----------|
| **KEK** | Key Encryption Key — the master key stored in the platform's hardware keystore. Used to encrypt/decrypt the DEK. Never leaves the secure hardware. |
| **Keystore** | Platform-specific secure key storage. Android Keystore (TEE/StrongBox) or iOS Keychain (Secure Enclave). |

## L

| Term | Definition |
|------|-----------|
| **LAN Discovery** | Feature that automatically scans the local network to find running Ollama instances. Uses `lan_scanner` + `network_info_plus` packages. Ported from the Maid Flutter app. |
| **LangChain.dart** | A Dart port of the LangChain framework providing unified abstractions (`BaseChatModel`, `Runnable`, chains, agents, tools) for working with LLMs. Gemmie's provider abstraction layer. See [langchain_dart](https://pub.dev/packages/langchain). |
| **LiteRT** | Google's on-device AI inference runtime (formerly TensorFlow Lite). Used for running TFLite models in Gemmie via platform channels. |
| **llama.cpp** | A C/C++ library for local LLM inference supporting 100+ model architectures with extensive quantization. Gemmie accesses it via `llama_sdk` (FFI) or Ollama. |
| **llama_sdk** | A Dart package wrapping llama.cpp via FFI for direct in-process LLM inference. Used by the Maid Flutter app. Supports conditional imports for web. |
| **Locked** | The most restrictive permission tier. AI cannot access the file/folder under any circumstances. Only the user has access. |
| **LWW** | Last Writer Wins — a simple conflict resolution strategy where the most recent write takes precedence. Used as the default sync conflict strategy. |

## M

| Term | Definition |
|------|-----------|
| **Memory Entry** | A piece of persistent context in the persona system. Memories survive across conversations and inform AI behavior. |
| **Modal** | A cloud compute platform for running code in the cloud. Supported as a remote code execution backend. |
| **Myers Algorithm** | An efficient algorithm for computing the minimum edit distance (diff) between two sequences. Core of Gemmie's versioning engine. |

## N

| Term | Definition |
|------|-----------|
| **Nonce** | A number used once. In AES-GCM, a 96-bit random value unique per encryption operation to ensure ciphertext uniqueness. |

## O

| Term | Definition |
|------|-----------|
| **Ollama** | A tool for running LLMs locally, wrapping llama.cpp with an easy API and model management. First-class provider in Gemmie via `langchain_ollama`. Supports LAN discovery for mobile-to-desktop connectivity. |
| **Open** | The least restrictive permission tier. AI can freely access the file/folder without asking. All accesses are still logged. |
| **OpenRouter** | A meta-provider that routes AI requests to various models via a unified API (OpenAI-compatible format). |

## P

| Term | Definition |
|------|-----------|
| **PBKDF2** | Password-Based Key Derivation Function 2 — used to derive encryption keys from user passphrases. 600,000 iterations for Gemmie sync keys. |
| **Persona** | The AI agent's identity configuration: soul (core identity), personality (behavioral traits), memory, rules, and knowledge files. |
| **Permission Tier** | One of three access levels for files/folders: Locked, Gated, or Open. Determines how the AI can interact with the resource. |
| **PKCE** | Proof Key for Code Exchange — an OAuth 2.0 extension preventing authorization code interception. Required for HuggingFace auth. |
| **Platform Channel** | Flutter's mechanism for Dart code to communicate with native platform code (Kotlin/Swift). Used for keystore and LiteRT access. |
| **Provider Registry** | A singleton that manages all registered AI providers. Handles registration, lookup, health checks, and provider lifecycle. |

## Q

| Term | Definition |
|------|-----------|
| **QuickJS** | A small, embeddable JavaScript engine. Used for sandboxed JavaScript/TypeScript execution in Gemmie. |

## R

| Term | Definition |
|------|-----------|
| **Recovery Key** | A 24-word BIP39 mnemonic that can restore access to cloud sync data if the user forgets their passphrase. |
| **Riverpod** | A reactive state management framework for Flutter. Version 2.x used in Gemmie for compile-safe dependency injection and state management. |
| **Runnable** | LangChain.dart's core composable interface. Allows chaining components with the pipe operator: `promptTemplate \| chatModel \| outputParser`. Every step in a chain is a Runnable. |
## S

| Term | Definition |
|------|-----------|
| **Sandbox** | See Code Execution Sandbox. |
| **Soul File** | The core identity definition in the persona system. Contains the AI agent's name, identity statement, primary directives, and immutable constraints. |
| **SSE** | Server-Sent Events — a protocol for server-to-client streaming over HTTP. Used by some AI providers for streaming responses. |
| **STRIDE** | A threat modeling framework: Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege. |
| **Streaming** | Receiving AI responses token-by-token as they are generated, rather than waiting for the complete response. |
| **Supabase** | An open-source Firebase alternative providing auth, real-time database, storage, and edge functions. Chosen for Gemmie's cloud sync backend (proven in Maid). |
| **System Prompt** | The initial instruction message sent to the AI model, assembled from the active persona's components (soul + personality + memory + rules + knowledge). |

## T

| Term | Definition |
|------|-----------|
| **TEE** | Trusted Execution Environment — a secure area of the processor that ensures code and data are protected. Android Keystore uses TEE for key storage. |
| **TLS** | Transport Layer Security — cryptographic protocol for secure network communication. Gemmie requires TLS 1.3 (or 1.2 minimum). |
| **Token** | (1) In AI: a piece of text (~4 characters) that models process. Used for billing and context limits. (2) In auth: an OAuth access/refresh token. |
| **Tool** | A capability that the AI can invoke during a conversation (e.g., web search, calculator, file read, code execution). |
| **Tool Calling** | See Function Calling. |

## V

| Term | Definition |
|------|-----------|
| **Version** | A snapshot of a file's state at a point in time, linked to its predecessor via a diff. Enables history browsing and rollback. |
| **Virtual Filesystem** | Gemmie's file storage system, implemented in Isar (not the device OS filesystem). Provides files, folders, encryption, and versioning. |

## W

| Term | Definition |
|------|-----------|
| **WCAG AA** | Web Content Accessibility Guidelines level AA — the target accessibility standard for Gemmie, covering contrast, screen readers, and keyboard navigation. |
| **Word-Level Diff** | A refinement of line-level diffs that identifies specifically which words within a changed line were added, removed, or modified. |

---

## Abbreviations Quick Reference

| Abbreviation | Full Form |
|-------------|-----------|
| AES | Advanced Encryption Standard |
| API | Application Programming Interface |
| CRDT | Conflict-free Replicated Data Type |
| CRUD | Create, Read, Update, Delete |
| DB | Database |
| DEK | Data Encryption Key |
| E2E | End-to-End |
| FFI | Foreign Function Interface |
| FR | Functional Requirement |
| GCM | Galois/Counter Mode |
| GGUF | GGML Universal Format |
| KEK | Key Encryption Key |
| KDF | Key Derivation Function |
| LAN | Local Area Network |
| LCEL | LangChain Expression Language |
| LWW | Last Writer Wins |
| MD | Markdown |
| NFR | Non-Functional Requirement |
| OWASP | Open Worldwide Application Security Project |
| PBKDF2 | Password-Based Key Derivation Function 2 |
| PKCE | Proof Key for Code Exchange |
| RLS | Row Level Security |
| SSE | Server-Sent Events |
| TEE | Trusted Execution Environment |
| TLS | Transport Layer Security |
| UI | User Interface |
| UX | User Experience |
| WCAG | Web Content Accessibility Guidelines |
| WSS | WebSocket Secure |
