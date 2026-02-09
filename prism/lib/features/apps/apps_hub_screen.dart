/// Apps Hub screen — grid of app modules (Tasks, Finance, etc.).
///
/// Each tile navigates to its sub-screen within this tab.
/// Styled with Moon Design tokens and distinct accent colors per app.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moon_design/moon_design.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/database.dart';

class AppsHubScreen extends ConsumerStatefulWidget {
  const AppsHubScreen({super.key});

  @override
  ConsumerState<AppsHubScreen> createState() => _AppsHubScreenState();
}

class _AppsHubScreenState extends ConsumerState<AppsHubScreen> {
  int? _selectedApp;

  static const _apps = [
    _AppDef(Icons.check_circle_outline_rounded, 'Tasks', 'Manage tasks & deadlines', Color(0xFF10B981)),
    _AppDef(Icons.account_balance_wallet_outlined, 'Finance', 'Track spending & budgets', Color(0xFFF59E0B)),
    _AppDef(Icons.extension_outlined, 'Tools', 'AI tools & utilities', Color(0xFF8B5CF6)),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.moonColors!;
    if (_selectedApp != null) return _buildSubScreen(colors);
    return _buildHub(colors);
  }

  // ── Hub Grid ────────────────────────────────────

  Widget _buildHub(MoonColors colors) {
    return Scaffold(
      backgroundColor: colors.gohan,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.goten,
              border: Border(bottom: BorderSide(color: colors.beerus)),
            ),
            child: Row(
              children: [
                Text('Apps', style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w700, fontSize: 18)),
                const Spacer(),
                MoonButton.icon(
                  onTap: () {},
                  icon: Icon(Icons.search, size: 20, color: colors.trunks),
                  buttonSize: MoonButtonSize.sm,
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 280,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.3,
              ),
              itemCount: _apps.length,
              itemBuilder: (context, i) => _AppTile(colors: colors, app: _apps[i], onTap: () => setState(() => _selectedApp = i)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sub-screen ──────────────────────────────────

  Widget _buildSubScreen(MoonColors colors) {
    return Scaffold(
      backgroundColor: colors.gohan,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: colors.goten,
              border: Border(bottom: BorderSide(color: colors.beerus)),
            ),
            child: Row(
              children: [
                MoonButton.icon(
                  onTap: () => setState(() => _selectedApp = null),
                  icon: Icon(Icons.arrow_back, size: 20, color: colors.trunks),
                  buttonSize: MoonButtonSize.sm,
                ),
                const SizedBox(width: 4),
                Text(
                  _apps[_selectedApp!].label,
                  style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ],
            ),
          ),
          Expanded(
            child: switch (_selectedApp!) {
              0 => const _TasksSubScreen(),
              1 => const _FinanceSubScreen(),
              2 => const _ToolsSubScreen(),
              _ => const SizedBox.shrink(),
            },
          ),
        ],
      ),
    );
  }
}

// ─── App Tile ─────────────────────────────────────────

