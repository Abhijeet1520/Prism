import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import 'chat_screen.dart';

class ConversationListScreen extends StatelessWidget {
  const ConversationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pinned =
        MockData.conversations.where((c) => c.isPinned).toList();
    final recent =
        MockData.conversations.where((c) => !c.isPinned).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('💬 Chats'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          if (pinned.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4, top: 4),
              child: Text(
                '📌 Pinned',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            ...pinned.map((c) => _ConversationTile(conversation: c)),
            const SizedBox(height: 12),
          ],
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Text(
              'Recent',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          ...recent.map((c) => _ConversationTile(conversation: c)),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text('Show Archived'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: CircleAvatar(
          backgroundColor: cs.primaryContainer,
          child: const Icon(Icons.smart_toy_outlined, size: 20),
        ),
        title: Text(
          conversation.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              conversation.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${conversation.timeAgo} · ${conversation.model}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChatScreen(conversation: conversation),
            ),
          );
        },
        trailing: conversation.isPinned
            ? Icon(Icons.push_pin, size: 16, color: cs.primary)
            : null,
      ),
    );
  }
}
