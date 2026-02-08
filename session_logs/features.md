# Prism — Feature Availability

> Lists all planned features with their current status, what's working, and expected timeline.
> This file is also used by the AI to understand available capabilities.

---

## Feature Status Key
- ✅ Working — Feature is functional
- 🔧 Partial — Basic version working, improvements planned
- 🎨 UI Only — Screen exists with mock data, no backend
- ⬜ Planned — Designed but not implemented
- ❌ Not Started — No work done yet

---

## Core Features

| Feature | Status | Description | Expected |
|---------|--------|-------------|----------|
| **Chat Interface** | 🎨 UI Only | Message display, input bar, conversation list | v0.2 |
| **Streaming Responses** | ⬜ Planned | Token-by-token AI response display | v0.2 |
| **Multi-Provider Support** | ⬜ Planned | OpenAI, Gemini, Claude, Ollama, etc. | v0.3 |
| **Local Model (Ollama)** | ⬜ Planned | Connect to local Ollama instance | v0.2 |
| **Local Model (GGUF)** | ⬜ Planned | Direct llama.cpp inference via llama_sdk | v0.4 |
| **Model Download** | ⬜ Planned | Download GGUF from HuggingFace | v0.4 |

## Knowledge & Organization

| Feature | Status | Description | Expected |
|---------|--------|-------------|----------|
| **Brain (PARA)** | 🎨 UI Only | Projects, Areas, Resources, Archive | v0.3 |
| **Note Creation** | 🎨 UI Only | Create/edit markdown notes | v0.3 |
| **Search** | ⬜ Planned | Full-text search across all content | v0.4 |

## Apps Hub

| Feature | Status | Description | Expected |
|---------|--------|-------------|----------|
| **Tasks** | 🎨 UI Only | Task list with categories and priorities | v0.3 |
| **Finance** | 🎨 UI Only | Transactions, budgets, spending summary | v0.3 |
| **Files** | 🎨 UI Only | Virtual filesystem browser | v0.3 |
| **Tools** | 🎨 UI Only | Tool grid with categories | v0.3 |
| **Gateway** | 🎨 UI Only | AI API gateway management | v0.5 |

## AI Tools

| Feature | Status | Description | Expected |
|---------|--------|-------------|----------|
| **Web Search** | ⬜ Planned | Search the web via AI | v0.3 |
| **Calculator** | ⬜ Planned | Math expressions | v0.3 |
| **File Editor** | ⬜ Planned | AI reads/writes virtual files | v0.3 |
| **Finance Manager** | ⬜ Planned | AI updates finance docs | v0.3 |
| **Code Execution** | ⬜ Planned | Run Python/JS/Dart | v0.5 |
| **Composable Tools** | ⬜ Planned | Tools use other tools | v0.5 |

## Settings & Personalization

| Feature | Status | Description | Expected |
|---------|--------|-------------|----------|
| **Theme Selection** | 🔧 Partial | Dark mode works, need more presets | v0.2 |
| **AI Providers Config** | 🎨 UI Only | Add/manage provider API keys | v0.2 |
| **Persona System** | 🎨 UI Only | Agent personality configuration | v0.4 |
| **Voice Input** | ⬜ Planned | Speech-to-text for chat | v0.3 |
| **Voice Output** | ⬜ Planned | Text-to-speech for AI responses | v0.4 |

## Security

| Feature | Status | Description | Expected |
|---------|--------|-------------|----------|
| **Encryption at Rest** | ⬜ Planned | AES-256-GCM for local data | v0.4 |
| **Biometric Lock** | ⬜ Planned | Fingerprint/face unlock | v0.5 |
| **Permission System** | 🎨 UI Only | Locked/Gated/Open for AI access | v0.4 |

## Cloud & Sync

| Feature | Status | Description | Expected |
|---------|--------|-------------|----------|
| **Cloud Sync** | ⬜ Planned | E2E encrypted sync via Supabase | v0.6 |
| **Multi-Device** | ⬜ Planned | Cross-device state sync | v0.6 |

---

## Version Timeline

| Version | Target | Focus |
|---------|--------|-------|
| v0.1 | Current | UI preview with mock data |
| v0.2 | Week 2 | Chat + Ollama + theme system |
| v0.3 | Week 4 | Tools + Brain + voice input |
| v0.4 | Week 8 | Local models + encryption + persona |
| v0.5 | Week 12 | Code execution + gateway + advanced tools |
| v0.6 | Week 16 | Cloud sync + production polish |
