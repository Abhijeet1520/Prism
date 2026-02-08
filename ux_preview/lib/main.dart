import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'screens/chat_screen.dart';
import 'screens/brain_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/finance_screen.dart';
import 'screens/files_screen.dart';
import 'screens/tools_screen.dart';
import 'screens/gateway_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const PrismApp());
}

class PrismApp extends StatelessWidget {
  const PrismApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadcnApp(
      title: 'Prism',
      theme: ThemeData(
        colorScheme: ColorSchemes.darkZinc,
        radius: 0.5,
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const _screens = <Widget>[
    ChatScreen(),
    BrainScreen(),
    TasksScreen(),
    FinanceScreen(),
    FilesScreen(),
    ToolsScreen(),
    GatewayScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return _buildDesktopLayout();
        } else {
          return _buildMobileLayout();
        }
      },
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      child: Row(
        children: [
          NavigationSidebar(
            index: _selectedIndex,
            onSelected: (i) => setState(() => _selectedIndex = i),
            children: [
              const NavigationLabel(
                child: Text('Prism', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              const NavigationGap(12),
              const NavigationLabel(child: Text('Main')),
              NavigationItem(
                label: const Text('Chat'),
                child: const Icon(RadixIcons.chatBubble),
              ),
              NavigationItem(
                label: const Text('Brain'),
                child: const Icon(RadixIcons.reader),
              ),
              NavigationItem(
                label: const Text('Tasks'),
                child: const Icon(RadixIcons.checkCircled),
              ),
              NavigationItem(
                label: const Text('Finance'),
                child: const Icon(RadixIcons.barChart),
              ),
              NavigationItem(
                label: const Text('Files'),
                child: const Icon(RadixIcons.file),
              ),
              const NavigationDivider(),
              const NavigationLabel(child: Text('System')),
              NavigationItem(
                label: const Text('Tools'),
                child: const Icon(RadixIcons.gear),
              ),
              NavigationItem(
                label: const Text('Gateway'),
                child: const Icon(RadixIcons.lightningBolt),
              ),
              NavigationItem(
                label: const Text('Settings'),
                child: const Icon(RadixIcons.mixerHorizontal),
              ),
            ],
          ),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Prism'),
          trailing: [
            Button.ghost(
              onPressed: () {},
              child: const Icon(RadixIcons.magnifyingGlass),
            ),
          ],
        ),
      ],
      child: Column(
        children: [
          Expanded(child: _screens[_selectedIndex]),
          NavigationBar(
            index: _selectedIndex < 5 ? _selectedIndex : 0,
            onSelected: (i) => setState(() => _selectedIndex = i),
            children: [
              NavigationItem(
                label: const Text('Chat'),
                child: const Icon(RadixIcons.chatBubble),
              ),
              NavigationItem(
                label: const Text('Brain'),
                child: const Icon(RadixIcons.reader),
              ),
              NavigationItem(
                label: const Text('Tasks'),
                child: const Icon(RadixIcons.checkCircled),
              ),
              NavigationItem(
                label: const Text('Finance'),
                child: const Icon(RadixIcons.barChart),
              ),
              NavigationItem(
                label: const Text('Files'),
                child: const Icon(RadixIcons.file),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
