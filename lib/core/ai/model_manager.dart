/// Prism Model Manager — download, manage, and discover local GGUF models.
///
/// Handles HuggingFace model downloads with progress tracking,
/// local model file management, and model discovery.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final bool supportsTools;
  final bool requiresAuth;

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
    this.supportsTools = false,
    this.requiresAuth = false,
  });

  String get sizeLabel {
    if (sizeBytes >= 1024 * 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(0)} MB';
  }

  String get downloadUrl =>
      'https://huggingface.co/$repo/resolve/${branch ?? 'main'}/$fileName?download=true';

  String get repoUrl => 'https://huggingface.co/$repo';
}

// ─── Download State ──────────────────────────────────

enum DownloadStatus { idle, downloading, paused, completed, error }

class ModelDownload {
  final String fileName;
  final DownloadStatus status;
  final double progress;
  final String? error;
  final String? filePath;
  final int bytesReceived;
  final int totalBytes;

  const ModelDownload({
    required this.fileName,
    this.status = DownloadStatus.idle,
    this.progress = 0.0,
    this.error,
    this.filePath,
    this.bytesReceived = 0,
    this.totalBytes = 0,
  });

  ModelDownload copyWith({
    DownloadStatus? status,
    double? progress,
    String? error,
    String? filePath,
    int? bytesReceived,
    int? totalBytes,
  }) =>
      ModelDownload(
        fileName: fileName,
        status: status ?? this.status,
        progress: progress ?? this.progress,
        error: error,
        filePath: filePath ?? this.filePath,
        bytesReceived: bytesReceived ?? this.bytesReceived,
        totalBytes: totalBytes ?? this.totalBytes,
      );

  String get progressLabel {
    if (totalBytes <= 0) return '${(progress * 100).toStringAsFixed(1)}%';
    final recvMB = bytesReceived / (1024 * 1024);
    final totalMB = totalBytes / (1024 * 1024);
    if (totalMB >= 1024) {
      return '${(recvMB / 1024).toStringAsFixed(1)} / ${(totalMB / 1024).toStringAsFixed(1)} GB';
    }
    return '${recvMB.toStringAsFixed(0)} / ${totalMB.toStringAsFixed(0)} MB';
  }
}

// ─── Model Manager State ─────────────────────────────

class ModelManagerState {
  final List<String> localModelPaths;
  final Map<String, ModelDownload> activeDownloads;
  final bool isScanning;
  final String? hfToken;

  const ModelManagerState({
    this.localModelPaths = const [],
    this.activeDownloads = const {},
    this.isScanning = false,
    this.hfToken,
  });

  ModelManagerState copyWith({
    List<String>? localModelPaths,
    Map<String, ModelDownload>? activeDownloads,
    bool? isScanning,
    String? hfToken,
    bool clearToken = false,
  }) =>
      ModelManagerState(
        localModelPaths: localModelPaths ?? this.localModelPaths,
        activeDownloads: activeDownloads ?? this.activeDownloads,
        isScanning: isScanning ?? this.isScanning,
        hfToken: clearToken ? null : (hfToken ?? this.hfToken),
      );

