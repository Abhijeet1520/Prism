/// Chat Screen — responsive split-view with conversation list + chat area.
///
/// Matches ux_preview design: sidebar on wide screens, full-screen chat on mobile.
/// Supports streaming AI responses, message persistence, model switching.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:uuid/uuid.dart';

import '../../core/ai/ai_service.dart';
import '../../core/database/database.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  String? _selectedConversationUuid;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;

        if (isWide) {
          return Row(
            children: [
              SizedBox(
                width: 300,
                child: _ConversationList(
                  selectedUuid: _selectedConversationUuid,
                  searchQuery: _searchQuery,
                  onSearchChanged: (q) => setState(() => _searchQuery = q),
                  onSelect: (uuid) =>
                      setState(() => _selectedConversationUuid = uuid),
                  onNewChat: _createNewChat,
                ),
              ),
              VerticalDivider(width: 1, color: _borderColor(context)),
              Expanded(
                child: _selectedConversationUuid != null
                    ? _ChatArea(
                        key: ValueKey(_selectedConversationUuid),
                        conversationUuid: _selectedConversationUuid!,
                      )
                    : _EmptyState(onNewChat: _createNewChat),
              ),
            ],
          );
        }

        // Mobile: show list or chat
        if (_selectedConversationUuid != null) {
          return _ChatArea(
            key: ValueKey(_selectedConversationUuid),
            conversationUuid: _selectedConversationUuid!,
            onBack: () => setState(() => _selectedConversationUuid = null),
          );
        }

        return _ConversationList(
          selectedUuid: null,
          searchQuery: _searchQuery,
          onSearchChanged: (q) => setState(() => _searchQuery = q),
          onSelect: (uuid) =>
              setState(() => _selectedConversationUuid = uuid),
          onNewChat: _createNewChat,
        );
      },
    );
  }

  Future<void> _createNewChat() async {
    final db = ref.read(databaseProvider);
    final uuid = const Uuid().v4();
    await db.createConversation(uuid: uuid);
    setState(() => _selectedConversationUuid = uuid);
  }

  Color _borderColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF252540) : const Color(0xFFE2E2EC);
  }
}

// ─── Conversation List ───────────────────────────────

class _ConversationList extends ConsumerWidget {
  final String? selectedUuid;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSelect;
  final VoidCallback onNewChat;

