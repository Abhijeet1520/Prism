import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moon_design/moon_design.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<dynamic> _providers = [];
  List<dynamic> _personas = [];
  int _themeIndex = 2; // ignore: unused_field -- used by segmented control
  bool _compactMode = false;
  bool _animations = true;
  bool _biometric = false;
  int _selectedSection = 0;

  static const _sections = ['AI Providers', 'Personas', 'Appearance', 'Security', 'About'];

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  Future<void> _loadMockData() async {
    final providersJson = await rootBundle.loadString('assets/mock_data/settings/providers.json');
    final personasJson = await rootBundle.loadString('assets/mock_data/settings/personas.json');
    setState(() {
      _providers = jsonDecode(providersJson) as List;
      _personas = jsonDecode(personasJson) as List;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.moonColors!;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 700) {
          return Row(
            children: [
              SizedBox(width: 200, child: _buildSectionList(colors)),
              VerticalDivider(width: 1, color: colors.beerus),
              Expanded(child: _buildSectionContent(colors)),
            ],
          );
        }
        return _buildSectionContent(colors, showHeader: true);
      },
    );
  }

  Widget _buildSectionList(MoonColors colors) {
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
            final selected = _selectedSection == i;
            return MoonMenuItem(
              onTap: () => setState(() => _selectedSection = i),
              backgroundColor: selected ? colors.piccolo.withValues(alpha: 0.08) : Colors.transparent,
              leading: Icon(
                _sectionIcon(i),
                size: 18,
                color: selected ? colors.piccolo : colors.trunks,
              ),
              label: Text(
                _sections[i],
                style: TextStyle(
                  color: selected ? colors.piccolo : colors.bulma,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionContent(MoonColors colors, {bool showHeader = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.goten,
              border: Border(bottom: BorderSide(color: colors.beerus)),
            ),
            child: Row(
              children: [
                Text('Settings', style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w700, fontSize: 18)),
                const Spacer(),
              ],
            ),
          ),
          // Mobile tabs
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
              0 => _buildProviders(colors),
              1 => _buildPersonas(colors),
              2 => _buildAppearance(colors),
              3 => _buildSecurity(colors),
              4 => _buildAbout(colors),
              _ => const SizedBox.shrink(),
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProviders(MoonColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AI Providers', style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 4),
        Text('Configure LLM providers and API keys.', style: TextStyle(color: colors.trunks, fontSize: 13)),
        const SizedBox(height: 16),
        ..._providers.map((p) {
          final provider = p as Map<String, dynamic>;
          final models = provider['models'] as List;
          return MoonAccordion<void>(
            backgroundColor: colors.goten,
            expandedBackgroundColor: colors.goten,
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            label: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: provider['isEnabled'] == true ? colors.roshi : colors.trunks,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    provider['name'] as String,
                    style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                ),
                MoonTag(
                  tagSize: MoonTagSize.x2s,
                  backgroundColor: provider['type'] == 'local' ? colors.krillin.withValues(alpha: 0.15) : colors.whis.withValues(alpha: 0.15),
                  label: Text(
                    provider['type'] as String,
                    style: TextStyle(fontSize: 10, color: provider['type'] == 'local' ? colors.krillin : colors.whis),
                  ),
                ),
                const SizedBox(width: 8),
                MoonSwitch(
                  switchSize: MoonSwitchSize.x2s,
                  value: provider['isEnabled'] as bool,
                  onChanged: (_) {},
                ),
              ],
            ),
            children: [
              if (provider['type'] != 'local') ...[
                MoonTextInput(
                  hintText: 'API Key',
                  textInputSize: MoonTextInputSize.sm,
                  leading: Icon(Icons.key, size: 14, color: colors.trunks),
                  trailing: provider['apiKeyConfigured'] == true
                      ? Icon(Icons.check_circle, size: 14, color: colors.roshi)
                      : null,
                ),
                const SizedBox(height: 8),
              ],
              Text('Models', style: TextStyle(color: colors.trunks, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              ...models.map((m) {
                final model = m as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Text(model['name'] as String, style: TextStyle(color: colors.bulma, fontSize: 12)),
                      const SizedBox(width: 6),
                      Text(
                        '${((model['contextWindow'] as num) / 1000).toStringAsFixed(0)}K ctx',
                        style: TextStyle(color: colors.trunks, fontSize: 10),
                      ),
                      const Spacer(),
                      if (model['isDefault'] == true)
                        MoonTag(
                          tagSize: MoonTagSize.x2s,
                          backgroundColor: colors.piccolo.withValues(alpha: 0.15),
                          label: Text('default', style: TextStyle(fontSize: 9, color: colors.piccolo)),
                        ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              Row(
                children: [
                  MoonOutlinedButton(
                    onTap: () {},
                    buttonSize: MoonButtonSize.sm,
                    label: const Text('Test Connection'),
                  ),
                ],
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildPersonas(MoonColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Personas', style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Customize AI personalities for different use cases.', style: TextStyle(color: colors.trunks, fontSize: 13)),
                ],
              ),
            ),
            MoonFilledButton(
              onTap: () {},
              buttonSize: MoonButtonSize.sm,
              label: const Text('New Persona'),
              leading: const Icon(Icons.add, size: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._personas.map((p) {
          final persona = p as Map<String, dynamic>;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.goten,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: persona['isDefault'] == true ? colors.piccolo : colors.beerus,
                width: persona['isDefault'] == true ? 1.5 : 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(persona['avatar'] as String, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            persona['name'] as String,
                            style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                          Text(
                            persona['role'] as String,
                            style: TextStyle(color: colors.trunks, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    if (persona['isDefault'] == true)
                      MoonTag(
                        tagSize: MoonTagSize.x2s,
                        backgroundColor: colors.piccolo.withValues(alpha: 0.15),
                        label: Text('default', style: TextStyle(fontSize: 10, color: colors.piccolo)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  persona['systemPrompt'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.trunks, fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _miniStat(colors, '${persona['conversationCount']} chats'),
                    const SizedBox(width: 8),
                    _miniStat(colors, '${persona['totalMessages']} msgs'),
                    const SizedBox(width: 8),
                    _miniStat(colors, 'temp: ${persona['temperature']}'),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAppearance(MoonColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Appearance', style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 16),
        Text('Theme', style: TextStyle(color: colors.trunks, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        MoonSegmentedControl(
          segmentedControlSize: MoonSegmentedControlSize.sm,
          isExpanded: true,
          segments: const [
            Segment(label: Text('Light')),
            Segment(label: Text('System')),
            Segment(label: Text('Dark')),
          ],
          onSegmentChanged: (i) => setState(() => _themeIndex = i),
        ),
        const SizedBox(height: 20),
        _toggleRow(colors, 'Compact Mode', 'Reduce spacing and padding', _compactMode, (v) => setState(() => _compactMode = v)),
        _toggleRow(colors, 'Animations', 'Enable UI transitions and effects', _animations, (v) => setState(() => _animations = v)),
      ],
    );
  }

  Widget _buildSecurity(MoonColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Security', style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 16),
        MoonAlert(
          show: true,
          backgroundColor: colors.roshi.withValues(alpha: 0.08),
          leading: Icon(Icons.shield, size: 18, color: colors.roshi),
          label: Text('All data stored locally with encryption enabled.', style: TextStyle(color: colors.roshi, fontSize: 12)),
        ),
        const SizedBox(height: 16),
        _toggleRow(colors, 'Biometric Unlock', 'Use fingerprint or face to unlock', _biometric, (v) => setState(() => _biometric = v)),
        const SizedBox(height: 12),
        MoonTextInput(
          hintText: 'Set app password',
          textInputSize: MoonTextInputSize.sm,
          leading: Icon(Icons.lock_outline, size: 14, color: colors.trunks),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            MoonOutlinedButton(
              onTap: () {},
              buttonSize: MoonButtonSize.sm,
              label: const Text('Export Keys'),
              leading: const Icon(Icons.download, size: 16),
            ),
            const SizedBox(width: 8),
            MoonOutlinedButton(
              onTap: () {},
              buttonSize: MoonButtonSize.sm,
              label: const Text('Import Keys'),
              leading: const Icon(Icons.upload, size: 16),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAbout(MoonColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About Prism', style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.goten,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.beerus, width: 0.5),
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colors.piccolo,
                  borderRadius: BorderRadius.circular(14),
                ),
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
                'Your intelligent, privacy-first personal assistant. Powered by local and cloud LLMs.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.trunks, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 16),
              Text('Built with Flutter & Moon Design', style: TextStyle(color: colors.trunks, fontSize: 11)),
              Text('License: AGPL-3.0', style: TextStyle(color: colors.trunks, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _toggleRow(MoonColors colors, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
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
          MoonSwitch(
            switchSize: MoonSwitchSize.x2s,
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _miniStat(MoonColors colors, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.gohan,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(color: colors.trunks, fontSize: 10)),
    );
  }

  IconData _sectionIcon(int index) {
    return switch (index) {
      0 => Icons.cloud_outlined,
      1 => Icons.person_outline,
      2 => Icons.palette_outlined,
      3 => Icons.shield_outlined,
      4 => Icons.info_outline,
      _ => Icons.settings,
    };
  }
}
