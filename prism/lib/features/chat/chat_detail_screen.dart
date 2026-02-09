/// Chat detail screen — real streaming AI conversation.
///
/// Uses [AIServiceNotifier] from Riverpod for model communication
/// and [PrismDatabase] for persistence.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ai/ai_service.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String conversationId;
  const ChatDetailScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <PrismMessage>[];
  String _streamingBuffer = '';
  bool _isStreaming = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final userMsg = PrismMessage(
      role: 'user',
      content: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _controller.clear();
      _isStreaming = true;
      _streamingBuffer = '';
    });
    _scrollToBottom();

    final aiService = ref.read(aiServiceProvider.notifier);
    final stream = aiService.generateStream(_messages);

    await for (final chunk in stream) {
      if (!mounted) break;
      setState(() {
        _streamingBuffer += chunk;
      });
      _scrollToBottom();
    }

    if (mounted) {
      setState(() {
        _messages.add(PrismMessage(
          role: 'assistant',
          content: _streamingBuffer,
          timestamp: DateTime.now(),
        ));
        _streamingBuffer = '';
        _isStreaming = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final aiState = ref.watch(aiServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat',
          style: TextStyle(fontWeight: FontWeight.w600, color: colors.onSurface),
        ),
        actions: [
          // Model selector chip
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ActionChip(
              avatar: Icon(
                aiState.activeModel?.provider == AIProvider.mock
                    ? Icons.bug_report_outlined
                    : Icons.smart_toy_outlined,
                size: 16,
                color: colors.primary,
              ),
              label: Text(
                aiState.activeModel?.name ?? 'No model',
                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
              ),
              onPressed: () => _showModelPicker(context),
              backgroundColor: colors.surface,
              side: BorderSide(color: colors.outline),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState(colors)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: _messages.length + (_isStreaming ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < _messages.length) {
                        return _MessageBubble(message: _messages[index]);
                      }
                      // Streaming message
                      return _MessageBubble(
                        message: PrismMessage(
                          role: 'assistant',
                          content: _streamingBuffer,
                          timestamp: DateTime.now(),
                        ),
                        isStreaming: true,
                      );
                    },
                  ),
          ),

          // Input bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(top: BorderSide(color: colors.outline, width: 0.5)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: colors.onSurface, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Message Prism...',
                        hintStyle: TextStyle(color: colors.onSurfaceVariant),
                        filled: true,
                        fillColor: colors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: colors.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: colors.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: colors.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      enabled: !_isStreaming,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _isStreaming ? null : _sendMessage,
                    icon: Icon(_isStreaming ? Icons.hourglass_top : Icons.arrow_upward_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: _isStreaming ? colors.outline : colors.primary,
                      foregroundColor: Colors.white,
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

  Widget _buildEmptyState(ColorScheme colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [colors.primary, colors.primary.withValues(alpha: 0.3)],
              ),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 20),
          Text('How can I help?',
              style: TextStyle(color: colors.onSurface, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Ask me anything. I can help with tasks,\nfinance, notes, and more.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _SuggestionChip('Plan my day', onTap: () {
                _controller.text = 'Help me plan my day';
                _sendMessage();
              }),
              _SuggestionChip('Log expense', onTap: () {
                _controller.text = 'I spent \$45 on groceries';
                _sendMessage();
              }),
              _SuggestionChip('Show tasks', onTap: () {
                _controller.text = 'What tasks do I have?';
                _sendMessage();
              }),
            ],
          ),
        ],
      ),
    );
  }

  void _showModelPicker(BuildContext context) {
    final aiState = ref.read(aiServiceProvider);
    final aiNotifier = ref.read(aiServiceProvider.notifier);

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Model',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 16),
            ...aiState.availableModels.map((model) => ListTile(
                  leading: Icon(
                    model.provider == AIProvider.mock
                        ? Icons.bug_report_outlined
                        : Icons.smart_toy_outlined,
                    color: model.id == aiState.activeModel?.id
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  title: Text(model.name),
                  subtitle: Text(model.provider.name),
                  selected: model.id == aiState.activeModel?.id,
                  selectedTileColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onTap: () {
                    aiNotifier.selectModel(model);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }
}

// ─── Message bubble widget ───────────────────────

class _MessageBubble extends StatelessWidget {
  final PrismMessage message;
  final bool isStreaming;

  const _MessageBubble({required this.message, this.isStreaming = false});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isUser = message.role == 'user';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.auto_awesome, size: 14, color: colors.primary),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? colors.primary.withValues(alpha: 0.12)
                    : colors.surface,
                borderRadius: BorderRadius.circular(16).copyWith(
                  topLeft: isUser ? null : const Radius.circular(4),
                  topRight: !isUser ? null : const Radius.circular(4),
                ),
                border: Border.all(
                  color: isUser ? colors.primary.withValues(alpha: 0.2) : colors.outline,
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content.isEmpty && isStreaming ? '...' : message.content,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  if (isStreaming)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: colors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 36),
        ],
      ),
    );
  }
}

// ─── Suggestion chip ─────────────────────────────

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SuggestionChip(this.label, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ActionChip(
      label: Text(label, style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant)),
      onPressed: onTap,
      backgroundColor: colors.surface,
      side: BorderSide(color: colors.outline),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
