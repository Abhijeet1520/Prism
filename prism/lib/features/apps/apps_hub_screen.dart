/// Apps Hub — 5 app tiles (Tasks, Finance, Files, Tools, Gateway)
/// with sub-screen navigation. Matches ux_preview design.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/database.dart';
import '../../core/ai/ai_host_server.dart';

class AppsHubScreen extends ConsumerStatefulWidget {
  const AppsHubScreen({super.key});

  @override
  ConsumerState<AppsHubScreen> createState() => _AppsHubScreenState();
}

class _AppsHubScreenState extends ConsumerState<AppsHubScreen> {
  int? _selectedApp;

  static const _apps = [
    _AppDef(Icons.check_circle_outline_rounded, 'Tasks',
        'Manage tasks & deadlines', Color(0xFF10B981), '✅'),
    _AppDef(Icons.account_balance_wallet_outlined, 'Finance',
        'Track spending & budgets', Color(0xFFF59E0B), '💰'),
    _AppDef(Icons.folder_outlined, 'Files',
        'Browse & manage files', Color(0xFF3B82F6), '📁'),
    _AppDef(Icons.extension_outlined, 'Tools',
        'AI tools & ML Kit utilities', Color(0xFF8B5CF6), '🧰'),
    _AppDef(Icons.hub_outlined, 'Gateway',
        'AI host for other apps', Color(0xFFEC4899), '🌐'),
  ];

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

    if (_selectedApp != null) {
      return _buildSubScreen(
        isDark: isDark,
        bgColor: bgColor,
        cardColor: cardColor,
        borderColor: borderColor,
        textPrimary: textPrimary,
        textSecondary: textSecondary,
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // ─── Header ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
            child: Row(
              children: [
                Text('Apps',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: textPrimary)),
                const Spacer(),
              ],
            ),
          ),

