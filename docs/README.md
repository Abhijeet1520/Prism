# Prism

> **The central hub for your intelligence.**

Prism is an open-source, privacy-first AI personal assistant built with Flutter. It combines local on-device AI inference with cloud providers, offering a unified interface for conversations, file management, task tracking, financial insights, knowledge organization, and extensible AI tooling.

## Key Features

- **Multi-Provider AI Chat** — Local (llama.cpp) and cloud (OpenAI, Gemini, Claude, Mistral, Ollama) via LangChain.dart
- **Second Brain (PARA)** — AI-organized knowledge management with Projects, Areas, Resources, Archives
- **Financial Tracker** — Auto-logs transactions from notification listening with AI categorization
- **Smart Tasks** — AI-prioritized task management with contextual suggestions
- **MCP Support** — Model Context Protocol host/client for extensible tool integration
- **Skillsets** — Community-contributed AI capability packages
- **AI Gateway** — Local HTTP server exposing OpenAI-compatible API for other apps
- **File Management** — Markdown-first with rich editing (AppFlowy Editor) and code editing (re_editor)
- **Smart Notifications** — Motivational, anti-procrastination, and contextual reminders
- **GitHub Integration** — Repo browsing, issues, PRs
- **Browser Automation** — Firecrawl REST API and Puppeteer (desktop)

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter / Dart |
| UI | moon_design |
| State | Riverpod 2.x |
| Database | Drift (SQLite) |
| Local AI | llama_cpp_dart |
| Providers | LangChain.dart, dart_openai |
| MCP | mcp_dart |
| Cloud Sync | Supabase |

## Documentation

All project documentation is in the [`docs/`](docs/) folder:

| Document | Description |
|---|---|
| [00 — Project Overview](docs/00-PROJECT-OVERVIEW.md) | Vision, capabilities, tech stack |
| [01 — Functional Requirements](docs/01-FUNCTIONAL-REQUIREMENTS.md) | Feature specifications |
| [02 — Non-Functional Requirements](docs/02-NON-FUNCTIONAL-REQUIREMENTS.md) | Performance, security, scalability |
| [03 — Architecture](docs/03-ARCHITECTURE.md) | System design and modules |
| [04 — Data Models](docs/04-DATA-MODELS.md) | Drift schemas |
| [05 — UI/UX Specification](docs/05-UI-UX-SPEC.md) | Moon Design component mapping |
| [06 — API Integration](docs/06-API-INTEGRATION-SPEC.md) | Provider APIs, MCP, AI Gateway |
| [07 — Security Specification](docs/07-SECURITY-SPEC.md) | Encryption, auth, sandboxing |
| [08 — Development Roadmap](docs/08-DEVELOPMENT-ROADMAP.md) | Phased delivery plan |
| [09 — Glossary](docs/09-GLOSSARY.md) | Terms and definitions |

## Platform Support

| Platform | Priority | Status |
|---|---|---|
| Android | Primary | Phase 1 |
| Windows / Linux / macOS | Secondary | Phase 2 |
| Web | Tertiary | Phase 3 |

## License

AGPL — See [LICENSE](LICENSE) for details.

## Distribution

- GitHub Releases
- F-Droid