  bool get hasToken => hfToken != null && hfToken!.trim().isNotEmpty;
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
    _init();
    return const ModelManagerState();
  }

  Future<void> _init() async {
    await _loadHfToken();
    await scanLocalModels();
  }

  // ─── HuggingFace Token ─────────────────────────────

  Future<void> _loadHfToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('hf_token');
    if (token != null && token.isNotEmpty) {
      state = state.copyWith(hfToken: token);
    }
  }

  Future<void> setHfToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token.trim().isEmpty) {
      await prefs.remove('hf_token');
      state = state.copyWith(clearToken: true);
    } else {
      await prefs.setString('hf_token', token.trim());
      state = state.copyWith(hfToken: token.trim());
    }
  }

  // ─── Model Scanning ───────────────────────────────

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

  // ─── Model Download ────────────────────────────────

  /// Download a model from HuggingFace. Call this after user confirms.
  Future<void> downloadModel(ModelCatalogEntry entry) async {
    // Check if already downloading
    if (_cancelTokens.containsKey(entry.fileName)) return;

    final dir = await _modelsDirectory();
    final filePath = p.join(dir.path, entry.fileName);
    final cancelToken = CancelToken();
    _cancelTokens[entry.fileName] = cancelToken;

    // Set initial downloading state
    _updateDownload(entry.fileName, ModelDownload(
      fileName: entry.fileName,
      status: DownloadStatus.downloading,
      totalBytes: entry.sizeBytes,
    ));

    try {
      final url = entry.downloadUrl;
      final headers = <String, dynamic>{};

      // Add auth token if available (needed for gated models)
      if (state.hasToken) {
        headers['Authorization'] = 'Bearer ${state.hfToken}';
      }

      await _dio.download(
        url,
        filePath,
        cancelToken: cancelToken,
        options: Options(headers: headers, followRedirects: true),
        onReceiveProgress: (received, total) {
          if (total <= 0) total = entry.sizeBytes;
          final progress = received / total;
          _updateDownload(entry.fileName,
              state.activeDownloads[entry.fileName]!.copyWith(
                progress: progress.clamp(0.0, 1.0),
                bytesReceived: received,
                totalBytes: total,
              ));
        },
      );

      // Verify file exists and has reasonable size
      final file = File(filePath);
      if (!await file.exists() || await file.length() < 1024 * 1024) {
        throw Exception('Downloaded file is too small or missing — '
            'the model may require authentication. '
            'Set your HuggingFace token and try again.');
      }

      // Success!
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
            supportsTools: entry.supportsTools,
          ));
    } on DioException catch (e) {
      // Clean up partial file
      try {
        final file = File(filePath);
        if (await file.exists()) await file.delete();
      } catch (_) {}

      if (e.type == DioExceptionType.cancel) {
        _updateDownload(entry.fileName,
            state.activeDownloads[entry.fileName]!.copyWith(
              status: DownloadStatus.idle,
              progress: 0,
            ));
      } else {
        String errorMsg = 'Download failed';
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
          errorMsg = 'Access denied — this model may be gated. '
              'Set a valid HuggingFace token with access to this repo.';
        } else if (e.response?.statusCode == 404) {
          errorMsg = 'Model file not found on HuggingFace.';
        } else if (e.type == DioExceptionType.connectionError) {
          errorMsg = 'No internet connection.';
        } else {
          errorMsg = e.message ?? 'Download failed: ${e.type}';
        }
        _updateDownload(entry.fileName,
            state.activeDownloads[entry.fileName]!.copyWith(
              status: DownloadStatus.error,
              error: errorMsg,
            ));
      }
    } catch (e) {
      // Clean up partial file
      try {
        final file = File(filePath);
        if (await file.exists()) await file.delete();
      } catch (_) {}

      _updateDownload(entry.fileName,
          state.activeDownloads[entry.fileName]!.copyWith(
            status: DownloadStatus.error,
            error: e.toString(),
          ));
    } finally {
      _cancelTokens.remove(entry.fileName);
    }
  }

  void _updateDownload(String fileName, ModelDownload download) {
    state = state.copyWith(
      activeDownloads: {...state.activeDownloads, fileName: download},
    );
  }

  /// Cancel an active download.
  void cancelDownload(String fileName) {
    _cancelTokens[fileName]?.cancel();
    _cancelTokens.remove(fileName);
  }

  /// Clear error state for a download.
  void clearDownloadError(String fileName) {
    final downloads = Map<String, ModelDownload>.from(state.activeDownloads);
    downloads.remove(fileName);
    state = state.copyWith(activeDownloads: downloads);
  }

  // ─── File Management ───────────────────────────────

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
          state.localModelPaths.where((path) => path != filePath).toList(),
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

  // ─── Custom HuggingFace Model Download ─────────────

  /// Fetch model info from HuggingFace API.
  /// Returns a map with 'id', 'modelId', 'siblings' (list of files), 'gguf' (if available), etc.
  Future<HuggingFaceModelInfo?> fetchHuggingFaceModelInfo(String repo) async {
    try {
      final url = 'https://huggingface.co/api/models/$repo';
      final headers = <String, dynamic>{};
      if (state.hasToken) {
        headers['Authorization'] = 'Bearer ${state.hfToken}';
      }

      final response = await _dio.get(
        url,
        options: Options(
          headers: headers,
          validateStatus: (s) => s != null && s < 500,
        ),
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Access denied — model may be gated. Set a HuggingFace token.');
      }
      if (response.statusCode == 404) {
        throw Exception('Model not found: $repo');
      }
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch model info (${response.statusCode})');
      }

      final data = response.data as Map<String, dynamic>;
      return HuggingFaceModelInfo.fromJson(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection');
      }
      throw Exception('Failed to fetch model info: ${e.message}');
    }
  }

  /// Download a custom model from HuggingFace.
  /// Unlike `downloadModel`, this takes a repo string and fileName directly.
  Future<void> downloadCustomModel({
    required String repo,
    required String fileName,
    String? modelName,
    int? sizeBytes,
    int contextWindow = 4096,
    bool supportsTools = false,
    bool supportsVision = false,
  }) async {
    // Construct a temporary catalog entry for the download
    final entry = ModelCatalogEntry(
      name: modelName ?? p.basenameWithoutExtension(fileName),
      repo: repo,
      fileName: fileName,
      sizeBytes: sizeBytes ?? 0,
      description: 'Custom model from $repo',
      contextWindow: contextWindow,
      supportsTools: supportsTools,
      supportsVision: supportsVision,
    );

    // Use existing download logic
    await downloadModel(entry);
  }
}

