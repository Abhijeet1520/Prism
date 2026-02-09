/// Prism Model Manager — download, manage, and discover local GGUF models.
///
/// Handles HuggingFace model downloads with progress tracking,
/// local model file management, and model discovery.
library;

import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';

import 'ai_service.dart';

// ─── Model Catalog Entry ─────────────────────────────

class ModelCatalogEntry {
  final String name;
  final String repo;
  final String fileName;
  final String? branch;
  final int sizeBytes;
  final String description;
  final String category; // 'general', 'code', 'vision', 'small'
  final int contextWindow;
  final bool supportsVision;

  const ModelCatalogEntry({
    required this.name,
    required this.repo,
    required this.fileName,
    this.branch = 'main',
    required this.sizeBytes,
    required this.description,
    this.category = 'general',
    this.contextWindow = 4096,
    this.supportsVision = false,
  });

  String get sizeLabel {
    if (sizeBytes >= 1024 * 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(0)} MB';
  }
}

// ─── Download State ──────────────────────────────────

enum DownloadStatus { idle, downloading, paused, completed, error }

class ModelDownload {
  final String fileName;
  final DownloadStatus status;
  final double progress;
  final String? error;
  final String? filePath;

  const ModelDownload({
    required this.fileName,
    this.status = DownloadStatus.idle,
    this.progress = 0.0,
    this.error,
    this.filePath,
  });

  ModelDownload copyWith({
    DownloadStatus? status,
    double? progress,
    String? error,
    String? filePath,
  }) =>
      ModelDownload(
        fileName: fileName,
        status: status ?? this.status,
        progress: progress ?? this.progress,
        error: error,
        filePath: filePath ?? this.filePath,
      );
}

// ─── Model Manager State ─────────────────────────────

class ModelManagerState {
  final List<String> localModelPaths;
  final Map<String, ModelDownload> activeDownloads;
  final bool isScanning;

  const ModelManagerState({
    this.localModelPaths = const [],
    this.activeDownloads = const {},
    this.isScanning = false,
  });

  ModelManagerState copyWith({
    List<String>? localModelPaths,
    Map<String, ModelDownload>? activeDownloads,
    bool? isScanning,
  }) =>
      ModelManagerState(
        localModelPaths: localModelPaths ?? this.localModelPaths,
        activeDownloads: activeDownloads ?? this.activeDownloads,
        isScanning: isScanning ?? this.isScanning,
      );
}

// ─── Model Manager Notifier ──────────────────────────

class ModelManagerNotifier extends Notifier<ModelManagerState> {
  final _dio = Dio();
  final _cancelTokens = <String, CancelToken>{};

  @override
  ModelManagerState build() {
    ref.onDispose(() {
      for (final token in _cancelTokens.values) {
        token.cancel();
      }
    });
    scanLocalModels();
    return const ModelManagerState();
  }

  /// Scan app directory for existing GGUF model files.
  Future<void> scanLocalModels() async {
    state = state.copyWith(isScanning: true);
    try {
      final dir = await _modelsDirectory();
      if (await dir.exists()) {
        final files = await dir
            .list()
            .where((e) => e.path.endsWith('.gguf'))
            .map((e) => e.path)
            .toList();
        state = state.copyWith(localModelPaths: files);
      }
    } catch (_) {}
    state = state.copyWith(isScanning: false);
  }

