# 02 — Non-Functional Requirements

> This document defines the quality attributes, constraints, and operational requirements for Gemmie. These are cross-cutting concerns that apply across all features and modules.

---

## Table of Contents

- [NFR-01: Security](#nfr-01-security)
- [NFR-02: Performance](#nfr-02-performance)
- [NFR-03: Scalability & Extensibility](#nfr-03-scalability--extensibility)
- [NFR-04: Privacy](#nfr-04-privacy)
- [NFR-05: Accessibility](#nfr-05-accessibility)
- [NFR-06: Reliability & Availability](#nfr-06-reliability--availability)
- [NFR-07: Usability](#nfr-07-usability)
- [NFR-08: Compatibility](#nfr-08-compatibility)
- [NFR-09: Maintainability](#nfr-09-maintainability)
- [NFR-10: Compliance](#nfr-10-compliance)

---

## NFR-01: Security

**See also:** [Security Specification](./07-SECURITY-SPEC.md) for detailed implementation.

| ID | Requirement | Priority | Metric / Target |
|----|-------------|----------|-----------------|
| NFR-01.1 | All user data at rest encrypted with AES-256-GCM | Must | Zero plaintext data on disk |
| NFR-01.2 | Encryption keys stored in platform keystore (Android Keystore / iOS Keychain) | Must | Keys never stored in app sandbox |
| NFR-01.3 | API keys and tokens never logged, displayed in full, or transmitted unencrypted | Must | Zero credential leakage in logs |
| NFR-01.4 | All network communication over TLS 1.3+ | Must | No HTTP (only HTTPS) for API calls |
| NFR-01.5 | Code execution sandboxed — no access to app data, user data, or device APIs outside allowed scope | Must | Sandbox escape = critical severity |
| NFR-01.6 | Authentication tokens (OAuth) have configurable expiry and automatic refresh | Must | Token refresh before expiry |
| NFR-01.7 | Biometric authentication option for app launch and sensitive operations | Should | Platform biometric API integration |
| NFR-01.8 | All AI-generated file modifications go through permission checks before applying | Must | Zero unreviewed AI writes to gated/locked files |
| NFR-01.9 | Cloud sync data encrypted client-side before any network transmission | Must | Server-side storage = ciphertext only |
| NFR-01.10 | Security audit trail for all permission changes, token operations, and data access | Must | Queryable audit log retained 90 days |

---

## NFR-02: Performance

| ID | Requirement | Priority | Metric / Target |
|----|-------------|----------|-----------------|
| NFR-02.1 | App cold start to interactive state | Must | ≤ 2 seconds on mid-range device |
| NFR-02.2 | Chat message send to first streamed token (cloud API) | Must | ≤ 3 seconds (network dependent) |
| NFR-02.3 | Chat message send to first streamed token (local model, warm) | Must | ≤ 1 second |
| NFR-02.4 | Local model cold load (first inference after app start) | Should | ≤ 10 seconds for <4B param models |
| NFR-02.5 | File browser navigation (open folder, list files) | Must | ≤ 200ms for folders with <1000 items |
| NFR-02.6 | File search results display | Must | ≤ 500ms for <10,000 total files |
| NFR-02.7 | Diff computation for files up to 100KB | Must | ≤ 500ms |
| NFR-02.8 | UI frame rate during normal operation | Must | 60 FPS (no jank during scrolling, transitions) |
| NFR-02.9 | Code execution startup (sandboxed, empty script) | Must | ≤ 2 seconds |
| NFR-02.10 | Memory usage ceiling during local model inference | Must | ≤ 80% of available device RAM |
| NFR-02.11 | Background download impact on UI responsiveness | Must | Zero UI jank during active downloads |
| NFR-02.12 | Encryption/decryption overhead for file operations | Must | ≤ 50ms per file open (up to 1MB) |
| NFR-02.13 | Database query for conversation history (1000+ messages) | Must | ≤ 300ms |
| NFR-02.14 | Battery consumption during idle (no active inference) | Should | ≤ 2% per hour |

---

## NFR-03: Scalability & Extensibility

| ID | Requirement | Priority | Metric / Target |
|----|-------------|----------|-----------------|
| NFR-03.1 | AI provider system is pluggable — adding a new provider requires implementing 1 adapter interface, no core code changes | Must | New provider in <200 LOC |
| NFR-03.2 | Tool system is pluggable — adding a new tool requires implementing 1 tool interface, no core code changes | Must | New tool in <100 LOC |
| NFR-03.3 | Code executor is pluggable — adding a new language requires implementing 1 executor interface | Must | New executor in <150 LOC |
| NFR-03.4 | File storage handles up to 100,000 files without performance degradation | Should | Query times within NFR-02 limits |
| NFR-03.5 | Conversation storage handles 10,000+ conversations with 1000+ messages each | Should | No degradation in search/list |
| NFR-03.6 | Version history handles 1000+ versions per file without UI lag | Should | History loads in <1 second |
| NFR-03.7 | Model allowlist can be updated remotely without app update | Must | JSON fetch + parse <2 seconds |
| NFR-03.8 | Feature flags system for toggling features without code deployment | Should | Remote config or local flags |
| NFR-03.9 | Modular package architecture — core packages can be used independently | Should | Each `gemmie_*` package has zero cross-package dependencies |

---

## NFR-04: Privacy

| ID | Requirement | Priority | Metric / Target |
|----|-------------|----------|-----------------|
| NFR-04.1 | App is fully functional offline (except cloud API features) | Must | All local features work with no network |
| NFR-04.2 | No data transmitted to any server without explicit user action | Must | Zero background data exfiltration |
| NFR-04.3 | Analytics and crash reporting are opt-in only | Must | Disabled by default |
| NFR-04.4 | Cloud sync is opt-in only with per-item granularity | Must | Disabled by default |
| NFR-04.5 | User can export all their data at any time (data portability) | Must | Complete export in <5 minutes |
| NFR-04.6 | User can delete all local data and reset to factory state | Must | Zero recoverable data after reset |
| NFR-04.7 | Local model inference processes no data outside the device | Must | No telemetry during inference |
| NFR-04.8 | Cloud API requests contain only the conversation context required for the current request | Should | No extraneous data in API payloads |
| NFR-04.9 | Clear privacy policy accessible within the app | Must | Single-tap access from settings |
| NFR-04.10 | Third-party library audit — no libraries with known data collection | Must | Dependency audit before each release |

---

## NFR-05: Accessibility

| ID | Requirement | Priority | Metric / Target |
|----|-------------|----------|-----------------|
| NFR-05.1 | Full screen reader support (TalkBack on Android, VoiceOver on iOS) | Must | All interactive elements have semantic labels |
| NFR-05.2 | Dynamic text sizing — all text respects system font size settings | Must | UI functional from 0.75x to 2.0x scale |
| NFR-05.3 | Minimum contrast ratio for text on background | Must | WCAG AA: 4.5:1 for normal text, 3:1 for large |
| NFR-05.4 | All interactive elements have sufficient touch target size | Must | ≥ 48x48 dp |
| NFR-05.5 | Focus order is logical for keyboard/switch navigation | Must | Tab order matches visual order |
| NFR-05.6 | Color is not the sole indicator for any information | Must | Icons/text supplement color coding |
| NFR-05.7 | Animations respect system reduced-motion preference | Should | Animations disabled when system prefers |
| NFR-05.8 | Voice input available as alternative to typing | Should | Integrated with FR-01.3.2 |
| NFR-05.9 | High contrast theme available | Could | ≥ 7:1 contrast ratio (WCAG AAA) |

---

## NFR-06: Reliability & Availability

| ID | Requirement | Priority | Metric / Target |
|----|-------------|----------|-----------------|
| NFR-06.1 | App does not crash during normal operation | Must | Crash-free rate ≥ 99.5% |
| NFR-06.2 | Graceful degradation when offline: cloud features show clear offline state, local features work fully | Must | No crashes on network loss |
| NFR-06.3 | Auto-save for all editors (chat drafts, code, documents, sheets) | Must | Save every 5 seconds during active editing |
| NFR-06.4 | Recovery from unexpected termination — no data loss for saved content | Must | All committed writes survive process kill |
| NFR-06.5 | Model inference errors handled gracefully with user-friendly error messages | Must | No raw stack traces shown to users |
| NFR-06.6 | Local model OOM (out of memory) handled by graceful unload + user notification | Must | No device freeze or force close |
| NFR-06.7 | Download resume after network interruption | Must | Downloads resume from last byte received |
| NFR-06.8 | Database corruption recovery mechanism | Should | Auto-detect + attempt recovery + user notification |
| NFR-06.9 | Background tasks (downloads, sync) survive app backgrounding | Must | WorkManager/background service integration |
| NFR-06.10 | Rate limit handling for all API providers with automatic retry and backoff | Must | Exponential backoff: 1s → 2s → 4s → 8s → fail |

---

## NFR-07: Usability

| ID | Requirement | Priority | Metric / Target |
|----|-------------|----------|-----------------|
| NFR-07.1 | New user can send first message within 60 seconds of first launch | Must | Onboarding to first interaction ≤ 60s |
| NFR-07.2 | Core workflows (chat, file browse, settings) reachable within 2 taps from home | Must | Navigation depth ≤ 2 for primary features |
| NFR-07.3 | Consistent visual language and interaction patterns across all screens | Must | Material 3 design system compliance |
| NFR-07.4 | Loading states and progress indicators for all async operations | Must | No blank/frozen screens during loading |
| NFR-07.5 | Error messages are actionable — tell the user what went wrong AND what to do | Must | Every error has a suggested action |
| NFR-07.6 | Undo support for destructive actions (delete file, discard draft) | Should | Snackbar with undo for 5 seconds |
| NFR-07.7 | Confirmation dialogs for irreversible actions (permanent delete, data wipe) | Must | Double confirmation for critical operations |
| NFR-07.8 | Contextual help/tooltips for complex features (permissions, model config, code execution) | Should | First-time usage hints |
| NFR-07.9 | Responsive layout adapting to phone, tablet, and desktop screen sizes | Must | Adaptive layout breakpoints at 600dp and 840dp |

---

## NFR-08: Compatibility

| ID | Requirement | Priority | Metric / Target |
|----|-------------|----------|-----------------|
| NFR-08.1 | **Android:** Minimum SDK 26 (Android 8.0), target SDK 35 | Must | ~95% of active devices |
| NFR-08.2 | **iOS:** Minimum iOS 15.0 | Must | ~95% of active devices |
| NFR-08.3 | **Web:** Chrome 90+, Firefox 90+, Safari 15+, Edge 90+ | Should | Modern browsers only |
| NFR-08.4 | **Desktop:** Windows 10+, macOS 12+, Ubuntu 22.04+ | Should | Long-term support OS versions |
| NFR-08.5 | Flutter SDK version ≥ 3.19 | Must | Stable channel |
| NFR-08.6 | Dart SDK version ≥ 3.3 | Must | Aligned with Flutter |
| NFR-08.7 | Support for both ARM64 and x86_64 on Android | Must | Separate APKs or universal |
| NFR-08.8 | Support for Apple Silicon and Intel on macOS | Should | Universal binary |
| NFR-08.9 | Screen orientation: portrait and landscape supported | Should | Adaptive layout |
| NFR-08.10 | Dark mode follows system preference by default | Must | Automatic theme switching |

---

## NFR-09: Maintainability

| ID | Requirement | Priority | Metric / Target |
|----|-------------|----------|-----------------|
| NFR-09.1 | Codebase follows consistent style guide (enforced via linter) | Must | Zero linter warnings in CI |
| NFR-09.2 | Minimum 80% unit test coverage for domain/data layers | Should | Coverage tracked in CI |
| NFR-09.3 | Integration tests for critical user flows (chat, model download, file CRUD) | Must | ≥ 10 integration test scenarios |
| NFR-09.4 | Widget tests for all custom UI components | Should | Every custom widget has tests |
| NFR-09.5 | CI/CD pipeline: lint → test → build → deploy | Must | Automated on every PR |
| NFR-09.6 | Architecture documentation kept in sync with code | Should | Architecture Decision Records (ADR) for major changes |
| NFR-09.7 | Dependency updates tracked and applied monthly | Should | Dependabot or equivalent |
| NFR-09.8 | Clear separation of concerns across layers (presentation → domain → data) | Must | No direct DB access from UI code |
| NFR-09.9 | Feature modularity — each feature can be developed and tested independently | Should | Feature packages with clear interfaces |
| NFR-09.10 | Code review required for all changes to security-critical code (encryption, permissions, auth) | Must | PR approval from ≥ 2 reviewers |

---

## NFR-10: Compliance

| ID | Requirement | Priority | Metric / Target |
|----|-------------|----------|-----------------|
| NFR-10.1 | GDPR compliance for EU users (data portability, right to erasure, consent management) | Must | Documented compliance measures |
| NFR-10.2 | CCPA compliance for California users | Should | Documented compliance measures |
| NFR-10.3 | App store compliance: Google Play policies, Apple App Store guidelines | Must | Pass review on first submission |
| NFR-10.4 | Open source license compliance for all dependencies | Must | License audit before each release |
| NFR-10.5 | AI model usage compliant with model licenses (Gemma terms, Llama terms, etc.) | Must | Per-model license tracking |
| NFR-10.6 | Responsible AI usage — content filtering, safety guidelines | Should | Configurable safety settings |
| NFR-10.7 | Age rating appropriate content management | Must | Content policies documented |

---

## Summary Matrix

| Category | Must | Should | Could | Total |
|----------|------|--------|-------|-------|
| Security | 9 | 1 | 0 | 10 |
| Performance | 11 | 2 | 0 | 13 (* was 14, one is Should) |
| Scalability | 5 | 4 | 0 | 9 |
| Privacy | 8 | 1 | 0 | 9 (* was 10, one is Should) |
| Accessibility | 5 | 3 | 1 | 9 |
| Reliability | 8 | 1 | 0 | 9 (* was 10, one is Should) |
| Usability | 6 | 3 | 0 | 9 |
| Compatibility | 6 | 4 | 0 | 10 |
| Maintainability | 5 | 5 | 0 | 10 |
| Compliance | 5 | 2 | 0 | 7 |
| **Total** | **68** | **26** | **1** | **95** |