// ─── HuggingFace Model Info ──────────────────────────

/// Parsed HuggingFace model info from API.
class HuggingFaceModelInfo {
  final String id;
  final String modelId;
  final String? author;
  final int downloads;
  final int likes;
  final List<String> tags;
  final List<HuggingFaceFile> siblings;
  final int? contextLength;
  final String? architecture;
  final bool isPrivate;
  final bool isGated;

  const HuggingFaceModelInfo({
    required this.id,
    required this.modelId,
    this.author,
    required this.downloads,
    required this.likes,
    required this.tags,
    required this.siblings,
    this.contextLength,
    this.architecture,
    this.isPrivate = false,
    this.isGated = false,
  });

  factory HuggingFaceModelInfo.fromJson(Map<String, dynamic> json) {
    final siblings = (json['siblings'] as List<dynamic>? ?? [])
        .map((s) => HuggingFaceFile.fromJson(s as Map<String, dynamic>))
        .toList();

    // Extract context length from gguf info if available
    int? contextLen;
    if (json['gguf'] != null && json['gguf']['context_length'] != null) {
      contextLen = json['gguf']['context_length'] as int?;
    }

    // Extract architecture from gguf info
    String? arch;
    if (json['gguf'] != null && json['gguf']['architecture'] != null) {
      arch = json['gguf']['architecture'] as String?;
    }

    return HuggingFaceModelInfo(
      id: json['_id'] as String? ?? '',
      modelId: json['modelId'] as String? ?? json['id'] as String? ?? '',
      author: json['author'] as String?,
      downloads: json['downloads'] as int? ?? 0,
      likes: json['likes'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>? ?? []).cast<String>(),
      siblings: siblings,
      contextLength: contextLen,
      architecture: arch,
      isPrivate: json['private'] as bool? ?? false,
      isGated: json['gated'] != null && json['gated'] != false,
    );
  }

  /// Get all GGUF files from siblings.
  List<HuggingFaceFile> get ggufFiles =>
      siblings.where((f) => f.isGguf).toList();

  /// Check if this repo has any GGUF files.
  bool get hasGgufFiles => ggufFiles.isNotEmpty;

