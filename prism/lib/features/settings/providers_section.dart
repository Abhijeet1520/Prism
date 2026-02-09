/// AI Providers settings section — local models, catalog, cloud providers, gateway.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ai/ai_service.dart';
import '../../core/ai/model_manager.dart';
import '../../core/ai/ai_host_server.dart';
import '../../core/ai/cloud_provider_service.dart';
import 'cloud_provider_tile.dart';
import 'settings_shared_widgets.dart';

class ProvidersSection extends ConsumerWidget {
  final Color cardColor, borderColor, textPrimary, textSecondary, accentColor;
  const ProvidersSection(
      {super.key,
      required this.cardColor,
      required this.borderColor,
      required this.textPrimary,
      required this.textSecondary,
      required this.accentColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiState = ref.watch(aiServiceProvider);
    final notifier = ref.read(aiServiceProvider.notifier);
    final modelMgr = ref.watch(modelManagerProvider);
    final hostState = ref.watch(aiHostProvider);
    final cloudState = ref.watch(cloudProviderProvider);
    final cloudNotifier = ref.read(cloudProviderProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
            title: 'AI Providers',
            subtitle: 'Local models, cloud APIs, and gateway',
            textPrimary: textPrimary,
            textSecondary: textSecondary),

        // ── FAVOURITE MODELS ──
        GroupLabel(text: 'FAVOURITE MODELS', color: textSecondary),
        const SizedBox(height: 8),

        _FavouriteModelPicker(
          label: '⚡ Fast Model',
          description: 'Quick responses — for simple tasks and chat',
          currentModel: aiState.favouriteFastModel,
          availableModels: aiState.availableModels,
          onSelect: (m) => notifier.setFavouriteFastModel(m),
          onClear: () => notifier.setFavouriteFastModel(null),
          cardColor: cardColor,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          accentColor: accentColor,
        ),
        const SizedBox(height: 8),
        _FavouriteModelPicker(
          label: '🧠 Quality Model',
          description: 'Best results — for complex reasoning and writing',
          currentModel: aiState.favouriteGoodModel,
          availableModels: aiState.availableModels,
          onSelect: (m) => notifier.setFavouriteGoodModel(m),
          onClear: () => notifier.setFavouriteGoodModel(null),
          cardColor: cardColor,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          accentColor: accentColor,
        ),

        SettingsDivider(color: borderColor),

        // ── ACTIVE PROVIDERS ──
        GroupLabel(text: 'ENABLED PROVIDERS', color: textSecondary),
        const SizedBox(height: 8),

        _EnabledProvidersSummary(
          aiState: aiState,
          cloudState: cloudState,
          onSelectModel: notifier.selectModel,
          cardColor: cardColor,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          accentColor: accentColor,
        ),

        SettingsDivider(color: borderColor),

        // ── LOCAL MODELS ──
        GroupLabel(text: 'LOCAL MODELS', color: textSecondary),
        const SizedBox(height: 8),

        // List local models
        if (modelMgr.localModelPaths.isEmpty)
          InfoCard(
            icon: Icons.model_training_outlined,
            text: 'No local models yet. Download one from the catalog below'
                ' or import a .gguf file.',
            cardColor: cardColor,
            borderColor: borderColor,
            textSecondary: textSecondary,
            accentColor: accentColor,
          )
        else
          ...modelMgr.localModelPaths.map((path) {
            final name = path.split('/').last.split('\\').last;
            final isActive = aiState.activeModel?.filePath == path;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isActive ? accentColor : borderColor,
                    width: isActive ? 1.5 : 0.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isActive ? const Color(0xFF10B981) : textSecondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: TextStyle(
                                color: textPrimary,
                                fontWeight: FontWeight.w500,
                                fontSize: 13)),
                        Text('Local GGUF',
                            style: TextStyle(
                                color: textSecondary, fontSize: 11)),
                      ],
                    ),
                  ),
                  if (!isActive)
                    SmallButton(
                      label: 'Load',
                      color: accentColor,
                      onTap: () {
                        notifier.selectModel(ModelConfig(
                          id: name,
                          name: name,
                          provider: ProviderType.local,
                          filePath: path,
                        ));
                      },
                    ),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF10B981).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('active',
                          style: TextStyle(
                              fontSize: 10, color: Color(0xFF10B981))),
                    ),
                ],
              ),
            );
          }),

        const SizedBox(height: 8),
        Row(
          children: [
            SmallButton(
              label: 'Import .gguf',
              color: accentColor,
              onTap: () =>
                  ref.read(modelManagerProvider.notifier).pickModelFile(),
            ),
            const SizedBox(width: 8),
            SmallButton(
              label: 'Scan Models',
              color: textSecondary,
              onTap: () =>
                  ref.read(modelManagerProvider.notifier).scanLocalModels(),
            ),
          ],
        ),

        SettingsDivider(color: borderColor),

        // ── MODEL CATALOG ──
        GroupLabel(text: 'DOWNLOAD MODELS', color: textSecondary),
        const SizedBox(height: 8),

        // HuggingFace token input
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.key_rounded, size: 16, color: accentColor),
                  const SizedBox(width: 8),
                  Text('HuggingFace Token',
                      style: TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.w500,
                          fontSize: 13)),
                  const Spacer(),
                  if (modelMgr.hasToken)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF10B981).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('set',
                          style: TextStyle(
                              fontSize: 10, color: Color(0xFF10B981))),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Required for gated models. Get a free token at huggingface.co/settings/tokens',
                style: TextStyle(color: textSecondary, fontSize: 11),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 34,
                      child: TextField(
                        style: TextStyle(color: textPrimary, fontSize: 12),
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: modelMgr.hasToken
                              ? '••••••••••••'
                              : 'hf_xxxxxxxxxx',
                          hintStyle: TextStyle(
                              color:
                                  textSecondary.withValues(alpha: 0.5),
                              fontSize: 12),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 0),
                          filled: true,
                          fillColor: borderColor.withValues(alpha: 0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: borderColor, width: 0.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: borderColor, width: 0.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: accentColor, width: 1),
                          ),
                        ),
                        onSubmitted: (value) {
                          ref
                              .read(modelManagerProvider.notifier)
                              .setHfToken(value);
                        },
                      ),
                    ),
                  ),
                  if (modelMgr.hasToken) ...[
                    const SizedBox(width: 6),
                    SmallButton(
                      label: 'Clear',
                      color: const Color(0xFFEF4444),
                      onTap: () => ref
                          .read(modelManagerProvider.notifier)
                          .setHfToken(''),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        ...ref.watch(modelCatalogProvider).when(
          data: (catalog) => catalog,
          loading: () => <ModelCatalogEntry>[],
          error: (_, __) => <ModelCatalogEntry>[],
        ).map((entry) {
          final download = modelMgr.activeDownloads[entry.fileName];
          final isDownloaded = modelMgr.localModelPaths
              .any((p) => p.contains(entry.fileName));

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.name,
                              style: TextStyle(
                                  color: textPrimary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13)),
                          Text('${entry.sizeLabel} · ${entry.description}',
                              style: TextStyle(
                                  color: textSecondary, fontSize: 11)),
                        ],
                      ),
                    ),
                    if (isDownloaded)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('installed',
                            style: TextStyle(
                                fontSize: 10, color: Color(0xFF10B981))),
                      )
                    else if (download != null &&
                        download.status == DownloadStatus.downloading)
                      SmallButton(
                        label: 'Cancel',
                        color: const Color(0xFFEF4444),
                        onTap: () => ref
                            .read(modelManagerProvider.notifier)
                            .cancelDownload(entry.fileName),
                      )
                    else if (download != null &&
                        download.status == DownloadStatus.error)
                      SmallButton(
                        label: 'Retry',
                        color: const Color(0xFFF59E0B),
                        onTap: () {
                          ref
                              .read(modelManagerProvider.notifier)
                              .clearDownloadError(entry.fileName);
                          showDownloadConfirmation(context, ref, entry);
                        },
                      )
                    else
                      SmallButton(
                        label: 'Download',
                        color: accentColor,
                        onTap: () =>
                            showDownloadConfirmation(context, ref, entry),
                      ),
                  ],
                ),
                if (download != null &&
                    download.status == DownloadStatus.downloading) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: download.progress,
                      backgroundColor: borderColor,
                      color: accentColor,
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(download.progressLabel,
                      style: TextStyle(color: textSecondary, fontSize: 10)),
                ],
                if (download != null &&
                    download.status == DownloadStatus.error) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFEF4444).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            size: 14, color: Color(0xFFEF4444)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            download.error ?? 'Download failed',
                            style: const TextStyle(
                                color: Color(0xFFEF4444), fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (download != null &&
                    download.status == DownloadStatus.completed) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFF10B981).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 14, color: Color(0xFF10B981)),
                        SizedBox(width: 6),
                        Text('Downloaded and ready to use!',
                            style: TextStyle(
                                color: Color(0xFF10B981), fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        }),

        SettingsDivider(color: borderColor),

        // ── CLOUD API ──
        GroupLabel(text: 'CLOUD PROVIDERS', color: textSecondary),
        const SizedBox(height: 8),

        // Existing registered cloud models
        ...aiState.availableModels
            .where((m) =>
                m.provider != ProviderType.local &&
                m.provider != ProviderType.mock)
            .map((model) {
          final isActive = aiState.activeModel?.id == model.id;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: isActive ? accentColor : borderColor,
                  width: isActive ? 1.5 : 0.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(model.name,
                          style: TextStyle(
                              color: textPrimary,
                              fontWeight: FontWeight.w500,
                              fontSize: 13)),
                      Text(
                          '${model.provider.name} · ${model.contextWindow ~/ 1024}K',
                          style: TextStyle(
                              color: textSecondary, fontSize: 11)),
                    ],
                  ),
                ),
                if (!isActive)
                  SmallButton(
                      label: 'Select',
                      color: accentColor,
                      onTap: () => notifier.selectModel(model))
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('active',
                        style: TextStyle(
                            fontSize: 10, color: Color(0xFF10B981))),
                  ),
              ],
            ),
          );
        }),

        const SizedBox(height: 8),

        // ── CONFIGURE CLOUD PROVIDER ──
        GroupLabel(text: 'ADD / CONFIGURE PROVIDER', color: textSecondary),
        const SizedBox(height: 8),

        ...cloudState.providers.map((provider) {
          final saved = cloudState.savedConfigs[provider.id];
          final isConfigured = saved?.isEnabled == true;
          final maskedKey = cloudNotifier.getMaskedKey(provider.id);

          return CloudProviderTile(
            provider: provider,
            isConfigured: isConfigured,
            maskedKey: maskedKey,
            cardColor: cardColor,
            borderColor: borderColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            accentColor: accentColor,
          );
        }),

        if (cloudState.providers.isEmpty)
          InfoCard(
            icon: Icons.cloud_outlined,
            text: 'No cloud providers configured. Add one below by entering '
                'a provider name, base URL, and API key.',
            cardColor: cardColor,
            borderColor: borderColor,
            textSecondary: textSecondary,
            accentColor: accentColor,
          ),

        SettingsDivider(color: borderColor),

        // ── AI GATEWAY ──
        GroupLabel(text: 'AI GATEWAY', color: textSecondary),
        const SizedBox(height: 8),
        ToggleRow(
          title: 'AI Host Server',
          subtitle: 'Expose model to other apps via localhost API',
          value: hostState.isRunning,
          onChanged: (_) {
            final n = ref.read(aiHostProvider.notifier);
            hostState.isRunning ? n.stop() : n.start();
          },
          cardColor: cardColor,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          accentColor: accentColor,
        ),
        if (hostState.isRunning)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Running on localhost:${hostState.port} · ${hostState.requestCount} requests',
              style: TextStyle(color: textSecondary, fontSize: 11),
            ),
          ),
      ],
    );
  }
}

