/// Settings Screen — 7 sections with responsive layout.
///
/// Appearance, AI Providers (local model management), Personas,
/// Voice & Input, Privacy, Data, About. Matches ux_preview design.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/prism_theme.dart';
import '../../core/ai/ai_service.dart';
import '../../core/ai/model_manager.dart';
import '../../core/ai/ai_host_server.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _selectedSection = 0;

  static const _sections = [
    ('Appearance', Icons.palette_outlined),
    ('AI Providers', Icons.model_training_outlined),
    ('Personas', Icons.person_outline_rounded),
    ('Voice & Input', Icons.mic_outlined),
    ('Privacy', Icons.shield_outlined),
    ('Data', Icons.storage_outlined),
    ('About', Icons.info_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0C0C16) : const Color(0xFFF5F5FA);
    final cardColor = isDark ? const Color(0xFF16162A) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF252540) : const Color(0xFFE2E2EC);
    final textPrimary =
        isDark ? const Color(0xFFE2E2EC) : const Color(0xFF1A1A2E);
    final textSecondary =
        isDark ? const Color(0xFF7A7A90) : const Color(0xFF6B6B80);
    final accentColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: bgColor,
      body: LayoutBuilder(
        builder: (context, c) {
          final isWide = c.maxWidth > 700;

          if (isWide) {
            return Row(
              children: [
                SizedBox(
                  width: 200,
                  child: _SideNav(
                    sections: _sections,
                    selected: _selectedSection,
                    onSelect: (i) => setState(() => _selectedSection = i),
                    cardColor: cardColor,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    accentColor: accentColor,
                  ),
                ),
                VerticalDivider(width: 1, color: borderColor),
                Expanded(
                  child: _buildContent(
                    isDark: isDark,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    accentColor: accentColor,
                  ),
                ),
              ],
            );
          }

          // Mobile: header + tabs + content
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
                child: Row(
                  children: [
                    Text('Settings',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: textPrimary)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Tab row
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _sections.length,
                  itemBuilder: (context, i) {
                    final sel = _selectedSection == i;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedSection = i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: sel
                                ? accentColor.withValues(alpha: 0.12)
                                : cardColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: sel ? accentColor : borderColor,
                                width: 0.5),
                          ),
                          child: Row(
                            children: [
                              Icon(_sections[i].$2,
                                  size: 14,
                                  color: sel
                                      ? accentColor
                                      : textSecondary),
                              const SizedBox(width: 4),
                              Text(_sections[i].$1,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: sel
                                          ? accentColor
                                          : textSecondary,
                                      fontWeight: sel
                                          ? FontWeight.w600
                                          : FontWeight.w400)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Divider(height: 16, color: borderColor),
              Expanded(
                child: _buildContent(
                  isDark: isDark,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  accentColor: accentColor,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent({
    required bool isDark,
    required Color cardColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color accentColor,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: switch (_selectedSection) {
        0 => _AppearanceSection(
            cardColor: cardColor,
            borderColor: borderColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            accentColor: accentColor),
        1 => _AiSection(
            cardColor: cardColor,
            borderColor: borderColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            accentColor: accentColor),
        2 => _PersonasSection(
            cardColor: cardColor,
            borderColor: borderColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            accentColor: accentColor),
        3 => _VoiceSection(
            cardColor: cardColor,
            borderColor: borderColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            accentColor: accentColor),
        4 => _PrivacySection(
            cardColor: cardColor,
            borderColor: borderColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            accentColor: accentColor),
        5 => _DataSection(
            cardColor: cardColor,
            borderColor: borderColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            accentColor: accentColor),
        6 => _AboutSection(
            cardColor: cardColor,
            borderColor: borderColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            accentColor: accentColor),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

// ─── Side Navigation (wide) ──────────────────────────

class _SideNav extends StatelessWidget {
  final List<(String, IconData)> sections;
  final int selected;
  final ValueChanged<int> onSelect;
  final Color cardColor, borderColor, textPrimary, textSecondary, accentColor;

  const _SideNav({
    required this.sections,
    required this.selected,
    required this.onSelect,
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Settings',
                style: TextStyle(
                    color: textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18)),
          ),
          Divider(height: 1, color: borderColor),
          ...List.generate(sections.length, (i) {
            final sel = selected == i;
            return GestureDetector(
              onTap: () => onSelect(i),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: sel
                    ? accentColor.withValues(alpha: 0.08)
                    : Colors.transparent,
                child: Row(
                  children: [
                    Icon(sections[i].$2,
                        size: 18,
                        color: sel ? accentColor : textSecondary),
                    const SizedBox(width: 10),
                    Text(sections[i].$1,
                        style: TextStyle(
                            fontSize: 13,
                            color: sel ? accentColor : textPrimary,
                            fontWeight:
                                sel ? FontWeight.w600 : FontWeight.w400)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Appearance Section ──────────────────────────────

class _AppearanceSection extends ConsumerWidget {
  final Color cardColor, borderColor, textPrimary, textSecondary, accentColor;
  const _AppearanceSection(
      {required this.cardColor,
      required this.borderColor,
      required this.textPrimary,
      required this.textSecondary,
      required this.accentColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(prismThemeProvider);
    final notifier = ref.read(prismThemeProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Appearance',
            subtitle: 'Customize theme and colors',
            textPrimary: textPrimary, textSecondary: textSecondary),

        _GroupLabel(text: 'THEME MODE', color: textSecondary),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final (label, mode) in [
              ('Light', ThemeMode.light),
              ('System', ThemeMode.system),
              ('Dark', ThemeMode.dark),
            ])
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => notifier.setMode(mode),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: theme.mode == mode
                            ? accentColor.withValues(alpha: 0.12)
                            : cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: theme.mode == mode
                                ? accentColor
                                : borderColor,
                            width: 0.5),
                      ),
                      child: Center(
                        child: Text(label,
                            style: TextStyle(
                                fontSize: 13,
                                color: theme.mode == mode
                                    ? accentColor
                                    : textSecondary,
                                fontWeight: theme.mode == mode
                                    ? FontWeight.w600
                                    : FontWeight.w400)),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),
        _ToggleRow(
          title: 'AMOLED Black',
          subtitle: 'Pure black background for OLED screens',
          value: theme.amoled,
          onChanged: (_) => notifier.toggleAmoled(),
          cardColor: cardColor,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          accentColor: accentColor,
        ),

        _Divider(color: borderColor),

        _GroupLabel(text: 'ACCENT COLOR', color: textSecondary),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: AccentPreset.values.map((preset) {
            final sel = theme.preset == preset;
            return GestureDetector(
              onTap: () => notifier.setPreset(preset),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: preset.color,
                      borderRadius: BorderRadius.circular(12),
                      border: sel
                          ? Border.all(color: Colors.white, width: 2.5)
                          : null,
                      boxShadow: sel
                          ? [
                              BoxShadow(
                                  color: preset.color.withValues(alpha: 0.4),
                                  blurRadius: 12)
                            ]
                          : null,
                    ),
                    child: sel
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 20)
                        : null,
                  ),
                  const SizedBox(height: 4),
                  Text(preset.label,
                      style: TextStyle(
                          color: sel ? textPrimary : textSecondary,
                          fontSize: 10,
                          fontWeight:
                              sel ? FontWeight.w600 : FontWeight.w400)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── AI Providers Section ────────────────────────────

class _AiSection extends ConsumerWidget {
  final Color cardColor, borderColor, textPrimary, textSecondary, accentColor;
  const _AiSection(
      {required this.cardColor,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'AI Providers',
            subtitle: 'Local models, cloud APIs, and gateway',
            textPrimary: textPrimary, textSecondary: textSecondary),

        // ── LOCAL MODELS ──
        _GroupLabel(text: 'LOCAL MODELS', color: textSecondary),
        const SizedBox(height: 8),

        // List local models
        if (modelMgr.localModelPaths.isEmpty)
          _InfoCard(
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
                      color: isActive
                          ? const Color(0xFF10B981)
                          : textSecondary,
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
                    _SmallButton(
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
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
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
            _SmallButton(
              label: 'Import .gguf',
              color: accentColor,
              onTap: () => ref.read(modelManagerProvider.notifier).pickModelFile(),
            ),
            const SizedBox(width: 8),
            _SmallButton(
              label: 'Scan Models',
              color: textSecondary,
              onTap: () =>
                  ref.read(modelManagerProvider.notifier).scanLocalModels(),
            ),
          ],
        ),

        _Divider(color: borderColor),

        // ── MODEL CATALOG ──
        _GroupLabel(text: 'DOWNLOAD MODELS', color: textSecondary),
        const SizedBox(height: 8),
        ...modelCatalog.map((entry) {
          final download = modelMgr.activeDownloads[entry.fileName];
          final isDownloaded = modelMgr.localModelPaths
              .any((p) => p.contains(entry.fileName));
          final sizeGB = (entry.sizeBytes / (1024 * 1024 * 1024))
              .toStringAsFixed(1);

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
                          Text('$sizeGB GB · ${entry.description}',
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
                                fontSize: 10,
                                color: Color(0xFF10B981))),
                      )
                    else if (download != null &&
                        download.status == DownloadStatus.downloading)
                      _SmallButton(
                        label: 'Cancel',
                        color: const Color(0xFFEF4444),
                        onTap: () => ref
                            .read(modelManagerProvider.notifier)
                            .cancelDownload(entry.fileName),
                      )
                    else
                      _SmallButton(
                        label: 'Download',
                        color: accentColor,
                        onTap: () => ref
                            .read(modelManagerProvider.notifier)
                            .downloadModel(entry),
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
                  Text('${(download.progress * 100).toStringAsFixed(1)}%',
                      style:
                          TextStyle(color: textSecondary, fontSize: 10)),
                ],
              ],
            ),
          );
        }),

        _Divider(color: borderColor),

        // ── CLOUD API ──
        _GroupLabel(text: 'CLOUD PROVIDERS', color: textSecondary),
        const SizedBox(height: 8),
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
                      Text('${model.provider.name} · ${model.contextWindow ~/ 1024}K',
                          style: TextStyle(
                              color: textSecondary, fontSize: 11)),
                    ],
                  ),
                ),
                if (!isActive)
                  _SmallButton(
                      label: 'Select',
                      color: accentColor,
                      onTap: () => notifier.selectModel(model))
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981)
                          .withValues(alpha: 0.12),
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

        _Divider(color: borderColor),

        // ── AI GATEWAY ──
        _GroupLabel(text: 'AI GATEWAY', color: textSecondary),
        const SizedBox(height: 8),
        _ToggleRow(
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

// ─── Personas Section ────────────────────────────────

class _PersonasSection extends StatelessWidget {
  final Color cardColor, borderColor, textPrimary, textSecondary, accentColor;
  const _PersonasSection(
      {required this.cardColor,
      required this.borderColor,
      required this.textPrimary,
      required this.textSecondary,
      required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final personas = [
      ('Default', 'Balanced, helpful assistant', '🤖', true),
      ('Creative', 'Imaginative and expressive', '🎨', false),
      ('Technical', 'Precise, code-focused', '💻', false),
      ('Concise', 'Brief and to the point', '⚡', false),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Personas',
            subtitle: 'Customize AI personality and behavior',
            textPrimary: textPrimary, textSecondary: textSecondary),

        ...personas.map((p) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: p.$4 ? accentColor : borderColor,
                  width: p.$4 ? 1.5 : 0.5),
            ),
            child: Row(
              children: [
                Text(p.$3, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.$1,
                          style: TextStyle(
                              color: textPrimary,
                              fontWeight: FontWeight.w500,
                              fontSize: 14)),
                      Text(p.$2,
                          style: TextStyle(
                              color: textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                if (p.$4)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('active',
                        style: TextStyle(
                            fontSize: 10, color: accentColor)),
                  ),
              ],
            ),
          );
        }),

        const SizedBox(height: 12),
        _SmallButton(
          label: 'Create Custom Persona',
          color: accentColor,
          onTap: () {},
        ),
      ],
    );
  }
}

// ─── Voice & Input Section ───────────────────────────

class _VoiceSection extends StatelessWidget {
  final Color cardColor, borderColor, textPrimary, textSecondary, accentColor;
  const _VoiceSection(
      {required this.cardColor,
      required this.borderColor,
      required this.textPrimary,
      required this.textSecondary,
      required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Voice & Input',
            subtitle: 'Configure input methods',
            textPrimary: textPrimary, textSecondary: textSecondary),

        _ToggleRow(
          title: 'Voice Input',
          subtitle: 'Use microphone for voice commands',
          value: false,
          onChanged: (_) {},
          cardColor: cardColor,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          accentColor: accentColor,
        ),
        _ToggleRow(
          title: 'Haptic Feedback',
          subtitle: 'Vibrate on interactions',
          value: true,
          onChanged: (_) {},
          cardColor: cardColor,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          accentColor: accentColor,
        ),
        _ToggleRow(
          title: 'Auto-send on Enter',
          subtitle: 'Send message with Enter key',
          value: true,
          onChanged: (_) {},
          cardColor: cardColor,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          accentColor: accentColor,
        ),
      ],
    );
  }
}

// ─── Privacy Section ─────────────────────────────────

class _PrivacySection extends StatelessWidget {
  final Color cardColor, borderColor, textPrimary, textSecondary, accentColor;
  const _PrivacySection(
      {required this.cardColor,
      required this.borderColor,
      required this.textPrimary,
      required this.textSecondary,
      required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Privacy & Security',
            subtitle: 'Protect your data and access',
            textPrimary: textPrimary, textSecondary: textSecondary),

        // Privacy badge
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.shield_rounded,
                  size: 18, color: Color(0xFF10B981)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                    'All data is stored locally on your device. Nothing leaves without your permission.',
                    style: TextStyle(
                        color: const Color(0xFF10B981), fontSize: 12)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _InfoCard(
          icon: Icons.dns_outlined,
          text: 'AI models run locally via llama.cpp. Cloud providers require your own API key.',
          cardColor: cardColor,
          borderColor: borderColor,
          textSecondary: textSecondary,
          accentColor: accentColor,
        ),
        _InfoCard(
          icon: Icons.visibility_off_outlined,
          text: 'No analytics, telemetry, or tracking. Period.',
          cardColor: cardColor,
          borderColor: borderColor,
          textSecondary: textSecondary,
          accentColor: accentColor,
        ),
        _InfoCard(
          icon: Icons.fingerprint_rounded,
          text: 'Biometric unlock available in a future update.',
          cardColor: cardColor,
          borderColor: borderColor,
          textSecondary: textSecondary,
          accentColor: accentColor,
        ),
      ],
    );
  }
}

// ─── Data Section ────────────────────────────────────

class _DataSection extends StatelessWidget {
  final Color cardColor, borderColor, textPrimary, textSecondary, accentColor;
  const _DataSection(
      {required this.cardColor,
      required this.borderColor,
      required this.textPrimary,
      required this.textSecondary,
      required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final stores = [
      ('Conversations', 'SQLite', Icons.chat_bubble_outline),
      ('Notes', 'SQLite + FTS5', Icons.auto_awesome_outlined),
      ('Tasks', 'SQLite', Icons.check_circle_outline),
      ('Transactions', 'SQLite', Icons.account_balance_wallet_outlined),
      ('Models', 'Local GGUF files', Icons.model_training_outlined),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Data & Storage',
            subtitle: 'Manage local data and cache',
            textPrimary: textPrimary, textSecondary: textSecondary),

        _GroupLabel(text: 'STORAGE', color: textSecondary),
        const SizedBox(height: 8),
        ...stores.map((s) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor, width: 0.5),
              ),
              child: Row(
                children: [
                  Icon(s.$3, size: 18, color: textSecondary),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(s.$1,
                          style: TextStyle(
                              color: textPrimary, fontSize: 13))),
                  Text(s.$2,
                      style: TextStyle(
                          color: textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            )),

        _Divider(color: borderColor),

        _GroupLabel(text: 'ACTIONS', color: textSecondary),
        const SizedBox(height: 8),
        Row(
          children: [
            _SmallButton(
                label: 'Export All', color: accentColor, onTap: () {}),
            const SizedBox(width: 8),
            _SmallButton(
                label: 'Import', color: textSecondary, onTap: () {}),
          ],
        ),
        const SizedBox(height: 12),
        _SmallButton(
          label: 'Clear All Data',
          color: const Color(0xFFEF4444),
          onTap: () {},
        ),
      ],
    );
  }
}

// ─── About Section ───────────────────────────────────

class _AboutSection extends StatelessWidget {
  final Color cardColor, borderColor, textPrimary, textSecondary, accentColor;
  const _AboutSection(
      {required this.cardColor,
      required this.borderColor,
      required this.textPrimary,
      required this.textSecondary,
      required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 0.5),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.auto_awesome,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            Text('Prism',
                style: TextStyle(
                    color: textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 22)),
            const SizedBox(height: 4),
            Text('AI Personal Assistant',
                style: TextStyle(color: textSecondary, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('v0.2.0-alpha',
                  style: TextStyle(fontSize: 11, color: accentColor)),
            ),
            const SizedBox(height: 16),
            Text(
              'Your intelligent, privacy-first personal assistant.\nLocal-first AI with cloud API support.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: textSecondary, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 20),
            _aboutRow('Framework', 'Flutter', textPrimary, textSecondary),
            _aboutRow('Local AI', 'llama.cpp (llama_sdk)', textPrimary, textSecondary),
            _aboutRow('Cloud AI', 'LangChain.dart', textPrimary, textSecondary),
            _aboutRow('Database', 'Drift + SQLite + FTS5', textPrimary, textSecondary),
            _aboutRow('ML Kit', 'OCR, NER, Smart Reply', textPrimary, textSecondary),
            _aboutRow('License', 'AGPL-3.0', textPrimary, textSecondary),
          ],
        ),
      ),
    );
  }

  static Widget _aboutRow(
      String label, String value, Color primary, Color secondary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$label: ',
              style: TextStyle(color: secondary, fontSize: 11)),
          Text(value,
              style: TextStyle(
                  color: primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ──────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title, subtitle;
  final Color textPrimary, textSecondary;
  const _SectionHeader(
      {required this.title,
      required this.subtitle,
      required this.textPrimary,
      required this.textSecondary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: TextStyle(color: textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _GroupLabel({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(text,
          style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1)),
    );
  }
}

class _Divider extends StatelessWidget {
  final Color color;
  const _Divider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(color: color, height: 1),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color cardColor, borderColor, textPrimary, textSecondary, accentColor;

  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(color: textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: accentColor,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color cardColor, borderColor, textSecondary, accentColor;

  const _InfoCard({
    required this.icon,
    required this.text,
    required this.cardColor,
    required this.borderColor,
    required this.textSecondary,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: accentColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    color: textSecondary, fontSize: 12, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _SmallButton(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12, color: color, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
