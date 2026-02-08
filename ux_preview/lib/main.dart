import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';

import 'screens/chat_screen.dart';
import 'screens/brain_screen.dart';
import 'screens/apps_hub_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const PrismApp());
}

class PrismApp extends StatelessWidget {
  const PrismApp({super.key});

  // ── Prism Dark Palette ──────────────────────────────────────────────
  static const _bgDeep      = Color(0xFF060610); // goku  – deepest layer
  static const _bgBase      = Color(0xFF0C0C16); // scaffold & gohan
  static const _surface     = Color(0xFF16162A); // goten – cards / panels
  static const _border      = Color(0xFF252540); // beerus
  static const _textPrimary = Color(0xFFE2E2EC); // bulma
  static const _textSecond  = Color(0xFF7A7A90); // trunks
  static const _accent      = Color(0xFF818CF8); // piccolo  (indigo-400)
  static const _accentHover = Color(0x1F818CF8); // jiren

  @override
  Widget build(BuildContext context) {
    // ── Light tokens ────────────────────────────────────────────────
    final lightTokens = MoonTokens.light.copyWith(
      colors: MoonColors.light.copyWith(
        piccolo: const Color(0xFF6366F1),
      ),
    );

    // ── Dark tokens ─────────────────────────────────────────────────
    final darkTokens = MoonTokens.dark.copyWith(
      colors: MoonColors.dark.copyWith(
        piccolo: _accent,
        hit: const Color(0xFF34D399),      // emerald-400
        goku: _bgDeep,
        gohan: _bgBase,
        goten: _surface,
        beerus: _border,
        bulma: _textPrimary,
        trunks: _textSecond,
        popo: _textPrimary,
        jiren: _accentHover,
        heles: const Color(0x0AFFFFFF),
        textPrimary: _textPrimary,
        textSecondary: _textSecond,
        iconPrimary: _textPrimary,
        iconSecondary: _textSecond,
      ),
    );

    // ── Material color scheme aligned with the Moon tokens ──────────
    final darkScheme = ColorScheme.dark(
      primary: _accent,
      onPrimary: Colors.white,
      surface: _surface,
      onSurface: _textPrimary,
      onSurfaceVariant: _textSecond,
      outline: _border,
      outlineVariant: _border,
    );

    return MaterialApp(
      title: 'Prism',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        extensions: <ThemeExtension<dynamic>>[MoonTheme(tokens: lightTokens)],
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _bgBase,
        colorScheme: darkScheme,
        cardColor: _surface,
        dividerColor: _border,
        appBarTheme: const AppBarTheme(
          backgroundColor: _surface,
          foregroundColor: _textPrimary,
          surfaceTintColor: Colors.transparent,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _surface,
          surfaceTintColor: Colors.transparent,
          indicatorColor: _accent.withValues(alpha: 0.12),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(color: _accent, fontSize: 12, fontWeight: FontWeight.w600);
            }
            return TextStyle(color: _textSecond, fontSize: 12);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(color: _accent);
            }
            return IconThemeData(color: _textSecond);
          }),
        ),
        extensions: <ThemeExtension<dynamic>>[MoonTheme(tokens: darkTokens)],
      ),
      themeMode: ThemeMode.dark,
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
    AppsHubScreen(),
    SettingsScreen(),
  ];

  static const _labels = ['Chat', 'Brain', 'Apps', 'Settings'];

  static const _icons = [
    Icons.chat_bubble_outline_rounded,
    Icons.auto_awesome_outlined,
    Icons.apps_rounded,
    Icons.settings_outlined,
  ];

  static const _selectedIcons = [
    Icons.chat_bubble_rounded,
    Icons.auto_awesome,
    Icons.apps_rounded,
    Icons.settings_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return _buildDesktopLayout(context);
        }
        return _buildMobileLayout(context);
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final colors = context.moonColors!;

    return Scaffold(
      backgroundColor: colors.gohan,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 220,
            decoration: BoxDecoration(
              color: colors.goten,
              border: Border(
                right: BorderSide(color: colors.beerus, width: 1),
              ),
            ),
            child: Column(
              children: [
                // Logo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: colors.piccolo,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Prism',
                        style: TextStyle(
                          color: colors.bulma,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: colors.beerus, height: 1),
                const SizedBox(height: 8),
                // Nav items
                ..._buildSidebarItems(colors),
                const Spacer(),
                Divider(color: colors.beerus, height: 1),
                _buildSidebarTile(colors, 3, Icons.settings_outlined, Icons.settings_rounded, 'Settings'),
                const SizedBox(height: 12),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSidebarItems(MoonColors colors) {
    return [
      _buildSidebarTile(colors, 0, Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Chat'),
      _buildSidebarTile(colors, 1, Icons.auto_awesome_outlined, Icons.auto_awesome, 'Brain'),
      const SizedBox(height: 4),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Text('APPS', style: TextStyle(color: colors.trunks, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1)),
      ),
      _buildSidebarTile(colors, 2, Icons.apps_rounded, Icons.apps_rounded, 'Apps Hub'),
    ];
  }

  Widget _buildSidebarTile(MoonColors colors, int index, IconData icon, IconData selectedIcon, String label) {
    final selected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: MoonMenuItem(
        onTap: () => setState(() => _selectedIndex = index),
        backgroundColor: selected ? colors.piccolo.withValues(alpha: 0.12) : Colors.transparent,
        label: Text(
          label,
          style: TextStyle(
            color: selected ? colors.piccolo : colors.bulma,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 14,
          ),
        ),
        leading: Icon(
          selected ? selectedIcon : icon,
          color: selected ? colors.piccolo : colors.trunks,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final colors = context.moonColors!;

    return Scaffold(
      backgroundColor: colors.gohan,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: colors.piccolo,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Text('Prism', style: TextStyle(color: colors.bulma, fontWeight: FontWeight.w700, fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded, color: colors.trunks),
            onPressed: () {},
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: List.generate(4, (i) {
          return NavigationDestination(
            icon: Icon(_icons[i]),
            selectedIcon: Icon(_selectedIcons[i]),
            label: _labels[i],
          );
        }),
      ),
    );
  }
}
