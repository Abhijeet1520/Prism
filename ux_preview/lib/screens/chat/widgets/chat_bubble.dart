import 'package:flutter/material.dart';
import '../../../data/mock_data.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final cs = Theme.of(context).colorScheme;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.85,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Role header
            Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 4, right: 4),
              child: Text(
                isUser
                    ? 'You'
                    : 'Gemmie (${message.model ?? "AI"})',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    ),
              ),
            ),
            // Message card
            Card(
              color: isUser
                  ? cs.primaryContainer
                  : cs.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Attachment
                    if (message.attachment != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.attach_file,
                                size: 16, color: cs.primary),
                            const SizedBox(width: 4),
                            Text(
                              message.attachment!,
                              style: TextStyle(color: cs.primary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    // Tool indicator
                    if (message.toolUsed != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: cs.tertiaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.build_outlined,
                                size: 14, color: cs.onTertiaryContainer),
                            const SizedBox(width: 4),
                            Text(
                              '🔧 ${message.toolUsed} · ✅ Complete',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: cs.onTertiaryContainer),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    // Content
                    SelectableText(
                      message.content,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: isUser
                            ? cs.onPrimaryContainer
                            : cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Action buttons for assistant messages
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ActionBtn(Icons.refresh, 'Regenerate', cs),
                    _ActionBtn(Icons.copy, 'Copy', cs),
                    _ActionBtn(Icons.thumb_up_outlined, null, cs),
                    _ActionBtn(Icons.thumb_down_outlined, null, cs),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String? label;
  final ColorScheme cs;

  const _ActionBtn(this.icon, this.label, this.cs);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 2),
      child: label != null
          ? TextButton.icon(
              onPressed: () {},
              icon: Icon(icon, size: 14),
              label: Text(label!, style: const TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                foregroundColor: cs.onSurfaceVariant,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 6),
              ),
            )
          : IconButton(
              onPressed: () {},
              icon: Icon(icon, size: 16),
              color: cs.onSurfaceVariant,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
    );
  }
}
