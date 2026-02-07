# Gemmie — Documentation Index

> **Gemmie** is a cross-platform AI personal assistant app that empowers users to run AI models locally or connect to cloud AI providers, manage files with enterprise-grade security, execute code in multiple languages, and interact with a fully customizable agent persona.

**Status:** Requirements Phase
**Platform:** Flutter (Android, iOS, Web, Desktop)
**Working Title:** Gemmie (subject to change)

---

## Documentation Map

| # | Document | Description |
|---|----------|-------------|
| 00 | [Project Overview](./00-PROJECT-OVERVIEW.md) | Vision, goals, tech stack, high-level architecture, and repository structure |
| 01 | [Functional Requirements](./01-FUNCTIONAL-REQUIREMENTS.md) | Complete feature specifications — chat, models, APIs, tools, storage, permissions, persona, code execution, docs/sheets |
| 02 | [Non-Functional Requirements](./02-NON-FUNCTIONAL-REQUIREMENTS.md) | Security, performance, scalability, privacy, accessibility, and reliability targets |
| 03 | [Architecture](./03-ARCHITECTURE.md) | System architecture, module breakdown, provider abstraction, plugin system, storage & diff engine design |
| 04 | [Data Models](./04-DATA-MODELS.md) | Schemas for users, conversations, models, files, permissions, persona, providers, and tools |
| 05 | [UI/UX Specification](./05-UI-UX-SPEC.md) | Screen-by-screen spec — home, chat, tools, file explorer, settings, persona editor, code editor, sheets/docs |
| 06 | [API Integration Spec](./06-API-INTEGRATION-SPEC.md) | Provider interface contracts, integration details for OpenAI, Gemini, Claude, HuggingFace, OpenRouter |
| 07 | [Security Specification](./07-SECURITY-SPEC.md) | Encryption, credential storage, code sandboxing, permission model, data flow diagrams |
| 08 | [Development Roadmap](./08-DEVELOPMENT-ROADMAP.md) | Phased delivery plan, milestones, dependencies, Gallery module porting timeline |
| 09 | [Glossary](./09-GLOSSARY.md) | Terms, abbreviations, and definitions used across all documentation |

---

## Requirements Traceability Matrix

Every user requirement is mapped to one or more functional requirements (FR), which in turn link to architecture components, data models, and UI screens.

| User Requirement | Functional Requirement(s) | Architecture Module | UI Screen(s) |
|---|---|---|---|
| Personal assistant app | FR-01 (Chat) | Chat Module | Chat Screen |
| Run AI models locally | FR-02 (Model Management) | Models Module | Model Manager |
| Connect using AI API tools | FR-03 (Cloud AI APIs) | Provider Module | Settings > Providers |
| Tools tab for AI interaction | FR-04 (Tools System) | Tools Module | Tools Tab |
| Settings with profiles & tokens | FR-05 (Settings & Profiles) | Settings Module | Settings Screen |
| Organized file storage | FR-06 (File Storage) | Storage Module | File Explorer |
| MD format data storage | FR-06 (File Storage) | Storage Module | File Viewer |
| Python code & scripts | FR-10 (Code Execution) | Execution Module | Code Editor |
| File locks & permissions | FR-08 (Permission & Locks) | Permission Engine | Permission Dialogs |
| Git-like diff system | FR-07 (Versioning & Diff) | Diff Engine | Diff Viewer |
| Sheets & docs creation | FR-11 (Sheets & Documents) | Docs Module | Sheets/Docs Editor |
| Agent personality/soul | FR-09 (Agent Persona) | Persona Module | Persona Editor |
| Cloud sync (optional) | FR-12 (Cloud Sync) | Sync Module | Settings > Sync |

---

## Conventions

- **Requirement IDs** follow the pattern `FR-XX` for functional, `NFR-XX` for non-functional
- **Priority** uses MoSCoW: **Must**, **Should**, **Could**, **Won't** (this release)
- **Status** of each requirement: `Draft` → `Reviewed` → `Approved` → `Implemented` → `Verified`
- **Cross-references** between docs use relative Markdown links
- **Diagrams** use text-based representations (Mermaid-compatible where possible)

---

## Quick Links

- **Reference Codebase:** [AI Edge Gallery](../gallery/Android/) — Android app for on-device GenAI models (Kotlin/Compose)
- **Gallery Module Porting Notes:** See [Development Roadmap § Gallery Porting](./08-DEVELOPMENT-ROADMAP.md#gallery-module-porting)
- **Contributing:** TBD once project structure is finalized
