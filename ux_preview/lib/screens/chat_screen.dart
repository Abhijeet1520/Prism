import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moon_design/moon_design.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<dynamic> _conversations = [];
  List<dynamic> _messages = [];
  int _selectedConversation = 0;
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  Future<void> _loadMockData() async {
    final convJson = await rootBundle.loadString('assets/mock_data/conversations/conversations.json');
    final msgJson = await rootBundle.loadString('assets/mock_data/conversations/messages.json');
    setState(() {
      _conversations = jsonDecode(convJson) as List;
      _messages = jsonDecode(msgJson) as List;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.moonColors!;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 700) {
          return Row(
            children: [
              SizedBox(width: 300, child: _buildConversationList(colors)),
              VerticalDivider(width: 1, color: colors.beerus),
              Expanded(child: _buildChatArea(colors)),
            ],
          );
        }
        return _buildChatArea(colors);
      },
    );
  }

  Widget _buildConversationList(MoonColors colors) {
    return Column(
      children: [
        // Search + New Chat
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: MoonTextInput(
                  hintText: 'Search conversations...',
                  leading: Icon(Icons.search, size: 18, color: colors.trunks),
                ),
              ),
              const SizedBox(width: 8),
              MoonButton.icon(
                onTap: () {},
                icon: Icon(Icons.edit_square, size: 20, color: colors.piccolo),
                buttonSize: MoonButtonSize.sm,
              ),
            ],
          ),
        ),
        Divider(height: 1, color: colors.beerus),
        // List
        Expanded(
          child: _conversations.isEmpty
              ? Center(child: MoonCircularLoader(color: colors.piccolo))
              : ListView.builder(
                  itemCount: _conversations.length,
                  itemBuilder: (context, i) {
                    final conv = _conversations[i] as Map<String, dynamic>;
                    final selected = i == _selectedConversation;
                    return MoonMenuItem(
                      onTap: () => setState(() => _selectedConversation = i),
                      backgroundColor: selected ? colors.piccolo.withValues(alpha: 0.08) : Colors.transparent,
                      leading: MoonAvatar(
                        backgroundColor: colors.piccolo.withValues(alpha: 0.15),
                        content: Text(
                          (conv['title'] as String).substring(0, 1),
                          style: TextStyle(color: colors.piccolo, fontWeight: FontWeight.w600),
                        ),
                      ),
                      label: Text(
                        conv['title'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.bulma,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      trailing: conv['isPinned'] == true
                          ? Icon(Icons.push_pin, size: 14, color: colors.trunks)
                          : (conv['unreadCount'] as int? ?? 0) > 0
                              ? MoonTag(
                                  tagSize: MoonTagSize.x2s,
                                  backgroundColor: colors.piccolo,
                                  label: Text('${conv['unreadCount']}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                                )
                              : null,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildChatArea(MoonColors colors) {
    // Filter messages for selected conversation
    final convId = _conversations.isNotEmpty ? _conversations[_selectedConversation]['id'] : null;
    final filtered = _messages.where((m) => m['conversationId'] == convId).toList();

    return Column(
      children: [
        // Chat header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colors.goten,
            border: Border(bottom: BorderSide(color: colors.beerus)),
          ),
          child: Row(
            children: [
              MoonAvatar(
                avatarSize: MoonAvatarSize.sm,
                backgroundColor: colors.piccolo.withValues(alpha: 0.15),
                content: Icon(Icons.auto_awesome, size: 16, color: colors.piccolo),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _conversations.isNotEmpty ? _conversations[_selectedConversation]['title'] as String : 'New Chat',
                      style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    Text(
                      'Gemini 2.0 Flash',
                      style: TextStyle(color: colors.trunks, fontSize: 12),
                    ),
                  ],
                ),
              ),
              MoonButton.icon(
                onTap: () {},
                icon: Icon(Icons.more_vert, color: colors.trunks, size: 20),
                buttonSize: MoonButtonSize.sm,
              ),
            ],
          ),
        ),
        // Messages
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyChat(colors)
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) => _buildMessage(colors, filtered[i] as Map<String, dynamic>),
                ),
        ),
        // Input bar
        _buildInputBar(colors),
      ],
    );
  }

  Widget _buildEmptyChat(MoonColors colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 48, color: colors.piccolo.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('Start a conversation', style: TextStyle(color: colors.trunks, fontSize: 16)),
          const SizedBox(height: 8),
          Text('Ask anything, get help with tasks, or explore ideas.', style: TextStyle(color: colors.trunks, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildMessage(MoonColors colors, Map<String, dynamic> msg) {
    final isUser = msg['role'] == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            MoonAvatar(
              avatarSize: MoonAvatarSize.xs,
              backgroundColor: colors.piccolo.withValues(alpha: 0.15),
              content: Icon(Icons.auto_awesome, size: 14, color: colors.piccolo),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? colors.piccolo.withValues(alpha: 0.12) : colors.goten,
                borderRadius: BorderRadius.circular(14),
                border: isUser ? null : Border.all(color: colors.beerus, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg['content'] as String,
                    style: TextStyle(color: colors.bulma, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${msg['tokenCount']} tokens',
                        style: TextStyle(color: colors.trunks, fontSize: 11),
                      ),
                      if (msg['generationTimeMs'] != null) ...[
                        Text(' \u00b7 ', style: TextStyle(color: colors.trunks, fontSize: 11)),
                        Text(
                          '${msg['generationTimeMs']}ms',
                          style: TextStyle(color: colors.trunks, fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _buildInputBar(MoonColors colors) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.goten,
        border: Border(top: BorderSide(color: colors.beerus)),
      ),
      child: Row(
        children: [
          MoonButton.icon(
            onTap: () {},
            icon: Icon(Icons.attach_file_rounded, color: colors.trunks, size: 20),
            buttonSize: MoonButtonSize.sm,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: MoonTextInput(
              controller: _controller,
              hintText: 'Message Prism...',
              textInputSize: MoonTextInputSize.md,
            ),
          ),
          const SizedBox(width: 8),
          MoonFilledButton(
            onTap: () {},
            buttonSize: MoonButtonSize.sm,
            label: const Icon(Icons.arrow_upward_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}
