/// AI Providers settings section — local models, catalog, cloud providers, gateway.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

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
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 250),
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView(
                shrinkWrap: true,
                children: modelMgr.localModelPaths.map((path) {
            final name = path.split('/').last.split('\\').last;
            final isActive = aiState.activeModel?.filePath == path;
            return InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: cardColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: borderColor)),
                    title: Text(name, style: TextStyle(color: textPrimary)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Details',
                            style: TextStyle(
                                color: textPrimary,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Path:',
                            style:
                                TextStyle(color: textSecondary, fontSize: 12)),
                        Text(path,
                            style:
                                TextStyle(color: textPrimary, fontSize: 12)),
                        const SizedBox(height: 16),
                        if (isActive)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6)),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle,
                                    size: 16, color: Color(0xFF10B981)),
                                SizedBox(width: 8),
                                Text('Currently Active Model',
                                    style: TextStyle(
                                        color: Color(0xFF10B981),
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ref
                              .read(modelManagerProvider.notifier)
                              .deleteModel(path);
                        },
                        child: const Text('Delete Model',
                            style: TextStyle(color: Color(0xFFEF4444))),
                      ),
                      if (!isActive)
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            notifier.selectModel(ModelConfig(
                              id: name,
                              name: name,
                              provider: ProviderType.local,
                              filePath: path,
                            ));
                          },
                          child: Text('Load Model',
                              style: TextStyle(color: accentColor)),
                        ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('Close',
                            style: TextStyle(color: textSecondary)),
                      ),
                    ],
                  ),
                );
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
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
                    if (!isActive) ...[
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
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => ref
                            .read(modelManagerProvider.notifier)
                            .deleteModel(path),
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(Icons.delete_outline,
                              size: 18, color: textSecondary),
                        ),
                      ),
                    ],
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
              ),
            );
          }).toList(),
              ),
            ),
          ),

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

        // ── MODEL CATALOG (Collapsible) ──
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text('DOWNLOAD MODELS (Hugging Face)',
                style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5)),
            children: [
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
                        TextButton(
                          onPressed: () => launchUrl(
                              Uri.parse('https://huggingface.co/settings/tokens')),
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                          child: Text('Get Key',
                              style: TextStyle(
                                  color: accentColor,
                                  fontSize: 11,
                                  decoration: TextDecoration.underline)),
                        ),
                        const SizedBox(width: 8),
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
                      'Required for gated models.',
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
                                    color: textSecondary.withValues(alpha: 0.5),
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

              // Scrollable model catalog
              Container(
                height: 300,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ref.watch(modelCatalogProvider).when(
                  data: (catalog) => ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: catalog.length,
                    itemBuilder: (context, index) {
                      final entry = catalog[index];
                      final download = modelMgr.activeDownloads[entry.fileName];
                      final isDownloaded = modelMgr.localModelPaths
                          .any((p) => p.contains(entry.fileName));
                      final isDownloading = download != null &&
                          download.status == DownloadStatus.downloading;

                      return InkWell(
                        onTap: isDownloading
                            ? null
                            : isDownloaded
                                ? () => _showInstalledModelOptions(
                                    context, ref, entry, modelMgr,
                                    cardColor: cardColor,
                                    borderColor: borderColor,
                                    textPrimary: textPrimary,
                                    textSecondary: textSecondary,
                                    accentColor: accentColor)
                                : () => showDownloadConfirmation(
                                    context, ref, entry),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
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
                      ),
                      );
                    },
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => Center(
                    child: Text('Failed to load catalog',
                        style: TextStyle(color: textSecondary)),
                  ),
                ),
              ),

              // Custom HuggingFace Repo button
              InkWell(
                onTap: () => showHuggingFaceRepoDialog(
                  context: context,
                  ref: ref,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  accentColor: accentColor,
                ),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: accentColor.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(Icons.add_rounded,
                            size: 18, color: accentColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Custom HuggingFace Repo',
                                style: TextStyle(
                                    color: textPrimary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13)),
                            Text('Download from any GGUF repository',
                                style: TextStyle(
                                    color: textSecondary, fontSize: 11)),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 14, color: textSecondary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        SettingsDivider(color: borderColor),

        // ── CONFIGURE CLOUD PROVIDER ──
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text('CLOUD PROVIDERS',
                style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5)),
            children: [
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
            ],
          ),
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

