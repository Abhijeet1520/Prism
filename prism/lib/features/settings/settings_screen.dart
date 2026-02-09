/// Settings screen — theme, AI providers, privacy, about.
///
/// Responsive: section nav on desktop, tabbed on mobile.
/// Uses [PrismThemeNotifier] for live theme changes.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moon_design/moon_design.dart';

import '../../core/theme/prism_theme.dart';
import '../../core/ai/ai_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _selectedSection = 0;

  static const _sections = ['Appearance', 'AI Providers', 'Privacy', 'Data', 'About'];

  @override
  Widget build(BuildContext context) {
    final colors = context.moonColors!;

    return Scaffold(
      backgroundColor: colors.gohan,
      body: LayoutBuilder(
        builder: (context, c) {
          if (c.maxWidth > 700) {
            return Row(
              children: [
                SizedBox(width: 200, child: _sectionNav(colors)),
                VerticalDivider(width: 1, color: colors.beerus),
                Expanded(child: _content(colors)),
              ],
            );
          }
          return _content(colors, showHeader: true);
        },
      ),
    );
  }

  Widget _sectionNav(MoonColors colors) {
    return Container(
      color: colors.goten,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Settings', style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w700, fontSize: 18)),
          ),
          Divider(height: 1, color: colors.beerus),
          ...List.generate(_sections.length, (i) {
            final sel = _selectedSection == i;
            return MoonMenuItem(
              onTap: () => setState(() => _selectedSection = i),
              backgroundColor: sel ? colors.piccolo.withValues(alpha: 0.08) : Colors.transparent,
              leading: Icon(_sectionIcon(i), size: 18, color: sel ? colors.piccolo : colors.trunks),
              label: Text(
                _sections[i],
                style: TextStyle(color: sel ? colors.piccolo : colors.bulma, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, fontSize: 14),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _content(MoonColors colors, {bool showHeader = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: colors.goten, border: Border(bottom: BorderSide(color: colors.beerus))),
            child: Text('Settings', style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w700, fontSize: 18)),
          ),
          Container(
            color: colors.goten,
            child: MoonTabBar(
              tabBarSize: MoonTabBarSize.sm,
              tabs: _sections.map((s) => MoonTab(label: Text(s))).toList(),
              onTabChanged: (i) => setState(() => _selectedSection = i),
            ),
          ),
          Divider(height: 1, color: colors.beerus),
        ],
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: switch (_selectedSection) {
              0 => _AppearanceSection(colors: colors),
              1 => _AiProvidersSection(colors: colors),
              2 => _PrivacySection(colors: colors),
              3 => _DataSection(colors: colors),
              4 => _AboutSection(colors: colors),
              _ => const SizedBox.shrink(),
            },
          ),
        ),
      ],
    );
  }

  IconData _sectionIcon(int i) {
    return switch (i) {
      0 => Icons.palette_outlined,
      1 => Icons.cloud_outlined,
      2 => Icons.shield_outlined,
      3 => Icons.storage_outlined,
      4 => Icons.info_outline,
      _ => Icons.settings,
    };
  }
}

// ─── Appearance ───────────────────────────────────────

