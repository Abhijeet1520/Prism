/// Finance sub-screen — income/expense/balance summary + transaction list.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
