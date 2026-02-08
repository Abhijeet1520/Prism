import 'package:shadcn_flutter/shadcn_flutter.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  int _tab = 0;

  static const _transactions = [
    _Transaction(title: 'Grocery Store', amount: -2450.00, category: 'Groceries', date: 'Today', method: 'UPI'),
    _Transaction(title: 'Salary Credit', amount: 65000.00, category: 'Income', date: 'Jan 1', method: 'Bank'),
    _Transaction(title: 'Netflix Subscription', amount: -649.00, category: 'Entertainment', date: 'Jan 2', method: 'Card'),
    _Transaction(title: 'Electricity Bill', amount: -1800.00, category: 'Utilities', date: 'Jan 3', method: 'UPI'),
    _Transaction(title: 'Coffee Shop', amount: -350.00, category: 'Food', date: 'Jan 4', method: 'UPI'),
    _Transaction(title: 'Freelance Payment', amount: 12000.00, category: 'Income', date: 'Jan 5', method: 'Bank'),
    _Transaction(title: 'Uber Ride', amount: -280.00, category: 'Transport', date: 'Jan 6', method: 'UPI'),
    _Transaction(title: 'Amazon Order', amount: -3200.00, category: 'Shopping', date: 'Jan 6', method: 'Card'),
  ];

  static const _budgets = [
    _Budget(category: 'Groceries', spent: 2450, limit: 8000),
    _Budget(category: 'Entertainment', spent: 649, limit: 2000),
    _Budget(category: 'Utilities', spent: 1800, limit: 5000),
    _Budget(category: 'Food', spent: 350, limit: 3000),
    _Budget(category: 'Transport', spent: 280, limit: 2000),
    _Budget(category: 'Shopping', spent: 3200, limit: 5000),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Financial Tracker'),
          trailing: [
            Button.primary(
              leading: const Icon(RadixIcons.plus),
              onPressed: () {},
              child: const Text('Add Entry'),
            ),
          ],
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Summary cards
            SizedBox(
              height: 100,
              child: Row(
                children: [
                  _summaryCard(theme, 'Income', '₹77,000', RadixIcons.arrowUp, Colors.green),
                  const SizedBox(width: 12),
                  _summaryCard(theme, 'Expenses', '₹8,729', RadixIcons.arrowDown, Colors.red),
                  const SizedBox(width: 12),
                  _summaryCard(theme, 'Balance', '₹68,271', RadixIcons.barChart, Colors.blue),
                  const SizedBox(width: 12),
                  _summaryCard(theme, 'Savings Rate', '88.7%', RadixIcons.rocket, Colors.purple),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Tabs
            Row(
              children: [
                TabList(
                  index: _tab,
                  onChanged: (i) => setState(() => _tab = i),
                  children: const [
                    TabItem(child: Text('Transactions')),
                    TabItem(child: Text('Budget')),
                    TabItem(child: Text('Insights')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _tab == 0
                  ? _buildTransactions()
                  : _tab == 1
                      ? _buildBudget()
                      : _buildInsights(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(ThemeData theme, String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 6),
                Text(label, style: TextStyle(fontSize: 12, color: theme.colorScheme.mutedForeground)),
              ],
            ),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactions() {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (final tx in _transactions)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: tx.amount > 0 ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        tx.amount > 0 ? RadixIcons.arrowUp : RadixIcons.arrowDown,
                        color: tx.amount > 0 ? Colors.green : Colors.red,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tx.title, style: const TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              OutlineBadge(child: Text(tx.category)),
                              const SizedBox(width: 8),
                              Text(tx.method, style: const TextStyle(fontSize: 12, color: Colors.gray)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${tx.amount > 0 ? '+' : ''}₹${tx.amount.abs().toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: tx.amount > 0 ? Colors.green : Colors.red,
                          ),
                        ),
                        Text(tx.date, style: const TextStyle(fontSize: 12, color: Colors.gray)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBudget() {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (final b in _budgets)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(b.category, style: const TextStyle(fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Text(
                          '₹${b.spent.toStringAsFixed(0)} / ₹${b.limit.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 13, color: Colors.gray),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Progress(
                      progress: (b.spent / b.limit).clamp(0.0, 1.0),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${((b.spent / b.limit) * 100).toStringAsFixed(0)}% used',
                      style: TextStyle(
                        fontSize: 12,
                        color: b.spent / b.limit > 0.8 ? Colors.red : Colors.gray,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInsights() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(RadixIcons.barChart, size: 48),
          const SizedBox(height: 16),
          const Text('AI-Powered Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text(
            'Spending patterns, anomaly detection, and savings recommendations',
            style: TextStyle(color: Colors.gray),
          ),
          const SizedBox(height: 24),
          Card(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(RadixIcons.lightningBolt, size: 16),
                    SizedBox(width: 8),
                    Text('Quick Insight', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your grocery spending this month is 12% lower than your 3-month average. '
                  'Entertainment spending is on track. Consider setting aside the savings difference.',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Transaction {
  final String title;
  final double amount;
  final String category;
  final String date;
  final String method;

  const _Transaction({
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.method,
  });
}

class _Budget {
  final String category;
  final double spent;
  final double limit;

  const _Budget({required this.category, required this.spent, required this.limit});
}
