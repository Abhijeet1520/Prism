/// Appearance settings section — theme mode and accent colors.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/prism_theme.dart';
import 'settings_shared_widgets.dart';

class AppearanceSection extends ConsumerWidget {
  final Color cardColor, borderColor, textPrimary, textSecondary, accentColor;
  const AppearanceSection(
      {super.key,
      required this.cardColor,
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
        SectionHeader(
            title: 'Appearance',
            subtitle: 'Customize theme and colors',
            textPrimary: textPrimary,
            textSecondary: textSecondary),

        GroupLabel(text: 'THEME MODE', color: textSecondary),
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
                            color:
                                theme.mode == mode ? accentColor : borderColor,
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
        ToggleRow(
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

        SettingsDivider(color: borderColor),

        GroupLabel(text: 'ACCENT COLOR', color: textSecondary),
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