  const _ConversationList({
    required this.selectedUuid,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onSelect,
    required this.onNewChat,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0C0C16) : const Color(0xFFF5F5FA);
    final cardColor = isDark ? const Color(0xFF16162A) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF252540) : const Color(0xFFE2E2EC);
    final textPrimary =
        isDark ? const Color(0xFFE2E2EC) : const Color(0xFF1A1A2E);
    final textSecondary =
        isDark ? const Color(0xFF7A7A90) : const Color(0xFF6B6B80);
    final accentColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
            child: Row(
              children: [
                Text(
                  'Chats',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onNewChat,
                  icon: Icon(Icons.add_rounded, color: accentColor),
                  style: IconButton.styleFrom(
                    backgroundColor: accentColor.withValues(alpha: 0.12),
                  ),
                ),
              ],
            ),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor, width: 0.5),
              ),
              child: TextField(
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  hintStyle: TextStyle(color: textSecondary, fontSize: 13),
                  prefixIcon: Icon(Icons.search_rounded,
                      size: 18, color: textSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                style: TextStyle(color: textPrimary, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Conversation List
          Expanded(
            child: StreamBuilder<List<Conversation>>(
              stream: db.watchConversations(),
              builder: (context, snap) {
                final conversations = snap.data ?? [];
                final filtered = searchQuery.isEmpty
                    ? conversations
                    : conversations
                        .where((c) => c.title
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()))
                        .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded,
                            size: 48,
                            color: textSecondary.withValues(alpha: 0.3)),
                        const SizedBox(height: 12),
                        Text(
                          'No conversations yet',
                          style:
                              TextStyle(fontSize: 14, color: textSecondary),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: onNewChat,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Start a Chat'),
                          style: FilledButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final c = filtered[index];
                    final isSelected = c.uuid == selectedUuid;
                    return _ConversationTile(
                      conversation: c,
                      isSelected: isSelected,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      accentColor: accentColor,
                      cardColor: cardColor,
                      onTap: () => onSelect(c.uuid),
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

// ─── Conversation Tile ───────────────────────────────

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final bool isSelected;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;
  final Color cardColor;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.isSelected,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
    required this.cardColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isSelected
            ? accentColor.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: accentColor.withValues(alpha: 0.15),
                  child: Text(
                    conversation.title.isNotEmpty
                        ? conversation.title[0].toUpperCase()
                        : 'C',
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _timeAgo(conversation.updatedAt),
                        style:
                            TextStyle(fontSize: 11, color: textSecondary),
                      ),
                    ],
                  ),
                ),
                if (conversation.isPinned)
                  Icon(Icons.push_pin_rounded,
                      size: 14, color: accentColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dt);
  }
}

// ─── Empty State ─────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onNewChat;
  const _EmptyState({required this.onNewChat});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary =
        isDark ? const Color(0xFF7A7A90) : const Color(0xFF6B6B80);
    final accentColor = Theme.of(context).colorScheme.primary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded,
              size: 48, color: textSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'Start a conversation',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a chat or create a new one',
            style: TextStyle(fontSize: 13, color: textSecondary),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onNewChat,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Chat'),
            style: FilledButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chat Area ───────────────────────────────────────

class _ChatArea extends ConsumerStatefulWidget {
  final String conversationUuid;
  final VoidCallback? onBack;

  const _ChatArea({
    super.key,
    required this.conversationUuid,
    this.onBack,
  });

  @override
  ConsumerState<_ChatArea> createState() => _ChatAreaState();
}

class _ChatAreaState extends ConsumerState<_ChatArea> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  int? _conversationId;
  String _conversationTitle = 'New Chat';
  final List<_DisplayMessage> _messages = [];
  bool _isStreaming = false;
  String _streamingText = '';
  bool _isListening = false;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadConversation();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (_) => setState(() => _isListening = false),
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
    );
  }

  void _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else if (_speechAvailable) {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _inputController.text = result.recognizedWords;
            _inputController.selection = TextSelection.fromPosition(
              TextPosition(offset: _inputController.text.length),
            );
          });
          // Auto-send on final result if user set that preference
          if (result.finalResult && _inputController.text.trim().isNotEmpty) {
            // Don't auto-send; let user review and tap send
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadConversation() async {
    final db = ref.read(databaseProvider);
    final conv = await db.getConversation(widget.conversationUuid);
    if (conv == null) return;

    _conversationId = conv.id;
    _conversationTitle = conv.title;

    final msgs = await db.watchMessages(conv.id).first;
    setState(() {
      _messages.clear();
      _messages.addAll(msgs.map((m) => _DisplayMessage(
            role: m.role,
            content: m.content,
          )));
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isStreaming) return;

    final db = ref.read(databaseProvider);
    final aiNotifier = ref.read(aiServiceProvider.notifier);

    // Add user message
    setState(() {
      _messages.add(_DisplayMessage(role: 'user', content: text));
      _isStreaming = true;
      _streamingText = '';
    });
    _inputController.clear();
    _scrollToBottom();

    // Persist user message
    if (_conversationId != null) {
      await db.addMessage(
        uuid: const Uuid().v4(),
        conversationId: _conversationId!,
        role: 'user',
        content: text,
      );
    }

    // Auto-title from first message
    if (_messages.length == 1 && _conversationId != null) {
      final title =
          text.length > 40 ? '${text.substring(0, 40)}...' : text;
      await db.updateConversationTitle(widget.conversationUuid, title);
      setState(() => _conversationTitle = title);
    }

    // Stream AI response
    final prismMessages =
        _messages.map((m) => PrismMessage(role: m.role, content: m.content)).toList();

    final buffer = StringBuffer();
    await for (final token in aiNotifier.generateStream(prismMessages)) {
      buffer.write(token);
      if (mounted) {
        setState(() => _streamingText = buffer.toString());
        _scrollToBottom();
      }
    }

    // Finalize
    final response = buffer.toString();
    if (mounted) {
      setState(() {
        _messages.add(_DisplayMessage(role: 'assistant', content: response));
        _isStreaming = false;
        _streamingText = '';
      });
    }

    // Persist assistant message
    if (_conversationId != null) {
      await db.addMessage(
        uuid: const Uuid().v4(),
        conversationId: _conversationId!,
        role: 'assistant',
        content: response,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0C0C16) : const Color(0xFFF5F5FA);
    final cardColor = isDark ? const Color(0xFF16162A) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF252540) : const Color(0xFFE2E2EC);
    final textPrimary =
        isDark ? const Color(0xFFE2E2EC) : const Color(0xFF1A1A2E);
    final textSecondary =
        isDark ? const Color(0xFF7A7A90) : const Color(0xFF6B6B80);
    final accentColor = Theme.of(context).colorScheme.primary;
    final aiState = ref.watch(aiServiceProvider);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
            decoration: BoxDecoration(
              color: cardColor,
              border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
            ),
            child: Row(
              children: [
                if (widget.onBack != null)
                  IconButton(
                    onPressed: widget.onBack,
                    icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
                  ),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: accentColor.withValues(alpha: 0.15),
                  child: Icon(Icons.auto_awesome_rounded,
                      size: 16, color: accentColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _conversationTitle,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        aiState.activeModel?.name ?? 'No model',
                        style:
                            TextStyle(fontSize: 11, color: textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showModelPicker(context),
                  icon: Icon(Icons.tune_rounded,
                      size: 20, color: textSecondary),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: _messages.isEmpty && !_isStreaming
                ? _ChatEmptyContent(
                    textSecondary: textSecondary,
                    accentColor: accentColor,
                    onSuggestion: _sendMessage,
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount:
                        _messages.length + (_isStreaming ? 1 : 0),
                    itemBuilder: (_, index) {
                      if (index == _messages.length && _isStreaming) {
                        return _MessageBubble(
                          role: 'assistant',
                          content: _streamingText,
                          isStreaming: true,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          accentColor: accentColor,
                          cardColor: cardColor,
                          borderColor: borderColor,
                        );
                      }
                      final msg = _messages[index];
                      return _MessageBubble(
                        role: msg.role,
                        content: msg.content,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        accentColor: accentColor,
                        cardColor: cardColor,
                        borderColor: borderColor,
                      );
                    },
                  ),
          ),

          // Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: BoxDecoration(
              color: cardColor,
              border: Border(top: BorderSide(color: borderColor, width: 0.5)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.attach_file_rounded,
                      size: 20, color: textSecondary),
                ),
                IconButton(
                  onPressed: _speechAvailable ? _toggleListening : null,
                  icon: Icon(
                    _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    size: 20,
                    color: _isListening ? Colors.red : textSecondary,
                  ),
                  style: _isListening
                      ? IconButton.styleFrom(
                          backgroundColor: Colors.red.withValues(alpha: 0.12),
                        )
                      : null,
                ),
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _inputController,
                      maxLines: null,
                      onSubmitted: _sendMessage,
                      textInputAction: TextInputAction.send,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle:
                            TextStyle(color: textSecondary, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      style: TextStyle(color: textPrimary, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _isStreaming
                    ? IconButton(
                        onPressed: () =>
                            ref.read(aiServiceProvider.notifier).stopGeneration(),
                        icon: Icon(Icons.stop_circle_rounded,
                            color: Colors.red.shade400),
                      )
                    : IconButton(
                        onPressed: () =>
                            _sendMessage(_inputController.text),
                        icon: Icon(Icons.arrow_upward_rounded,
                            color: accentColor),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              accentColor.withValues(alpha: 0.12),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showModelPicker(BuildContext context) {
    final aiState = ref.read(aiServiceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF16162A) : Colors.white;
    final textPrimary =
        isDark ? const Color(0xFFE2E2EC) : const Color(0xFF1A1A2E);
    final accentColor = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Model',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textPrimary)),
            const SizedBox(height: 16),
            ...aiState.availableModels.map((m) {
              final isActive = m.id == aiState.activeModel?.id;
              return ListTile(
                leading: Icon(
                  isActive
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: isActive ? accentColor : null,
                ),
                title: Text(m.name,
                    style: TextStyle(color: textPrimary)),
                subtitle: Text(m.provider.name,
                    style: const TextStyle(fontSize: 12)),
                onTap: () {
                  ref.read(aiServiceProvider.notifier).selectModel(m);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─── Chat Empty Content ──────────────────────────────

class _ChatEmptyContent extends StatelessWidget {
  final Color textSecondary;
  final Color accentColor;
  final ValueChanged<String> onSuggestion;

  const _ChatEmptyContent({
    required this.textSecondary,
    required this.accentColor,
    required this.onSuggestion,
  });

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      'Plan my day',
      'Log an expense',
      'Show my tasks',
      'Help me write',
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded,
                size: 48, color: textSecondary.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              'How can I help?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: suggestions
                  .map((s) => ActionChip(
                        label: Text(s, style: const TextStyle(fontSize: 13)),
                        onPressed: () => onSuggestion(s),
                        backgroundColor:
                            accentColor.withValues(alpha: 0.08),
                        side: BorderSide(
                            color: accentColor.withValues(alpha: 0.2)),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Message Bubble ──────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final String role;
  final String content;
  final bool isStreaming;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;
  final Color cardColor;
  final Color borderColor;

  const _MessageBubble({
    required this.role,
    required this.content,
    this.isStreaming = false,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = role == 'user';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: accentColor.withValues(alpha: 0.15),
              child: Icon(Icons.auto_awesome_rounded,
                  size: 14, color: accentColor),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? accentColor.withValues(alpha: 0.12)
                    : cardColor,
                borderRadius: BorderRadius.circular(14),
                border: isUser
                    ? null
                    : Border.all(color: borderColor, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    content.isEmpty && isStreaming ? '...' : content,
                    style: TextStyle(
                      fontSize: 14,
                      color: textPrimary,
                      height: 1.5,
                    ),
                  ),
                  if (isStreaming)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: accentColor,
                        ),
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
}

// ─── Display Message Model ───────────────────────────

class _DisplayMessage {
  final String role;
  final String content;
  _DisplayMessage({required this.role, required this.content});
}
