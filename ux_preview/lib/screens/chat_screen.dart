import 'package:shadcn_flutter/shadcn_flutter.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  int _selectedConversation = 0;

  static const _conversations = [
    'Flutter Architecture Help',
    'Dart Design Patterns',
    'API Integration Guide',
    'Code Review: Auth Module',
    'Database Schema Design',
  ];

  static const _messages = [
    _Msg(role: 'user', text: 'Can you help me design a clean architecture for my Flutter app?'),
    _Msg(
      role: 'assistant',
      text:
          'I recommend a feature-first modular architecture with Riverpod for state management. Here\'s the structure:\n\n'
          '```\nlib/\n  core/       # Shared infrastructure\n  features/   # Feature modules\n  shared/     # Shared widgets\n```\n\n'
          'Each feature module contains its own providers, repositories, models, and UI. This keeps concerns separated and makes testing easier.',
    ),
    _Msg(role: 'user', text: 'What about the database layer? Should I use Drift or Hive?'),
    _Msg(
      role: 'assistant',
      text:
          'I strongly recommend **Drift** over Hive for your use case:\n\n'
          '- **Type-safe** queries with compile-time verification\n'
          '- **Reactive** streams — UI updates automatically when data changes\n'
          '- **SQL power** — JOINs, aggregations, FTS5 full-text search\n'
          '- **Web support** via sql.js\n'
          '- **Flutter Favorite** with 2,300+ likes\n\n'
          'Hive CE is good for simple key-value storage, but Drift is the right choice for relational data like conversations, messages, and tasks.',
    ),
    _Msg(role: 'user', text: 'That makes sense. Can you show me a Drift table definition?'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Conversation sidebar (desktop only)
        if (MediaQuery.of(context).size.width > 800)
          SizedBox(
            width: 280,
            child: _buildConversationList(),
          ),
        Expanded(child: _buildChatArea()),
      ],
    );
  }

  Widget _buildConversationList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  placeholder: const Text('Search chats...'),
                ),
              ),
              const SizedBox(width: 8),
              Button.outline(
                onPressed: () {},
                child: const Icon(RadixIcons.plus),
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: _conversations.length,
            itemBuilder: (context, index) {
              final isSelected = index == _selectedConversation;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                child: Button(
                  style: isSelected
                      ? const ButtonStyle.secondary(density: ButtonDensity.compact)
                      : const ButtonStyle.ghost(density: ButtonDensity.compact),
                  onPressed: () => setState(() => _selectedConversation = index),
                  child: Row(
                    children: [
                      const Icon(RadixIcons.chatBubble, size: 14),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _conversations[index],
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (index == 0) const PrimaryBadge(child: Text('3')),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChatArea() {
    return Column(
      children: [
        // Chat header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.border)),
          ),
          child: Row(
            children: [
              const Avatar(initials: 'FA', size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_conversations[_selectedConversation],
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const Text('Using GPT-4o · General Assistant',
                        style: TextStyle(fontSize: 12, color: Colors.gray)),
                  ],
                ),
              ),
              const OutlineBadge(
                child: Text('Branch 1/3'),
              ),
              const SizedBox(width: 8),
              Button.ghost(
                onPressed: () {},
                child: const Icon(RadixIcons.dotsHorizontal),
              ),
            ],
          ),
        ),

        // Messages area
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (final msg in _messages) _buildMessage(msg),
                // Streaming indicator
                _buildStreamingIndicator(),
              ],
            ),
          ),
        ),

        // Input area
        _buildInputArea(),
      ],
    );
  }

  Widget _buildMessage(_Msg msg) {
    final isUser = msg.role == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            const Avatar(initials: 'AI', size: 28),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Card(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(msg.text),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isUser ? 'You' : 'GPT-4o · 247 tokens',
                        style: const TextStyle(fontSize: 11, color: Colors.gray),
                      ),
                      const SizedBox(width: 8),
                      if (!isUser)
                        Button(
                          style: const ButtonStyle.ghost(density: ButtonDensity.compact),
                          onPressed: () {},
                          child: const Icon(RadixIcons.copy, size: 12),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 10),
            const Avatar(initials: 'U', size: 28),
          ],
        ],
      ),
    );
  }

  Widget _buildStreamingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Avatar(initials: 'AI', size: 28),
          const SizedBox(width: 10),
          Card(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(size: 14),
                const SizedBox(width: 10),
                const Text('Generating response...'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.border)),
      ),
      child: Row(
        children: [
          Button.outline(
            onPressed: () {},
            child: const Icon(RadixIcons.paperPlane),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _messageController,
              placeholder: const Text('Message Prism...'),
            ),
          ),
          const SizedBox(width: 8),
          Button.primary(
            onPressed: () {},
            child: const Icon(RadixIcons.arrowUp),
          ),
        ],
      ),
    );
  }
}

class _Msg {
  final String role;
  final String text;
  const _Msg({required this.role, required this.text});
}
