import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';

import 'theme/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/brain_screen.dart';
import 'screens/apps_hub_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const PrismApp());
}

class PrismApp extends StatefulWidget {
  const PrismApp({super.key});

  @override
  State<PrismApp> createState() => _PrismAppState();
}

class _PrismAppState extends State<PrismApp> {
  final _themeProvider = ThemeProvider();
  bool _splashDone = false;

  @override
  void initState() {
    super.initState();
    _themeProvider.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final tp = _themeProvider;
    final accent = tp.accent;

    final bgDeep = tp.bgDeep;
    final bgBase = tp.bgBase;
    final surface = tp.surface;
    final border = tp.border;
    const textPrimary = ThemeProvider.textPrimary;
    const textSecond = ThemeProvider.textSecondary;

    final lightTokens = MoonTokens.light.copyWith(
      colors: MoonColors.light.copyWith(piccolo: accent),
    );

    final darkTokens = MoonTokens.dark.copyWith(
      colors: MoonColors.dark.copyWith(
        piccolo: accent,
        hit: const Color(0xFF34D399),
        goku: bgDeep,
        gohan: bgBase,
        goten: surface,
        beerus: border,
        bulma: textPrimary,
        trunks: textSecond,
        popo: textPrimary,
        jiren: accent.withValues(alpha: 0.12),
        heles: const Color(0x0AFFFFFF),
        textPrimary: textPrimary,
        textSecondary: textSecond,
        iconPrimary: textPrimary,
        iconSecondary: textSecond,
      ),
    );

    final darkScheme = ColorScheme.dark(
      primary: accent,
      onPrimary: Colors.white,
      surface: surface,
      onSurface: textPrimary,
      onSurfaceVariant: textSecond,
      outline: border,
      outlineVariant: border,
    );

    return MaterialApp(
      title: 'Prism',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        extensions: <ThemeExtension>[MoonTheme(tokens: lightTokens)],
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgBase,
        colorScheme: darkScheme,
        cardColor: surface,
        dividerColor: border,
        appBarTheme: AppBarTheme(
          backgroundColor: surface,
          foregroundColor: textPrimary,
          surfaceTintColor: Colors.transparent,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: surface,
          surfaceTintColor: Colors.transparent,
          indicatorColor: accent.withValues(alpha: 0.12),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w600);
            }
            return const TextStyle(color: textSecond, fontSize: 12);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(color: accent);
            }
            return const IconThemeData(color: textSecond);
          }),
        ),
        extensions: <ThemeExtension>[MoonTheme(tokens: darkTokens)],
      ),
      themeMode: tp.mode,
      home: _splashDone
          ? AppShell(themeProvider: _themeProvider)
          : SplashScreen(onComplete: () => setState(() => _splashDone = true)),
    );
  }
}

/// 5-tab shell: Home, Chat, Brain, Apps, Settings
class AppShell extends StatefulWidget {
  final ThemeProvider themeProvider;
  const AppShell({super.key, required this.themeProvider});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const _labels = ['Home', 'Chat', 'Brain', 'Apps', 'Settings'];
  static const _icons = [
    Icons.home_outlined, Icons.chat_bubble_outline_rounded,
    Icons.auto_awesome_outlined, Icons.apps_rounded, Icons.settings_outlined,
  ];
  static const _selectedIcons = [
    Icons.home_rounded, Icons.chat_bubble_rounded,
    Icons.auto_awesome, Icons.apps_rounded, Icons.settings_rounded,
  ];

  void _navigateToTab(int index) => setState(() => _selectedIndex = index);
  void _navigateToApp(String appId) => setState(() => _selectedIndex = 3);

  List<Widget> get _screens => [
    HomeScreen(onNavigateTab: _navigateToTab, onNavigateApp: _navigateToApp),
    const ChatScreen(),
    const BrainScreen(),
    const AppsHubScreen(),
    SettingsScreen(themeProvider: widget.themeProvider),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      return c.maxWidth > 800 ? _desktop(context) : _mobile(context);
    });
  }

  Widget _desktop(BuildContext context) {
    final colors = context.moonColors!;
    return Scaffold(
      backgroundColor: colors.gohan,
      body: Row(children: [
        Container(
          width: 220,
          decoration: BoxDecoration(
            color: colors.goten,
            border: Border(right: BorderSide(color: colors.beerus, width: 1)),
          ),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: colors.piccolo, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Text('Prism', style: TextStyle(color: colors.bulma, fontSize: 20, fontWeight: FontWeight.w700)),
              ]),
            ),
            Divider(color: colors.beerus, height: 1),
            const SizedBox(height: 8),
            _tile(colors, 0, 'Home'),
            _tile(colors, 1, 'Chat'),
            _tile(colors, 2, 'Brain'),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text('APPS', style: TextStyle(color: colors.trunks, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1)),
            ),
            _tile(colors, 3, 'Apps Hub'),
            const Spacer(),
            Divider(color: colors.beerus, height: 1),
            _tile(colors, 4, 'Settings'),
            const SizedBox(height: 12),
          ]),
        ),
        Expanded(child: _screens[_selectedIndex]),
      ]),
    );
  }

  Widget _tile(MoonColors colors, int i, String label) {
    final sel = _selectedIndex == i;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: MoonMenuItem(
        onTap: () => setState(() => _selectedIndex = i),
        backgroundColor: sel ? colors.piccolo.withValues(alpha: 0.12) : Colors.transparent,
        label: Text(label, style: TextStyle(color: sel ? colors.piccolo : colors.bulma, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, fontSize: 14)),
        leading: Icon(sel ? _selectedIcons[i] : _icons[i], color: sel ? colors.piccolo : colors.trunks, size: 20),
      ),
    );
  }

  Widget _mobile(BuildContext context) {
    final colors = context.moonColors!;
    return Scaffold(
      backgroundColor: colors.gohan,
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: List.generate(5, (i) => NavigationDestination(
          icon: Icon(_icons[i]),
          selectedIcon: Icon(_selectedIcons[i]),
          label: _labels[i],
        )),
      ),
    );
  }
}
