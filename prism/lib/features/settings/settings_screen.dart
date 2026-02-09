/// Settings Screen  7 sections with responsive layout.
///
/// Appearance, AI Providers (local model management), Personas,
/// Voice & Input, Privacy, Data, About. Matches ux_preview design.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'appearance_section.dart';
import 'providers_section.dart';
import 'personas_section.dart';
import 'voice_section.dart';
import 'privacy_section.dart';
import 'data_section.dart';
import 'about_section.dart';

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
        0 => AppearanceSection(
            cardColor: cardColor,
            borderColor: borderColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            accentColor: accentColor),
        1 => ProvidersSection(
            cardColor: cardColor,
            borderColor: borderColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            accentColor: accentColor),
        2 => PersonasSection(
            cardColor: cardColor,
            borderColor: borderColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            accentColor: accentColor),
        3 => VoiceSection(
            cardColor: cardColor,
            borderColor: borderColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            accentColor: accentColor),
        4 => PrivacySection(
            cardColor: cardColor,
            borderColor: borderColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            accentColor: accentColor),
        5 => DataSection(
            cardColor: cardColor,
            borderColor: borderColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            accentColor: accentColor),
        6 => AboutSection(
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

// Side Navigation (wide)

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
