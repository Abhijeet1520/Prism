/// Privacy & Security settings section — data privacy info cards.
library;

import 'package:flutter/material.dart';

import 'settings_shared_widgets.dart';

class PrivacySection extends StatelessWidget {
  final Color cardColor, borderColor, textPrimary, textSecondary, accentColor;
  const PrivacySection(
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
            title: 'Privacy & Security',
            subtitle: 'Protect your data and access',
            textPrimary: textPrimary,
            textSecondary: textSecondary),

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

        InfoCard(
          icon: Icons.dns_outlined,
          text:
              'AI models run locally via llama.cpp. Cloud providers require your own API key.',
          cardColor: cardColor,
          borderColor: borderColor,
          textSecondary: textSecondary,
          accentColor: accentColor,
        ),
        InfoCard(
          icon: Icons.visibility_off_outlined,
          text: 'No analytics, telemetry, or tracking. Period.',
          cardColor: cardColor,
          borderColor: borderColor,
          textSecondary: textSecondary,
          accentColor: accentColor,
        ),
        InfoCard(
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
