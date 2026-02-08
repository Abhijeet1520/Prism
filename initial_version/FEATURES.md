# Prism Feature Availability

> This document is used by the AI to understand what it can and cannot do.
> Update this file whenever features are added or their status changes.

## Legend
- ✅ Available — Fully functional
- 🎨 Preview — Works with sample data
- 🔧 Partial — Some parts working
- 📋 Planned — Designed, not built
- ❌ Unavailable — Not started

## v0.1 — UX Preview (Current)

| Feature | Status | Notes |
|---------|--------|-------|
| Daily Digest Home | 🎨 | Weather, tasks, events, finance cards — mock data |
| Soul Orb Animation | ✅ | Animated organic orb on home screen |
| AI Chat | 🎨 | Simulated responses, no real AI |
| Brain (Knowledge Base) | 🎨 | Sample docs, notes, snippets |
| Task Management | 🎨 | Sample tasks with categories |
| Finance Tracker | 🎨 | Sample transactions and budgets |
| Files Manager | 🎨 | Sample file listings |
| Apps Hub | 🎨 | Navigation to all app modules |
| Theme System | ✅ | 7 accent presets, AMOLED, font scale |
| Splash Screen | ✅ | Animated Prism logo, data preload |
| Settings | ✅ | 7 sections, theme controls work |
| Navigation | ✅ | 5-tab mobile + desktop sidebar |
| Tool System | 🔧 | Registry + mock execution |
| Feature Gate UI | ✅ | Status banners for unavailable features |

## v0.2 — Initial Version (Next)

| Feature | Status | Notes |
|---------|--------|-------|
| Local Model (llama.cpp) | 📋 | On-device inference via llama_sdk |
| Ollama Integration | 📋 | Connect to local Ollama server |
| Cloud APIs | 📋 | OpenAI, Gemini, Anthropic |
| Model Download | 📋 | Dio + progress + hash verification |
| Real Tool Execution | 📋 | AI function calling |
| Local Database | 📋 | Drift/Hive for persistent storage |
| E2E Encryption | 📋 | Encrypt local data at rest |

## v0.3 — Voice & Intelligence

| Feature | Status | Notes |
|---------|--------|-------|
| Voice Input (STT) | 📋 | On-device speech recognition |
| Voice Output (TTS) | 📋 | On-device text-to-speech |
| RAG | 📋 | AI grounded in Brain documents |
| Smart Suggestions | 📋 | Proactive AI recommendations |

## v0.4 — Integrations

| Feature | Status | Notes |
|---------|--------|-------|
| Calendar Sync | 📋 | Google/Apple Calendar |
| Wake Word | 📋 | "Hey Prism" activation |
| Continuous Listening | 📋 | Background voice detection |
| Notification Actions | 📋 | Reply from notification |

## v0.5+

| Feature | Status | Notes |
|---------|--------|-------|
| Home Screen Widgets | 📋 | Android/iOS widgets |
| Multi-device Sync | 📋 | Encrypted cloud sync |
| Plugin System | 📋 | Third-party extensions |

---

## How the AI Uses This

When a user asks about a feature:
1. Check this registry via `FeatureRegistry`
2. If `available` or `preview` → proceed normally
3. If `partial` → explain what works and what doesn't
4. If `planned` → show expected version + what to do instead
5. If `unavailable` → acknowledge and suggest alternatives

Example: User says "Set a reminder with voice"
→ Voice Input is `planned` for v0.3
→ Response: "Voice input is planned for v0.3. For now, you can type your reminder and I'll schedule it for you. Would you like to do that?"
