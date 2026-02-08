# Prism — Project Overview

> **Prism: The central hub for your intelligence.**

## 1 Purpose

Prism is an open-source, privacy-first AI personal assistant application built with Flutter. It combines local on-device inference with cloud AI providers through a unified interface, enabling users to manage conversations, files, tasks, finances, and knowledge — all orchestrated by AI.

Prism is designed to be the **single intelligent hub** that users interact with daily — a "Second Brain" powered by AI that grows with them.

## 2 Vision

- **Privacy-first**: On-device inference via llama.cpp (GGUF models) with optional cloud provider fallback.
- **Provider-agnostic**: Unified abstraction over Ollama, OpenAI, Google Gemini, Anthropic Claude, Mistral, and any OpenAI-compatible endpoint via LangChain.dart.
- **Extensible**: Model Context Protocol (MCP) support for tool integration. Skillset system for community-contributed AI capabilities.
- **AI Gateway**: Local HTTP server (shelf) exposing OpenAI-compatible API endpoints, allowing other apps on the device to use Prism's AI capabilities.
- **Second Brain**: PARA-method knowledge management (Projects, Areas, Resources, Archives) with AI-assisted organization.
- **Cross-platform**: Android (primary), Desktop (Windows/Linux/macOS secondary), Web (tertiary).

## 3 Core Capabilities

| Capability | Description |
|---|---|
| **Multi-Provider Chat** | Conversations with local and cloud AI models, branching threads, persona system |
| **File Management** | Markdown-first file storage with rich editing (AppFlowy Editor), code editing (re_editor), file locking |
| **Second Brain (PARA)** | AI-organized knowledge base using Projects / Areas / Resources / Archives methodology |
| **Task Management** | Smart tasks with AI prioritization, deadlines, recurring tasks, and contextual suggestions |
| **Financial Tracker** | Automatic transaction logging via notification listening, AI categorization, budget insights |
| **Tools & MCP** | Extensible tool system with MCP host/client support for external tool servers |
| **Skillsets** | Community-contributed AI skill packages (prompt templates, tool chains, workflows) |
| **AI Gateway** | Local HTTP API server for other apps to consume Prism's AI capabilities |
| **Smart Notifications** | Contextual motivation, procrastination detection, checklist reminders |
| **Code Execution** | Remote execution (primary), QuickJS (mobile local), Docker (desktop local) |
| **GitHub Integration** | Repository browsing, issue management, PR workflows via github package |
| **Browser Automation** | Web scraping and automation via Firecrawl REST API and Puppeteer (desktop) |

## 4 Tech Stack Summary

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.x / Dart 3.x |
| **State Management** | Riverpod 2.x |
| **Navigation** | GoRouter |
| **UI Library** | moon_design (1.1.0) — Moon Design System, themable widgets with squircle borders |
| **Database** | Drift 2.x (SQLite) — reactive queries, type-safe, web support |
| **Local Inference** | llama_cpp_dart (FFI bindings for llama.cpp, GGUF models) |
| **Provider Abstraction** | LangChain.dart (langchain_core, langchain_openai, langchain_google, langchain_ollama, langchain_mistralai) |
| **OpenAI Client** | dart_openai (custom baseUrl for local models) |
| **MCP** | mcp_dart (Model Context Protocol SDK) |
| **Code Editor** | re_editor (100+ languages, code folding, web support) |
| **Rich Text Editor** | appflowy_editor (Notion-style block editor) |
| **GitHub** | github package (REST API v3) |
| **HTTP Server** | shelf + shelf_router (AI Gateway) |
| **Notifications** | notification_listener_service (Android only) |
| **ML Kit** | google_mlkit_genai_summarization (on-device summarization, Android) |
| **Web Scraping** | Puppeteer (desktop), Firecrawl REST API |
| **Cloud Sync** | Supabase Cloud |
| **CI/CD** | GitHub Actions |
| **Distribution** | GitHub Releases, F-Droid |
| **License** | AGPL (open source) |

## 5 Target Users

| Persona | Description |
|---|---|
| **Power User** | Developers and tech enthusiasts who want full control over AI models and tools |
| **Knowledge Worker** | Professionals managing tasks, notes, and projects who want AI assistance |
| **Privacy-Conscious User** | Users who prefer local inference and on-device data storage |
| **Tinkerer** | Users who want to extend Prism with custom skillsets, MCP tools, and integrations |

## 6 Key Design Principles

1. **Offline-first** — Core features work without internet via local models and Drift/SQLite.
2. **Progressive enhancement** — Cloud features layer on top of a fully functional local experience.
3. **Convention over configuration** — Sensible defaults that work out of the box, deep customization available.
4. **Composable architecture** — Features are modular; users enable what they need.
5. **AI-native UX** — AI is woven into every feature, not bolted on as an afterthought.

## 7 Document Index

| # | Document | Description |
|---|---|---|
| 00 | Project Overview | This document |
| 01 | [Functional Requirements](01-FUNCTIONAL-REQUIREMENTS.md) | Feature specifications |
| 02 | [Non-Functional Requirements](02-NON-FUNCTIONAL-REQUIREMENTS.md) | Performance, security, scalability |
| 03 | [Architecture](03-ARCHITECTURE.md) | System design and module structure |
| 04 | [Data Models](04-DATA-MODELS.md) | Drift schemas and data structures |
| 05 | [UI/UX Specification](05-UI-UX-SPEC.md) | Moon Design component mapping |
| 06 | [API Integration](06-API-INTEGRATION-SPEC.md) | Provider APIs and MCP protocol |
| 07 | [Security Specification](07-SECURITY-SPEC.md) | Encryption, auth, sandboxing |
| 08 | [Development Roadmap](08-DEVELOPMENT-ROADMAP.md) | Phased delivery plan |
| 09 | [Glossary](09-GLOSSARY.md) | Terms and definitions |
