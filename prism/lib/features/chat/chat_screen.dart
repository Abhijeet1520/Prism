/// Chat Screen — responsive split-view with conversation list + chat area.
///
/// Matches ux_preview design: sidebar on wide screens, full-screen chat on mobile.
/// Supports streaming AI responses, message persistence, model switching.
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:uuid/uuid.dart';

import '../../core/ai/ai_service.dart';
import '../../core/ai/tool_registry.dart';
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
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Chat'),
                            content: Text(
                                'Delete "${c.title}"? This cannot be undone.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await db.deleteConversation(c.uuid);
                        }
                      },
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
  final VoidCallback onDelete;

  const _ConversationTile({
    required this.conversation,
    required this.isSelected,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
    required this.cardColor,
    required this.onTap,
    required this.onDelete,
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
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(Icons.push_pin_rounded,
                        size: 14, color: accentColor),
                  ),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: IconButton(
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: textSecondary,
                    ),
                    tooltip: 'Delete chat',
                  ),
                ),
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

  // ─── Tool approval state ─────────────────────────
  bool _isWaitingForToolApproval = false;

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

  // ─── Message Actions ──────────────────────────────────

  void _editMessage(int index) {
    final msg = _messages[index];
    if (msg.role != 'user') return;
    _inputController.text = msg.content;
    // Remove this message and all subsequent messages
    final removedMessages = _messages.sublist(index);
    setState(() {
      _messages.removeRange(index, _messages.length);
    });
    // Delete from DB
    final db = ref.read(databaseProvider);
    for (final m in removedMessages) {
      db.deleteMessage(m.uuid);
    }
  }

  void _deleteMessage(int index) {
    final msg = _messages[index];
    final db = ref.read(databaseProvider);
    db.deleteMessage(msg.uuid);
    setState(() {
      _messages.removeAt(index);
    });
  }

  Future<void> _resendMessage(int index) async {
    if (_isStreaming) return;
    // Find the user message that preceded this assistant message
    String? userText;
    for (int i = index - 1; i >= 0; i--) {
      if (_messages[i].role == 'user') {
        userText = _messages[i].content;
        break;
      }
    }
    if (userText == null) return;
    // Remove the assistant message being resent
    final msg = _messages[index];
    final db = ref.read(databaseProvider);
    db.deleteMessage(msg.uuid);
    setState(() {
      _messages.removeAt(index);
    });
    // Re-send the user message to get a new response
    await _sendMessageWithoutUserAdd(userText);
  }

  Future<void> _sendMessageWithoutUserAdd(String text) async {
    if (_isStreaming) return;
    // Stream AI response with tools (messages already contain the history)
    await _streamWithTools();
  }

  // ─── Send Message ──────────────────────────────────

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isStreaming) return;

    final db = ref.read(databaseProvider);

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

    // Stream AI response with tools
    await _streamWithTools();
  }

  // ─── Stream with Tool Calling ──────────────────────

  /// Core streaming method that handles both content and tool calls.
  Future<void> _streamWithTools() async {
    final db = ref.read(databaseProvider);
    final aiNotifier = ref.read(aiServiceProvider.notifier);
    final activeModel = ref.read(aiServiceProvider).activeModel;
    final tools = PrismToolRegistry.toOpenAITools();

    // Build PrismMessage list including tool messages
    final prismMessages = _messages.map((m) {
      if (m.role == 'assistant' && m.toolCalls != null) {
        return PrismMessage(
          role: 'assistant',
          content: m.content,
          toolCalls: jsonDecode(m.toolCalls!) as Map<String, dynamic>,
        );
      }
      if (m.role == 'tool' && m.toolCallId != null) {
        return PrismMessage.tool(m.content, toolCallId: m.toolCallId!);
      }
      return PrismMessage(role: m.role, content: m.content);
    }).toList();

    setState(() {
      _isStreaming = true;
      _streamingText = '';
    });
    _scrollToBottom();

    final buffer = StringBuffer();
    final stopwatch = Stopwatch()..start();
    int tokenEstimate = 0;

    try {
      await for (final event
          in aiNotifier.generateStreamWithTools(prismMessages, tools: tools)) {
        if (!mounted || !_isStreaming) break;

        switch (event) {
          case ToolStreamContent(:final content):
            buffer.write(content);
            tokenEstimate++;
            setState(() => _streamingText = buffer.toString());
            _scrollToBottom();

          case ToolCallRequest():
            stopwatch.stop();
            // If there was any content before the tool call, save it
            final preContent = buffer.toString();

            // Show the tool approval UI
            setState(() {
              _isStreaming = false;
              _streamingText = '';
              _isWaitingForToolApproval = true;

              // Add assistant message with tool call info (pending state)
              if (preContent.isNotEmpty) {
                _messages.add(_DisplayMessage(
                  role: 'assistant',
                  content: preContent,
                  modelName: activeModel?.name,
                  providerName: activeModel?.provider.name,
                  tokenCount: tokenEstimate,
                  responseTime: stopwatch.elapsed,
                ));
              }

              // Add a tool-call display message
              _messages.add(_DisplayMessage(
                role: 'tool_call',
                content: '',
                toolName: event.name,
                toolArgs: event.arguments,
                toolCallId: event.id,
                toolCalls: jsonEncode({'tool_calls': event.rawToolCalls}),
                toolApprovalStatus: 'pending',
              ));
            });
            _scrollToBottom();
            return; // Wait for user approval
        }
      }
    } catch (_) {}
    stopwatch.stop();

    // Finalize normal response (no tool call)
    final response = buffer.toString();
    if (mounted) {
      setState(() {
        _messages.add(_DisplayMessage(
          role: 'assistant',
          content: response,
          modelName: activeModel?.name,
          providerName: activeModel?.provider.name,
          tokenCount: tokenEstimate,
          responseTime: stopwatch.elapsed,
        ));
        _isStreaming = false;
        _streamingText = '';
      });
    }

    if (_conversationId != null && response.isNotEmpty) {
      await db.addMessage(
        uuid: const Uuid().v4(),
        conversationId: _conversationId!,
        role: 'assistant',
        content: response,
      );
    }
  }

  // ─── Tool Approval Handlers ────────────────────────

  /// User approved the tool call — execute it and continue.
  Future<void> _handleToolApproval(int messageIndex) async {
    final msg = _messages[messageIndex];
    if (msg.toolApprovalStatus != 'pending') return;

    final db = ref.read(databaseProvider);
    final toolName = msg.toolName!;
    final toolArgs = msg.toolArgs!;
    final toolCallId = msg.toolCallId!;

    setState(() {
      msg.toolApprovalStatus = 'approved';
    });

    // Execute the tool
    final result = await PrismToolRegistry.execute(
      toolName,
      toolArgs,
      db: db,
    );

    // Persist the assistant tool-call message
    if (_conversationId != null) {
      await db.addMessage(
        uuid: const Uuid().v4(),
        conversationId: _conversationId!,
        role: 'assistant',
        content: '',
        toolCalls: msg.toolCalls,
      );
    }

    // Add tool result to messages
    final resultMsg = _DisplayMessage(
      role: 'tool',
      content: result,
      toolCallId: toolCallId,
      toolName: toolName,
      toolResult: result,
    );
    setState(() {
      _messages.add(resultMsg);
      _isWaitingForToolApproval = false;
    });

    // Persist tool result message
    if (_conversationId != null) {
      await db.addMessage(
        uuid: const Uuid().v4(),
        conversationId: _conversationId!,
        role: 'tool',
        content: result,
        toolResult: result,
      );
    }

    // Continue the conversation — send the tool result back to the model
    await _streamWithTools();
  }

  /// User denied the tool call.
  Future<void> _handleToolDenial(int messageIndex) async {
    final msg = _messages[messageIndex];
    if (msg.toolApprovalStatus != 'pending') return;

    setState(() {
      msg.toolApprovalStatus = 'denied';
      _isWaitingForToolApproval = false;
    });

    // Add a note that the tool was denied and continue with a regular response
    final denialMsg = _DisplayMessage(
      role: 'tool',
      content: '{"denied": true, "message": "User denied tool execution"}',
      toolCallId: msg.toolCallId,
      toolName: msg.toolName,
    );
    setState(() {
      _messages.add(denialMsg);
    });

    // Persist denial
    if (_conversationId != null) {
      await db.addMessage(
        uuid: const Uuid().v4(),
        conversationId: _conversationId!,
        role: 'assistant',
        content: '',
        toolCalls: msg.toolCalls,
      );
      await db.addMessage(
        uuid: const Uuid().v4(),
        conversationId: _conversationId!,
        role: 'tool',
        content: '{"denied": true}',
      );
    }

    // Continue — model should respond without the tool result
    await _streamWithTools();
  }

  /// User wants to edit tool args before execution.
  Future<void> _handleToolEdit(int messageIndex) async {
    final msg = _messages[messageIndex];
    if (msg.toolApprovalStatus != 'pending') return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF16162A) : Colors.white;
    final textPrimary =
        isDark ? const Color(0xFFE2E2EC) : const Color(0xFF1A1A2E);
    final textSecondary =
        isDark ? const Color(0xFF7A7A90) : const Color(0xFF6B6B80);
    final accentColor = Theme.of(context).colorScheme.primary;

    final controller = TextEditingController(
      text: const JsonEncoder.withIndent('  ').convert(msg.toolArgs),
    );

    final editedJson = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardColor,
        title: Text(
          'Edit Tool Arguments',
          style: TextStyle(color: textPrimary, fontSize: 16),
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tool: ${msg.toolName}',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 10,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 13,
                  fontFamily: 'monospace',
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: textSecondary.withValues(alpha: 0.3)),
                  ),
                  hintText: 'JSON arguments',
                  hintStyle: TextStyle(color: textSecondary),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: textSecondary)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            style: FilledButton.styleFrom(backgroundColor: accentColor),
            child: const Text('Save & Execute'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (editedJson != null) {
      try {
        final newArgs = jsonDecode(editedJson) as Map<String, dynamic>;
        setState(() {
          // Update the message with edited args
          _messages[messageIndex] = _DisplayMessage(
            uuid: msg.uuid,
            role: msg.role,
            content: msg.content,
            toolName: msg.toolName,
            toolArgs: newArgs,
            toolCallId: msg.toolCallId,
            toolCalls: msg.toolCalls,
            toolApprovalStatus: 'edited',
          );
        });

        // Execute with edited args
        final db = ref.read(databaseProvider);
        final result = await PrismToolRegistry.execute(
          msg.toolName!,
          newArgs,
          db: db,
        );

        // Persist
        if (_conversationId != null) {
          await db.addMessage(
            uuid: const Uuid().v4(),
            conversationId: _conversationId!,
            role: 'assistant',
            content: '',
            toolCalls: msg.toolCalls,
          );
        }

        final resultMsg = _DisplayMessage(
          role: 'tool',
          content: result,
          toolCallId: msg.toolCallId,
          toolName: msg.toolName,
          toolResult: result,
        );
        setState(() {
          _messages.add(resultMsg);
          _isWaitingForToolApproval = false;
        });

        if (_conversationId != null) {
          await db.addMessage(
            uuid: const Uuid().v4(),
            conversationId: _conversationId!,
            role: 'tool',
            content: result,
            toolResult: result,
          );
        }

        // Continue conversation
        await _streamWithTools();
      } catch (_) {
        // Invalid JSON — show error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid JSON. Please fix and try again.')),
          );
        }
      }
    }
  }

  PrismDatabase get db => ref.read(databaseProvider);

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

                      // Tool call approval card
                      if (msg.role == 'tool_call') {
                        return _ToolApprovalCard(
                          toolName: msg.toolName ?? 'Unknown',
                          toolArgs: msg.toolArgs ?? {},
                          status: msg.toolApprovalStatus ?? 'pending',
                          accentColor: accentColor,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          onApprove: msg.toolApprovalStatus == 'pending'
                              ? () => _handleToolApproval(index)
                              : null,
                          onDeny: msg.toolApprovalStatus == 'pending'
                              ? () => _handleToolDenial(index)
                              : null,
                          onEdit: msg.toolApprovalStatus == 'pending'
                              ? () => _handleToolEdit(index)
                              : null,
                        );
                      }

                      // Tool result message (compact display)
                      if (msg.role == 'tool') {
                        return _ToolResultCard(
                          toolName: msg.toolName ?? 'Tool',
                          result: msg.content,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          cardColor: cardColor,
                          borderColor: borderColor,
                        );
                      }

                      return _MessageBubble(
                        role: msg.role,
                        content: msg.content,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        accentColor: accentColor,
                        cardColor: cardColor,
                        borderColor: borderColor,
                        modelName: msg.modelName,
                        providerName: msg.providerName,
                        tokenCount: msg.tokenCount,
                        responseTime: msg.responseTime,
                        onEdit: msg.role == 'user'
                            ? () => _editMessage(index)
                            : null,
                        onDelete: () => _deleteMessage(index),
                        onResend: msg.role == 'assistant'
                            ? () => _resendMessage(index)
                            : null,
                        onCopy: () {
                          Clipboard.setData(
                              ClipboardData(text: msg.content));
                        },
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
                      enabled: !_isWaitingForToolApproval,
                      onSubmitted: _sendMessage,
                      textInputAction: TextInputAction.send,
                      decoration: InputDecoration(
                        hintText: _isWaitingForToolApproval
                            ? 'Waiting for tool approval...'
                            : 'Type a message...',
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
                        onPressed: () {
                            ref.read(aiServiceProvider.notifier).stopGeneration();
                            setState(() => _isStreaming = false);
                        },
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
    final bgColor = isDark ? const Color(0xFF0C0C16) : const Color(0xFFF5F5FA);
    final textPrimary =
        isDark ? const Color(0xFFE2E2EC) : const Color(0xFF1A1A2E);
    final textSecondary =
        isDark ? const Color(0xFF7A7A90) : const Color(0xFF6B6B80);
    final accentColor = Theme.of(context).colorScheme.primary;
    final borderColor =
        isDark ? const Color(0xFF252540) : const Color(0xFFE2E2EC);

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _ModelPickerSheet(
        models: aiState.availableModels,
        activeModelId: aiState.activeModel?.id,
        cardColor: cardColor,
        bgColor: bgColor,
        textPrimary: textPrimary,
        textSecondary: textSecondary,
        accentColor: accentColor,
        borderColor: borderColor,
        onSelect: (m) {
          ref.read(aiServiceProvider.notifier).selectModel(m);
          Navigator.pop(context);
        },
        onGoToSettings: () {
          Navigator.pop(context);
          // Navigate to settings > AI Providers
          context.go('/settings');
        },
      ),
    );
  }
}

