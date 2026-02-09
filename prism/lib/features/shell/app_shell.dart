import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// 5-tab shell layout with NavigationBar (mobile) and NavigationRail (desktop).
/// Handles back navigation: returns to Home tab first, then shows exit confirm.
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

  /// Handle system back button: navigate to Home first, then confirm exit.
  Future<bool> _onBackPressed() async {
    final location = GoRouterState.of(context).uri.path;

    // If not on Home, navigate to Home instead of exiting
    if (location != '/') {
      context.go('/');
      return false;
    }

    // On Home tab — show exit confirmation
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit Prism?'),
        content: const Text('Are you sure you want to close the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      SystemNavigator.pop();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final selected = _indexOfLocation(location);
    final wide = MediaQuery.sizeOf(context).width > 800;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBackPressed();
      },
      child: wide ? _desktop(context, selected) : _mobile(context, selected),
    );
  }

  Widget _mobile(BuildContext context, int selected) {
    return Scaffold(
      body: SafeArea(bottom: false, child: widget.child),
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
          Expanded(child: SafeArea(bottom: false, child: widget.child)),
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
