import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';

import 'tasks_screen.dart';
import 'finance_screen.dart';
import 'files_screen.dart';
import 'tools_screen.dart';
import 'gateway_screen.dart';

class AppsHubScreen extends StatefulWidget {
  const AppsHubScreen({super.key});

  @override
  State<AppsHubScreen> createState() => _AppsHubScreenState();
}

class _AppsHubScreenState extends State<AppsHubScreen> {
  int? _selectedApp;

  static const _apps = [
    _AppInfo(icon: Icons.check_circle_outline_rounded, label: 'Tasks', description: 'Manage tasks, projects & deadlines', color: Color(0xFF10B981)),
    _AppInfo(icon: Icons.account_balance_wallet_outlined, label: 'Finance', description: 'Track spending, budgets & goals', color: Color(0xFFF59E0B)),
    _AppInfo(icon: Icons.folder_outlined, label: 'Files', description: 'Browse & manage local files', color: Color(0xFF3B82F6)),
    _AppInfo(icon: Icons.extension_outlined, label: 'Tools', description: 'MCP tools & server management', color: Color(0xFF8B5CF6)),
    _AppInfo(icon: Icons.bolt_outlined, label: 'Gateway', description: 'AI Gateway & API management', color: Color(0xFFEF4444)),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.moonColors!;

    if (_selectedApp != null) {
      return _buildSubScreen(colors);
    }
    return _buildHub(colors);
  }

  Widget _buildHub(MoonColors colors) {
    return Column(
      children: [
        // Header
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
        // Grid
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
            itemBuilder: (context, i) => _buildAppTile(colors, _apps[i], i),
          ),
        ),
      ],
    );
  }

  Widget _buildAppTile(MoonColors colors, _AppInfo app, int index) {
    return MoonBaseControl(
      onTap: () => setState(() => _selectedApp = index),
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
            Text(
              app.label,
              style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              app.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.trunks, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubScreen(MoonColors colors) {
    return Column(
      children: [
        // Back bar
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
        // Sub-screen
        Expanded(
          child: switch (_selectedApp!) {
            0 => const TasksScreen(),
            1 => const FinanceScreen(),
            2 => const FilesScreen(),
            3 => const ToolsScreen(),
            4 => const GatewayScreen(),
            _ => const SizedBox.shrink(),
          },
        ),
      ],
    );
  }
}

class _AppInfo {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  const _AppInfo({required this.icon, required this.label, required this.description, required this.color});
}
