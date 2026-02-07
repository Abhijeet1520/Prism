# 08 — Development Roadmap

> Phased delivery plan for Gemmie, including milestones, dependencies, Gallery module porting timeline, and effort estimates.

---

## Table of Contents

- [1. Phasing Strategy](#1-phasing-strategy)
- [2. Phase 0 — Project Bootstrap](#2-phase-0--project-bootstrap)
- [3. Phase 1 — Core Shell](#3-phase-1--core-shell)
- [4. Phase 2 — AI Integration](#4-phase-2--ai-integration)
- [5. Phase 3 — Tools & Code Execution](#5-phase-3--tools--code-execution)
- [6. Phase 4 — Files, Versioning & Permissions](#6-phase-4--files-versioning--permissions)
- [7. Phase 5 — Agent Persona](#7-phase-5--agent-persona)
- [8. Phase 6 — Advanced Features](#8-phase-6--advanced-features)
- [9. Gallery Module Porting](#9-gallery-module-porting)
- [10. Milestones & Success Criteria](#10-milestones--success-criteria)
- [11. Risk Register](#11-risk-register)
- [12. Dependency Graph](#12-dependency-graph)

---

## 1. Phasing Strategy

Although the user wants the full feature set (no MVP phasing at launch), the build sequence is ordered for maximum value-per-phase and minimal rework.

| Phase | Name | Duration | Dependencies |
|-------|------|----------|--------------|
| 0 | Project Bootstrap | 1 week | — |
| 1 | Core Shell | 3 weeks | Phase 0 |
| 2 | AI Integration | 4 weeks | Phase 1 |
| 3 | Tools & Code Execution | 3 weeks | Phase 2 |
| 4 | Files, Versioning & Permissions | 4 weeks | Phase 1 |
| 5 | Agent Persona | 2 weeks | Phase 2 |
| 6 | Advanced Features | 4 weeks | Phase 3, 4, 5 |
| — | **Total** | **~21 weeks** | |

### Parallel Tracks

Phases 3, 4, and 5 can proceed in parallel after Phase 2 completes, since they have no mutual dependencies. This could condense the timeline to ~16 weeks.

```
Timeline (compressed):

Week  1 ──── Phase 0: Bootstrap
Week  2-4 ── Phase 1: Core Shell
Week  5-8 ── Phase 2: AI Integration
Week  9-12 ─┬─ Phase 3: Tools & Code Execution
             ├─ Phase 4: Files, Versioning & Permissions
             └─ Phase 5: Agent Persona
Week 13-16 ── Phase 6: Advanced Features
```

---

## 2. Phase 0 — Project Bootstrap

**Duration**: 1 week
**Goal**: Project structure, CI/CD, dev environment

### Tasks

| ID | Task | Effort | Output |
|----|------|--------|--------|
| 0.1 | Create Flutter project (`flutter create gennie`) | 1h | Project skeleton |
| 0.2 | Configure project structure per 03-ARCHITECTURE.md | 4h | Clean Architecture folders |
| 0.3 | Set up Riverpod 2.x with code generation | 2h | Providers configured |
| 0.4 | Set up GoRouter navigation skeleton | 2h | Route definitions |
| 0.5 | Add linting rules (`very_good_analysis` or custom) | 1h | `analysis_options.yaml` |
| 0.6 | Set up Isar database with initial schemas | 4h | DB layer |
| 0.7 | Configure platform-specific keystore wrappers | 4h | Secure storage |
| 0.8 | Set up CI pipeline (GitHub Actions) | 4h | Build + test on push |
| 0.9 | Create shared design tokens / theme | 4h | `AppTheme`, `AppColors`, `AppTypography` |
| 0.10 | README, LICENSE, CONTRIBUTING.md in `gennie/` | 2h | Repo docs |

### Deliverable

- **Buildable app** with empty screens, correct architecture, and CI passing
- Theme system renders placeholder home screen

---

## 3. Phase 1 — Core Shell

**Duration**: 3 weeks
**Goal**: Chat UI, conversation management, settings, navigation

### Tasks

| ID | Task | Effort | Output |
|----|------|--------|--------|
| 1.1 | Implement bottom navigation (4 tabs) | 4h | TabBar scaffold |
| 1.2 | Conversation list screen | 12h | List with create/delete/rename |
| 1.3 | Chat screen — message bubbles | 16h | User + AI messages, markdown rendering |
| 1.4 | Chat screen — input bar (text, attachments) | 8h | Multi-line input, send button |
| 1.5 | Chat screen — streaming token display | 8h | Animated token-by-token rendering |
| 1.6 | Message persistence (Isar) | 8h | Conversations & messages CRUD |
| 1.7 | Encryption layer for DB | 12h | AES-256-GCM encrypt/decrypt |
| 1.8 | Settings screen — profile, preferences | 8h | Theme toggle, storage info |
| 1.9 | Settings screen — API key management | 12h | Add/edit/delete keys, masked display |
| 1.10 | Adaptive layout (phone/tablet/desktop) | 12h | Responsive breakpoints |
| 1.11 | Error handling & loading states | 8h | Shimmer, error banners, retry |

### Exit Criteria

- User can create conversations, type messages, see them persisted across restarts
- All data encrypted at rest
- Settings screen shows API key management (keys stored in keystore)
- App works on Android, iOS, and one desktop target

---

## 4. Phase 2 — AI Integration

**Duration**: 4 weeks
**Goal**: All AI providers working, model management, chat completions

### Tasks

| ID | Task | Effort | Output |
|----|------|--------|--------|
| 2.1 | Provider abstraction layer (`AIProvider` interface) | 8h | Core interface + registry |
| 2.2 | OpenAI provider implementation | 12h | Chat + streaming + tool calling |
| 2.3 | Google Gemini provider implementation | 12h | Chat + streaming + tool calling |
| 2.4 | Anthropic Claude provider implementation | 12h | Chat + streaming + tool calling |
| 2.5 | HuggingFace Inference API provider | 8h | Chat completion via API |
| 2.6 | OpenRouter provider (meta-router) | 8h | OpenAI-compatible wrapper |
| 2.7 | Custom provider support (user-configured) | 8h | Configurable endpoint |
| 2.8 | HuggingFace model download (OAuth) | 16h | Browse, download, manage |
| 2.9 | Local model inference (LiteRT FFI) | 24h | On-device inference pipeline |
| 2.10 | Token counting & cost estimation | 8h | Per-provider tokenizer |
| 2.11 | Rate limiting & retry logic | 8h | Exponential backoff, queue |
| 2.12 | Model selector bottom sheet in chat | 8h | Model switching mid-conversation |
| 2.13 | Provider health checks & status indicators | 4h | Green/yellow/red badges |

### Exit Criteria

- All 7 provider types functional with at least one model each
- Streaming works for OpenAI, Gemini, Claude
- Local model can be downloaded and run inference
- Token usage tracked and displayed to user

---

## 5. Phase 3 — Tools & Code Execution

**Duration**: 3 weeks
**Goal**: Tool system, built-in tools, code execution in 3 languages

### Tasks

| ID | Task | Effort | Output |
|----|------|--------|--------|
| 3.1 | Tool registry & invocation framework | 12h | `GemmieTool` interface, registry |
| 3.2 | Built-in tools: web search, calculator, unit converter | 16h | 3 tools working |
| 3.3 | Built-in tools: date/time, text transform, JSON formatter | 8h | 3 tools working |
| 3.4 | Tool result rendering in chat (tables, code blocks) | 8h | Rich tool output |
| 3.5 | Python execution sandbox (CPython FFI) | 20h | Isolated Python runner |
| 3.6 | JavaScript execution sandbox (QuickJS) | 16h | Isolated JS runner |
| 3.7 | Dart execution sandbox (dart_eval) | 12h | In-process Dart evaluator |
| 3.8 | Code editor UI (syntax highlighting, output panel) | 16h | Full code editor screen |
| 3.9 | Script management (save, load, parameters) | 12h | Script library |
| 3.10 | Remote execution connector (Modal, Daytona, SSH) | 16h | Remote code runner |
| 3.11 | Tools tab UI (grid, categories, search) | 8h | Tools discovery screen |
| 3.12 | AI tool calling integration (function calling) | 12h | AI invokes tools via function call API |

### Exit Criteria

- AI can call built-in tools during conversation
- User can write and execute Python, JS, Dart in the code editor
- Remote execution connects to at least one provider
- Tool results rendered inline in chat

---

## 6. Phase 4 — Files, Versioning & Permissions

**Duration**: 4 weeks
**Goal**: Virtual filesystem, version history, diff viewer, permission engine

### Tasks

| ID | Task | Effort | Output |
|----|------|--------|--------|
| 4.1 | Virtual filesystem core (GemmieFile, GemmieFolder) | 16h | CRUD on files/folders |
| 4.2 | File explorer UI (tree view, context menu) | 16h | Browse, create, rename, delete |
| 4.3 | Markdown editor with live preview | 16h | Full MD editing experience |
| 4.4 | Spreadsheet/grid editor | 20h | Cell editing, formulas, CSV |
| 4.5 | Version tracking engine | 12h | Auto-version on save/AI edit |
| 4.6 | Myers diff algorithm + word-level refinement | 16h | Compute diffs between versions |
| 4.7 | Diff viewer UI (side-by-side, inline) | 12h | Visual diff display |
| 4.8 | File history timeline | 8h | Version list with restore |
| 4.9 | Permission engine (Locked/Gated/Open) | 12h | Evaluation + grants |
| 4.10 | Permission UI (dialogs, indicators, audit) | 12h | User-facing permission controls |
| 4.11 | File encryption layer | 8h | Transparent encrypt/decrypt |
| 4.12 | File info panel (metadata, permissions, versions) | 8h | Info sheet |
| 4.13 | Audit log storage and dashboard | 8h | Security audit screen |

### Exit Criteria

- User can create, edit, organize files in virtual filesystem
- AI file edits create versions with diffs
- Locked files inaccessible to AI; Gated files require approval
- Audit dashboard shows all AI file access

---

## 7. Phase 5 — Agent Persona

**Duration**: 2 weeks
**Goal**: Persona system with soul files, personality, memory, evolution

### Tasks

| ID | Task | Effort | Output |
|----|------|--------|--------|
| 5.1 | Persona data model and storage | 8h | Persona CRUD |
| 5.2 | Soul file editor | 8h | Identity / directive editing |
| 5.3 | Personality editor (visual sliders) | 8h | Trait adjustment UI |
| 5.4 | Memory system (persistent context) | 12h | Memory entries CRUD |
| 5.5 | Rules engine (behavioral constraints) | 8h | Rule definitions |
| 5.6 | Knowledge file management | 8h | Attach reference documents |
| 5.7 | System prompt assembly from persona | 8h | Prompt builder pipeline |
| 5.8 | Multi-persona switching | 4h | Active persona selector |
| 5.9 | Persona evolution tracking | 8h | Change history for persona files |

### Exit Criteria

- User can create and switch between multiple personas
- AI behavior visibly changes with persona settings
- Memory persists across conversations
- Persona changes are version-tracked

---

## 8. Phase 6 — Advanced Features

**Duration**: 4 weeks
**Goal**: Cloud sync, polish, advanced integrations, testing

### Tasks

| ID | Task | Effort | Output |
|----|------|--------|--------|
| 6.1 | Cloud sync — E2E encrypted upload/download | 20h | Sync engine |
| 6.2 | Cloud sync — conflict resolution UI | 12h | Conflict dialogs |
| 6.3 | Cloud sync — multi-device state reconciliation | 16h | CRDT or LWW merge |
| 6.4 | Onboarding flow (3-step wizard) | 8h | First-launch experience |
| 6.5 | Notifications (permission requests, downloads) | 8h | In-app + system notifications |
| 6.6 | Performance optimization pass | 16h | Cold start < 2s, 60 FPS |
| 6.7 | Accessibility audit (WCAG AA) | 12h | Screen reader, contrast fixes |
| 6.8 | Integration test suite (>80% coverage) | 24h | Automated tests |
| 6.9 | Security penetration testing | 16h | Vulnerability assessment |
| 6.10 | Documentation (user guide, API docs) | 12h | End-user docs |
| 6.11 | App store preparation (playstore, appstore, web) | 8h | Store listings, screenshots |

### Exit Criteria

- Cloud sync works with E2E encryption
- All features accessible via screen reader
- 80% test coverage
- Security audit complete with no critical findings

---

## 9. Gallery Module Porting

The AI Edge Gallery (Kotlin/Compose) contains modules worth porting to Flutter. These are scheduled as enhancements after the initial build.

### Porting Priority

| Priority | Gallery Module | Target Phase | Effort | Notes |
|----------|---------------|-------------|--------|-------|
| P1 | HuggingFace OAuth flow | Phase 2 | 12h | Port auth flow + token management |
| P1 | Model download manager | Phase 2 | 16h | Port download queue + progress UI |
| P2 | LiteRT inference engine | Phase 2 | 20h | Port via FFI, not direct Kotlin port |
| P2 | Model config parsing | Phase 2 | 4h | Port JSON schema for model configs |
| P3 | Task plugin system | Phase 3 | 8h | Adapt plugin interface to Flutter tools |
| P3 | Benchmark runner | Phase 3 | 8h | Port performance benchmarking |
| P4 | UI patterns (chat bubbles, etc.) | Phase 1 | 4h | Adapt Compose patterns to Flutter |

### Porting Approach

1. **Study** the Kotlin source in `gallery/Android/src/`
2. **Extract** the interface contracts and data models
3. **Rewrite** in Dart following Gemmie's architecture (NOT a 1:1 port)
4. **Test** against the same inputs/outputs as the Gallery version
5. **Document** differences and improvements

---

## 10. Milestones & Success Criteria

| Milestone | Target | Success Criteria |
|-----------|--------|------------------|
| M0: Skeleton | End of Week 1 | Flutter app builds on all platforms; CI green; architecture in place |
| M1: Chat Works | End of Week 4 | User can chat with encrypted message persistence |
| M2: AI Connected | End of Week 8 | All 7 providers functional; local model runs inference |
| M3: Tools Ready | End of Week 12 | Tool calling works; code execution in 3 languages |
| M4: Files Ready | End of Week 12 | Virtual filesystem with versioning and permissions |
| M5: Persona Ready | End of Week 12 | Agent persona system functional |
| M6: Feature Complete | End of Week 16 | All features working; cloud sync, onboarding |
| M7: Release Candidate | End of Week 18 | Testing, security audit, accessibility audit complete |
| M8: Launch | End of Week 20 | App published to stores / web deployment |

---

## 11. Risk Register

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| LiteRT Flutter FFI complexity | High | High | Start early (Phase 2); fallback to platform channels |
| Python CPython FFI on iOS restrictions | Medium | High | Fallback to remote execution; JS as primary local lang |
| Cloud sync conflict resolution complexity | Medium | Medium | Start with simple LWW; upgrade to CRDT if needed |
| Cross-platform sandbox inconsistencies | Medium | Medium | Abstract sandbox interface; platform-specific impls |
| Provider API breaking changes | Medium | Low | Version-pin API clients; adapter pattern absorbs changes |
| Performance on low-end devices | Low | High | Profile early; lazy loading; progressive feature enablement |
| Scope creep from full-feature mandate | High | Medium | Strict phase boundaries; feature freeze at M6 |
| Key dependency deprecation (Isar, etc.) | Low | High | Abstractions over all deps; swap-ready interfaces |

---

## 12. Dependency Graph

```
Phase 0 (Bootstrap)
    │
    ▼
Phase 1 (Core Shell)
    │
    ├──────────────────────┬──────────────────────┐
    ▼                      ▼                      ▼
Phase 2 (AI Integration)  Phase 4 (Files)         │
    │                      │                      │
    ├──────────┐           │                      │
    ▼          ▼           │                      │
Phase 3      Phase 5      │                      │
(Tools)      (Persona)     │                      │
    │          │           │                      │
    └──────────┴───────────┘                      │
               │                                  │
               ▼                                  │
         Phase 6 (Advanced)  ◄────────────────────┘
```

### Key Dependencies

| Dependent | Depends On | Reason |
|-----------|-----------|--------|
| Phase 2 | Phase 1 | Needs chat UI + DB + encryption |
| Phase 3 | Phase 2 | Tools invoked by AI; needs provider layer |
| Phase 4 | Phase 1 | Needs DB + encryption layer |
| Phase 5 | Phase 2 | Persona modifies AI behavior; needs provider layer |
| Phase 6 | Phase 3, 4, 5 | Sync needs all data types; testing needs all features |
