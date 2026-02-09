/// Home screen — daily digest with greeting, quick actions, and summary cards.
///
/// Voice-first design with Soul Orb as primary interaction element.
/// Uses Moon Design tokens via [context.moonColors].
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moon_design/moon_design.dart';

import '../../core/ai/ai_service.dart';
import '../../core/database/database.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = context.moonColors!;
    final now = DateTime.now();
    final greeting = _greetingForHour(now.hour);

    return Scaffold(
      backgroundColor: colors.gohan,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Greeting ───────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _GreetingHeader(greeting: greeting, colors: colors),
              ),
            ),

            // ── Quick Input ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _QuickInput(colors: colors, onSubmit: _handleQuickInput),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Quick Actions ──────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _QuickActions(colors: colors, onAction: _handleAction),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Live Data Cards ────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _TasksSummaryCard(colors: colors),
                  const SizedBox(height: 12),
                  _NotesSummaryCard(colors: colors),
                  const SizedBox(height: 12),
                  _AiStatusCard(colors: colors),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greetingForHour(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _handleQuickInput(String text) {
    // Navigate to a new chat with the user's input
    context.go('/chat');
  }

  void _handleAction(String action) {
    switch (action) {
      case 'chat':
        context.go('/chat');
      case 'brain':
        context.go('/brain');
      case 'apps':
        context.go('/apps');
      case 'settings':
        context.go('/settings');
    }
  }
}

// ─── Greeting Header ──────────────────────────────────

class _GreetingHeader extends StatelessWidget {
  final String greeting;
  final MoonColors colors;
  const _GreetingHeader({required this.greeting, required this.colors});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dateStr = '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(color: colors.bulma, fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(dateStr, style: TextStyle(color: colors.trunks, fontSize: 14)),
            ],
          ),
        ),
        // Status indicator
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
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: colors.roshi, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text('Online', style: TextStyle(color: colors.bulma, fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Quick Input ──────────────────────────────────────

class _QuickInput extends StatefulWidget {
  final MoonColors colors;
  final ValueChanged<String> onSubmit;
  const _QuickInput({required this.colors, required this.onSubmit});

  @override
  State<_QuickInput> createState() => _QuickInputState();
}

class _QuickInputState extends State<_QuickInput> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: widget.colors.goten,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: widget.colors.beerus, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, size: 20, color: widget.colors.piccolo),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _ctrl,
              style: TextStyle(color: widget.colors.bulma, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Ask Prism anything...',
                hintStyle: TextStyle(color: widget.colors.trunks, fontSize: 15),
                border: InputBorder.none,
              ),
              onSubmitted: (text) {
                if (text.trim().isNotEmpty) widget.onSubmit(text.trim());
              },
            ),
          ),
          IconButton(
            onPressed: () {
              if (_ctrl.text.trim().isNotEmpty) widget.onSubmit(_ctrl.text.trim());
            },
            icon: Icon(Icons.arrow_upward_rounded, color: widget.colors.piccolo, size: 22),
            style: IconButton.styleFrom(
              backgroundColor: widget.colors.piccolo.withValues(alpha: 0.12),
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(36, 36),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Actions ────────────────────────────────────

class _QuickActions extends StatelessWidget {
  final MoonColors colors;
  final void Function(String action) onAction;
  const _QuickActions({required this.colors, required this.onAction});

  static const _actions = [
    ('chat', Icons.chat_bubble_outline_rounded, 'Chat', Color(0xFF818CF8)),
    ('brain', Icons.auto_awesome_outlined, 'Brain', Color(0xFF34D399)),
    ('apps', Icons.apps_outlined, 'Apps', Color(0xFFF59E0B)),
    ('settings', Icons.settings_outlined, 'Settings', Color(0xFF3B82F6)),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: TextStyle(color: colors.bulma, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          children: _actions.map((a) {
            return Expanded(
              child: GestureDetector(
                onTap: () => onAction(a.$1),
                child: Container(
                  margin: EdgeInsets.only(right: a != _actions.last ? 10 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: colors.goten,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.beerus, width: 0.5),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: a.$4.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(a.$2, color: a.$4, size: 20),
                      ),
                      const SizedBox(height: 8),
                      Text(a.$3, style: TextStyle(color: colors.bulma, fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── Tasks Summary Card ───────────────────────────────

class _TasksSummaryCard extends ConsumerWidget {
  final MoonColors colors;
  const _TasksSummaryCard({required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return StreamBuilder<List<TaskEntry>>(
      stream: db.watchPendingTasks(),
      builder: (context, snapshot) {
        final tasks = snapshot.data ?? [];
        final count = tasks.length;
        final highPriority = tasks.where((t) => t.priority == 'high').length;

        return _SummaryCard(
          colors: colors,
          icon: Icons.check_circle_outline_rounded,
          iconColor: const Color(0xFF10B981),
          title: 'Tasks',
          subtitle: count == 0 ? 'All caught up!' : '$count pending${highPriority > 0 ? ' · $highPriority high priority' : ''}',
          onTap: () => context.go('/apps'),
          trailing: count > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('$count', style: const TextStyle(color: Color(0xFF10B981), fontSize: 13, fontWeight: FontWeight.w600)),
                )
              : null,
        );
      },
    );
  }
}

// ─── Notes Summary Card ───────────────────────────────

class _NotesSummaryCard extends ConsumerWidget {
  final MoonColors colors;
  const _NotesSummaryCard({required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return StreamBuilder<List<Note>>(
      stream: db.watchNotes(),
      builder: (context, snapshot) {
        final notes = snapshot.data ?? [];

        return _SummaryCard(
          colors: colors,
          icon: Icons.auto_awesome_outlined,
          iconColor: const Color(0xFF818CF8),
          title: 'Brain',
          subtitle: notes.isEmpty ? 'No notes yet' : '${notes.length} notes in your knowledge base',
          onTap: () => context.go('/brain'),
          trailing: notes.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF818CF8).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${notes.length}', style: const TextStyle(color: Color(0xFF818CF8), fontSize: 13, fontWeight: FontWeight.w600)),
                )
              : null,
        );
      },
    );
  }
}

// ─── AI Status Card ───────────────────────────────────

class _AiStatusCard extends ConsumerWidget {
  final MoonColors colors;
  const _AiStatusCard({required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiState = ref.watch(aiServiceProvider);
    final model = aiState.activeModel;
    final modelName = model?.name ?? 'No model';
    final providerName = model?.provider.name ?? 'none';

    return _SummaryCard(
      colors: colors,
      icon: Icons.smart_toy_outlined,
      iconColor: const Color(0xFFF59E0B),
      title: 'AI Model',
      subtitle: '$modelName · $providerName',
      onTap: () => context.go('/settings'),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: colors.roshi.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text('ready', style: TextStyle(color: colors.roshi, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ─── Shared Summary Card ──────────────────────────────

class _SummaryCard extends StatelessWidget {
  final MoonColors colors;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SummaryCard({
    required this.colors,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.goten,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.beerus, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: colors.trunks, fontSize: 13)),
                ],
              ),
            ),
            ?trailing,
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: colors.trunks, size: 20),
          ],
        ),
      ),
    );
  }
}
