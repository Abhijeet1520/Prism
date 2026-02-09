/// Voice & Input settings section — voice, haptic, keyboard options.
library;

import 'package:flutter/material.dart';

import 'settings_shared_widgets.dart';

class VoiceSection extends StatelessWidget {
  final Color cardColor, borderColor, textPrimary, textSecondary, accentColor;
  const VoiceSection(
      {super.key,
      required this.cardColor,
      required this.borderColor,
      required this.textPrimary,
      required this.textSecondary,
      required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
            title: 'Voice & Input',
            subtitle: 'Configure input methods',
            textPrimary: textPrimary,
            textSecondary: textSecondary),

        ToggleRow(
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
        ToggleRow(
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
        ToggleRow(
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
