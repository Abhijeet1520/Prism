/// Apps Hub — 5 app tiles (Tasks, Finance, Files, Tools, Gateway)
/// with sub-screen navigation. Matches ux_preview design.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tasks_sub_screen.dart';
import 'finance_sub_screen.dart';
import 'files_sub_screen.dart';
import 'tools_sub_screen.dart';
import 'gateway_sub_screen.dart';

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
              0 => TasksSubScreen(
                  isDark: isDark,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary),
              1 => FinanceSubScreen(
                  isDark: isDark,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary),
              2 => FilesSubScreen(
                  isDark: isDark,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary),
              3 => ToolsSubScreen(
                  isDark: isDark,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary),
              4 => GatewaySubScreen(
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

class _AppDef {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final String emoji;
  const _AppDef(this.icon, this.label, this.description, this.color, this.emoji);
}