class _AppearanceSection extends ConsumerWidget {
  final MoonColors colors;
  const _AppearanceSection({required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(prismThemeProvider);
    final notifier = ref.read(prismThemeProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(colors, 'Appearance', 'Customize theme, colors, and display'),

        _groupLabel(colors, 'THEME MODE'),
        const SizedBox(height: 8),
        MoonSegmentedControl(
          segmentedControlSize: MoonSegmentedControlSize.sm,
          isExpanded: true,
          segments: const [
            Segment(label: Text('Light')),
            Segment(label: Text('System')),
            Segment(label: Text('Dark')),
          ],
          onSegmentChanged: (i) {
            final modes = [ThemeMode.light, ThemeMode.system, ThemeMode.dark];
            notifier.setMode(modes[i]);
          },
        ),
        const SizedBox(height: 12),
        _ToggleRow(
          colors: colors,
          title: 'AMOLED Black',
          subtitle: 'Pure black background for OLED screens',
          value: theme.amoled,
          onChanged: (_) => notifier.toggleAmoled(),
        ),

        _divider(colors),

        _groupLabel(colors, 'ACCENT COLOR'),
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
                      border: sel ? Border.all(color: Colors.white, width: 2.5) : null,
                      boxShadow: sel ? [BoxShadow(color: preset.color.withValues(alpha: 0.4), blurRadius: 12)] : null,
                    ),
                    child: sel ? const Icon(Icons.check_rounded, color: Colors.white, size: 20) : null,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    preset.label,
                    style: TextStyle(color: sel ? colors.bulma : colors.trunks, fontSize: 10, fontWeight: sel ? FontWeight.w600 : FontWeight.w400),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── AI Providers ─────────────────────────────────────

class _AiProvidersSection extends ConsumerWidget {
  final MoonColors colors;
  const _AiProvidersSection({required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiState = ref.watch(aiServiceProvider);
    final notifier = ref.read(aiServiceProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(colors, 'AI Providers', 'Configure LLM models and connections'),
        _groupLabel(colors, 'AVAILABLE MODELS'),
        const SizedBox(height: 8),
        ...aiState.availableModels.map((model) {
          final isActive = aiState.activeModel?.id == model.id;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.goten,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isActive ? colors.piccolo : colors.beerus, width: isActive ? 1.5 : 0.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? colors.roshi : colors.trunks,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(model.name, style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w500, fontSize: 14)),
                      Text(
                        '${model.provider.name} · ${model.contextWindow ~/ 1024}K ctx',
                        style: TextStyle(color: colors.trunks, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                MoonTag(
                  tagSize: MoonTagSize.x2s,
                  backgroundColor: model.provider == AIProvider.mock
                      ? colors.krillin.withValues(alpha: 0.15)
                      : colors.piccolo.withValues(alpha: 0.15),
                  label: Text(
                    model.provider.name,
                    style: TextStyle(fontSize: 10, color: model.provider == AIProvider.mock ? colors.krillin : colors.piccolo),
                  ),
                ),
                const SizedBox(width: 8),
                if (!isActive)
                  MoonOutlinedButton(
                    onTap: () => notifier.selectModel(model),
                    buttonSize: MoonButtonSize.sm,
                    label: const Text('Select'),
                  )
                else
                  MoonTag(
                    tagSize: MoonTagSize.x2s,
                    backgroundColor: colors.roshi.withValues(alpha: 0.15),
                    label: Text('active', style: TextStyle(fontSize: 10, color: colors.roshi)),
                  ),
              ],
            ),
          );
        }),

        _divider(colors),

        _groupLabel(colors, 'CONNECTION'),
        const SizedBox(height: 8),
        MoonTextInput(
          hintText: 'Ollama URL (e.g. http://localhost:11434)',
          textInputSize: MoonTextInputSize.sm,
          leading: Icon(Icons.link, size: 14, color: colors.trunks),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            MoonOutlinedButton(onTap: () {}, buttonSize: MoonButtonSize.sm, label: const Text('Test Connection')),
            const SizedBox(width: 8),
            MoonOutlinedButton(onTap: () {}, buttonSize: MoonButtonSize.sm, label: const Text('Discover Models')),
          ],
        ),
      ],
    );
  }
}

// ─── Privacy ──────────────────────────────────────────

class _PrivacySection extends StatelessWidget {
  final MoonColors colors;
  const _PrivacySection({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(colors, 'Privacy & Security', 'Protect your data and access'),
        MoonAlert(
          show: true,
          backgroundColor: colors.roshi.withValues(alpha: 0.08),
          leading: Icon(Icons.shield, size: 18, color: colors.roshi),
          label: Text('All data stored locally. Nothing leaves your device.', style: TextStyle(color: colors.roshi, fontSize: 12)),
        ),
        const SizedBox(height: 16),
        _groupLabel(colors, 'ACCESS'),
        const SizedBox(height: 8),
        _infoCard(colors, Icons.fingerprint, 'Biometric unlock available in a future update.'),
        _divider(colors),
        _groupLabel(colors, 'DATA POLICY'),
        const SizedBox(height: 8),
        _infoCard(colors, Icons.dns_outlined, 'AI models run locally via Ollama. Cloud providers require you to bring your own API key.'),
        _infoCard(colors, Icons.visibility_off_outlined, 'No analytics, telemetry, or tracking. Period.'),
      ],
    );
  }
}

// ─── Data ─────────────────────────────────────────────