  /// Get the models storage directory.
  Future<Directory> _modelsDirectory() async {
    final appDir = await getApplicationSupportDirectory();
    final modelsDir = Directory(p.join(appDir.path, 'models'));
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }
    return modelsDir;
  }

  /// Download a model from HuggingFace.
  Stream<double> downloadModel(ModelCatalogEntry entry) async* {
    final dir = await _modelsDirectory();
    final filePath = p.join(dir.path, entry.fileName);
    final cancelToken = CancelToken();
    _cancelTokens[entry.fileName] = cancelToken;

    state = state.copyWith(
      activeDownloads: {
        ...state.activeDownloads,
        entry.fileName: ModelDownload(
          fileName: entry.fileName,
          status: DownloadStatus.downloading,
        ),
      },
    );

    try {
      final url =
          'https://huggingface.co/${entry.repo}/resolve/${entry.branch}/${entry.fileName}?download=true';

      await _dio.download(
        url,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total <= 0) return;
          final progress = received / total;
          state = state.copyWith(
            activeDownloads: {
              ...state.activeDownloads,
              entry.fileName: state.activeDownloads[entry.fileName]!.copyWith(
                progress: progress,
              ),
            },
          );
        },
      );

      state = state.copyWith(
        localModelPaths: [...state.localModelPaths, filePath],
        activeDownloads: {
          ...state.activeDownloads,
          entry.fileName: state.activeDownloads[entry.fileName]!.copyWith(
            status: DownloadStatus.completed,
            progress: 1.0,
            filePath: filePath,
          ),
        },
      );

      // Register with AI service
      ref.read(aiServiceProvider.notifier).addModel(ModelConfig(
            id: p.basenameWithoutExtension(entry.fileName),
            name: entry.name,
            provider: ProviderType.local,
            filePath: filePath,
            contextWindow: entry.contextWindow,
            supportsVision: entry.supportsVision,
          ));

      yield 1.0;
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        state = state.copyWith(
          activeDownloads: {
            ...state.activeDownloads,
            entry.fileName: state.activeDownloads[entry.fileName]!.copyWith(
              status: DownloadStatus.paused,
            ),
          },
        );
      } else {
        state = state.copyWith(
          activeDownloads: {
            ...state.activeDownloads,
            entry.fileName: state.activeDownloads[entry.fileName]!.copyWith(
              status: DownloadStatus.error,
              error: e.toString(),
            ),
          },
        );
      }
    } finally {
      _cancelTokens.remove(entry.fileName);
    }
  }

  /// Cancel an active download.
  void cancelDownload(String fileName) {
    _cancelTokens[fileName]?.cancel();
  }

  /// Pick a local model file from device storage.
  Future<String?> pickModelFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      dialogTitle: 'Select GGUF Model File',
    );
    if (result == null || result.files.isEmpty) return null;

    final filePath = result.files.single.path;
    if (filePath == null) return null;

    // Copy to models directory if not already there
    final dir = await _modelsDirectory();
    final fileName = p.basename(filePath);
    final destPath = p.join(dir.path, fileName);

    if (filePath != destPath) {
      await File(filePath).copy(destPath);
    }

    state = state.copyWith(
      localModelPaths: [...state.localModelPaths, destPath],
    );

    // Register with AI service
    ref.read(aiServiceProvider.notifier).addModel(ModelConfig(
          id: p.basenameWithoutExtension(fileName),
          name: p.basenameWithoutExtension(fileName),
          provider: ProviderType.local,
          filePath: destPath,
        ));

    return destPath;
  }

  /// Delete a downloaded model.
  Future<void> deleteModel(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}

    state = state.copyWith(
      localModelPaths:
          state.localModelPaths.where((p) => p != filePath).toList(),
    );

    ref
        .read(aiServiceProvider.notifier)
        .removeModel(p.basenameWithoutExtension(filePath));
  }

  /// Get file size of a local model.
  Future<int> getModelSize(String filePath) async {
    try {
      return await File(filePath).length();
    } catch (_) {
      return 0;
    }
  }
}

// ─── Curated Model Catalog ───────────────────────────

const modelCatalog = <ModelCatalogEntry>[
  ModelCatalogEntry(
    name: 'Gemma 3 1B',
    repo: 'bartowski/gemma-3-1b-it-GGUF',
    fileName: 'gemma-3-1b-it-Q4_K_M.gguf',
    sizeBytes: 800 * 1024 * 1024,
    description: 'Compact and fast. Great for basic chat and tasks.',
    category: 'small',
    contextWindow: 8192,
  ),
  ModelCatalogEntry(
    name: 'Gemma 3 4B',
    repo: 'bartowski/gemma-3-4b-it-GGUF',
    fileName: 'gemma-3-4b-it-Q4_K_M.gguf',
    sizeBytes: 2700 * 1024 * 1024,
    description: 'Balanced size and quality. Good general assistant.',
    category: 'general',
    contextWindow: 8192,
  ),
  ModelCatalogEntry(
    name: 'Phi-4 Mini',
    repo: 'bartowski/phi-4-mini-instruct-GGUF',
    fileName: 'phi-4-mini-instruct-Q4_K_M.gguf',
    sizeBytes: 2500 * 1024 * 1024,
    description: 'Microsoft\'s compact model. Strong reasoning.',
    category: 'general',
    contextWindow: 4096,
  ),
  ModelCatalogEntry(
    name: 'Qwen 2.5 1.5B',
    repo: 'Qwen/Qwen2.5-1.5B-Instruct-GGUF',
    fileName: 'qwen2.5-1.5b-instruct-q4_k_m.gguf',
    sizeBytes: 1100 * 1024 * 1024,
    description: 'Efficient multilingual model from Alibaba.',
    category: 'small',
    contextWindow: 4096,
  ),
  ModelCatalogEntry(
    name: 'Llama 3.2 1B',
    repo: 'bartowski/Llama-3.2-1B-Instruct-GGUF',
    fileName: 'Llama-3.2-1B-Instruct-Q4_K_M.gguf',
    sizeBytes: 760 * 1024 * 1024,
    description: 'Meta\'s small model. Fast on mobile devices.',
    category: 'small',
    contextWindow: 4096,
  ),
  ModelCatalogEntry(
    name: 'Llama 3.2 3B',
    repo: 'bartowski/Llama-3.2-3B-Instruct-GGUF',
    fileName: 'Llama-3.2-3B-Instruct-Q4_K_M.gguf',
    sizeBytes: 2000 * 1024 * 1024,
    description: 'Meta\'s balanced model. Good for most tasks.',
    category: 'general',
    contextWindow: 4096,
  ),
  ModelCatalogEntry(
    name: 'TinyLlama 1.1B',
    repo: 'TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF',
    fileName: 'tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf',
    sizeBytes: 670 * 1024 * 1024,
    description: 'Ultra-compact. Fastest inference on any device.',
    category: 'small',
    contextWindow: 2048,
  ),
];

// ─── Riverpod Provider ───────────────────────────────

final modelManagerProvider =
    NotifierProvider<ModelManagerNotifier, ModelManagerState>(
  ModelManagerNotifier.new,
);