// ─── Model Picker Sheet ──────────────────────────────

class _ModelPickerSheet extends StatefulWidget {
  final List<ModelConfig> models;
  final String? activeModelId;
  final Color cardColor, bgColor, textPrimary, textSecondary, accentColor, borderColor;
  final ValueChanged<ModelConfig> onSelect;
  final VoidCallback onGoToSettings;

  const _ModelPickerSheet({
    required this.models,
    required this.activeModelId,
    required this.cardColor,
    required this.bgColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
    required this.borderColor,
    required this.onSelect,
    required this.onGoToSettings,
  });

  @override
  State<_ModelPickerSheet> createState() => _ModelPickerSheetState();
}

class _ModelPickerSheetState extends State<_ModelPickerSheet> {
  String _search = '';

  IconData _providerIcon(ProviderType type) => switch (type) {
        ProviderType.local => Icons.phone_android_rounded,
        ProviderType.ollama => Icons.dns_rounded,
        ProviderType.openai => Icons.cloud_outlined,
        ProviderType.gemini => Icons.auto_awesome_rounded,
        ProviderType.custom => Icons.settings_ethernet_rounded,
        ProviderType.mock => Icons.science_rounded,
      };

  String _providerLabel(ProviderType type) => switch (type) {
        ProviderType.local => 'Local Models',
        ProviderType.ollama => 'Ollama',
        ProviderType.openai => 'Cloud API',
        ProviderType.gemini => 'Google Gemini',
        ProviderType.custom => 'Custom',
        ProviderType.mock => 'Demo',
      };

