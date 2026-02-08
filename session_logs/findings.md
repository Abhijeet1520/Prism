# Research Findings

> Key discoveries, package evaluations, and technical decisions made during sessions.

---

## 2026-02-09

### Gallery App Splash Screen
- Uses Android SplashScreen API with animated vector drawable
- 4 colored shapes (Google brand colors) that scale-in, rotate, and fade out
- Total animation: ~2.6s + 300ms crossfade = ~3 seconds
- Background: white (light) / #131314 (dark)
- While splash shows: pre-loads model allowlist
- **Decision**: We'll create a Flutter-native splash with animated Prism logo (not Android-specific AVD)

### Maid Local Model Architecture
- Uses `llama_sdk: ^0.0.5` (llama.cpp FFI wrapper) for GGUF inference
- Abstract `AIController` hierarchy → `LlamaCppController` (local) + `RemoteAIController` (cloud)
- `ValueNotifier<AIController?>` singleton for global state
- Curated model catalog in YAML (`huggingface.yaml`) with quantization tags
- Download via Dio to app cache with `Stream<double>` progress
- Hash-based reload guard (only reinstantiate when model/params change)
- `.gguf` extension assertion on load
- Conditional web/native imports
- **Decision**: Adopt controller pattern + YAML catalog approach. Start with Ollama support, add llama_sdk later.

### Key Packages to Use
| Package | Purpose | Status |
|---------|---------|--------|
| `ollama_dart` | Local Ollama inference | Primary for v1 |
| `llama_sdk` | Direct GGUF via FFI | Future (needs native build) |
| `dio` | HTTP downloads, API calls | Add for model downloads |
| `file_picker` | GGUF file selection | Add for local model import |
| `path_provider` | App directories | Add |
| `speech_to_text` | Voice input | Evaluate |
| `flutter_tts` | Text-to-speech for AI responses | Evaluate |
| `shared_preferences` | Settings persistence | Add |
| `flutter_animate` | Smooth animations | Add for splash + orb |

### Moon Design Token Reference (from ux_preview)
```
piccolo  = #818CF8  (accent/primary)
goten    = #16162A  (surface/cards)
gohan    = #0C0C16  (scaffold bg)
bulma    = #E2E2EC  (text primary)
trunks   = #7A7A90  (text secondary)
beerus   = #252540  (border)
goku     = #060610  (deepest bg)
```
