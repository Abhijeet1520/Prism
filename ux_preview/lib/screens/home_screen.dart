import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import '../data/mock_data_service.dart';
import '../widgets/soul_orb.dart';

/// Home screen with floating soul orb and daily digest cards.
/// Voice-first design: microphone is primary, text is secondary.
/// Tapping any summary section navigates to its respective screen.
class HomeScreen extends StatefulWidget {
  final void Function(int tabIndex) onNavigateTab;
  final void Function(String appId) onNavigateApp;

  const HomeScreen({
    super.key,
    required this.onNavigateTab,
    required this.onNavigateApp,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> _summary = {};
  bool _isListening = false;
  final _textCtrl = TextEditingController();
  bool _showTextInput = false;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    final data = await MockDataService.instance.getDailySummary();
    if (mounted) setState(() => _summary = data);
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.moonColors!;

    if (_summary.isEmpty) {
      return Scaffold(
        backgroundColor: colors.gohan,
        body: Center(child: MoonCircularLoader(color: colors.piccolo)),
      );
    }

    final greeting = _summary['greeting'] ?? 'Good morning';
    final weather = _summary['weather'] as Map<String, dynamic>? ?? {};
    final tasksSummary = _summary['tasks_summary'] as Map<String, dynamic>? ?? {};
    final chatSummary = _summary['chat_summary'] as Map<String, dynamic>? ?? {};
    final financeSummary = _summary['finance_summary'] as Map<String, dynamic>? ?? {};
    final events = (_summary['events'] as List<dynamic>?) ?? [];

    return Scaffold(
      backgroundColor: colors.gohan,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Greeting + Weather ─────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _buildGreeting(colors, greeting, weather),
              ),
            ),

            // ── Soul Orb (center) ──────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: SoulOrb(
                    size: 160,
                    color: colors.piccolo,
                    onTap: () {
                      // Navigate to chat
                      widget.onNavigateTab(1);
                    },
                  ),
                ),
              ),
            ),

            // ── Voice/Text Input ───────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildVoiceInput(colors),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Quick Actions ──────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildQuickActions(colors),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Daily Digest Cards ─────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildTasksCard(colors, tasksSummary),
                  const SizedBox(height: 12),
                  _buildEventsCard(colors, events),
                  const SizedBox(height: 12),
                  _buildFinanceCard(colors, financeSummary),
                  const SizedBox(height: 12),
                  _buildChatsCard(colors, chatSummary),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting(MoonColors colors, String greeting, Map<String, dynamic> weather) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting,
                  style: TextStyle(color: colors.bulma, fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                _summary['date'] ?? '',
                style: TextStyle(color: colors.trunks, fontSize: 14),
              ),
            ],
          ),
        ),
        // Weather pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colors.goten,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.beerus, width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_weatherIcon(weather['condition'] ?? ''),
                  color: const Color(0xFFF59E0B), size: 18),
              const SizedBox(width: 6),
              Text(
                '${weather['temperature'] ?? '--'}${weather['unit'] ?? '°F'}',
                style: TextStyle(color: colors.bulma, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceInput(MoonColors colors) {
    return Column(
      children: [
        // Mic button
        GestureDetector(
          onTap: () => setState(() => _isListening = !_isListening),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _isListening ? colors.piccolo : colors.goten,
              shape: BoxShape.circle,
              border: Border.all(
                color: _isListening ? colors.piccolo : colors.beerus,
                width: _isListening ? 2 : 1,
              ),
              boxShadow: _isListening
                  ? [BoxShadow(color: colors.piccolo.withValues(alpha: 0.3), blurRadius: 16)]
                  : null,
            ),
            child: Icon(
              _isListening ? Icons.mic : Icons.mic_none_rounded,
              color: _isListening ? Colors.white : colors.trunks,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isListening ? 'Listening...' : 'Tap to speak',
          style: TextStyle(color: colors.trunks, fontSize: 12),
        ),
        const SizedBox(height: 8),
        // Toggle to text input
        GestureDetector(
          onTap: () => setState(() => _showTextInput = !_showTextInput),
          child: Text(
            _showTextInput ? 'Use voice instead' : 'Or type a message',
            style: TextStyle(
              color: colors.piccolo,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (_showTextInput) ...[
          const SizedBox(height: 12),
          MoonTextInput(
            controller: _textCtrl,
            hintText: 'Ask Prism anything...',
            trailing: MoonButton.icon(
              onTap: () {
                if (_textCtrl.text.isNotEmpty) {
                  widget.onNavigateTab(1); // go to chat
                  _textCtrl.clear();
                }
              },
              icon: Icon(Icons.send_rounded, color: colors.piccolo, size: 18),
              buttonSize: MoonButtonSize.sm,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuickActions(MoonColors colors) {
    final actions = [
      _QuickAction('New Chat', Icons.chat_bubble_outline_rounded, colors.piccolo, () => widget.onNavigateTab(1)),
      _QuickAction('Add Task', Icons.check_circle_outline, const Color(0xFF10B981), () => widget.onNavigateApp('tasks')),
      _QuickAction('Quick Note', Icons.edit_note_rounded, const Color(0xFF3B82F6), () => widget.onNavigateTab(2)),
      _QuickAction('Log Expense', Icons.account_balance_wallet_outlined, const Color(0xFFF59E0B), () => widget.onNavigateApp('finance')),
    ];

    return Row(
      children: actions.map((a) {
        return Expanded(
          child: GestureDetector(
            onTap: a.onTap,
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: a.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(a.icon, color: a.color, size: 20),
                ),
                const SizedBox(height: 6),
                Text(a.label, style: TextStyle(color: colors.trunks, fontSize: 11), textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Digest Cards ─────────────────────────────────────────────

  Widget _buildDigestCard({
    required MoonColors colors,
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.goten,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.beerus, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 18),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(color: colors.bulma, fontSize: 15, fontWeight: FontWeight.w600)),
                const Spacer(),
                Icon(Icons.chevron_right_rounded, color: colors.trunks, size: 18),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTasksCard(MoonColors colors, Map<String, dynamic> tasks) {
    final completed = tasks['completed'] ?? 0;
    final total = tasks['total'] ?? 0;
    final topTasks = (tasks['top_tasks'] as List<dynamic>?) ?? [];
    final progress = total > 0 ? completed / total : 0.0;

    return _buildDigestCard(
      colors: colors,
      title: 'Tasks',
      icon: Icons.check_circle_outline,
      iconColor: const Color(0xFF10B981),
      onTap: () => widget.onNavigateApp('tasks'),
      children: [
        // Progress bar
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: colors.beerus,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF10B981)),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text('$completed/$total', style: TextStyle(color: colors.trunks, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 10),
        // Top tasks
        ...topTasks.take(2).map((t) {
          final task = t as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Icon(Icons.radio_button_unchecked, color: colors.trunks, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task['title'] ?? '',
                    style: TextStyle(color: colors.bulma, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  task['due'] ?? '',
                  style: TextStyle(color: colors.trunks, fontSize: 11),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEventsCard(MoonColors colors, List<dynamic> events) {
    return _buildDigestCard(
      colors: colors,
      title: 'Today\'s Schedule',
      icon: Icons.calendar_today_rounded,
      iconColor: const Color(0xFF3B82F6),
      onTap: () => widget.onNavigateApp('tasks'), // events under tasks for now
      children: events.take(3).map((e) {
        final event = e as Map<String, dynamic>;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 32,
                decoration: BoxDecoration(
                  color: event['type'] == 'personal'
                      ? const Color(0xFF22C55E)
                      : const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event['title'] ?? '', style: TextStyle(color: colors.bulma, fontSize: 13)),
                    Text('${event['time']} · ${event['duration']}',
                        style: TextStyle(color: colors.trunks, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFinanceCard(MoonColors colors, Map<String, dynamic> finance) {
    final todaySpent = finance['today_spent'] ?? 0;
    final budgetRemaining = finance['budget_remaining'] ?? 0;
    final transactions = (finance['recent_transactions'] as List<dynamic>?) ?? [];

    return _buildDigestCard(
      colors: colors,
      title: 'Finance',
      icon: Icons.account_balance_wallet_outlined,
      iconColor: const Color(0xFFF59E0B),
      onTap: () => widget.onNavigateApp('finance'),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Today', style: TextStyle(color: colors.trunks, fontSize: 11)),
                  Text('\$$todaySpent', style: TextStyle(color: colors.bulma, fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Remaining', style: TextStyle(color: colors.trunks, fontSize: 11)),
                  Text('\$$budgetRemaining', style: TextStyle(color: const Color(0xFF10B981), fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...transactions.take(2).map((t) {
          final tx = t as Map<String, dynamic>;
          final amount = (tx['amount'] as num?) ?? 0;
          final isIncome = amount > 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(tx['name'] ?? '', style: TextStyle(color: colors.bulma, fontSize: 12)),
                ),
                Text(
                  '${isIncome ? '+' : ''}\$${amount.abs()}',
                  style: TextStyle(
                    color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildChatsCard(MoonColors colors, Map<String, dynamic> chats) {
    final unread = chats['unread'] ?? 0;
    final recent = (chats['recent'] as List<dynamic>?) ?? [];

    return _buildDigestCard(
      colors: colors,
      title: 'Chats',
      icon: Icons.chat_bubble_outline_rounded,
      iconColor: colors.piccolo,
      onTap: () => widget.onNavigateTab(1),
      children: [
        if (unread > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.piccolo.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('$unread unread', style: TextStyle(color: colors.piccolo, fontSize: 12, fontWeight: FontWeight.w500)),
            ),
          ),
        ...recent.take(2).map((c) {
          final chat = c as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(chat['title'] ?? '', style: TextStyle(color: colors.bulma, fontSize: 13, fontWeight: FontWeight.w500)),
                      Text(chat['preview'] ?? '', style: TextStyle(color: colors.trunks, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Text(chat['time'] ?? '', style: TextStyle(color: colors.trunks, fontSize: 11)),
              ],
            ),
          );
        }),
      ],
    );
  }

  IconData _weatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return Icons.wb_sunny_rounded;
      case 'cloudy':
        return Icons.cloud_rounded;
      case 'rainy':
      case 'rain':
        return Icons.water_drop_rounded;
      case 'partly cloudy':
      default:
        return Icons.cloud_queue_rounded;
    }
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction(this.label, this.icon, this.color, this.onTap);
}
