import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/prism_theme.dart';
import 'core/router/app_router.dart';
import 'features/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PrismApp()));
}

class PrismApp extends ConsumerStatefulWidget {
  const PrismApp({super.key});

  @override
  ConsumerState<PrismApp> createState() => _PrismAppState();
}

class _PrismAppState extends ConsumerState<PrismApp> {
  bool _splashDone = false;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(prismThemeProvider);

    if (!_splashDone) {
      return MaterialApp(
        title: 'Prism',
        debugShowCheckedModeBanner: false,
        theme: theme.darkTheme,
        themeMode: ThemeMode.dark,
        home: SplashScreen(onComplete: () => setState(() => _splashDone = true)),
      );
    }

    return MaterialApp.router(
      title: 'Prism',
      debugShowCheckedModeBanner: false,
      theme: theme.lightTheme,
      darkTheme: theme.darkTheme,
      themeMode: theme.mode,
      routerConfig: appRouter,
    );
  }
}
