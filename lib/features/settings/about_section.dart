/// About settings section — app version and tech stack info.
library;

import 'package:flutter/material.dart';

class AboutSection extends StatelessWidget {
  final Color cardColor, borderColor, textPrimary, textSecondary, accentColor;
  const AboutSection(
      {super.key,
      required this.cardColor,
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
            _aboutRow(
                'Local AI', 'llama.cpp (llama_sdk)', textPrimary, textSecondary),
            _aboutRow(
                'Cloud AI', 'LangChain.dart', textPrimary, textSecondary),
            _aboutRow('Database', 'Drift + SQLite + FTS5', textPrimary,
                textSecondary),
            _aboutRow(
                'ML Kit', 'OCR, NER, Smart Reply', textPrimary, textSecondary),
            _aboutRow('License', 'AGPL-3.0', textPrimary, textSecondary),
            const SizedBox(height: 12),
            _aboutRow('Built by', 'Abhijeet', textPrimary, textSecondary),
            _aboutRow('Portfolio', 'abhi1520.com', textPrimary, textSecondary),
            _aboutRow('GitHub', 'Abhijeet1520', textPrimary, textSecondary),
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
