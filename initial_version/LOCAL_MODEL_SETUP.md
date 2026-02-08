# Local Model Setup Guide

## Prerequisites

- Android device with 4GB+ RAM (for 4B parameter models)
- ~3GB storage per model
- Android 8.0+ (API 26+)

## Supported Models

| Model | Size | RAM Needed | Quality |
|-------|------|-----------|---------|
| Gemma 3 4B Q4 | 2.5 GB | 4 GB | Good for general tasks |
| Llama 3.2 3B Q4 | 2.0 GB | 3 GB | Fast, good reasoning |
| Phi-4 Mini 3.8B Q4 | 2.3 GB | 4 GB | Strong coding/math |

## How It Will Work (v0.2)

### 1. Package Setup
```yaml
# pubspec.yaml additions for v0.2
dependencies:
  llama_sdk: ^0.0.5          # llama.cpp FFI for on-device inference
  ollama_dart: ^0.2.2        # Ollama API (if running local server)
  dio: ^5.7.0                # Model download with progress
  path_provider: ^2.1.5      # App documents directory
  crypto: ^3.0.5             # SHA-256 hash verification
```

### 2. Download Flow
```dart
// Simplified from Maid's implementation
class ModelDownloader {
  final Dio _dio = Dio();

  Stream<double> download(String url, String savePath) async* {
    await _dio.download(
      url,
      savePath,
      onReceiveProgress: (received, total) {
        if (total > 0) yield received / total;
      },
    );
  }
}
```

### 3. Loading
```dart
// Simplified from Maid's LlamaCppController
import 'package:llama_sdk/llama_sdk.dart';

class LlamaController extends AIController {
  LlamaProcessor? _processor;

  Future<void> loadModel(String modelPath) async {
    _processor = LlamaProcessor(
      modelPath: modelPath,
      contextSize: 8192,
      gpuLayers: 0,  // CPU-only for compatibility
    );
    await _processor!.init();
  }
}
```

### 4. Inference
```dart
Future<String> generate(List<AIMessage> messages) async {
  final prompt = formatChatPrompt(messages);  // Apply chat template
  final result = await _processor!.generate(
    prompt,
    maxTokens: 512,
    temperature: 0.7,
    topP: 0.9,
  );
  return result;
}
```

## Ollama Alternative

If you have Ollama running on your PC, Prism can connect to it over your local network:

1. Install Ollama: https://ollama.com
2. Pull a model: `ollama pull gemma3:4b`
3. Start with network access: `OLLAMA_HOST=0.0.0.0 ollama serve`
4. In Prism: Settings → AI Providers → Ollama → Enter your PC's IP

## Cloud Fallback

For devices that can't run local models:
- Settings → AI Providers → Enable OpenAI/Gemini/Anthropic
- Enter API key
- Select model
- All data still stored locally; only chat messages sent to API

## Current Status

**v0.1 (Current)**: Mock AI responses — all interactions are simulated.
**v0.2 (Next)**: Real local model loading + Ollama + cloud APIs.
**v0.3 (Future)**: Voice input/output, RAG with Brain documents.