class _AppTile extends StatelessWidget {
  final MoonColors colors;
  final _AppDef app;
  final VoidCallback onTap;
  const _AppTile({required this.colors, required this.app, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.goten,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.beerus, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: app.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(app.icon, color: app.color, size: 22),
            ),
            const SizedBox(height: 14),
            Text(app.label, style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 4),
            Text(app.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: colors.trunks, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ─── Tasks Sub-Screen ─────────────────────────────────

class _TasksSubScreen extends ConsumerStatefulWidget {
  const _TasksSubScreen();

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
    final db = ref.read(databaseProvider);
    await db.createTask(uuid: const Uuid().v4(), title: title);
    _titleCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.moonColors!;
    final db = ref.watch(databaseProvider);

    return Column(
      children: [
        // Add task input
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: MoonTextInput(
                  controller: _titleCtrl,
                  hintText: 'Add a new task...',
                  textInputSize: MoonTextInputSize.sm,
                  leading: Icon(Icons.add, size: 18, color: colors.trunks),
                  onSubmitted: (_) => _addTask(),
                ),
              ),
              const SizedBox(width: 8),
              MoonFilledButton(onTap: _addTask, buttonSize: MoonButtonSize.sm, label: const Text('Add')),
            ],
          ),
        ),
        Divider(height: 1, color: colors.beerus),
        // Task list
        Expanded(
          child: StreamBuilder<List<TaskEntry>>(
            stream: db.watchPendingTasks(),
            builder: (context, snapshot) {
              final tasks = snapshot.data ?? [];
              if (tasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline, size: 48, color: colors.piccolo.withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
                      Text('All tasks complete!', style: TextStyle(color: colors.trunks, fontSize: 16)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: tasks.length,
                itemBuilder: (context, i) {
                  final task = tasks[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.goten,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.beerus, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => ref.read(databaseProvider).toggleTask(task.uuid),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: _priorityColor(task.priority), width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(task.title, style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w500, fontSize: 14)),
                              if (task.description.isNotEmpty)
                                Text(task.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: colors.trunks, fontSize: 12)),
                            ],
                          ),
                        ),
                        MoonTag(
                          tagSize: MoonTagSize.x2s,
                          backgroundColor: _priorityColor(task.priority).withValues(alpha: 0.12),
                          label: Text(task.priority, style: TextStyle(fontSize: 10, color: _priorityColor(task.priority))),
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

  Color _priorityColor(String priority) {
    return switch (priority) {
      'high' => const Color(0xFFEF4444),
      'medium' => const Color(0xFFF59E0B),
      _ => const Color(0xFF10B981),
    };
  }
}

// ─── Finance Sub-Screen ───────────────────────────────

class _FinanceSubScreen extends ConsumerWidget {
  const _FinanceSubScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.moonColors!;
    final db = ref.watch(databaseProvider);

    return StreamBuilder<List<Transaction>>(
      stream: db.watchCurrentMonthTransactions(),
      builder: (context, snapshot) {
        final txns = snapshot.data ?? [];
        final totalExpense = txns.where((t) => t.type == 'expense').fold<double>(0, (sum, t) => sum + t.amount);
        final totalIncome = txns.where((t) => t.type == 'income').fold<double>(0, (sum, t) => sum + t.amount);

        return Column(
          children: [
            // Summary header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(child: _FinanceStat(colors: colors, label: 'Income', amount: totalIncome, color: const Color(0xFF10B981))),
                  const SizedBox(width: 12),
                  Expanded(child: _FinanceStat(colors: colors, label: 'Expenses', amount: totalExpense, color: const Color(0xFFEF4444))),
                  const SizedBox(width: 12),
                  Expanded(child: _FinanceStat(colors: colors, label: 'Balance', amount: totalIncome - totalExpense, color: colors.piccolo)),
                ],
              ),
            ),
            Divider(height: 1, color: colors.beerus),
            // Transaction list
            Expanded(
              child: txns.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.account_balance_wallet_outlined, size: 48, color: colors.piccolo.withValues(alpha: 0.3)),
                          const SizedBox(height: 12),
                          Text('No transactions this month', style: TextStyle(color: colors.trunks, fontSize: 16)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: txns.length,
                      itemBuilder: (context, i) {
                        final txn = txns[i];
                        final isExpense = txn.type == 'expense';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.goten,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: colors.beerus, width: 0.5),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: (isExpense ? const Color(0xFFEF4444) : const Color(0xFF10B981)).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                                  color: isExpense ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(txn.category, style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w500, fontSize: 14)),
                                    if (txn.description.isNotEmpty)
                                      Text(txn.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: colors.trunks, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Text(
                                '${isExpense ? '-' : '+'}\$${txn.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: isExpense ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
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

class _FinanceStat extends StatelessWidget {
  final MoonColors colors;
  final String label;
  final double amount;
  final Color color;
  const _FinanceStat({required this.colors, required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.goten,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.beerus, width: 0.5),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: colors.trunks, fontSize: 11)),
          const SizedBox(height: 4),
          Text('\$${amount.toStringAsFixed(2)}', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 16)),
        ],
      ),
    );
  }
}

// ─── Tools Sub-Screen ─────────────────────────────────

class _ToolsSubScreen extends StatelessWidget {
  const _ToolsSubScreen();

  static const _tools = [
    ('OCR Scanner', Icons.document_scanner_outlined, 'Extract text from images using ML Kit', Color(0xFF3B82F6)),
    ('Language ID', Icons.translate_rounded, 'Identify text language on-device', Color(0xFF8B5CF6)),
    ('Smart Reply', Icons.quickreply_outlined, 'Get AI-suggested replies', Color(0xFF10B981)),
    ('Entity Extract', Icons.category_outlined, 'Find dates, addresses, phones in text', Color(0xFFF59E0B)),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.moonColors!;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: _tools.length,
      itemBuilder: (context, i) {
        final tool = _tools[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.goten,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.beerus, width: 0.5),
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
              const SizedBox(height: 12),
              Text(tool.$1, style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 4),
              Text(tool.$3, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: colors.trunks, fontSize: 11)),
            ],
          ),
        );
      },
    );
  }
}

// ─── App definition ───────────────────────────────────

class _AppDef {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  const _AppDef(this.icon, this.label, this.description, this.color);
}
