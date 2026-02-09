import 'package:go_router/go_router.dart';

import '../../features/shell/app_shell.dart';
import '../../features/chat/chat_detail_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/chat/chat_list_screen.dart';
import '../../features/brain/brain_screen.dart';
import '../../features/apps/apps_hub_screen.dart';
import '../../features/settings/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
        GoRoute(path: '/chat', builder: (_, _) => const ChatListScreen()),
        GoRoute(path: '/brain', builder: (_, _) => const BrainScreen()),
        GoRoute(path: '/apps', builder: (_, _) => const AppsHubScreen()),
        GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
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
