import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moon_design/moon_design.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  List<dynamic> _transactions = [];
  List<dynamic> _budgets = [];
  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  Future<void> _loadMockData() async {
    final txJson = await rootBundle.loadString('assets/mock_data/finance/transactions.json');
    final budJson = await rootBundle.loadString('assets/mock_data/finance/budgets.json');
    setState(() {
      _transactions = jsonDecode(txJson) as List;
      _budgets = jsonDecode(budJson) as List;
    });
  }

  double get _totalIncome => _transactions
      .where((t) => (t['amount'] as num) > 0)
      .fold(0.0, (sum, t) => sum + (t['amount'] as num).toDouble());

  double get _totalExpenses => _transactions
      .where((t) => (t['amount'] as num) < 0)
      .fold(0.0, (sum, t) => sum + (t['amount'] as num).toDouble().abs());

  @override
  Widget build(BuildContext context) {
    final colors = context.moonColors!;

    return Column(
      children: [
        // Summary cards
        Container(
          padding: const EdgeInsets.all(16),
          color: colors.goten,
          child: Row(
            children: [
              Expanded(child: _summaryCard(colors, 'Income', '\$${_totalIncome.toStringAsFixed(0)}', colors.roshi)),
              const SizedBox(width: 10),
              Expanded(child: _summaryCard(colors, 'Expenses', '\$${_totalExpenses.toStringAsFixed(0)}', colors.chichi)),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryCard(
                  colors,
                  'Balance',
                  '\$${(_totalIncome - _totalExpenses).toStringAsFixed(0)}',
                  colors.piccolo,
                ),
              ),
            ],
          ),
        ),
        // Tabs
        Container(
          color: colors.goten,
          child: MoonTabBar(
            tabBarSize: MoonTabBarSize.sm,
            tabs: const [
              MoonTab(label: Text('Transactions')),
              MoonTab(label: Text('Budget')),
            ],
            onTabChanged: (i) => setState(() => _activeTab = i),
          ),
        ),
        Divider(height: 1, color: colors.beerus),
        // Content
        Expanded(
          child: _activeTab == 0 ? _buildTransactions(colors) : _buildBudget(colors),
        ),
      ],
    );
  }

  Widget _summaryCard(MoonColors colors, String label, String value, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: colors.trunks, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: accentColor, fontWeight: FontWeight.w700, fontSize: 20)),
        ],
      ),
    );
  }

  Widget _buildTransactions(MoonColors colors) {
    if (_transactions.isEmpty) {
      return Center(child: MoonCircularLoader(color: colors.piccolo));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      itemBuilder: (context, i) {
        final tx = _transactions[i] as Map<String, dynamic>;
        final amount = (tx['amount'] as num).toDouble();
        final isIncome = amount > 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          child: MoonMenuItem(
            backgroundColor: colors.goten,
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (isIncome ? colors.roshi : colors.chichi).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                size: 16,
                color: isIncome ? colors.roshi : colors.chichi,
              ),
            ),
            label: Text(
              tx['title'] as String,
              style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w500, fontSize: 14),
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${isIncome ? '+' : '-'}\$${amount.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isIncome ? colors.roshi : colors.chichi,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  (tx['date'] as String).substring(0, 10),
                  style: TextStyle(color: colors.trunks, fontSize: 10),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBudget(MoonColors colors) {
    if (_budgets.isEmpty) {
      return Center(child: MoonCircularLoader(color: colors.piccolo));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _budgets.length,
      itemBuilder: (context, i) {
        final budget = _budgets[i] as Map<String, dynamic>;
        final spent = (budget['spent'] as num).toDouble();
        final limit = (budget['monthlyLimit'] as num).toDouble();
        final ratio = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
        final colorHex = int.tryParse((budget['color'] as String).replaceFirst('#', ''), radix: 16);
        final barColor = colorHex != null ? Color(0xFF000000 | colorHex) : colors.piccolo;
        final isOver = spent > limit;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.goten,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.beerus, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    budget['category'] as String,
                    style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  const Spacer(),
                  Text(
                    '\$${spent.toStringAsFixed(0)} / \$${limit.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: isOver ? colors.chichi : colors.trunks,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              MoonLinearProgress(
                value: ratio,
                color: isOver ? colors.chichi : barColor,
                backgroundColor: colors.beerus,
              ),
            ],
          ),
        );
      },
    );
  }
}
