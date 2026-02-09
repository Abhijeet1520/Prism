/// Finance sub-screen — income/expense/balance summary + transaction list.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/database/database.dart';

class FinanceSubScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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
                          color: accentColor,
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
                        return GestureDetector(
                          onTap: () => _showTransactionActions(
                            context, ref, txn, cardColor, borderColor,
                            textPrimary, textSecondary, accentColor,
                          ),
                          child: Container(
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
                                          color: textSecondary, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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

  void _showTransactionActions(
    BuildContext context,
    WidgetRef ref,
    Transaction txn,
    Color cardColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color accentColor,
  ) {
    final isExp = txn.type == 'expense';
    final c = isExp ? const Color(0xFFEF4444) : const Color(0xFF10B981);
    final categories = ['food', 'transport', 'entertainment', 'bills', 'shopping', 'income', 'health', 'education', 'other'];

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction header
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: c.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_categoryIcon(txn.category), color: c, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        txn.description.isNotEmpty ? txn.description : txn.category,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        '${isExp ? '-' : '+'}\$${txn.amount.toStringAsFixed(2)} • ${DateFormat('MMM d, y').format(txn.createdAt)}',
                        style: TextStyle(fontSize: 13, color: textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Divider(color: borderColor, height: 1),
            const SizedBox(height: 12),

            // Change category
            Text('Change Category',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: categories.map((cat) {
                final isActive = cat == txn.category.toLowerCase();
                return GestureDetector(
                  onTap: () {
                    // TODO: Update category in DB
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Category changed to ${cat[0].toUpperCase()}${cat.substring(1)}')),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive ? accentColor.withValues(alpha: 0.12) : borderColor.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: isActive ? Border.all(color: accentColor, width: 1) : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_categoryIcon(cat), size: 14, color: isActive ? accentColor : textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          cat[0].toUpperCase() + cat.substring(1),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                            color: isActive ? accentColor : textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Divider(color: borderColor, height: 1),
            const SizedBox(height: 8),

            // Action buttons
            ListTile(
              leading: Icon(Icons.edit_rounded, color: accentColor, size: 20),
              title: Text('Edit Transaction', style: TextStyle(color: textPrimary, fontSize: 14)),
              dense: true,
              visualDensity: VisualDensity.compact,
              onTap: () {
                Navigator.pop(ctx);
                // TODO: Open edit dialog
              },
            ),
            ListTile(
              leading: Icon(Icons.copy_rounded, color: textSecondary, size: 20),
              title: Text('Duplicate', style: TextStyle(color: textPrimary, fontSize: 14)),
              dense: true,
              visualDensity: VisualDensity.compact,
              onTap: () {
                Navigator.pop(ctx);
                // TODO: Duplicate transaction
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
              title: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444), fontSize: 14)),
              dense: true,
              visualDensity: VisualDensity.compact,
              onTap: () {
                Navigator.pop(ctx);
                // TODO: Delete transaction from DB
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaction deleted')),
                );
              },
            ),
          ],
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
