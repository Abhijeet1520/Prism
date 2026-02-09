/// Cloud Provider Service — manages cloud AI provider configurations.
///
/// Loads provider configs from JSON, validates API keys,
/// and connects to OpenAI-compatible endpoints.
/// Supports fetching available models from providers like OpenRouter.
library;

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ai_service.dart';

// ─── Cloud Provider Config ───────────────────────────

class CloudProviderConfig {
  final String id;
  final String name;
  final String description;
  final String baseUrl;
  final String authType; // 'bearer', 'api-key', 'none'
  final String authHeader;
  final String docsUrl;
  final String signupUrl;
  final bool isDefault;
  final List<CloudModelInfo> models;

  const CloudProviderConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.baseUrl,
    this.authType = 'bearer',
    this.authHeader = 'Authorization',
    this.docsUrl = '',
    this.signupUrl = '',
    this.isDefault = false,
    this.models = const [],
  });

  CloudProviderConfig copyWith({
    List<CloudModelInfo>? models,
  }) =>
      CloudProviderConfig(
        id: id,
        name: name,
        description: description,
        baseUrl: baseUrl,
        authType: authType,
        authHeader: authHeader,
        docsUrl: docsUrl,
        signupUrl: signupUrl,
        isDefault: isDefault,
        models: models ?? this.models,
      );

  factory CloudProviderConfig.fromJson(Map<String, dynamic> json) {
    return CloudProviderConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      baseUrl: json['baseUrl'] as String? ?? '',
      authType: json['authType'] as String? ?? 'bearer',
      authHeader: json['authHeader'] as String? ?? 'Authorization',
      docsUrl: json['docsUrl'] as String? ?? '',
      signupUrl: json['signupUrl'] as String? ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
      models: (json['models'] as List<dynamic>?)
              ?.map((m) => CloudModelInfo.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class CloudModelInfo {
  final String id;
  final String name;
  final int contextWindow;
  final bool isFree;
  final String? pricing; // e.g. "$0.50/1M tokens"

  const CloudModelInfo({
    required this.id,
    required this.name,
    this.contextWindow = 4096,
    this.isFree = false,
    this.pricing,
  });

  factory CloudModelInfo.fromJson(Map<String, dynamic> json) {
    return CloudModelInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      contextWindow: json['contextWindow'] as int? ?? 4096,
      isFree: json['isFree'] as bool? ?? false,
      pricing: json['pricing'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'contextWindow': contextWindow,
        'isFree': isFree,
        'pricing': pricing,
      };
}

// ─── Saved Provider State ────────────────────────────

class SavedProviderConfig {
  final String providerId;
  final String? apiKey;
  final String? customBaseUrl;
  final bool isEnabled;
  final List<String> selectedModelIds; // user-selected models from provider

  const SavedProviderConfig({
    required this.providerId,
    this.apiKey,
    this.customBaseUrl,
    this.isEnabled = false,
    this.selectedModelIds = const [],
  });

  Map<String, dynamic> toJson() => {
        'providerId': providerId,
        'apiKey': apiKey,
        'customBaseUrl': customBaseUrl,
        'isEnabled': isEnabled,
        'selectedModelIds': selectedModelIds,
      };

  factory SavedProviderConfig.fromJson(Map<String, dynamic> json) {
    return SavedProviderConfig(
      providerId: json['providerId'] as String,
      apiKey: json['apiKey'] as String?,
      customBaseUrl: json['customBaseUrl'] as String?,
      isEnabled: json['isEnabled'] as bool? ?? false,
      selectedModelIds: (json['selectedModelIds'] as List<dynamic>?)
              ?.cast<String>() ??
          [],
    );
  }

  SavedProviderConfig copyWith({
    String? apiKey,
    String? customBaseUrl,
    bool? isEnabled,
    List<String>? selectedModelIds,
  }) =>
      SavedProviderConfig(
        providerId: providerId,
        apiKey: apiKey ?? this.apiKey,
        customBaseUrl: customBaseUrl ?? this.customBaseUrl,
        isEnabled: isEnabled ?? this.isEnabled,
        selectedModelIds: selectedModelIds ?? this.selectedModelIds,
      );
}

// ─── Cloud Provider State ────────────────────────────

class CloudProviderState {
  final List<CloudProviderConfig> providers;
  final Map<String, SavedProviderConfig> savedConfigs;
  final bool isLoaded;
  final Map<String, List<CloudModelInfo>> fetchedModels; // provider ID → fetched models
  final Map<String, bool> fetchingModels; // provider ID → loading

  const CloudProviderState({
    this.providers = const [],
    this.savedConfigs = const {},
    this.isLoaded = false,
    this.fetchedModels = const {},
    this.fetchingModels = const {},
  });

  CloudProviderState copyWith({
    List<CloudProviderConfig>? providers,
    Map<String, SavedProviderConfig>? savedConfigs,
    bool? isLoaded,
    Map<String, List<CloudModelInfo>>? fetchedModels,
    Map<String, bool>? fetchingModels,
  }) =>
      CloudProviderState(
        providers: providers ?? this.providers,
        savedConfigs: savedConfigs ?? this.savedConfigs,
        isLoaded: isLoaded ?? this.isLoaded,
        fetchedModels: fetchedModels ?? this.fetchedModels,
        fetchingModels: fetchingModels ?? this.fetchingModels,
      );
}

// ─── Cloud Provider Notifier ─────────────────────────

class CloudProviderNotifier extends Notifier<CloudProviderState> {
  @override
  CloudProviderState build() {
    _init();
    return const CloudProviderState();
  }

  Future<void> _init() async {
    await _loadProviders();
    await _loadSavedConfigs();
    await _loadSavedSelectedModels();
    _registerCloudModels();
  }

  Future<void> _loadProviders() async {
    try {
      final jsonStr =
          await rootBundle.loadString('assets/config/model_catalog.json');
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final providers = (data['cloudProviders'] as List<dynamic>?)
              ?.map((p) =>
                  CloudProviderConfig.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [];
      state = state.copyWith(providers: providers, isLoaded: true);
    } catch (e) {
      // Fallback to hardcoded defaults
      state = state.copyWith(isLoaded: true);
    }
  }

  Future<void> _loadSavedConfigs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('cloud_providers');
      if (json != null) {
        final list = (jsonDecode(json) as List)
            .map((e) =>
                SavedProviderConfig.fromJson(e as Map<String, dynamic>))
            .toList();
        final map = {for (final c in list) c.providerId: c};
        state = state.copyWith(savedConfigs: map);
      }
    } catch (_) {}
  }

  Future<void> _loadSavedSelectedModels() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('cloud_selected_models');
      if (json != null) {
        final map = (jsonDecode(json) as Map<String, dynamic>).map(
          (k, v) => MapEntry(
            k,
            (v as List)
                .map((m) =>
                    CloudModelInfo.fromJson(m as Map<String, dynamic>))
                .toList(),
          ),
        );
        state = state.copyWith(fetchedModels: map);
      }
    } catch (_) {}
  }

  Future<void> _saveSavedSelectedModels() async {
    final prefs = await SharedPreferences.getInstance();
    final map = state.fetchedModels.map(
      (k, v) => MapEntry(k, v.map((m) => m.toJson()).toList()),
    );
    await prefs.setString('cloud_selected_models', jsonEncode(map));
  }

  Future<void> _saveConfigs() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(
        state.savedConfigs.values.map((c) => c.toJson()).toList());
    await prefs.setString('cloud_providers', json);
  }

  void _registerCloudModels() {
    final aiNotifier = ref.read(aiServiceProvider.notifier);
    for (final config in state.savedConfigs.values) {
      if (!config.isEnabled || config.apiKey == null) continue;
      final provider = state.providers
          .where((p) => p.id == config.providerId)
          .firstOrNull;
      if (provider == null) continue;

      final baseUrl = config.customBaseUrl?.isNotEmpty == true
          ? config.customBaseUrl!
          : provider.baseUrl;

      // If user has selected specific models, use those; otherwise use catalog defaults
      final modelsToRegister = config.selectedModelIds.isNotEmpty
          ? _getSelectedModels(provider, config)
          : provider.models;

      for (final model in modelsToRegister) {
        aiNotifier.addModel(ModelConfig(
          id: '${provider.id}/${model.id}',
          name: '${model.name} (${provider.name})',
          provider: _providerTypeFromId(provider.id),
          baseUrl: baseUrl,
          apiKey: config.apiKey,
          contextWindow: model.contextWindow,
          supportsTools: true,
        ));
      }
    }
  }

  List<CloudModelInfo> _getSelectedModels(
      CloudProviderConfig provider, SavedProviderConfig saved) {
    // Combine catalog models + fetched models to find the selected ones
    final allModels = <String, CloudModelInfo>{};
    for (final m in provider.models) {
      allModels[m.id] = m;
    }
    final fetched = state.fetchedModels[provider.id] ?? [];
    for (final m in fetched) {
      allModels[m.id] = m;
    }
    return saved.selectedModelIds
        .where((id) => allModels.containsKey(id))
        .map((id) => allModels[id]!)
        .toList();
  }

  ProviderType _providerTypeFromId(String id) {
    return switch (id) {
      'openai' || 'openrouter' => ProviderType.openai,
      'gemini' => ProviderType.gemini,
      'anthropic' || 'mistral' => ProviderType.openai, // OpenAI-compatible
      'ollama' => ProviderType.ollama,
      _ => ProviderType.custom,
    };
  }

  /// Fetch available models from a provider (e.g. OpenRouter /api/v1/models).
  Future<List<CloudModelInfo>> fetchProviderModels(String providerId) async {
    final provider =
        state.providers.where((p) => p.id == providerId).firstOrNull;
    if (provider == null) return [];

    final saved = state.savedConfigs[providerId];
    if (saved?.apiKey == null || saved!.apiKey!.isEmpty) return [];

    final baseUrl = saved.customBaseUrl?.isNotEmpty == true
        ? saved.customBaseUrl!
        : provider.baseUrl;

    state = state.copyWith(fetchingModels: {
      ...state.fetchingModels,
      providerId: true,
    });

    try {
      final dio = Dio();
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
      };
      if (provider.authType == 'bearer') {
        headers['Authorization'] = 'Bearer ${saved.apiKey}';
      }
      // OpenRouter specific headers
      if (providerId == 'openrouter') {
        headers['HTTP-Referer'] = 'https://prism.app';
        headers['X-Title'] = 'Prism AI';
      }

      final response = await dio.get(
        '$baseUrl/models',
        options: Options(
          headers: headers,
          receiveTimeout: const Duration(seconds: 15),
        ),
      );
      dio.close();

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final models = (data['data'] as List<dynamic>?)?.map((m) {
              final map = m as Map<String, dynamic>;
              final id = map['id'] as String;
              final name = map['name'] as String? ?? id;
              final ctx = (map['context_length'] as num?)?.toInt() ?? 4096;
              // Detect free models
              final pricing = map['pricing'] as Map<String, dynamic>?;
              final promptPrice =
                  double.tryParse(pricing?['prompt']?.toString() ?? '1') ?? 1;
              final completionPrice =
                  double.tryParse(pricing?['completion']?.toString() ?? '1') ??
                      1;
              final isFree = promptPrice == 0 && completionPrice == 0;
              String? pricingLabel;
              if (!isFree && pricing != null) {
                pricingLabel =
                    '\$${(promptPrice * 1000000).toStringAsFixed(2)}/1M in, '
                    '\$${(completionPrice * 1000000).toStringAsFixed(2)}/1M out';
              }
              return CloudModelInfo(
                id: id,
                name: name,
                contextWindow: ctx,
                isFree: isFree,
                pricing: isFree ? 'Free' : pricingLabel,
              );
            }).toList() ??
            [];

        // Sort: free first, then by name
        models.sort((a, b) {
          if (a.isFree && !b.isFree) return -1;
          if (!a.isFree && b.isFree) return 1;
          return a.name.compareTo(b.name);
        });

        state = state.copyWith(
          fetchedModels: {...state.fetchedModels, providerId: models},
          fetchingModels: {...state.fetchingModels, providerId: false},
        );
        await _saveSavedSelectedModels();
        return models;
      }
    } on DioException catch (_) {
      // silently fail
    } catch (_) {
      // silently fail
    }

    state = state.copyWith(fetchingModels: {
      ...state.fetchingModels,
      providerId: false,
    });
    return [];
  }

  /// Update user's selected models for a provider.
  Future<void> updateSelectedModels(
      String providerId, List<String> modelIds) async {
    final saved = state.savedConfigs[providerId];
    if (saved == null) return;
    state = state.copyWith(savedConfigs: {
      ...state.savedConfigs,
      providerId: saved.copyWith(selectedModelIds: modelIds),
    });
    await _saveConfigs();
    _registerCloudModels();
    await _saveSavedSelectedModels();
  }

  /// Save API key and enable a cloud provider.
  Future<void> configureProvider(
    String providerId, {
    required String apiKey,
    String? customBaseUrl,
  }) async {
    final existing = state.savedConfigs[providerId];
    final saved = SavedProviderConfig(
      providerId: providerId,
      apiKey: apiKey.trim(),
      customBaseUrl: customBaseUrl?.trim(),
      isEnabled: apiKey.trim().isNotEmpty,
      selectedModelIds: existing?.selectedModelIds ?? [],
    );
    state = state.copyWith(savedConfigs: {
      ...state.savedConfigs,
      providerId: saved,
    });
    await _saveConfigs();
    _registerCloudModels();
  }

  /// Remove a cloud provider configuration.
  Future<void> removeProvider(String providerId) async {
    final configs = Map<String, SavedProviderConfig>.from(state.savedConfigs);
    configs.remove(providerId);
    state = state.copyWith(savedConfigs: configs);
    await _saveConfigs();

    // Remove associated models from AI service
    final aiNotifier = ref.read(aiServiceProvider.notifier);
    final provider =
        state.providers.where((p) => p.id == providerId).firstOrNull;
    if (provider != null) {
      for (final model in provider.models) {
        aiNotifier.removeModel('${provider.id}/${model.id}');
      }
    }
  }

  /// Validate API key by making a test request.
  Future<(bool, String)> validateApiKey(
    String providerId,
    String apiKey, {
    String? customBaseUrl,
  }) async {
    final provider =
        state.providers.where((p) => p.id == providerId).firstOrNull;
    if (provider == null) return (false, 'Unknown provider');

    final baseUrl = customBaseUrl?.isNotEmpty == true
        ? customBaseUrl!
        : provider.baseUrl;

    if (baseUrl.isEmpty) return (false, 'No base URL configured');

    try {
      final dio = Dio();
      final headers = <String, dynamic>{};

      if (provider.authType == 'bearer') {
        headers['Authorization'] = 'Bearer $apiKey';
      } else if (provider.authType == 'api-key') {
        headers[provider.authHeader] = apiKey;
      }

      final response = await dio.get(
        '$baseUrl/models',
        options: Options(
          headers: headers,
          validateStatus: (s) => s != null && s < 500,
        ),
      );

      if (response.statusCode == 200) {
        return (true, 'Connected successfully!');
      } else if (response.statusCode == 401 ||
          response.statusCode == 403) {
        return (false, 'Invalid API key');
      } else {
        return (false, 'HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        return (false, 'Cannot reach server');
      }
      return (false, e.message ?? 'Connection failed');
    } catch (e) {
      return (false, e.toString());
    }
  }

  /// Get masked API key for display.
  String getMaskedKey(String providerId) {
    final config = state.savedConfigs[providerId];
    if (config?.apiKey == null || config!.apiKey!.isEmpty) return '';
    final key = config.apiKey!;
    if (key.length <= 8) return '●' * key.length;
    return '${key.substring(0, 4)}${'●' * 8}${key.substring(key.length - 4)}';
  }
}

// ─── Riverpod Provider ───────────────────────────────

final cloudProviderProvider =
    NotifierProvider<CloudProviderNotifier, CloudProviderState>(
  CloudProviderNotifier.new,
);
