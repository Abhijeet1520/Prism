/// Finance sub-screen — summary cards + Transactions / Budget tabs.
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/database/database.dart';

class FinanceSubScreen extends ConsumerStatefulWidget {
  final bool isDark;
  final Color cardColor, borderColor, textPrimary, textSecondary;

  const FinanceSubScreen({
    super.key,
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  ConsumerState<FinanceSubScreen> createState() => _FinanceSubScreenState();
}

class _FinanceSubScreenState extends ConsumerState<FinanceSubScreen> {
  int _activeTab = 0; // 0 = Transactions, 1 = Budget
  List<dynamic> _budgets = [];
  int? _expandedTxnIndex; // index of expanded transaction for inline actions

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    final raw = await rootBundle.loadString('assets/mock_data/app_data.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    setState(() => _budgets = (json['budgets'] as List?) ?? []);
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final accentColor = Theme.of(context).colorScheme.primary;

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
                          cardColor: widget.cardColor,
                          borderColor: widget.borderColor,
                          textSecondary: widget.textSecondary)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _StatCard(
                          label: 'Expenses',
                          amount: totalExp,
                          color: const Color(0xFFEF4444),
                          cardColor: widget.cardColor,
                          borderColor: widget.borderColor,
                          textSecondary: widget.textSecondary)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _StatCard(
                          label: 'Balance',
                          amount: totalInc - totalExp,
                          color: accentColor,
                          cardColor: widget.cardColor,
                          borderColor: widget.borderColor,
                          textSecondary: widget.textSecondary)),
                ],
              ),
            ),
            // Tab bar: Transactions / Budget + Add button
            Container(
              padding: const EdgeInsets.only(right: 8),
              color: widget.cardColor,
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: _TabBtn(
                          label: 'Transactions', isActive: _activeTab == 0,
                          accent: accentColor, secondary: widget.textSecondary,
                          onTap: () => setState(() => _activeTab = 0))),
                        Expanded(child: _TabBtn(
                          label: 'Budget', isActive: _activeTab == 1,
                          accent: accentColor, secondary: widget.textSecondary,
                          onTap: () => setState(() => _activeTab = 1))),
                      ],
                    ),
                  ),
                  // Add Transaction button
                  IconButton(
                    onPressed: () => _showAddTransactionDialog(accentColor),
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.add_rounded, color: accentColor, size: 18),
                    ),
                    tooltip: 'Add Transaction',
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: widget.borderColor),
            // Content
            Expanded(
              child: _activeTab == 1
                  ? _buildBudgetView(accentColor)
                  : txns.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.account_balance_wallet_outlined,
                              size: 48,
                              color: widget.textSecondary.withValues(alpha: 0.3)),
                          const SizedBox(height: 12),
                          Text('No transactions this month',
                              style: TextStyle(
                                  color: widget.textSecondary, fontSize: 14)),
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
                        final isExpanded = _expandedTxnIndex == i;
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () => setState(() =>
                                  _expandedTxnIndex = isExpanded ? null : i),
                              child: Container(
                                margin: EdgeInsets.only(bottom: isExpanded ? 0 : 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: widget.cardColor,
                                  borderRadius: isExpanded
                                      ? const BorderRadius.vertical(top: Radius.circular(10))
                                      : BorderRadius.circular(10),
                                  border: Border.all(
                                      color: isExpanded ? accentColor.withValues(alpha: 0.4) : widget.borderColor, width: 0.5),
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
                                          _categoryIcon(txn.category),
                                          color: c,
                                          size: 18),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(txn.category.isNotEmpty
                                              ? txn.category[0].toUpperCase() + txn.category.substring(1)
                                              : 'Other',
                                              style: TextStyle(
                                                  color: widget.textPrimary,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14)),
                                          if (txn.description.isNotEmpty)
                                            Text(txn.description,
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    color: widget.textSecondary,
                                                    fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${isExp ? '-' : '+'}\$${txn.amount.toStringAsFixed(2)}',
                                          style: TextStyle(
                                              color: c,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14),
                                        ),
                                        Text(
                                          DateFormat('MMM d').format(txn.createdAt),
                                          style: TextStyle(
                                              color: widget.textSecondary, fontSize: 10),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                                      size: 18, color: widget.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // ─── Inline Actions Panel ────
                            if (isExpanded)
                              _buildInlineActions(txn, accentColor, i),
                          ],
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  IconData _categoryIcon(String category) {
    return switch (category.toLowerCase()) {
      'food' => Icons.restaurant_rounded,
      'transport' => Icons.directions_bus_rounded,
      'entertainment' => Icons.movie_rounded,
      'bills' => Icons.receipt_long_rounded,
      'shopping' => Icons.shopping_bag_rounded,
      'income' => Icons.account_balance_rounded,
      'health' => Icons.favorite_rounded,
      'education' => Icons.school_rounded,
      _ => Icons.attach_money_rounded,
    };
  }

  Widget _buildInlineActions(Transaction txn, Color accentColor, int index) {
    final categories = ['food', 'transport', 'entertainment', 'bills', 'shopping', 'income', 'health', 'education', 'other'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      decoration: BoxDecoration(
        color: widget.cardColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
        border: Border.all(color: accentColor.withValues(alpha: 0.4), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text('Change Category',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: widget.textSecondary)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: categories.map((cat) {
              final isActive = cat == txn.category.toLowerCase();
              return GestureDetector(
                onTap: () async {
                  final db = ref.read(databaseProvider);
                  await db.updateTransactionCategory(txn.uuid, cat);
                  if (mounted) {
                    setState(() => _expandedTxnIndex = null);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isActive ? accentColor.withValues(alpha: 0.12) : widget.borderColor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: isActive ? Border.all(color: accentColor, width: 1) : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_categoryIcon(cat), size: 12, color: isActive ? accentColor : widget.textSecondary),
                      const SizedBox(width: 3),
                      Text(
                        cat[0].toUpperCase() + cat.substring(1),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isActive ? accentColor : widget.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Divider(color: widget.borderColor, height: 1),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () async {
                    final db = ref.read(databaseProvider);
                    await db.duplicateTransaction(txn);
                    if (mounted) setState(() => _expandedTxnIndex = null);
                  },
                  icon: Icon(Icons.copy_rounded, size: 16, color: widget.textSecondary),
                  label: Text('Duplicate', style: TextStyle(fontSize: 12, color: widget.textPrimary)),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () async {
                    final db = ref.read(databaseProvider);
                    await db.deleteTransaction(txn.uuid);
                    if (mounted) setState(() => _expandedTxnIndex = null);
                  },
                  icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                  label: const Text('Delete', style: TextStyle(fontSize: 12, color: Color(0xFFEF4444))),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Budget View ────────────────────────────────────

  Widget _buildBudgetView(Color accent) {
    if (_budgets.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.pie_chart_outline_rounded, size: 48,
              color: widget.textSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text('Loading budgets...',
              style: TextStyle(color: widget.textSecondary, fontSize: 14)),
        ]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _budgets.length,
      itemBuilder: (context, i) {
        final b = _budgets[i] as Map<String, dynamic>;
        final category = b['category'] as String;
        final limit = (b['limit'] as num?)?.toDouble() ?? 0.0;
        final spent = (b['spent'] as num?)?.toDouble() ?? 0.0;
        final ratio = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
        final isOver = spent > limit;
        final colorHex = b['color'] as String;
        final barColor = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: widget.cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: widget.borderColor, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_categoryIcon(category), size: 16,
                      color: barColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      category[0].toUpperCase() + category.substring(1),
                      style: TextStyle(
                          color: widget.textPrimary,
                          fontWeight: FontWeight.w500, fontSize: 14)),
                  ),
                  Text(
                    '\$${spent.toStringAsFixed(0)} / \$${limit.toStringAsFixed(0)}',
                    style: TextStyle(
                        color: isOver
                            ? const Color(0xFFEF4444)
                            : widget.textSecondary,
                        fontSize: 12,
                        fontWeight: isOver ? FontWeight.w600 : FontWeight.w400),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 6,
                  backgroundColor: widget.isDark
                      ? const Color(0xFF1E1E36)
                      : const Color(0xFFF0F0F8),
                  valueColor: AlwaysStoppedAnimation(
                      isOver ? const Color(0xFFEF4444) : barColor),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Add Transaction Dialog ────────────────────────────────────

  Future<void> _showAddTransactionDialog(Color accentColor) async {
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedType = 'expense';
    String selectedCategory = 'food';
    final categories = ['food', 'transport', 'entertainment', 'bills', 'shopping', 'income', 'health', 'education', 'other'];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: widget.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.add_card_rounded, size: 20, color: accentColor),
              const SizedBox(width: 8),
              Text('Add Transaction', style: TextStyle(color: widget.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          content: SizedBox(
            width: 350,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type selector
                  Text('Type', style: TextStyle(color: widget.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setDialogState(() => selectedType = 'expense'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selectedType == 'expense' ? const Color(0xFFEF4444).withValues(alpha: 0.12) : widget.borderColor.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: selectedType == 'expense' ? Border.all(color: const Color(0xFFEF4444), width: 1) : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.remove_circle_outline_rounded, size: 16, color: selectedType == 'expense' ? const Color(0xFFEF4444) : widget.textSecondary),
                                const SizedBox(width: 4),
                                Text('Expense', style: TextStyle(color: selectedType == 'expense' ? const Color(0xFFEF4444) : widget.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setDialogState(() => selectedType = 'income'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selectedType == 'income' ? const Color(0xFF10B981).withValues(alpha: 0.12) : widget.borderColor.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: selectedType == 'income' ? Border.all(color: const Color(0xFF10B981), width: 1) : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle_outline_rounded, size: 16, color: selectedType == 'income' ? const Color(0xFF10B981) : widget.textSecondary),
                                const SizedBox(width: 4),
                                Text('Income', style: TextStyle(color: selectedType == 'income' ? const Color(0xFF10B981) : widget.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Amount
                  Text('Amount', style: TextStyle(color: widget.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(color: widget.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: TextStyle(color: widget.textSecondary.withValues(alpha: 0.5)),
                      prefixText: '\$ ',
                      prefixStyle: TextStyle(color: widget.textSecondary, fontSize: 14),
                      filled: true,
                      fillColor: widget.borderColor.withValues(alpha: 0.3),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Category
                  Text('Category', style: TextStyle(color: widget.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: categories.map((cat) {
                      final isActive = cat == selectedCategory;
                      return GestureDetector(
                        onTap: () => setDialogState(() => selectedCategory = cat),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isActive ? accentColor.withValues(alpha: 0.12) : widget.borderColor.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: isActive ? Border.all(color: accentColor, width: 1) : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_categoryIcon(cat), size: 14, color: isActive ? accentColor : widget.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                cat[0].toUpperCase() + cat.substring(1),
                                style: TextStyle(fontSize: 12, color: isActive ? accentColor : widget.textSecondary, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Description
                  Text('Description (optional)', style: TextStyle(color: widget.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descCtrl,
                    style: TextStyle(color: widget.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'What was this for?',
                      hintStyle: TextStyle(color: widget.textSecondary.withValues(alpha: 0.5)),
                      filled: true,
                      fillColor: widget.borderColor.withValues(alpha: 0.3),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: TextStyle(color: widget.textSecondary)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: accentColor),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
      if (amount > 0) {
        final db = ref.read(databaseProvider);
        await db.logTransaction(
          uuid: DateTime.now().millisecondsSinceEpoch.toString(),
          amount: amount,
          category: selectedCategory,
          type: selectedType,
          description: descCtrl.text.trim(),
          source: 'manual',
        );
      }
    }
  }
}

// ─── Tab Button ───────────────────────────────────────

class _TabBtn extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color accent, secondary;
  final VoidCallback onTap;
  const _TabBtn({
    required this.label, required this.isActive,
    required this.accent, required this.secondary, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? accent : Colors.transparent,
                width: 2)),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isActive ? accent : secondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
        ),
      ),
    );
  }
}

// ─── Stat Card ───────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color, cardColor, borderColor, textSecondary;

  const _StatCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.cardColor,
    required this.borderColor,
    required this.textSecondary,
  });

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