          // ─── App Grid ────────────────────────────
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 280,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.25,
              ),
              itemCount: _apps.length,
              itemBuilder: (context, i) {
                final app = _apps[i];
                return GestureDetector(
                  onTap: () => setState(() => _selectedApp = i),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: app.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(app.emoji,
                                style: const TextStyle(fontSize: 22)),
                          ),
                        ),
                        const Spacer(),
                        Text(app.label,
                            style: TextStyle(
                                color: textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(app.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubScreen({
    required bool isDark,
    required Color bgColor,
    required Color cardColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final app = _apps[_selectedApp!];

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Sub-screen header
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => setState(() => _selectedApp = null),
                  icon: Icon(Icons.arrow_back_rounded,
                      size: 20, color: textSecondary),
                ),
                Text(app.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(app.label,
                    style: TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16)),
              ],
            ),
          ),
          Divider(color: borderColor, height: 16),
          Expanded(
            child: switch (_selectedApp!) {
              0 => _TasksSubScreen(
                  isDark: isDark,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary),
              1 => _FinanceSubScreen(
                  isDark: isDark,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary),
              2 => _FilesSubScreen(
                  isDark: isDark,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary),
              3 => _ToolsSubScreen(
                  isDark: isDark,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary),
              4 => _GatewaySubScreen(
                  isDark: isDark,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary),
              _ => const SizedBox.shrink(),
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Tasks Sub-Screen
// ─────────────────────────────────────────────────────

class _TasksSubScreen extends ConsumerStatefulWidget {
  final bool isDark;
  final Color cardColor, borderColor, textPrimary, textSecondary;
  const _TasksSubScreen(
      {required this.isDark,
      required this.cardColor,
      required this.borderColor,
      required this.textPrimary,
      required this.textSecondary});

  @override
  ConsumerState<_TasksSubScreen> createState() => _TasksSubScreenState();
}

class _TasksSubScreenState extends ConsumerState<_TasksSubScreen> {
  final _titleCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _addTask() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    await ref.read(databaseProvider).createTask(
          uuid: const Uuid().v4(),
          title: title,
        );
    _titleCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        // Add task bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: widget.cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: widget.borderColor, width: 0.5),
                  ),
                  child: TextField(
                    controller: _titleCtrl,
                    onSubmitted: (_) => _addTask(),
                    decoration: InputDecoration(
                      hintText: 'Add a new task...',
                      hintStyle: TextStyle(
                          color: widget.textSecondary, fontSize: 13),
                      prefixIcon: Icon(Icons.add_rounded,
                          size: 18, color: widget.textSecondary),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: TextStyle(
                        color: widget.textPrimary, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _addTask,
                style: FilledButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(60, 42),
                ),
                child: const Text('Add', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: widget.borderColor),
        // Task list
        Expanded(
          child: StreamBuilder<List<TaskEntry>>(
            stream: ref.watch(databaseProvider).watchPendingTasks(),
            builder: (context, snap) {
              final tasks = snap.data ?? [];
              if (tasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 48,
                          color:
                              widget.textSecondary.withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
                      Text('All tasks complete!',
                          style: TextStyle(
                              color: widget.textSecondary, fontSize: 14)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: tasks.length,
                itemBuilder: (context, i) {
                  final task = tasks[i];
                  final pColor = _priorityColor(task.priority);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: widget.borderColor, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => ref
                              .read(databaseProvider)
                              .toggleTask(task.uuid),
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: pColor, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(task.title,
                                  style: TextStyle(
                                      color: widget.textPrimary,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14)),
                              if (task.description.isNotEmpty)
                                Text(task.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: widget.textSecondary,
                                        fontSize: 12)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: pColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(task.priority,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: pColor,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Color _priorityColor(String p) => switch (p) {
        'high' => const Color(0xFFEF4444),
        'medium' => const Color(0xFFF59E0B),
        _ => const Color(0xFF10B981),
      };
}

// ─────────────────────────────────────────────────────
// Finance Sub-Screen
// ─────────────────────────────────────────────────────

class _FinanceSubScreen extends ConsumerWidget {
  final bool isDark;
  final Color cardColor, borderColor, textPrimary, textSecondary;
  const _FinanceSubScreen(
      {required this.isDark,
      required this.cardColor,
      required this.borderColor,
      required this.textPrimary,
      required this.textSecondary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return StreamBuilder<List<Transaction>>(
      stream: db.watchCurrentMonthTransactions(),
      builder: (context, snap) {
        final txns = snap.data ?? [];
        final totalExp = txns
            .where((t) => t.type == 'expense')
            .fold<double>(0, (s, t) => s + t.amount);
        final totalInc = txns
            .where((t) => t.type == 'income')
            .fold<double>(0, (s, t) => s + t.amount);

        return Column(
          children: [
            // Summary cards
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                      child: _StatCard(
                          label: 'Income',
                          amount: totalInc,
                          color: const Color(0xFF10B981),
                          cardColor: cardColor,
                          borderColor: borderColor,
                          textSecondary: textSecondary)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _StatCard(
                          label: 'Expenses',
                          amount: totalExp,
                          color: const Color(0xFFEF4444),
                          cardColor: cardColor,
                          borderColor: borderColor,
                          textSecondary: textSecondary)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _StatCard(
                          label: 'Balance',
                          amount: totalInc - totalExp,
                          color: Theme.of(context).colorScheme.primary,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          textSecondary: textSecondary)),
                ],
              ),
            ),
            Divider(height: 1, color: borderColor),
            // Transactions list
            Expanded(
              child: txns.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.account_balance_wallet_outlined,
                              size: 48,
                              color: textSecondary.withValues(alpha: 0.3)),
                          const SizedBox(height: 12),
                          Text('No transactions this month',
                              style: TextStyle(
                                  color: textSecondary, fontSize: 14)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: txns.length,
                      itemBuilder: (context, i) {
                        final txn = txns[i];
                        final isExp = txn.type == 'expense';
                        final c = isExp
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF10B981);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: borderColor, width: 0.5),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: c.withValues(alpha: 0.12),
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Icon(
                                    isExp
                                        ? Icons.arrow_upward_rounded
                                        : Icons.arrow_downward_rounded,
                                    color: c,
                                    size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(txn.category,
                                        style: TextStyle(
                                            color: textPrimary,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14)),
                                    if (txn.description.isNotEmpty)
                                      Text(txn.description,
                                          maxLines: 1,
                                          overflow:
                                              TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: textSecondary,
                                              fontSize: 12)),
                                  ],
                                ),
                              ),
                              Text(
                                '${isExp ? '-' : '+'}\$${txn.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                    color: c,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color, cardColor, borderColor, textSecondary;
  const _StatCard(
      {required this.label,
      required this.amount,
      required this.color,
      required this.cardColor,
      required this.borderColor,
      required this.textSecondary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: textSecondary, fontSize: 11)),
          const SizedBox(height: 4),
          FittedBox(
            child: Text('\$${amount.toStringAsFixed(2)}',
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Files Sub-Screen (placeholder with file browser concept)
// ─────────────────────────────────────────────────────

class _FilesSubScreen extends StatelessWidget {
  final bool isDark;
  final Color cardColor, borderColor, textPrimary, textSecondary;
  const _FilesSubScreen(
      {required this.isDark,
      required this.cardColor,
      required this.borderColor,
      required this.textPrimary,
      required this.textSecondary});

  @override
  Widget build(BuildContext context) {
    final categories = [
      ('Documents', Icons.description_outlined, '12 files',
          const Color(0xFF3B82F6)),
      ('Images', Icons.image_outlined, '37 files',
          const Color(0xFF10B981)),
      ('Downloads', Icons.download_rounded, '8 files',
          const Color(0xFFF59E0B)),
      ('Models', Icons.model_training_outlined, '3 files',
          const Color(0xFF8B5CF6)),
    ];

    return Column(
      children: [
        // Storage usage
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Storage',
                    style: TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.35,
                    backgroundColor: borderColor,
                    color: Theme.of(context).colorScheme.primary,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Text('1.2 GB of 4.0 GB used',
                    style: TextStyle(
                        color: textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ),
        // File categories
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, i) {
              final cat = categories[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor, width: 0.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cat.$4.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(cat.$2, color: cat.$4, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cat.$1,
                              style: TextStyle(
                                  color: textPrimary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14)),
                          Text(cat.$3,
                              style: TextStyle(
                                  color: textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        size: 20, color: textSecondary),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────
// Tools Sub-Screen
// ─────────────────────────────────────────────────────

class _ToolsSubScreen extends StatelessWidget {
  final bool isDark;
  final Color cardColor, borderColor, textPrimary, textSecondary;
  const _ToolsSubScreen(
      {required this.isDark,
      required this.cardColor,
      required this.borderColor,
      required this.textPrimary,
      required this.textSecondary});

  static const _tools = [
    ('OCR Scanner', Icons.document_scanner_outlined,
        'Extract text from images', Color(0xFF3B82F6)),
    ('Language ID', Icons.translate_rounded,
        'Identify text language', Color(0xFF8B5CF6)),
    ('Smart Reply', Icons.quickreply_outlined,
        'Get suggest replies', Color(0xFF10B981)),
    ('Entity Extract', Icons.category_outlined,
        'Find dates, phones, etc.', Color(0xFFF59E0B)),
    ('Summarize', Icons.summarize_outlined,
        'Summarize long text with AI', Color(0xFFEC4899)),
    ('Translate', Icons.g_translate_rounded,
        'Translate text on-device', Color(0xFF06B6D4)),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: _tools.length,
      itemBuilder: (context, i) {
        final tool = _tools[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: tool.$4.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(tool.$2, color: tool.$4, size: 18),
              ),
              const Spacer(),
              Text(tool.$1,
                  style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
              const SizedBox(height: 2),
              Text(tool.$3,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: textSecondary, fontSize: 11)),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────
// Gateway Sub-Screen — AI Host Server controls
// ─────────────────────────────────────────────────────

class _GatewaySubScreen extends ConsumerWidget {
  final bool isDark;
  final Color cardColor, borderColor, textPrimary, textSecondary;
  const _GatewaySubScreen(
      {required this.isDark,
      required this.cardColor,
      required this.borderColor,
      required this.textPrimary,
      required this.textSecondary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final host = ref.watch(aiHostProvider);
    final accentColor = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Server status card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: host.isRunning
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      host.isRunning ? 'Server Running' : 'Server Stopped',
                      style: TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15),
                    ),
                    const Spacer(),
                    Switch.adaptive(
                      value: host.isRunning,
                      onChanged: (_) {
                        final notifier = ref.read(aiHostProvider.notifier);
                        if (host.isRunning) {
                          notifier.stop();
                        } else {
                          notifier.start();
                        }
                      },
                      activeTrackColor: accentColor,
                    ),
                  ],
                ),
                if (host.isRunning) ...[
                  const SizedBox(height: 12),
                  _infoRow('Endpoint',
                      'http://localhost:${host.port}/v1/chat/completions'),
                  const SizedBox(height: 6),
                  _infoRow('Port', '${host.port}'),
                  const SizedBox(height: 6),
                  _infoRow('Requests Served', '${host.requestCount}'),
                ],
                if (host.error != null) ...[
                  const SizedBox(height: 8),
                  Text(host.error!,
                      style: const TextStyle(
                          color: Color(0xFFEF4444), fontSize: 12)),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('About Gateway',
                    style: TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  'Gateway exposes your loaded AI model as an OpenAI-compatible API on localhost. '
                  'Other apps on this device can send requests to use your model — no cloud needed.',
                  style: TextStyle(
                      color: textSecondary,
                      fontSize: 13,
                      height: 1.5),
                ),
                const SizedBox(height: 12),
                Text('Compatible endpoints:',
                    style: TextStyle(
                        color: textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 12)),
                const SizedBox(height: 6),
                _endpoint('GET', '/health', textSecondary),
                _endpoint('GET', '/v1/models', textSecondary),
                _endpoint('POST', '/v1/chat/completions', textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(label,
              style: TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Text(value,
              style: TextStyle(color: textPrimary, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _endpoint(String method, String path, Color secondary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: method == 'GET'
                  ? const Color(0xFF10B981).withValues(alpha: 0.12)
                  : const Color(0xFF3B82F6).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(method,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: method == 'GET'
                        ? const Color(0xFF10B981)
                        : const Color(0xFF3B82F6))),
          ),
          const SizedBox(width: 8),
          Text(path, style: TextStyle(color: secondary, fontSize: 12)),
        ],
      ),
    );
  }
}

// ─── Shared ──────────────────────────────────────────

class _AppDef {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final String emoji;
  const _AppDef(this.icon, this.label, this.description, this.color, this.emoji);
}
