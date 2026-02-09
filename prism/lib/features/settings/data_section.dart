/// Data & Storage settings section — storage info, demo data, import/export.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database.dart';
import '../../core/data/demo_data_service.dart';
import 'settings_shared_widgets.dart';

class DataSection extends ConsumerStatefulWidget {
  final Color cardColor, borderColor, textPrimary, textSecondary, accentColor;
  const DataSection(
      {super.key,
      required this.cardColor,
      required this.borderColor,
      required this.textPrimary,
      required this.textSecondary,
      required this.accentColor});

  @override
  ConsumerState<DataSection> createState() => DataSectionState();
}

class DataSectionState extends ConsumerState<DataSection> {
  bool _hasDemoData = false;
  bool _isLoading = false;
  Map<String, int>? _demoCounts;

  @override
  void initState() {
    super.initState();
    _checkDemoData();
  }

  Future<void> _checkDemoData() async {
    final db = ref.read(databaseProvider);
    final has = await DemoDataService.hasDemoData(db);
    Map<String, int>? counts;
    if (has) {
      counts = await DemoDataService.getDemoDataCounts(db);
    }
    if (mounted) {
      setState(() {
        _hasDemoData = has;
        _demoCounts = counts;
      });
    }
  }

  Future<void> _loadDemoData() async {
    setState(() => _isLoading = true);
    try {
      final db = ref.read(databaseProvider);
      final counts = await DemoDataService.loadDemoData(db);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Loaded demo data: ${counts['tasks']} tasks, ${counts['notes']} notes, '
            '${counts['transactions']} transactions, ${counts['conversations']} conversations',
          ),
          duration: const Duration(seconds: 3),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to load demo data: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ));
      }
    }
    await _checkDemoData();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _removeDemoData() async {
    setState(() => _isLoading = true);
    try {
      final db = ref.read(databaseProvider);
      final counts = await DemoDataService.removeDemoData(db);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Removed demo data: ${counts['tasks']} tasks, ${counts['notes']} notes, '
            '${counts['transactions']} transactions, ${counts['conversations']} conversations',
          ),
          duration: const Duration(seconds: 3),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to remove demo data: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ));
      }
    }
    await _checkDemoData();
    if (mounted) setState(() => _isLoading = false);
  }

  void _confirmLoadDemoData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.science_outlined, size: 20, color: widget.accentColor),
            const SizedBox(width: 10),
            Text('Load Demo Data',
                style: TextStyle(
                    color: widget.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This will add sample data to explore the app:',
                style: TextStyle(color: widget.textSecondary, fontSize: 13)),
            const SizedBox(height: 12),
            _DemoCountItem(
                icon: Icons.check_circle_outline,
                label: '7 sample tasks',
                color: widget.textSecondary),
            _DemoCountItem(
                icon: Icons.auto_awesome_outlined,
                label: '5 sample notes',
                color: widget.textSecondary),
            _DemoCountItem(
                icon: Icons.account_balance_wallet_outlined,
                label: '10 sample transactions',
                color: widget.textSecondary),
            _DemoCountItem(
                icon: Icons.chat_bubble_outline,
                label: '2 sample conversations',
                color: widget.textSecondary),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 14, color: Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Demo data is tagged separately and can be removed without affecting your real data.',
                      style: TextStyle(
                          color: const Color(0xFF10B981), fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: TextStyle(color: widget.textSecondary, fontSize: 13)),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: widget.accentColor),
            onPressed: () {
              Navigator.of(ctx).pop();
              _loadDemoData();
            },
            icon: const Icon(Icons.add_rounded, size: 16),
            label:
                const Text('Load Demo Data', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveDemoData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.delete_sweep_outlined,
                size: 20, color: Color(0xFFEF4444)),
            const SizedBox(width: 10),
            Text('Remove Demo Data',
                style: TextStyle(
                    color: widget.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This will remove all demo data:',
                style: TextStyle(color: widget.textSecondary, fontSize: 13)),
            if (_demoCounts != null) ...[
              const SizedBox(height: 12),
              if ((_demoCounts!['tasks'] ?? 0) > 0)
                _DemoCountItem(
                    icon: Icons.check_circle_outline,
                    label: '${_demoCounts!['tasks']} demo tasks',
                    color: widget.textSecondary),
              if ((_demoCounts!['notes'] ?? 0) > 0)
                _DemoCountItem(
                    icon: Icons.auto_awesome_outlined,
                    label: '${_demoCounts!['notes']} demo notes',
                    color: widget.textSecondary),
              if ((_demoCounts!['transactions'] ?? 0) > 0)
                _DemoCountItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label:
                        '${_demoCounts!['transactions']} demo transactions',
                    color: widget.textSecondary),
              if ((_demoCounts!['conversations'] ?? 0) > 0)
                _DemoCountItem(
                    icon: Icons.chat_bubble_outline,
                    label:
                        '${_demoCounts!['conversations']} demo conversations',
                    color: widget.textSecondary),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined,
                      size: 14, color: Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Only demo data will be removed. Your real data is safe.',
                      style: TextStyle(
                          color: const Color(0xFF10B981), fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: TextStyle(color: widget.textSecondary, fontSize: 13)),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444)),
            onPressed: () {
              Navigator.of(ctx).pop();
              _removeDemoData();
            },
            icon: const Icon(Icons.delete_sweep_outlined, size: 16),
            label: const Text('Remove All Demo Data',
                style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stores = [
      ('Conversations', 'SQLite', Icons.chat_bubble_outline),
      ('Notes', 'SQLite + FTS5', Icons.auto_awesome_outlined),
      ('Tasks', 'SQLite', Icons.check_circle_outline),
      ('Transactions', 'SQLite', Icons.account_balance_wallet_outlined),
      ('Models', 'Local GGUF files', Icons.model_training_outlined),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
            title: 'Data & Storage',
            subtitle: 'Manage local data and cache',
            textPrimary: widget.textPrimary,
            textSecondary: widget.textSecondary),

        GroupLabel(text: 'STORAGE', color: widget.textSecondary),
        const SizedBox(height: 8),
        ...stores.map((s) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.cardColor,
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: widget.borderColor, width: 0.5),
              ),
              child: Row(
                children: [
                  Icon(s.$3, size: 18, color: widget.textSecondary),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(s.$1,
                          style: TextStyle(
                              color: widget.textPrimary, fontSize: 13))),
                  Text(s.$2,
                      style: TextStyle(
                          color: widget.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            )),

        SettingsDivider(color: widget.borderColor),

        // ── DEMO DATA ──
        GroupLabel(text: 'DEMO DATA', color: widget.textSecondary),
        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
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
                  Icon(Icons.science_outlined,
                      size: 16, color: widget.accentColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _hasDemoData
                          ? 'Demo data is loaded'
                          : 'Load sample data to explore the app',
                      style: TextStyle(
                          color: widget.textPrimary,
                          fontWeight: FontWeight.w500,
                          fontSize: 13),
                    ),
                  ),
                  if (_hasDemoData)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color:
                            widget.accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('active',
                          style: TextStyle(
                              fontSize: 10, color: widget.accentColor)),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _hasDemoData
                    ? 'Demo tasks, notes, transactions, and conversations are loaded. '
                        'Remove them anytime — your real data is untouched.'
                    : 'Adds sample tasks, notes, transactions, and conversations. '
                        'Tagged separately so they can be cleanly removed later.',
                style: TextStyle(color: widget.textSecondary, fontSize: 11),
              ),
              const SizedBox(height: 10),
              if (_isLoading)
                Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: widget.accentColor,
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    if (!_hasDemoData)
                      SmallButton(
                        label: 'Load Demo Data',
                        color: widget.accentColor,
                        onTap: _confirmLoadDemoData,
                      ),
                    if (_hasDemoData) ...[
                      SmallButton(
                        label: 'Remove Demo Data',
                        color: const Color(0xFFEF4444),
                        onTap: _confirmRemoveDemoData,
                      ),
                      const SizedBox(width: 8),
                      SmallButton(
                        label: 'Reload',
                        color: widget.textSecondary,
                        onTap: () async {
                          await _removeDemoData();
                          await _loadDemoData();
                        },
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),

        SettingsDivider(color: widget.borderColor),

        GroupLabel(text: 'ACTIONS', color: widget.textSecondary),
        const SizedBox(height: 8),
        Row(
          children: [
            SmallButton(
                label: 'Export All',
                color: widget.accentColor,
                onTap: () {}),
            const SizedBox(width: 8),
            SmallButton(
                label: 'Import',
                color: widget.textSecondary,
                onTap: () {}),
          ],
        ),
        const SizedBox(height: 12),
        SmallButton(
          label: 'Clear All Data',
          color: const Color(0xFFEF4444),
          onTap: () {},
        ),
      ],
    );
  }
}

class _DemoCountItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _DemoCountItem(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}