  @override
  Widget build(BuildContext context) {
    // Filter by search
    final filtered = _search.isEmpty
        ? widget.models
        : widget.models
            .where((m) =>
                m.name.toLowerCase().contains(_search.toLowerCase()) ||
                m.id.toLowerCase().contains(_search.toLowerCase()) ||
                m.provider.name.toLowerCase().contains(_search.toLowerCase()))
            .toList();

    // Group by provider
    final groups = <ProviderType, List<ModelConfig>>{};
    for (final m in filtered) {
      groups.putIfAbsent(m.provider, () => []).add(m);
    }

    // Order: mock first (demo), then local, ollama, cloud, gemini, custom
    final order = [
      ProviderType.mock,
      ProviderType.local,
      ProviderType.ollama,
      ProviderType.openai,
      ProviderType.gemini,
      ProviderType.custom,
    ];
    final sortedKeys =
        order.where((t) => groups.containsKey(t)).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text('Select Model',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: widget.textPrimary)),
              const Spacer(),
              GestureDetector(
                onTap: widget.onGoToSettings,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: widget.accentColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: widget.accentColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.settings_rounded,
                          size: 14, color: widget.accentColor),
                      const SizedBox(width: 4),
                      Text('AI Providers',
                          style: TextStyle(
                              color: widget.accentColor, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Search bar
          Container(
            height: 38,
            decoration: BoxDecoration(
              color: widget.bgColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: widget.borderColor, width: 0.5),
            ),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search models...',
                hintStyle:
                    TextStyle(color: widget.textSecondary, fontSize: 13),
                prefixIcon: Icon(Icons.search_rounded,
                    size: 18, color: widget.textSecondary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 9),
              ),
              style: TextStyle(color: widget.textPrimary, fontSize: 13),
            ),
          ),
          const SizedBox(height: 12),
          // Grouped model list
          Flexible(
            child: filtered.isEmpty
                ? Center(
                    child: Text('No models found',
                        style: TextStyle(
                            color: widget.textSecondary, fontSize: 13)),
                  )
                : ListView(
                    shrinkWrap: true,
                    children: [
                      for (final type in sortedKeys) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 6),
                          child: Row(
                            children: [
                              Icon(_providerIcon(type),
                                  size: 14, color: widget.textSecondary),
                              const SizedBox(width: 6),
                              Text(
                                _providerLabel(type).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: widget.textSecondary,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Divider(
                                    height: 1, color: widget.borderColor),
                              ),
                            ],
                          ),
                        ),
                        ...groups[type]!.map((m) {
                          final isActive = m.id == widget.activeModelId;
                          return InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => widget.onSelect(m),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              margin: const EdgeInsets.only(bottom: 2),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? widget.accentColor
                                        .withValues(alpha: 0.08)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isActive
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    size: 18,
                                    color: isActive
                                        ? widget.accentColor
                                        : widget.textSecondary,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(m.name,
                                            style: TextStyle(
                                              color: widget.textPrimary,
                                              fontSize: 13,
                                              fontWeight: isActive
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                            )),
                                        Text(
                                          '${m.contextWindow ~/ 1024}K ctx',
                                          style: TextStyle(
                                              color: widget.textSecondary,
                                              fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isActive)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981)
                                            .withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                      child: const Text('active',
                                          style: TextStyle(
                                              fontSize: 9,
                                              color: Color(0xFF10B981))),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
          ),
        ],
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

class _MessageBubble extends StatefulWidget {
  final String role;
  final String content;
  final bool isStreaming;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;
  final Color cardColor;
  final Color borderColor;
  final String? modelName;
  final String? providerName;
  final int? tokenCount;
  final Duration? responseTime;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onResend;
  final VoidCallback? onCopy;

  const _MessageBubble({
    required this.role,
    required this.content,
    this.isStreaming = false,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
    required this.cardColor,
    required this.borderColor,
    this.modelName,
    this.providerName,
    this.tokenCount,
    this.responseTime,
    this.onEdit,
    this.onDelete,
    this.onResend,
    this.onCopy,
  });

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble> {
  bool _showActions = false;

  @override
  Widget build(BuildContext context) {
    final isUser = widget.role == 'user';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          if (!widget.isStreaming) {
            setState(() => _showActions = !_showActions);
          }
        },
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
                  isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isUser) ...[
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: widget.accentColor.withValues(alpha: 0.15),
                    child: Icon(Icons.auto_awesome_rounded,
                        size: 14, color: widget.accentColor),
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isUser
                          ? widget.accentColor.withValues(alpha: 0.12)
                          : widget.cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: isUser
                          ? null
                          : Border.all(
                              color: widget.borderColor, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isUser)
                          SelectableText(
                            widget.content,
                            style: TextStyle(
                              fontSize: 14,
                              color: widget.textPrimary,
                              height: 1.5,
                            ),
                          )
                        else
                          MarkdownBody(
                            data: widget.content.isEmpty && widget.isStreaming
                                ? '...'
                                : widget.content,
                            selectable: true,
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(
                                  fontSize: 14,
                                  color: widget.textPrimary,
                                  height: 1.5),
                              h1: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: widget.textPrimary),
                              h2: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: widget.textPrimary),
                              h3: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: widget.textPrimary),
                              code: TextStyle(
                                fontSize: 13,
                                fontFamily: 'monospace',
                                color: widget.accentColor,
                                backgroundColor:
                                    widget.accentColor.withValues(alpha: 0.08),
                              ),
                              codeblockDecoration: BoxDecoration(
                                color: widget.textPrimary
                                    .withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: widget.borderColor, width: 0.5),
                              ),
                              codeblockPadding: const EdgeInsets.all(12),
                              blockquoteDecoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                      color: widget.accentColor, width: 3),
                                ),
                              ),
                              blockquotePadding: const EdgeInsets.only(
                                  left: 12, top: 4, bottom: 4),
                              listBullet: TextStyle(
                                  fontSize: 14, color: widget.textPrimary),
                              strong: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: widget.textPrimary),
                              em: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: widget.textPrimary),
                              tableHead: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: widget.textPrimary),
                              tableBody:
                                  TextStyle(color: widget.textPrimary),
                              tableBorder: TableBorder.all(
                                  color: widget.borderColor, width: 0.5),
                              tableCellsPadding: const EdgeInsets.all(6),
                            ),
                          ),
                        if (widget.isStreaming)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: widget.accentColor,
                              ),
                            ),
                          ),
                        // Token/model info footer for assistant messages
                        if (!isUser &&
                            !widget.isStreaming &&
                            widget.content.isNotEmpty &&
                            (widget.modelName != null ||
                                widget.tokenCount != null))
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.modelName != null) ...[
                                  Icon(Icons.smart_toy_outlined,
                                      size: 11,
                                      color: widget.textSecondary
                                          .withValues(alpha: 0.6)),
                                  const SizedBox(width: 3),
                                  Text(
                                    widget.modelName!,
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: widget.textSecondary
                                            .withValues(alpha: 0.6)),
                                  ),
                                ],
                                if (widget.tokenCount != null) ...[
                                  const SizedBox(width: 8),
                                  Icon(Icons.token_outlined,
                                      size: 11,
                                      color: widget.textSecondary
                                          .withValues(alpha: 0.6)),
                                  const SizedBox(width: 3),
                                  Text(
                                    '~${widget.tokenCount} tokens',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: widget.textSecondary
                                            .withValues(alpha: 0.6)),
                                  ),
                                ],
                                if (widget.responseTime != null) ...[
                                  const SizedBox(width: 8),
                                  Icon(Icons.timer_outlined,
                                      size: 11,
                                      color: widget.textSecondary
                                          .withValues(alpha: 0.6)),
                                  const SizedBox(width: 3),
                                  Text(
                                    widget.responseTime!.inMilliseconds >
                                            1000
                                        ? '${(widget.responseTime!.inMilliseconds / 1000).toStringAsFixed(1)}s'
                                        : '${widget.responseTime!.inMilliseconds}ms',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: widget.textSecondary
                                            .withValues(alpha: 0.6)),
                                  ),
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Action buttons (shown on tap)
            if (_showActions && !widget.isStreaming)
              Padding(
                padding: EdgeInsets.only(
                  top: 4,
                  left: isUser ? 0 : 36,
                ),
                child: Wrap(
                  spacing: 4,
                  children: [
                    _ActionChip(
                      icon: Icons.copy_rounded,
                      label: 'Copy',
                      color: widget.textSecondary,
                      onTap: () {
                        Clipboard.setData(
                            ClipboardData(text: widget.content));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Copied to clipboard'),
                              duration: Duration(seconds: 1)),
                        );
                        setState(() => _showActions = false);
                      },
                    ),
                    if (isUser && widget.onEdit != null)
                      _ActionChip(
                        icon: Icons.edit_rounded,
                        label: 'Edit',
                        color: widget.accentColor,
                        onTap: () {
                          setState(() => _showActions = false);
                          widget.onEdit!();
                        },
                      ),
                    if (!isUser && widget.onResend != null)
                      _ActionChip(
                        icon: Icons.refresh_rounded,
                        label: 'Resend',
                        color: widget.accentColor,
                        onTap: () {
                          setState(() => _showActions = false);
                          widget.onResend!();
                        },
                      ),
                    if (widget.onDelete != null)
                      _ActionChip(
                        icon: Icons.delete_outline_rounded,
                        label: 'Delete',
                        color: const Color(0xFFEF4444),
                        onTap: () {
                          setState(() => _showActions = false);
                          widget.onDelete!();
                        },
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ─── Tool Approval Card ──────────────────────────────

class _ToolApprovalCard extends StatelessWidget {
  final String toolName;
  final Map<String, dynamic> toolArgs;
  final String status;
  final Color accentColor, textPrimary, textSecondary, cardColor, borderColor;
  final VoidCallback? onApprove;
  final VoidCallback? onDeny;
  final VoidCallback? onEdit;

  const _ToolApprovalCard({
    required this.toolName,
    required this.toolArgs,
    required this.status,
    required this.accentColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.cardColor,
    required this.borderColor,
    this.onApprove,
    this.onDeny,
    this.onEdit,
  });

  IconData get _statusIcon => switch (status) {
        'approved' => Icons.check_circle_rounded,
        'denied' => Icons.cancel_rounded,
        'edited' => Icons.edit_rounded,
        _ => Icons.build_circle_rounded,
      };

  Color get _statusColor => switch (status) {
        'approved' => const Color(0xFF10B981),
        'denied' => const Color(0xFFEF4444),
        'edited' => const Color(0xFFF59E0B),
        _ => accentColor,
      };

  String get _statusLabel => switch (status) {
        'approved' => 'Approved',
        'denied' => 'Denied',
        'edited' => 'Edited & Executed',
        _ => 'Pending Approval',
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _statusColor.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.06),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(11),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.functions_rounded,
                      size: 16, color: _statusColor),
                  const SizedBox(width: 8),
                  Text(
                    'Tool Call: $toolName',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_statusIcon, size: 12, color: _statusColor),
                        const SizedBox(width: 4),
                        Text(
                          _statusLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Arguments display
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Arguments:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: textSecondary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      const JsonEncoder.withIndent('  ').convert(toolArgs),
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: textPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons (only when pending)
            if (status == 'pending')
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _ToolActionButton(
                        icon: Icons.check_rounded,
                        label: 'Approve',
                        color: const Color(0xFF10B981),
                        onTap: onApprove,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ToolActionButton(
                        icon: Icons.edit_rounded,
                        label: 'Edit',
                        color: const Color(0xFFF59E0B),
                        onTap: onEdit,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ToolActionButton(
                        icon: Icons.close_rounded,
                        label: 'Deny',
                        color: const Color(0xFFEF4444),
                        onTap: onDeny,
                      ),
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ToolActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ToolActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tool Result Card ────────────────────────────────

class _ToolResultCard extends StatelessWidget {
  final String toolName;
  final String result;
  final Color textPrimary, textSecondary, cardColor, borderColor;

  const _ToolResultCard({
    required this.toolName,
    required this.result,
    required this.textPrimary,
    required this.textSecondary,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    // Try to parse as JSON for nice display
    String displayResult = result;
    try {
      final parsed = jsonDecode(result);
      displayResult = const JsonEncoder.withIndent('  ').convert(parsed);
    } catch (_) {}

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: 0.25),
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle_outline_rounded,
                    size: 14, color: const Color(0xFF10B981)),
                const SizedBox(width: 6),
                Text(
                  'Tool Result: $toolName',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: textSecondary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                displayResult,
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: textPrimary.withValues(alpha: 0.7),
                ),
                maxLines: 8,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Display Message Model ───────────────────────────

class _DisplayMessage {
  final String uuid;
  final String role;
  String content;
  final String? modelName;
  final String? providerName;
  final int? tokenCount;
  final Duration? responseTime;
  /// JSON-encoded tool calls from assistant message
  final String? toolCalls;
  /// JSON-encoded tool result
  final String? toolResult;
  /// Tool call ID (for role='tool')
  final String? toolCallId;
  /// Tool name (for display in approval UI)
  final String? toolName;
  /// Tool arguments (for display in approval UI)
  final Map<String, dynamic>? toolArgs;
  /// Tool approval status: 'pending', 'approved', 'denied', 'edited'
  String? toolApprovalStatus;

  _DisplayMessage({
    String? uuid,
    required this.role,
    required this.content,
    this.modelName,
    this.providerName,
    this.tokenCount,
    this.responseTime,
    this.toolCalls,
    this.toolResult,
    this.toolCallId,
    this.toolName,
    this.toolArgs,
    this.toolApprovalStatus,
  }) : uuid = uuid ?? const Uuid().v4();
}
