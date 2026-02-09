import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 5-tab shell layout with NavigationBar (mobile) and NavigationRail (desktop).
class AppShell extends StatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _tabs = [
    _Tab('Home', Icons.home_outlined, Icons.home_rounded, '/'),
    _Tab('Chat', Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, '/chat'),
    _Tab('Brain', Icons.auto_awesome_outlined, Icons.auto_awesome, '/brain'),
    _Tab('Apps', Icons.apps_outlined, Icons.apps_rounded, '/apps'),
    _Tab('Settings', Icons.settings_outlined, Icons.settings_rounded, '/settings'),
  ];

  int _indexOfLocation(String location) {
    for (int i = 0; i < _tabs.length; i++) {
      if (location == _tabs[i].path) return i;
    }
    return 0;
  }

  void _onTap(int index) => context.go(_tabs[index].path);

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final selected = _indexOfLocation(location);
    final wide = MediaQuery.sizeOf(context).width > 800;

    if (wide) return _desktop(context, selected);
    return _mobile(context, selected);
  }

  Widget _mobile(BuildContext context, int selected) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: _onTap,
        height: 68,
        destinations: _tabs
            .map((t) => NavigationDestination(
                  icon: Icon(t.icon),
                  selectedIcon: Icon(t.activeIcon),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }

  Widget _desktop(BuildContext context, int selected) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selected,
            onDestinationSelected: _onTap,
            extended: false,
            backgroundColor: colors.surface,
            leading: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              ),
            ),
            destinations: _tabs
                .map((t) => NavigationRailDestination(
                      icon: Icon(t.icon),
                      selectedIcon: Icon(t.activeIcon),
                      label: Text(t.label),
                    ))
                .toList(),
          ),
          VerticalDivider(width: 1, thickness: 1, color: colors.outline),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}

class _Tab {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String path;
  const _Tab(this.label, this.icon, this.activeIcon, this.path);
}
