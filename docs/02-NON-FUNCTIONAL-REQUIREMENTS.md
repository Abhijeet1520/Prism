# Prism — Non-Functional Requirements

## NFR-01 Performance

| Metric | Target |
|---|---|
| App cold start | < 2 seconds on mid-range Android device |
| Chat first-token latency (local) | < 500 ms for 7B Q4 model |
| Chat first-token latency (cloud) | < 1 second (network-dependent) |
| Local inference throughput | ≥ 10 tokens/sec on Snapdragon 8 Gen 2 |
| UI frame rate | 60 fps during chat streaming |
| Database query (Drift) | < 50 ms for typical queries |
| FTS5 search | < 200 ms for 10K+ records |
| File open (rich editor) | < 1 second for files up to 1 MB |
| AI Gateway response | < 100 ms overhead on top of model latency |
| Background sync cycle | < 5 seconds for incremental sync |

### NFR-01.1 Memory Management

- Peak memory usage < 500 MB (excluding loaded AI models).
- Model memory mapped (mmap) via llama_cpp_dart; not fully loaded into RAM.
- Lazy-load UI screens; dispose controllers when off-screen.
- Image/thumbnail caching with bounded LRU cache.

### NFR-01.2 Battery Optimization

- Background inference deferred on battery < 20%.
- Batch network requests where possible.
- Adaptive sync frequency based on battery state.
- Respect Android Doze mode and app standby buckets.

---

## NFR-02 Scalability

| Dimension | Target |
|---|---|
| Conversations | 10,000+ without degradation |
| Messages per conversation | 50,000+ |
| Files | 100,000+ metadata entries in Drift |
| PARA notes | 50,000+ |
| Tasks | 10,000+ |
| Financial transactions | 100,000+ |
| Concurrent MCP tool servers | 10+ |
| AI Gateway concurrent requests | 10+ |

### NFR-02.1 Database Scalability

- Drift/SQLite with proper indexing on all query columns.
- FTS5 virtual tables for full-text search.
- Pagination for all list views (cursor-based).
- Database vacuum and optimization on schedule.

---

## NFR-03 Reliability

| Metric | Target |
|---|---|
| Crash-free sessions | > 99.5% |
| Data loss incidents | Zero (WAL mode, atomic transactions) |
| Graceful degradation | App functional without network |
| Recovery from model crash | Auto-restart inference engine |

### NFR-03.1 Error Handling

- All provider errors caught and displayed as user-friendly messages.
- Retry logic with exponential backoff for network requests.
- Model inference errors do not crash the app; fallback message shown.
- Drift transactions ensure atomic writes (no partial state).

### NFR-03.2 Data Integrity

- SQLite WAL mode for concurrent read/write safety.
- Schema migrations via Drift's built-in migration system.
- Backup/restore functionality (export database + files as ZIP).
- Supabase sync with conflict detection.

---

## NFR-04 Security

> Detailed in [07-SECURITY-SPEC.md](07-SECURITY-SPEC.md).

| Requirement | Implementation |
|---|---|
| API key storage | flutter_secure_storage (Keystore/Keychain) |
| Data at rest | SQLCipher encryption (optional) |
| Network traffic | TLS 1.2+ for all API calls |
| Code execution | Sandboxed (QuickJS mobile, Docker desktop, remote cloud) |
| AI Gateway auth | Token-based with rate limiting |
| MCP auth | Per-server token configuration |
| Notification data | Processed locally, never sent to cloud without consent |
| Financial data | Encrypted at rest, excluded from cloud sync by default |

---

## NFR-05 Usability

| Requirement | Detail |
|---|---|
| Onboarding | First-run wizard: choose provider → configure key/Ollama → select model → optional Supabase |
| Learning curve | Core chat usable in < 2 minutes |
| Design system | moon_design with token-based MoonTheme theming |
| Accessibility | WCAG 2.1 AA compliance target |
| Responsiveness | Adaptive layout for phone, tablet, desktop, web |
| Keyboard shortcuts | Full keyboard navigation on desktop (command palette, Ctrl+K) |

---

## NFR-06 Maintainability

| Requirement | Detail |
|---|---|
| Architecture | Feature-based modular structure with clear boundaries |
| State management | Riverpod 2.x with code generation |
| Testing | Unit tests for business logic, widget tests for UI, integration tests for flows |
| Code coverage | Target 70%+ for core modules |
| Documentation | Inline dartdoc + architecture docs |
| CI/CD | GitHub Actions: lint → test → build → release |
| Code style | dart analyze + custom lint rules |
| Dependency updates | Dependabot or Renovate for automated PRs |

### NFR-06.1 Module Independence

- Each feature module (chat, files, tasks, finance, etc.) is self-contained.
- Shared code lives in `core/` and `shared/` modules.
- Inter-module communication via Riverpod providers, not direct imports.
- Module can be disabled without breaking the app.

---

## NFR-07 Portability

| Platform | Support Level |
|---|---|
| Android 8+ (API 26+) | Full support (primary) |
| Windows 10+ | Full support (Phase 2) |
| macOS 12+ | Full support (Phase 2) |
| Linux (x64) | Full support (Phase 2) |
| Web (Chrome, Firefox, Safari) | Partial support (Phase 3, no local inference) |
| iOS | Deferred (sandboxing limitations for notifications, AI Gateway) |

### NFR-07.1 Platform-Specific Considerations

- **Android**: notification_listener_service, WorkManager, file system access.
- **Desktop**: Docker for code execution, puppeteer for browser automation, tray icon.
- **Web**: No local inference (llama_cpp_dart requires FFI). Drift works via sql.js. No AI Gateway.
- **iOS**: No notification listening. No background HTTP server. Potential future with limited scope.

---

## NFR-08 Deployment & Distribution

| Channel | Details |
|---|---|
| GitHub Releases | APK, Windows installer, macOS DMG, Linux AppImage |
| F-Droid | Android only, FOSS compliance |
| GitHub Actions CI/CD | Automated build, test, release pipeline |
| Versioning | Semantic Versioning (semver) |
| Update checking | In-app update notification via GitHub API |

---

## NFR-09 Observability

| Aspect | Implementation |
|---|---|
| Crash reporting | Sentry (opt-in) |
| Analytics | None (privacy-first; optional self-hosted analytics) |
| Logging | dart:developer + configurable log levels |
| Performance monitoring | Custom timing metrics for inference, sync, search |
| AI Gateway logs | Request/response logging with configurable retention |

---

## NFR-10 Capacity Planning

| Resource | Estimate |
|---|---|
| App size (APK) | < 30 MB (without bundled model) |
| Bundled model (optional) | 2–4 GB for 7B Q4 GGUF |
| Drift database (typical) | 50–500 MB after 1 year of use |
| Supabase storage (free tier) | 1 GB database, 1 GB file storage |
| AI Gateway throughput | Bounded by underlying model speed |
