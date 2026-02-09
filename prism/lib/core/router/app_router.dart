import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/shell/app_shell.dart';
import '../../features/chat/chat_detail_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, _) => const _HomeTab()),
        GoRoute(path: '/chat', builder: (_, _) => const _ChatTab()),
        GoRoute(path: '/brain', builder: (_, _) => const _BrainTab()),
        GoRoute(path: '/apps', builder: (_, _) => const _AppsTab()),
        GoRoute(path: '/settings', builder: (_, _) => const _SettingsTab()),
      ],
    ),
    GoRoute(
      path: '/chat/:id',
      builder: (_, state) => ChatDetailScreen(
        conversationId: state.pathParameters['id']!,
      ),
    ),
  ],
);

// Thin wrappers that import feature screens.
// Keeps route config clean and allows lazy imports.

class _HomeTab extends StatelessWidget {
  const _HomeTab();
  @override
  Widget build(BuildContext context) {
    // Lazy import within the feature module
    return const _PlaceholderScreen(title: 'Home', icon: Icons.home_rounded);
  }
}

class _ChatTab extends StatelessWidget {
  const _ChatTab();
  @override
  Widget build(BuildContext context) {
    return const _PlaceholderScreen(title: 'Chat', icon: Icons.chat_bubble_rounded);
  }
}

class _BrainTab extends StatelessWidget {
  const _BrainTab();
  @override
  Widget build(BuildContext context) {
    return const _PlaceholderScreen(title: 'Brain', icon: Icons.auto_awesome);
  }
}

class _AppsTab extends StatelessWidget {
  const _AppsTab();
  @override
  Widget build(BuildContext context) {
    return const _PlaceholderScreen(title: 'Apps', icon: Icons.apps_rounded);
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();
  @override
  Widget build(BuildContext context) {
    return const _PlaceholderScreen(title: 'Settings', icon: Icons.settings_rounded);
  }
}

/// Minimal placeholder until each feature module is complete.
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  const _PlaceholderScreen({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: colors.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text(title,
                style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Coming soon',
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