  /// Get a human-readable context length string.
  String get contextLengthLabel {
    if (contextLength == null) return 'Unknown';
    if (contextLength! >= 1000000) {
      return '${(contextLength! / 1000000).toStringAsFixed(1)}M';
    }
    if (contextLength! >= 1000) {
      return '${(contextLength! / 1000).toStringAsFixed(0)}K';
    }
    return contextLength.toString();
  }
}

/// A file in a HuggingFace repo's siblings list.
class HuggingFaceFile {
  final String filename;
  final int? size; // May not always be present

  const HuggingFaceFile({required this.filename, this.size});

  factory HuggingFaceFile.fromJson(Map<String, dynamic> json) {
    return HuggingFaceFile(
      filename: json['rfilename'] as String? ?? '',
      size: json['size'] as int?,
    );
  }

  bool get isGguf => filename.toLowerCase().endsWith('.gguf');

  /// Get quantization level from filename (e.g., 'Q4_K_M', 'Q8_0').
  String? get quantization {
    final match = RegExp(r'[_-](Q\d+[_\w]*|IQ\d+[_\w]*|F\d+|BF\d+)\.gguf', caseSensitive: false)
        .firstMatch(filename);
    return match?.group(1)?.toUpperCase();
  }

  /// Get a human-readable size label.
  String get sizeLabel {
    if (size == null) return 'Unknown size';
    if (size! >= 1024 * 1024 * 1024) {
      return '${(size! / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
    return '${(size! / (1024 * 1024)).toStringAsFixed(0)} MB';
  }
}

// ─── Model Catalog Loader ────────────────────────────

/// Loads model catalog from assets/config/model_catalog.json.
/// Falls back to an empty list if loading fails.
Future<List<ModelCatalogEntry>> loadModelCatalog() async {
  try {
    final jsonStr = await rootBundle.loadString('assets/config/model_catalog.json');
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    final models = data['models'] as List<dynamic>? ?? [];
    return models.map((m) {
      final map = m as Map<String, dynamic>;
      return ModelCatalogEntry(
        name: map['name'] as String,
        repo: map['repo'] as String,
        fileName: map['fileName'] as String,
        branch: map['branch'] as String? ?? 'main',
        sizeBytes: map['sizeBytes'] as int,
        description: map['description'] as String,
        category: map['category'] as String? ?? 'general',
        contextWindow: map['contextWindow'] as int? ?? 4096,
        supportsVision: map['supportsVision'] as bool? ?? false,
        supportsTools: map['supportsTools'] as bool? ?? false,
        requiresAuth: map['requiresAuth'] as bool? ?? false,
      );
    }).toList();
  } catch (_) {
    return _fallbackCatalog;
  }
}

/// Fallback catalog in case JSON loading fails.
const _fallbackCatalog = <ModelCatalogEntry>[
  ModelCatalogEntry(
    name: 'TinyLlama 1.1B',
    repo: 'TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF',
    fileName: 'tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf',
    sizeBytes: 670 * 1024 * 1024,
    description: 'Ultra-compact. Fastest inference on any device.',
    category: 'small',
    contextWindow: 2048,
  ),
  ModelCatalogEntry(
    name: 'Gemma 3 1B',
    repo: 'unsloth/gemma-3-1b-it-GGUF',
    fileName: 'gemma-3-1b-it-Q4_K_M.gguf',
    sizeBytes: 800 * 1024 * 1024,
    description: 'Compact and fast. Great for basic chat and tasks.',
    category: 'small',
    contextWindow: 8192,
  ),
];

/// Riverpod provider that loads the catalog asynchronously.
final modelCatalogProvider = FutureProvider<List<ModelCatalogEntry>>((ref) {
  return loadModelCatalog();
});

// ─── Riverpod Provider ───────────────────────────────

final modelManagerProvider =
    NotifierProvider<ModelManagerNotifier, ModelManagerState>(
  ModelManagerNotifier.new,
);