// ─── Favourite Model Picker ──────────────────────────

class _FavouriteModelPicker extends StatelessWidget {
  final String label;
  final String description;
  final ModelConfig? currentModel;
  final List<ModelConfig> availableModels;
  final ValueChanged<ModelConfig> onSelect;
  final VoidCallback onClear;
  final Color cardColor, borderColor, textPrimary, textSecondary, accentColor;

  const _FavouriteModelPicker({
    required this.label,
    required this.description,
    required this.currentModel,
    required this.availableModels,
    required this.onSelect,
    required this.onClear,
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: currentModel != null
                ? accentColor.withValues(alpha: 0.3)
                : borderColor,
            width: currentModel != null ? 1 : 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(
                    color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 2),
                Text(currentModel?.name ?? description,
                    style: TextStyle(
                        color: currentModel != null ? textPrimary : textSecondary,
                        fontSize: 11,
                        fontWeight: currentModel != null ? FontWeight.w500 : FontWeight.w400)),
              ],
            ),
          ),
          if (currentModel != null) ...[
            GestureDetector(
              onTap: onClear,
              child: Icon(Icons.close_rounded, size: 16, color: textSecondary),
            ),
            const SizedBox(width: 8),
          ],
          PopupMenuButton<ModelConfig>(
            onSelected: onSelect,
            tooltip: 'Pick model',
            icon: Icon(Icons.swap_horiz_rounded, size: 18, color: accentColor),
            color: cardColor,
            itemBuilder: (_) => availableModels
                .where((m) => m.provider != ProviderType.mock)
                .map((m) => PopupMenuItem(
                      value: m,
                      child: Text(m.name, style: TextStyle(
                          color: textPrimary, fontSize: 12)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Enabled Providers Summary ───────────────────────

class _EnabledProvidersSummary extends StatelessWidget {
  final AIServiceState aiState;
  final CloudProviderState cloudState;
  final ValueChanged<ModelConfig> onSelectModel;
  final Color cardColor, borderColor, textPrimary, textSecondary, accentColor;

  const _EnabledProvidersSummary({
    required this.aiState,
    required this.cloudState,
    required this.onSelectModel,
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final enabledProviders = cloudState.savedConfigs.entries
        .where((e) => e.value.isEnabled)
        .toList();

    if (enabledProviders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 0.5),
        ),
        child: Row(children: [
          Icon(Icons.info_outline_rounded, size: 16, color: textSecondary),
          const SizedBox(width: 8),
          Expanded(child: Text(
            'No cloud providers enabled. Configure one below to get started.',
            style: TextStyle(color: textSecondary, fontSize: 12),
          )),
        ]),
      );
    }

    return Column(
      children: enabledProviders.map((entry) {
        final provider = cloudState.providers
            .where((p) => p.id == entry.key)
            .firstOrNull;
        if (provider == null) return const SizedBox.shrink();

        final activeModels = aiState.availableModels
            .where((m) => m.baseUrl == provider.baseUrl ||
                m.id.startsWith('${provider.id}/'))
            .toList();

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF10B981)),
                ),
                const SizedBox(width: 8),
                Text(provider.name, style: TextStyle(
                    color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                const Spacer(),
                Text('${activeModels.length} models',
                    style: TextStyle(color: textSecondary, fontSize: 11)),
              ]),
              if (activeModels.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(spacing: 4, runSpacing: 4,
                  children: activeModels.take(3).map((m) {
                    final isActive = aiState.activeModel?.id == m.id;
                    return GestureDetector(
                      onTap: () => onSelectModel(m),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isActive
                              ? accentColor.withValues(alpha: 0.15)
                              : borderColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: isActive ? accentColor : borderColor, width: 0.5),
                        ),
                        child: Text(
                          m.name.length > 25 ? '${m.name.substring(0, 25)}...' : m.name,
                          style: TextStyle(fontSize: 10,
                              color: isActive ? accentColor : textSecondary),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}
