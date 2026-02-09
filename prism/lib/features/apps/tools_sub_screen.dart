/// Tools sub-screen — 6 ML Kit tools in a responsive grid.
library;

import 'package:flutter/material.dart';

class ToolsSubScreen extends StatelessWidget {
  final bool isDark;
  final Color cardColor, borderColor, textPrimary, textSecondary;

  const ToolsSubScreen({
    super.key,
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  static const _tools = [
    ('OCR Scanner', Icons.document_scanner_outlined,
        'Extract text from images', Color(0xFF3B82F6)),
    ('Language ID', Icons.translate_rounded,
        'Identify text language', Color(0xFF8B5CF6)),
    ('Smart Reply', Icons.quickreply_outlined,
        'Get suggest replies', Color(0xFF10B981)),
    ('Entity Extract', Icons.category_outlined,
        'Find dates, phones, etc.', Color(0xFFF59E0B)),
    ('Summarize', Icons.summarize_outlined,
        'Summarize long text with AI', Color(0xFFEC4899)),
    ('Translate', Icons.g_translate_rounded,
        'Translate text on-device', Color(0xFF06B6D4)),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: _tools.length,
      itemBuilder: (context, i) {
        final tool = _tools[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: tool.$4.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(tool.$2, color: tool.$4, size: 18),
              ),
              const Spacer(),
              Text(tool.$1,
                  style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
              const SizedBox(height: 2),
              Text(tool.$3,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: textSecondary, fontSize: 11)),
            ],
          ),
        );
      },
    );
  }
}
