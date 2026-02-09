/// Home Screen — daily digest with Soul Orb, quick actions, and summary cards.
///
/// Matches ux_preview design: greeting, animated soul orb, voice/text input,
/// quick actions grid, and digest cards for tasks/events/finance/chats.
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/ai/ai_service.dart';
import '../../core/database/database.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _rotateController;
  final _inputController = TextEditingController();
  bool _inputExpanded = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0C0C16) : const Color(0xFFF5F5FA);
    final cardColor = isDark ? const Color(0xFF16162A) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF252540) : const Color(0xFFE2E2EC);
    final textPrimary =
        isDark ? const Color(0xFFE2E2EC) : const Color(0xFF1A1A2E);
    final textSecondary =
        isDark ? const Color(0xFF7A7A90) : const Color(0xFF6B6B80);
    final accentColor = colors.primary;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // ─── Greeting + Weather ──────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('EEEE, MMMM d').format(DateTime.now()),
                          style:
                              TextStyle(fontSize: 14, color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                  // Weather pill
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor, width: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wb_sunny_rounded,
                            size: 16, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 6),
                        Text(
                          '24°C',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Soul Orb ────────────────────────────
          SliverToBoxAdapter(
            child: GestureDetector(
              onTap: () => context.go('/chat'),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: AnimatedBuilder(
                    animation: Listenable.merge(
                        [_pulseController, _rotateController]),
                    builder: (context, _) {
                      final scale =
                          0.95 + 0.05 * _pulseController.value;
                      return Transform.scale(
                        scale: scale,
                        child: SizedBox(
                          width: 140,
                          height: 140,
                          child: CustomPaint(
                            painter: _SoulOrbPainter(
                              pulseValue: _pulseController.value,
                              rotateValue: _rotateController.value,
                              color: accentColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // ─── Input Bar ───────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Mic button
                  GestureDetector(
                    onTap: () {
                      // Voice input — placeholder
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: cardColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor, width: 0.5),
                      ),
                      child: Icon(Icons.mic_rounded,
                          size: 22, color: textSecondary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Text input
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: borderColor, width: 0.5),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _inputController,
                              onTap: () =>
                                  setState(() => _inputExpanded = true),
                              onSubmitted: (text) {
                                if (text.trim().isNotEmpty) {
                                  context.go('/chat');
                                }
                              },
                              decoration: InputDecoration(
                                hintText: 'Ask Prism anything...',
                                hintStyle: TextStyle(
                                    color: textSecondary, fontSize: 14),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                              ),
                              style: TextStyle(
                                  color: textPrimary, fontSize: 14),
                            ),
                          ),
                          if (_inputExpanded)
                            IconButton(
                              onPressed: () {
                                if (_inputController.text.trim().isNotEmpty) {
                                  context.go('/chat');
                                }
                              },
                              icon: Icon(Icons.arrow_upward_rounded,
                                  color: accentColor, size: 20),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Quick Actions ───────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  _QuickAction(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'New Chat',
                    color: accentColor,
                    onTap: () => context.go('/chat'),
                  ),
                  const SizedBox(width: 12),
                  _QuickAction(
                    icon: Icons.add_task_rounded,
                    label: 'Add Task',
                    color: const Color(0xFF10B981),
                    onTap: () => context.go('/apps'),
                  ),
                  const SizedBox(width: 12),
                  _QuickAction(
                    icon: Icons.note_add_outlined,
                    label: 'Quick Note',
                    color: const Color(0xFF3B82F6),
                    onTap: () => context.go('/brain'),
                  ),
                  const SizedBox(width: 12),
                  _QuickAction(
                    icon: Icons.receipt_long_outlined,
                    label: 'Log Expense',
                    color: const Color(0xFFF59E0B),
                    onTap: () => context.go('/apps'),
                  ),
                ],
              ),
            ),
          ),

          // ─── Digest Cards ────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            sliver: SliverList.list(
              children: [
                // Tasks Card
                _buildDigestCard(
                  context,
                  icon: Icons.check_circle_outline_rounded,
                  iconColor: const Color(0xFF10B981),
                  title: 'Tasks',
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  onTap: () => context.go('/apps'),
                  child: _TasksDigest(
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    accentColor: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(height: 12),

                // AI Status Card
                _buildDigestCard(
                  context,
                  icon: Icons.auto_awesome_rounded,
                  iconColor: accentColor,
                  title: 'AI Status',
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  onTap: () => context.go('/settings'),
                  child: _AIStatusDigest(
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    accentColor: accentColor,
                  ),
                ),
                const SizedBox(height: 12),

                // Notes Card
                _buildDigestCard(
                  context,
                  icon: Icons.lightbulb_outline_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  title: 'Brain',
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  onTap: () => context.go('/brain'),
                  child: _BrainDigest(
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ),
                const SizedBox(height: 12),

                // Finance Card
                _buildDigestCard(
                  context,
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'Finance',
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  onTap: () => context.go('/apps'),
                  child: _FinanceDigest(
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDigestCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required Color cardColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const Spacer(),
                Icon(Icons.chevron_right_rounded,
                    size: 18, color: textSecondary),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

// ─── Quick Action Button ─────────────────────────────

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF7A7A90)
                    : const Color(0xFF6B6B80),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Soul Orb Painter ────────────────────────────────

class _SoulOrbPainter extends CustomPainter {
  final double pulseValue;
  final double rotateValue;
  final Color color;

  _SoulOrbPainter({
    required this.pulseValue,
    required this.rotateValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.7;

    // Outer glow layers
    for (var i = 3; i >= 1; i--) {
      canvas.drawCircle(
        center,
        radius + i * 12 * pulseValue,
        Paint()
          ..color = color.withValues(alpha: 0.06 * (4 - i))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8.0 * i),
      );
    }

    // Organic edge using sine noise
    final path = Path();
    const segments = 72;
    for (var i = 0; i <= segments; i++) {
      final angle = (i / segments) * 2 * math.pi;
      final noise = math.sin(angle * 3 + rotateValue * 2 * math.pi) * 3 +
          math.sin(angle * 5 - rotateValue * 4 * math.pi) * 2;
      final r = radius + noise * pulseValue;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Body gradient
    canvas.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: 0.8),
            color.withValues(alpha: 0.4),
            color.withValues(alpha: 0.15),
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    // Edge highlight
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = color.withValues(alpha: 0.3),
    );

    // Core spot
    canvas.drawCircle(
      center,
      radius * 0.15,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  @override
  bool shouldRepaint(_SoulOrbPainter old) => true;
}

// ─── Tasks Digest Widget ─────────────────────────────

class _TasksDigest extends ConsumerWidget {
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;

  const _TasksDigest({
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    return StreamBuilder<List<TaskEntry>>(
      stream: db.watchPendingTasks(),
      builder: (context, snap) {
        final tasks = snap.data ?? [];
        final total = tasks.length;
        final completed = 0; // pending tasks are all incomplete
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : completed / math.max(total, 1),
                      backgroundColor: accentColor.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation(accentColor),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$completed/$total',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...tasks.take(2).map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(Icons.radio_button_unchecked,
                          size: 16, color: textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t.title,
                          style: TextStyle(fontSize: 13, color: textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (t.dueDate != null)
                        Text(
                          DateFormat('MMM d').format(t.dueDate!),
                          style:
                              TextStyle(fontSize: 11, color: textSecondary),
                        ),
                    ],
                  ),
                )),
            if (tasks.isEmpty)
              Text(
                'No pending tasks. Tap to add one!',
                style: TextStyle(fontSize: 13, color: textSecondary),
              ),
          ],
        );
      },
    );
  }
}

// ─── AI Status Digest ────────────────────────────────

class _AIStatusDigest extends ConsumerWidget {
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;

  const _AIStatusDigest({
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiState = ref.watch(aiServiceProvider);
    final model = aiState.activeModel;

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: aiState.isModelLoaded
                ? const Color(0xFF10B981)
                : const Color(0xFFF59E0B),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                model?.name ?? 'No model selected',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                aiState.isModelLoaded
                    ? '${model?.provider.name ?? 'Unknown'} • Ready'
                    : 'Configure in Settings',
                style: TextStyle(fontSize: 12, color: textSecondary),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            model?.provider.name.toUpperCase() ?? 'NONE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Brain Digest ────────────────────────────────────

class _BrainDigest extends ConsumerWidget {
  final Color textPrimary;
  final Color textSecondary;

  const _BrainDigest({
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    return StreamBuilder<List<Note>>(
      stream: db.watchNotes(),
      builder: (context, snap) {
        final notes = snap.data ?? [];
        return Row(
          children: [
            Icon(Icons.layers_outlined, size: 16, color: textSecondary),
            const SizedBox(width: 6),
            Text(
              '${notes.length} notes',
              style: TextStyle(fontSize: 13, color: textPrimary),
            ),
            const Spacer(),
            if (notes.isNotEmpty)
              Flexible(
                child: Text(
                  'Latest: ${notes.first.title}',
                  style: TextStyle(fontSize: 12, color: textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─── Finance Digest ──────────────────────────────────

class _FinanceDigest extends ConsumerWidget {
  final Color textPrimary;
  final Color textSecondary;

  const _FinanceDigest({
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    return StreamBuilder<List<Transaction>>(
      stream: db.watchCurrentMonthTransactions(),
      builder: (context, snap) {
        final txns = snap.data ?? [];
        final totalExpense = txns
            .where((t) => t.type == 'expense')
            .fold<double>(0, (sum, t) => sum + t.amount);
        final totalIncome = txns
            .where((t) => t.type == 'income')
            .fold<double>(0, (sum, t) => sum + t.amount);

        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Spent', style: TextStyle(fontSize: 11, color: textSecondary)),
                  Text(
                    '\$${totalExpense.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Income', style: TextStyle(fontSize: 11, color: textSecondary)),
                  Text(
                    '\$${totalIncome.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${txns.length} transactions',
              style: TextStyle(fontSize: 11, color: textSecondary),
            ),
          ],
        );
      },
    );
  }
}