// ─── Installed Model Options Dialog ──────────────────

void _showInstalledModelOptions(
  BuildContext context,
  WidgetRef ref,
  ModelCatalogEntry entry,
  ModelManagerState modelMgr, {
  required Color cardColor,
  required Color borderColor,
  required Color textPrimary,
  required Color textSecondary,
  required Color accentColor,
}) {
  final installedPath = modelMgr.localModelPaths
      .firstWhere((p) => p.contains(entry.fileName), orElse: () => '');
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final bgColor = isDark ? const Color(0xFF16162A) : Colors.white;

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.check_circle_rounded, size: 22, color: const Color(0xFF10B981)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(entry.name,
                style: TextStyle(
                    color: textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline,
                    size: 16, color: Color(0xFF10B981)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('This model is installed and ready to use.',
                      style: TextStyle(color: const Color(0xFF10B981), fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _DetailRow(label: 'Size', value: entry.sizeLabel, color: textSecondary),
          _DetailRow(
              label: 'Context',
              value: '${entry.contextWindow ~/ 1024}K tokens',
              color: textSecondary),
          _DetailRow(label: 'Category', value: entry.category, color: textSecondary),
          if (installedPath.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Path:', style: TextStyle(color: textSecondary, fontSize: 11)),
            Text(installedPath,
                style: TextStyle(color: textPrimary, fontSize: 11),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            if (installedPath.isNotEmpty) {
              ref.read(modelManagerProvider.notifier).deleteModel(installedPath);
            }
          },
          child: const Text('Delete Model',
              style: TextStyle(color: Color(0xFFEF4444), fontSize: 13)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            if (installedPath.isNotEmpty) {
              final name = installedPath.split('/').last.split('\\').last;
              ref.read(aiServiceProvider.notifier).selectModel(ModelConfig(
                id: name,
                name: entry.name,
                provider: ProviderType.local,
                filePath: installedPath,
              ));
            }
          },
          child: Text('Load Model', style: TextStyle(color: accentColor, fontSize: 13)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Close', style: TextStyle(color: textSecondary, fontSize: 13)),
        ),
      ],
    ),
  );
}

// ─── Download Confirmation Dialog ────────────────────

void showDownloadConfirmation(
    BuildContext context, WidgetRef ref, ModelCatalogEntry entry) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final bgColor = isDark ? const Color(0xFF16162A) : Colors.white;
  final textPrimary =
      isDark ? const Color(0xFFE2E2EC) : const Color(0xFF1A1A2E);
  final textSecondary =
      isDark ? const Color(0xFF7A7A90) : const Color(0xFF6B6B80);
  final borderColor =
      isDark ? const Color(0xFF252540) : const Color(0xFFE2E2EC);
  final accentColor = Theme.of(context).colorScheme.primary;

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.download_rounded, size: 22, color: accentColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Download Model',
                style: TextStyle(
                    color: textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Model name & description
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: accentColor.withValues(alpha: 0.15), width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.name,
                      style: TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                  const SizedBox(height: 6),
                  Text(entry.description,
                      style: TextStyle(color: textSecondary, fontSize: 12)),
                  const SizedBox(height: 10),
                  _DetailRow(
                      label: 'Size', value: entry.sizeLabel, color: textSecondary),
                  _DetailRow(
                      label: 'Context',
                      value: '${entry.contextWindow ~/ 1024}K tokens',
                      color: textSecondary),
                  _DetailRow(
                      label: 'Category',
                      value: entry.category,
                      color: textSecondary),
                  _DetailRow(
                      label: 'Format',
                      value: 'GGUF Q4_K_M',
                      color: textSecondary),
                  if (entry.supportsVision)
                    _DetailRow(
                        label: 'Vision', value: 'Yes', color: textSecondary),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // HuggingFace repo + link
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: borderColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.hub_rounded, size: 14, color: textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(entry.repo,
                            style: TextStyle(
                                color: textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => launchUrl(Uri.parse(entry.repoUrl),
                        mode: LaunchMode.externalApplication),
                    child: Row(
                      children: [
                        Icon(Icons.open_in_new_rounded,
                            size: 13, color: accentColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            entry.repoUrl,
                            style: TextStyle(
                                color: accentColor,
                                fontSize: 11,
                                decoration: TextDecoration.underline,
                                decorationColor: accentColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.storage_rounded, size: 14, color: textSecondary),
                const SizedBox(width: 6),
                Text('Requires ${entry.sizeLabel} free storage',
                    style: TextStyle(
                        color: textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Cancel',
              style: TextStyle(color: textSecondary, fontSize: 13)),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: accentColor),
          onPressed: () {
            Navigator.pop(ctx);
            ref.read(modelManagerProvider.notifier).downloadModel(entry);
          },
          icon: const Icon(Icons.download_rounded, size: 16),
          label: Text('Download ${entry.sizeLabel}',
              style: const TextStyle(fontSize: 13)),
        ),
      ],
    ),
  );
}

/// Detail row for model info card.
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _DetailRow(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(label,
                style: TextStyle(
                    color: color, fontSize: 11, fontWeight: FontWeight.w500)),
          ),
          Text(value, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}

// ─── Custom HuggingFace Repo Dialog ──────────────────

void showHuggingFaceRepoDialog({
  required BuildContext context,
  required WidgetRef ref,
  required Color cardColor,
  required Color borderColor,
  required Color textPrimary,
  required Color textSecondary,
  required Color accentColor,
}) {
  showDialog(
    context: context,
    builder: (ctx) => _HuggingFaceRepoDialog(
      cardColor: cardColor,
      borderColor: borderColor,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      accentColor: accentColor,
    ),
  );
}

class _HuggingFaceRepoDialog extends ConsumerStatefulWidget {
  final Color cardColor, borderColor, textPrimary, textSecondary, accentColor;

  const _HuggingFaceRepoDialog({
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
  });

  @override
  ConsumerState<_HuggingFaceRepoDialog> createState() =>
      _HuggingFaceRepoDialogState();
}

class _HuggingFaceRepoDialogState extends ConsumerState<_HuggingFaceRepoDialog> {
  final _repoController = TextEditingController();
  HuggingFaceModelInfo? _modelInfo;
  String? _error;
  bool _loading = false;
  String? _selectedFile;

  @override
  void dispose() {
    _repoController.dispose();
    super.dispose();
  }

  Future<void> _fetchModelInfo() async {
    final repo = _repoController.text.trim();
    if (repo.isEmpty) {
      setState(() => _error = 'Please enter a repository name');
      return;
    }
    if (!repo.contains('/')) {
      setState(() => _error = 'Format: owner/repo-name  (e.g., unsloth/gemma-3-1b-it-GGUF)');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _modelInfo = null;
      _selectedFile = null;
    });

    try {
      final info = await ref
          .read(modelManagerProvider.notifier)
          .fetchHuggingFaceModelInfo(repo);
      if (mounted) {
        setState(() {
          _modelInfo = info;
          _loading = false;
          if (info != null && !info.hasGgufFiles) {
            _error = 'No GGUF files found in this repository';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  Future<void> _downloadSelected() async {
    if (_selectedFile == null || _modelInfo == null) return;

    final repo = _repoController.text.trim();
    final file = _modelInfo!.ggufFiles.firstWhere((f) => f.filename == _selectedFile);

    Navigator.of(context).pop();

    await ref.read(modelManagerProvider.notifier).downloadCustomModel(
          repo: repo,
          fileName: file.filename,
          sizeBytes: file.size,
          contextWindow: _modelInfo!.contextLength ?? 4096,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF16162A) : Colors.white;

    return AlertDialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.hub_outlined, size: 22, color: widget.accentColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Custom HuggingFace Repo',
                style: TextStyle(
                    color: widget.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      content: SizedBox(
        width: 340,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter the repository path (e.g., unsloth/gemma-3-1b-it-GGUF)',
                  style: TextStyle(color: widget.textSecondary, fontSize: 12)),
              const SizedBox(height: 12),

              // Repo input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _repoController,
                      style: TextStyle(color: widget.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'owner/repo-name',
                        hintStyle: TextStyle(
                            color: widget.textSecondary.withValues(alpha: 0.5)),
                        prefixIcon: Icon(Icons.search,
                            size: 18, color: widget.textSecondary),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        filled: true,
                        fillColor: widget.borderColor.withValues(alpha: 0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _fetchModelInfo(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _loading ? null : _fetchModelInfo,
                    style: FilledButton.styleFrom(
                      backgroundColor: widget.accentColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Fetch'),
                  ),
                ],
              ),

              // Error message
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          size: 16, color: Color(0xFFEF4444)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_error!,
                            style: const TextStyle(
                                color: Color(0xFFEF4444), fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ],

              // Model info
              if (_modelInfo != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.accentColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: widget.accentColor.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(_modelInfo!.modelId,
                                style: TextStyle(
                                    color: widget.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14)),
                          ),
                          if (_modelInfo!.isGated)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('gated',
                                  style: TextStyle(
                                      fontSize: 10, color: Color(0xFFF59E0B))),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _InfoChip(
                              icon: Icons.download_rounded,
                              label: '${_modelInfo!.downloads}',
                              color: widget.textSecondary),
                          const SizedBox(width: 12),
                          _InfoChip(
                              icon: Icons.favorite_rounded,
                              label: '${_modelInfo!.likes}',
                              color: widget.textSecondary),
                          const SizedBox(width: 12),
                          if (_modelInfo!.contextLength != null)
                            _InfoChip(
                                icon: Icons.memory_rounded,
                                label: _modelInfo!.contextLengthLabel,
                                color: widget.textSecondary),
                        ],
                      ),
                      if (_modelInfo!.architecture != null) ...[
                        const SizedBox(height: 6),
                        Text('Architecture: ${_modelInfo!.architecture}',
                            style: TextStyle(
                                color: widget.textSecondary, fontSize: 11)),
                      ],
                    ],
                  ),
                ),

                // GGUF files list
                if (_modelInfo!.hasGgufFiles) ...[
                  const SizedBox(height: 12),
                  Text('Select GGUF file to download:',
                      style: TextStyle(
                          color: widget.textPrimary,
                          fontWeight: FontWeight.w500,
                          fontSize: 12)),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _modelInfo!.ggufFiles.length,
                      itemBuilder: (_, i) {
                        final file = _modelInfo!.ggufFiles[i];
                        final isSelected = _selectedFile == file.filename;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedFile = file.filename),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? widget.accentColor.withValues(alpha: 0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? widget.accentColor
                                    : widget.borderColor,
                                width: isSelected ? 1 : 0.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  size: 16,
                                  color: isSelected
                                      ? widget.accentColor
                                      : widget.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    file.filename,
                                    style: TextStyle(
                                        color: widget.textPrimary,
                                        fontSize: 11),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (file.quantization != null) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: widget.accentColor
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(file.quantization!,
                                        style: TextStyle(
                                            color: widget.accentColor,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ],
                                const SizedBox(width: 6),
                                Text(file.sizeLabel,
                                    style: TextStyle(
                                        color: widget.textSecondary,
                                        fontSize: 10)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child:
              Text('Cancel', style: TextStyle(color: widget.textSecondary)),
        ),
        if (_modelInfo != null && _selectedFile != null)
          FilledButton.icon(
            onPressed: _downloadSelected,
            style: FilledButton.styleFrom(backgroundColor: widget.accentColor),
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Download'),
          ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(color: color, fontSize: 11)),
      ],
    );
  }
}
