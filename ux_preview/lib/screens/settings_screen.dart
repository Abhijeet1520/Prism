import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moon_design/moon_design.dart';

import '../theme/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  final ThemeProvider themeProvider;
  const SettingsScreen({super.key, required this.themeProvider});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<dynamic> _providers = [];
  List<dynamic> _personas = [];
  bool _biometric = false;
  bool _voiceEnabled = true;
  bool _hapticFeedback = true;
  bool _notifEnabled = true;
  bool _analyticsEnabled = false;
  int _selectedSection = 0;

  ThemeProvider get _tp => widget.themeProvider;

  static const _sections = [
    'Appearance',
    'AI Providers',
    'Personas',
    'Voice & Input',
    'Privacy & Security',
    'Data & Storage',
    'About',
  ];

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  Future<void> _loadMockData() async {
    try {
      final pJson = await rootBundle.loadString('assets/mock_data/settings/providers.json');
      final aJson = await rootBundle.loadString('assets/mock_data/settings/personas.json');
      setState(() {
        _providers = jsonDecode(pJson) as List;
        _personas = jsonDecode(aJson) as List;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.moonColors!;
    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth > 700) {
        return Row(children: [
          SizedBox(width: 200, child: _sectionNav(colors)),
          VerticalDivider(width: 1, color: colors.beerus),
          Expanded(child: _content(colors)),
        ]);
      }
      return _content(colors, showHeader: true);
    });
  }

  Widget _sectionNav(MoonColors colors) {
    return Container(
      color: colors.goten,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
            label: Text(_sections[i],
              style: TextStyle(color: sel ? colors.piccolo : colors.bulma, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, fontSize: 14)),
          );
        }),
      ]),
    );
  }

  Widget _content(MoonColors colors, {bool showHeader = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
            0 => _buildAppearance(colors),
            1 => _buildProviders(colors),
            2 => _buildPersonas(colors),
            3 => _buildVoice(colors),
            4 => _buildSecurity(colors),
            5 => _buildData(colors),
            6 => _buildAbout(colors),
            _ => const SizedBox.shrink(),
          },
        ),
      ),
    ]);
  }

  // ── Appearance ──────────────────────────────────────────────────────

  Widget _buildAppearance(MoonColors colors) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle(colors, 'Appearance', 'Customize theme, colors, and display preferences'),

      // Theme mode
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
          _tp.setMode(modes[i]);
        },
      ),
      const SizedBox(height: 8),
      _toggleRow(colors, 'AMOLED Black', 'Pure black background for OLED screens', _tp.amoled, (v) => _tp.setAmoled(v)),

      _divider(colors),

      // Accent color
      _groupLabel(colors, 'ACCENT COLOR'),
      const SizedBox(height: 10),
      Wrap(spacing: 10, runSpacing: 10, children: List.generate(kThemePresets.length, (i) {
        final preset = kThemePresets[i];
        final sel = _tp.presetId == preset.id;
        return GestureDetector(
          onTap: () => _tp.setPreset(preset.id),
          child: Column(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: preset.accent,
                borderRadius: BorderRadius.circular(12),
                border: sel ? Border.all(color: Colors.white, width: 2.5) : null,
                boxShadow: sel ? [BoxShadow(color: preset.accent.withValues(alpha: 0.4), blurRadius: 12)] : null,
              ),
              child: sel ? const Icon(Icons.check_rounded, color: Colors.white, size: 20) : null,
            ),
            const SizedBox(height: 4),
            Text(preset.name, style: TextStyle(color: sel ? colors.bulma : colors.trunks, fontSize: 10, fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
          ]),
        );
      })),

      _divider(colors),

      // Display
      _groupLabel(colors, 'DISPLAY'),
      const SizedBox(height: 8),
      _toggleRow(colors, 'Compact Mode', 'Reduce spacing and padding', _tp.compactMode, (v) => _tp.setCompactMode(v)),
      _toggleRow(colors, 'Animations', 'Enable transitions and effects', _tp.animations, (v) => _tp.setAnimations(v)),
      const SizedBox(height: 8),
      _sliderRow(colors, 'Font Scale', _tp.fontScale, 0.8, 1.4, (v) => _tp.setFontScale(v)),
    ]);
  }

  // ── AI Providers ────────────────────────────────────────────────────

  Widget _buildProviders(MoonColors colors) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle(colors, 'AI Providers', 'Configure LLM providers and API keys'),
      _groupLabel(colors, 'LOCAL MODELS'),
      const SizedBox(height: 8),
      ..._providers.where((p) => (p as Map)['type'] == 'local').map((p) => _providerCard(colors, p as Map<String, dynamic>)),
      _divider(colors),
      _groupLabel(colors, 'CLOUD PROVIDERS'),
      const SizedBox(height: 8),
      ..._providers.where((p) => (p as Map)['type'] != 'local').map((p) => _providerCard(colors, p as Map<String, dynamic>)),
    ]);
  }

  Widget _providerCard(MoonColors colors, Map<String, dynamic> provider) {
    final models = (provider['models'] as List?) ?? [];
    return MoonAccordion<void>(
      backgroundColor: colors.goten,
      expandedBackgroundColor: colors.goten,
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      label: Row(children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            color: provider['isEnabled'] == true ? colors.roshi : colors.trunks,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(provider['name'] as String, style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w500, fontSize: 14))),
        MoonTag(
          tagSize: MoonTagSize.x2s,
          backgroundColor: provider['type'] == 'local' ? colors.krillin.withValues(alpha: 0.15) : colors.whis.withValues(alpha: 0.15),
          label: Text(provider['type'] as String, style: TextStyle(fontSize: 10, color: provider['type'] == 'local' ? colors.krillin : colors.whis)),
        ),
        const SizedBox(width: 8),
        MoonSwitch(switchSize: MoonSwitchSize.x2s, value: provider['isEnabled'] as bool, onChanged: (_) {}),
      ]),
      children: [
        if (provider['type'] != 'local') ...[
          MoonTextInput(
            hintText: 'API Key',
            textInputSize: MoonTextInputSize.sm,
            leading: Icon(Icons.key, size: 14, color: colors.trunks),
            trailing: provider['apiKeyConfigured'] == true ? Icon(Icons.check_circle, size: 14, color: colors.roshi) : null,
          ),
          const SizedBox(height: 8),
        ],
        Text('Models', style: TextStyle(color: colors.trunks, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        ...models.map((m) {
          final model = m as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(children: [
              Text(model['name'] as String, style: TextStyle(color: colors.bulma, fontSize: 12)),
              const SizedBox(width: 6),
              Text('${((model['contextWindow'] as num) / 1000).toStringAsFixed(0)}K ctx', style: TextStyle(color: colors.trunks, fontSize: 10)),
              const Spacer(),
              if (model['isDefault'] == true)
                MoonTag(tagSize: MoonTagSize.x2s, backgroundColor: colors.piccolo.withValues(alpha: 0.15),
                  label: Text('default', style: TextStyle(fontSize: 9, color: colors.piccolo))),
            ]),
          );
        }),
        const SizedBox(height: 8),
        Row(children: [MoonOutlinedButton(onTap: () {}, buttonSize: MoonButtonSize.sm, label: const Text('Test Connection'))]),
      ],
    );
  }

  // ── Personas ────────────────────────────────────────────────────────

  Widget _buildPersonas(MoonColors colors) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: _sectionTitle(colors, 'Personas', 'AI personalities for different use cases')),
        MoonFilledButton(onTap: () {}, buttonSize: MoonButtonSize.sm, label: const Text('New'), leading: const Icon(Icons.add, size: 16)),
      ]),
      const SizedBox(height: 8),
      ..._personas.map((p) => _personaCard(colors, p as Map<String, dynamic>)),
    ]);
  }

  Widget _personaCard(MoonColors colors, Map<String, dynamic> persona) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.goten,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: persona['isDefault'] == true ? colors.piccolo : colors.beerus, width: persona['isDefault'] == true ? 1.5 : 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(persona['avatar'] as String, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(persona['name'] as String, style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w600, fontSize: 15)),
            Text(persona['role'] as String, style: TextStyle(color: colors.trunks, fontSize: 12)),
          ])),
          if (persona['isDefault'] == true)
            MoonTag(tagSize: MoonTagSize.x2s, backgroundColor: colors.piccolo.withValues(alpha: 0.15),
              label: Text('default', style: TextStyle(fontSize: 10, color: colors.piccolo))),
        ]),
        const SizedBox(height: 8),
        Text(persona['systemPrompt'] as String, maxLines: 2, overflow: TextOverflow.ellipsis,
          style: TextStyle(color: colors.trunks, fontSize: 12, height: 1.4)),
        const SizedBox(height: 8),
        Row(children: [
          _miniStat(colors, '${persona['conversationCount']} chats'),
          const SizedBox(width: 8),
          _miniStat(colors, '${persona['totalMessages']} msgs'),
          const SizedBox(width: 8),
          _miniStat(colors, 'temp: ${persona['temperature']}'),
        ]),
      ]),
    );
  }

  // ── Voice & Input ───────────────────────────────────────────────────

  Widget _buildVoice(MoonColors colors) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle(colors, 'Voice & Input', 'Configure voice recognition and input methods'),
      _groupLabel(colors, 'VOICE'),
      const SizedBox(height: 8),
      _toggleRow(colors, 'Voice Input', 'Use microphone for hands-free interaction', _voiceEnabled, (v) => setState(() => _voiceEnabled = v)),
      _infoCard(colors, Icons.mic_none_rounded, 'Voice processing happens entirely on-device. No audio is sent to the cloud.'),
      _divider(colors),
      _groupLabel(colors, 'INTERACTION'),
      const SizedBox(height: 8),
      _toggleRow(colors, 'Haptic Feedback', 'Vibrate on key interactions', _hapticFeedback, (v) => setState(() => _hapticFeedback = v)),
      _statusRow(colors, 'Wake Word', 'Coming in v0.3', false),
      _statusRow(colors, 'Continuous Listening', 'Coming in v0.4', false),
    ]);
  }

  // ── Security ────────────────────────────────────────────────────────

  Widget _buildSecurity(MoonColors colors) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle(colors, 'Privacy & Security', 'Protect your data and access'),
      MoonAlert(
        show: true,
        backgroundColor: colors.roshi.withValues(alpha: 0.08),
        leading: Icon(Icons.shield, size: 18, color: colors.roshi),
        label: Text('All data stored locally with encryption.', style: TextStyle(color: colors.roshi, fontSize: 12)),
      ),
      const SizedBox(height: 16),
      _groupLabel(colors, 'ACCESS'),
      const SizedBox(height: 8),
      _toggleRow(colors, 'Biometric Unlock', 'Fingerprint or face to unlock', _biometric, (v) => setState(() => _biometric = v)),
      MoonTextInput(hintText: 'Set app password', textInputSize: MoonTextInputSize.sm, leading: Icon(Icons.lock_outline, size: 14, color: colors.trunks)),
      _divider(colors),
      _groupLabel(colors, 'DATA'),
      const SizedBox(height: 8),
      _toggleRow(colors, 'Analytics', 'Anonymous usage data (opt-in)', _analyticsEnabled, (v) => setState(() => _analyticsEnabled = v)),
      _toggleRow(colors, 'Notifications', 'Task reminders and updates', _notifEnabled, (v) => setState(() => _notifEnabled = v)),
      const SizedBox(height: 12),
      Row(children: [
        MoonOutlinedButton(onTap: () {}, buttonSize: MoonButtonSize.sm, label: const Text('Export Keys'), leading: const Icon(Icons.download, size: 16)),
        const SizedBox(width: 8),
        MoonOutlinedButton(onTap: () {}, buttonSize: MoonButtonSize.sm, label: const Text('Import Keys'), leading: const Icon(Icons.upload, size: 16)),
      ]),
    ]);
  }

  // ── Data & Storage ──────────────────────────────────────────────────

  Widget _buildData(MoonColors colors) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle(colors, 'Data & Storage', 'Manage local data and cached models'),
      _groupLabel(colors, 'STORAGE'),
      const SizedBox(height: 8),
      _storageRow(colors, 'Conversations', '2.4 MB', Icons.chat_bubble_outline),
      _storageRow(colors, 'Brain Documents', '8.1 MB', Icons.auto_awesome_outlined),
      _storageRow(colors, 'Downloaded Models', '0 B', Icons.download_done_outlined),
      _storageRow(colors, 'Cache', '1.2 MB', Icons.cached_rounded),
      _divider(colors),
      _groupLabel(colors, 'ACTIONS'),
      const SizedBox(height: 8),
      Row(children: [
        MoonOutlinedButton(onTap: () {}, buttonSize: MoonButtonSize.sm, label: const Text('Export All Data'), leading: const Icon(Icons.file_download_outlined, size: 16)),
        const SizedBox(width: 8),
        MoonOutlinedButton(onTap: () {}, buttonSize: MoonButtonSize.sm, label: const Text('Import Data'), leading: const Icon(Icons.file_upload_outlined, size: 16)),
      ]),
      const SizedBox(height: 12),
      MoonOutlinedButton(
        onTap: () {},
        buttonSize: MoonButtonSize.sm,
        borderColor: Colors.redAccent,
        label: const Text('Clear All Data', style: TextStyle(color: Colors.redAccent)),
        leading: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
      ),
    ]);
  }

  // ── About ───────────────────────────────────────────────────────────

  Widget _buildAbout(MoonColors colors) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Center(child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: colors.goten, borderRadius: BorderRadius.circular(16), border: Border.all(color: colors.beerus, width: 0.5)),
        child: Column(children: [
          Container(width: 56, height: 56, decoration: BoxDecoration(color: colors.piccolo, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28)),
          const SizedBox(height: 12),
          Text('Prism', style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w700, fontSize: 22)),
          const SizedBox(height: 4),
          Text('AI Personal Assistant', style: TextStyle(color: colors.trunks, fontSize: 14)),
          const SizedBox(height: 8),
          MoonTag(tagSize: MoonTagSize.x2s, backgroundColor: colors.piccolo.withValues(alpha: 0.15),
            label: Text('v0.1.0-alpha', style: TextStyle(fontSize: 11, color: colors.piccolo))),
          const SizedBox(height: 16),
          Text('Your intelligent, privacy-first personal assistant.\nPowered by local and cloud LLMs.',
            textAlign: TextAlign.center, style: TextStyle(color: colors.trunks, fontSize: 13, height: 1.5)),
          const SizedBox(height: 20),
          _aboutRow(colors, 'Framework', 'Flutter + Moon Design'),
          _aboutRow(colors, 'License', 'AGPL-3.0'),
          _aboutRow(colors, 'Platform', 'Android, iOS, Web, Desktop'),
        ]),
      )),
    ]);
  }

  // ── Shared widgets ──────────────────────────────────────────────────

  Widget _sectionTitle(MoonColors colors, String title, String sub) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 4),
        Text(sub, style: TextStyle(color: colors.trunks, fontSize: 13)),
      ]),
    );
  }

  Widget _groupLabel(MoonColors colors, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(text, style: TextStyle(color: colors.trunks, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1)),
    );
  }

  Widget _divider(MoonColors colors) => Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Divider(color: colors.beerus, height: 1));

  Widget _toggleRow(MoonColors colors, String title, String sub, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: colors.goten, borderRadius: BorderRadius.circular(10), border: Border.all(color: colors.beerus, width: 0.5)),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w500, fontSize: 14)),
          const SizedBox(height: 2),
          Text(sub, style: TextStyle(color: colors.trunks, fontSize: 12)),
        ])),
        MoonSwitch(switchSize: MoonSwitchSize.x2s, value: value, onChanged: onChanged),
      ]),
    );
  }

  Widget _statusRow(MoonColors colors, String title, String status, bool available) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: colors.goten, borderRadius: BorderRadius.circular(10), border: Border.all(color: colors.beerus, width: 0.5)),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w500, fontSize: 14)),
          const SizedBox(height: 2),
          Text(status, style: TextStyle(color: colors.trunks, fontSize: 12)),
        ])),
        MoonTag(tagSize: MoonTagSize.x2s, backgroundColor: colors.krillin.withValues(alpha: 0.15),
          label: Text(available ? 'ready' : 'planned', style: TextStyle(fontSize: 10, color: colors.krillin))),
      ]),
    );
  }

  Widget _sliderRow(MoonColors colors, String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: colors.goten, borderRadius: BorderRadius.circular(10), border: Border.all(color: colors.beerus, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(label, style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w500, fontSize: 14)),
          const Spacer(),
          Text('${(value * 100).round()}%', style: TextStyle(color: colors.trunks, fontSize: 12)),
        ]),
        SliderTheme(
          data: SliderThemeData(activeTrackColor: colors.piccolo, thumbColor: colors.piccolo, inactiveTrackColor: colors.beerus, overlayColor: colors.piccolo.withValues(alpha: 0.1)),
          child: Slider(value: value, min: min, max: max, divisions: 12, onChanged: onChanged),
        ),
      ]),
    );
  }

  Widget _infoCard(MoonColors colors, IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: colors.piccolo.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        Icon(icon, size: 18, color: colors.piccolo),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: TextStyle(color: colors.trunks, fontSize: 12, height: 1.4))),
      ]),
    );
  }

  Widget _storageRow(MoonColors colors, String label, String size, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: colors.goten, borderRadius: BorderRadius.circular(10), border: Border.all(color: colors.beerus, width: 0.5)),
      child: Row(children: [
        Icon(icon, size: 18, color: colors.trunks),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: TextStyle(color: colors.bulma, fontSize: 14))),
        Text(size, style: TextStyle(color: colors.trunks, fontSize: 12, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _aboutRow(MoonColors colors, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('$label: ', style: TextStyle(color: colors.trunks, fontSize: 11)),
        Text(value, style: TextStyle(color: colors.bulma, fontSize: 11, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _miniStat(MoonColors colors, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: colors.gohan, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(color: colors.trunks, fontSize: 10)),
    );
  }

  IconData _sectionIcon(int index) {
    return switch (index) {
      0 => Icons.palette_outlined,
      1 => Icons.cloud_outlined,
      2 => Icons.person_outline,
      3 => Icons.mic_outlined,
      4 => Icons.shield_outlined,
      5 => Icons.storage_outlined,
      6 => Icons.info_outline,
      _ => Icons.settings,
    };
  }
}
