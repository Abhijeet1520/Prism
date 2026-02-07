import 'package:flutter/material.dart';
import '../screens/chat/conversation_list_screen.dart';
import '../screens/tools/tools_screen.dart';
import '../screens/files/file_explorer_screen.dart';
import '../screens/settings/settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const _screens = <Widget>[
    ConversationListScreen(),
    ToolsScreen(),
    FileExplorerScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    return Scaffold(
      body: Row(
        children: [
          if (isWide)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) => setState(() => _selectedIndex = i),
              leading: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FloatingActionButton.small(
                  onPressed: () {},
                  child: const Icon(Icons.add),
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.chat_bubble_outline),
                  selectedIcon: Icon(Icons.chat_bubble),
                  label: Text('Chat'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.build_outlined),
                  selectedIcon: Icon(Icons.build),
                  label: Text('Tools'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.folder_outlined),
                  selectedIcon: Icon(Icons.folder),
                  label: Text('Files'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
            ),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) => setState(() => _selectedIndex = i),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.chat_bubble_outline),
                  selectedIcon: Icon(Icons.chat_bubble),
                  label: 'Chat',
                ),
                NavigationDestination(
                  icon: Icon(Icons.build_outlined),
                  selectedIcon: Icon(Icons.build),
                  label: 'Tools',
                ),
                NavigationDestination(
                  icon: Icon(Icons.folder_outlined),
                  selectedIcon: Icon(Icons.folder),
                  label: 'Files',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
    );
  }
}
