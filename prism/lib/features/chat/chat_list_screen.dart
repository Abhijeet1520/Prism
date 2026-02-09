/// Chat list screen — browse, search, and manage conversations.
///
/// Responsive layout: conversation list on mobile, split view on desktop.
/// Wired to [PrismDatabase] for live conversation data.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moon_design/moon_design.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/database.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _createConversation() async {
    final db = ref.read(databaseProvider);
    final uuid = const Uuid().v4();
    await db.createConversation(uuid: uuid, title: 'New Chat');
    if (mounted) context.go('/chat/$uuid');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.moonColors!;
    final db = ref.watch(databaseProvider);

    return Scaffold(
      backgroundColor: colors.gohan,
      body: Column(
        children: [
          // ── Header ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.goten,
              border: Border(bottom: BorderSide(color: colors.beerus)),
            ),
            child: Row(
              children: [
                Text(
                  'Conversations',
                  style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w700, fontSize: 18),
                ),
                const Spacer(),
                MoonButton.icon(
                  onTap: _createConversation,
                  icon: Icon(Icons.edit_square, size: 20, color: colors.piccolo),
                  buttonSize: MoonButtonSize.sm,
                ),
              ],
            ),
          ),

          // ── Search ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: MoonTextInput(
              controller: _searchCtrl,
              hintText: 'Search conversations...',
              textInputSize: MoonTextInputSize.sm,
              leading: Icon(Icons.search, size: 18, color: colors.trunks),
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              trailing: _searchQuery.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: Icon(Icons.close, size: 16, color: colors.trunks),
                    )
                  : null,
            ),
          ),

          // ── List ───────────────────────────────────────
          Expanded(
            child: StreamBuilder<List<Conversation>>(
              stream: db.watchConversations(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: MoonCircularLoader(color: colors.piccolo));
                }

                final allConversations = snapshot.data ?? [];
                final filtered = _searchQuery.isEmpty
                    ? allConversations
                    : allConversations.where((c) => c.title.toLowerCase().contains(_searchQuery)).toList();

                if (filtered.isEmpty) {
                  return _EmptyState(colors: colors, hasSearch: _searchQuery.isNotEmpty, onCreate: _createConversation);
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 2),
                  itemBuilder: (context, i) {
                    final conv = filtered[i];
                    return _ConversationTile(
                      colors: colors,
                      conversation: conv,
                      onTap: () => context.go('/chat/${conv.uuid}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Conversation Tile ────────────────────────────────

class _ConversationTile extends StatelessWidget {
  final MoonColors colors;
  final Conversation conversation;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.colors,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initial = conversation.title.isNotEmpty ? conversation.title[0].toUpperCase() : '?';
    final timeAgo = _formatTimeAgo(conversation.updatedAt);

    return MoonMenuItem(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      leading: MoonAvatar(
        backgroundColor: colors.piccolo.withValues(alpha: 0.15),
        content: Text(initial, style: TextStyle(color: colors.piccolo, fontWeight: FontWeight.w600)),
      ),
      label: Text(
        conversation.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w500, fontSize: 14),
      ),
      content: Text(
        '${conversation.provider} · $timeAgo',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: colors.trunks, fontSize: 12),
      ),
      trailing: conversation.isPinned
          ? Icon(Icons.push_pin, size: 14, color: colors.trunks)
          : Icon(Icons.chevron_right_rounded, size: 18, color: colors.trunks),
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}';
  }
}

// ─── Empty State ──────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final MoonColors colors;
  final bool hasSearch;
  final VoidCallback onCreate;

  const _EmptyState({
    required this.colors,
    required this.hasSearch,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasSearch ? Icons.search_off_rounded : Icons.chat_bubble_outline_rounded,
            size: 48,
            color: colors.piccolo.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            hasSearch ? 'No matching conversations' : 'No conversations yet',
            style: TextStyle(color: colors.trunks, fontSize: 16),
          ),
          if (!hasSearch) ...[
            const SizedBox(height: 12),
            MoonFilledButton(
              onTap: onCreate,
              buttonSize: MoonButtonSize.sm,
              label: const Text('Start a Chat'),
              leading: const Icon(Icons.add, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}