class _DataSection extends StatelessWidget {
  final MoonColors colors;
  const _DataSection({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(colors, 'Data & Storage', 'Manage local data and cache'),
        _groupLabel(colors, 'STORAGE'),
        const SizedBox(height: 8),
        _storageRow(colors, 'Conversations', 'SQLite', Icons.chat_bubble_outline),
        _storageRow(colors, 'Notes', 'SQLite + FTS5', Icons.auto_awesome_outlined),
        _storageRow(colors, 'Tasks', 'SQLite', Icons.check_circle_outline),
        _storageRow(colors, 'Transactions', 'SQLite', Icons.account_balance_wallet_outlined),
        _divider(colors),
        _groupLabel(colors, 'ACTIONS'),
        const SizedBox(height: 8),
        Row(
          children: [
            MoonOutlinedButton(onTap: () {}, buttonSize: MoonButtonSize.sm, label: const Text('Export All Data'), leading: const Icon(Icons.file_download_outlined, size: 16)),
            const SizedBox(width: 8),
            MoonOutlinedButton(onTap: () {}, buttonSize: MoonButtonSize.sm, label: const Text('Import Data'), leading: const Icon(Icons.file_upload_outlined, size: 16)),
          ],
        ),
        const SizedBox(height: 12),
        MoonOutlinedButton(
          onTap: () {},
          buttonSize: MoonButtonSize.sm,
          borderColor: Colors.redAccent,
          label: const Text('Clear All Data', style: TextStyle(color: Colors.redAccent)),
          leading: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
        ),
      ],
    );
  }
}

// ─── About ────────────────────────────────────────────

class _AboutSection extends StatelessWidget {
  final MoonColors colors;
  const _AboutSection({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.goten,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.beerus, width: 0.5),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: colors.piccolo, borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            Text('Prism', style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w700, fontSize: 22)),
            const SizedBox(height: 4),
            Text('AI Personal Assistant', style: TextStyle(color: colors.trunks, fontSize: 14)),
            const SizedBox(height: 8),
            MoonTag(
              tagSize: MoonTagSize.x2s,
              backgroundColor: colors.piccolo.withValues(alpha: 0.15),
              label: Text('v0.1.0-alpha', style: TextStyle(fontSize: 11, color: colors.piccolo)),
            ),
            const SizedBox(height: 16),
            Text(
              'Your intelligent, privacy-first personal assistant.\nPowered by local and cloud LLMs.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.trunks, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 20),
            _aboutRow(colors, 'Framework', 'Flutter + Moon Design'),
            _aboutRow(colors, 'AI Backend', 'LangChain.dart + Ollama'),
            _aboutRow(colors, 'Database', 'Drift + SQLite + FTS5'),
            _aboutRow(colors, 'ML Kit', 'OCR, NER, Smart Reply'),
            _aboutRow(colors, 'License', 'AGPL-3.0'),
            _aboutRow(colors, 'Platform', 'Android, iOS, Web, Desktop'),
          ],
        ),
      ),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────

Widget _sectionTitle(MoonColors colors, String title, String sub) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 4),
        Text(sub, style: TextStyle(color: colors.trunks, fontSize: 13)),
      ],
    ),
  );
}

Widget _groupLabel(MoonColors colors, String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 4),
    child: Text(text, style: TextStyle(color: colors.trunks, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1)),
  );
}

Widget _divider(MoonColors colors) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Divider(color: colors.beerus, height: 1),
  );
}

Widget _infoCard(MoonColors colors, IconData icon, String text) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: colors.piccolo.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Icon(icon, size: 18, color: colors.piccolo),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: TextStyle(color: colors.trunks, fontSize: 12, height: 1.4))),
      ],
    ),
  );
}

Widget _storageRow(MoonColors colors, String label, String detail, IconData icon) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: colors.goten,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: colors.beerus, width: 0.5),
    ),
    child: Row(
      children: [
        Icon(icon, size: 18, color: colors.trunks),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: TextStyle(color: colors.bulma, fontSize: 14))),
        Text(detail, style: TextStyle(color: colors.trunks, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    ),
  );
}

Widget _aboutRow(MoonColors colors, String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('$label: ', style: TextStyle(color: colors.trunks, fontSize: 11)),
        Text(value, style: TextStyle(color: colors.bulma, fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    ),
  );
}

class _ToggleRow extends StatelessWidget {
  final MoonColors colors;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.colors,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.goten,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.beerus, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w500, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: colors.trunks, fontSize: 12)),
              ],
            ),
          ),
          MoonSwitch(switchSize: MoonSwitchSize.x2s, value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
