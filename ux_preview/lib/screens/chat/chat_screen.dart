import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/model_selector_sheet.dart';

class ChatScreen extends StatelessWidget {
  final Conversation conversation;
  const ChatScreen({super.key, required this.conversation});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(conversation.title),
        actions: [
          ActionChip(
            avatar: const Icon(Icons.memory, size: 16),
            label: Text(conversation.model),
            onPressed: () => _showModelSelector(context),
          ),
          const SizedBox(width: 4),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: MockData.chatMessages.length,
              itemBuilder: (context, index) {
                return ChatBubble(message: MockData.chatMessages[index]);
              },
            ),
          ),
          // Input bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(top: BorderSide(color: cs.outlineVariant)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.attach_file),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.mic_outlined),
                        onPressed: () {},
                      ),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        icon: const Icon(Icons.send),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Using: ${conversation.model} (${conversation.provider}) · ${conversation.tokenCount} tokens',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showModelSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const ModelSelectorSheet(),
    );
  }
}
