/// Settings Screen — accordion sections with responsive layout.
///
/// AI Providers (open by default), Appearance, Personas,
/// Voice & Input, Privacy, Data, About. Matches ux_preview design.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'appearance_section.dart';
import 'providers_section.dart';
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
  // AI Providers (index 0) is open by default; rest closed
  late final Set<int> _expandedSections = {0};

  // Sections with AI Providers first
  static const _sections = [
    ('AI Providers', Icons.model_training_outlined),
    ('Appearance', Icons.palette_outlined),
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
            // Wide: side nav stays, content area shows selected section
            return Row(
              children: [
                SizedBox(
                  width: 200,
                  child: _SideNav(
                    sections: _sections,
                    expandedSections: _expandedSections,
                    onToggle: (i) => setState(() {
                      if (_expandedSections.contains(i)) {
                        _expandedSections.remove(i);
                      } else {
                        _expandedSections.add(i);
                      }
                    }),
                    cardColor: cardColor,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    accentColor: accentColor,
                  ),
                ),
                VerticalDivider(width: 1, color: borderColor),
                Expanded(
                  child: _buildWideContent(
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

          // Mobile: accordion layout with all sections
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
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
              Expanded(
                child: _buildAccordionContent(
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

  Widget _buildAccordionContent({
    required bool isDark,
    required Color cardColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color accentColor,
  }) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: _sections.length,
      itemBuilder: (context, i) {
        final isExpanded = _expandedSections.contains(i);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isExpanded ? accentColor.withValues(alpha: 0.3) : borderColor,
              width: isExpanded ? 1 : 0.5,
            ),
          ),
          child: Column(
            children: [
              // Accordion header
              InkWell(
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(12),
                  bottom: Radius.circular(isExpanded ? 0 : 12),
                ),
                onTap: () => setState(() {
                  if (_expandedSections.contains(i)) {
                    _expandedSections.remove(i);
                  } else {
                    _expandedSections.add(i);
                  }
                }),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(_sections[i].$2,
                          size: 20,
                          color: isExpanded ? accentColor : textSecondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _sections[i].$1,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isExpanded ? FontWeight.w600 : FontWeight.w500,
                            color: isExpanded ? accentColor : textPrimary,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(Icons.expand_more_rounded,
                            size: 22, color: textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              // Accordion body
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _buildSectionContent(
                    i,
                    isDark: isDark,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    accentColor: accentColor,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWideContent({
    required bool isDark,
    required Color cardColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color accentColor,
  }) {
    // Show all expanded sections in scrollable view
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          for (int i = 0; i < _sections.length; i++)
            if (_expandedSections.contains(i))
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildSectionContent(
                  i,
                  isDark: isDark,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  accentColor: accentColor,
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildSectionContent(
    int index, {
    required bool isDark,
    required Color cardColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color accentColor,
  }) {
    return switch (index) {
      0 => ProvidersSection(
          cardColor: cardColor,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          accentColor: accentColor),
      1 => AppearanceSection(
          cardColor: cardColor,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          accentColor: accentColor),
      2 => VoiceSection(
          cardColor: cardColor,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          accentColor: accentColor),
      3 => PrivacySection(
          cardColor: cardColor,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          accentColor: accentColor),
      4 => DataSection(
          cardColor: cardColor,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          accentColor: accentColor),
      5 => AboutSection(
          cardColor: cardColor,
          borderColor: borderColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          accentColor: accentColor),
      _ => const SizedBox.shrink(),
    };
  }
}

// Side Navigation (wide) — now uses checkmarks for expanded sections

class _SideNav extends StatelessWidget {
  final List<(String, IconData)> sections;
  final Set<int> expandedSections;
  final ValueChanged<int> onToggle;
  final Color cardColor, borderColor, textPrimary, textSecondary, accentColor;

  const _SideNav({
    required this.sections,
    required this.expandedSections,
    required this.onToggle,
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
            final sel = expandedSections.contains(i);
            return GestureDetector(
              onTap: () => onToggle(i),
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
                    Expanded(
                      child: Text(sections[i].$1,
                          style: TextStyle(
                              fontSize: 13,
                              color: sel ? accentColor : textPrimary,
                              fontWeight:
                                  sel ? FontWeight.w600 : FontWeight.w400)),
                    ),
                    if (sel)
                      Icon(Icons.check_rounded,
                          size: 16, color: accentColor),
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
