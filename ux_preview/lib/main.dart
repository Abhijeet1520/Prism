import 'package:flutter/material.dart';
import 'theme/gemmie_theme.dart';
import 'shell/app_shell.dart';

void main() {
  runApp(const GemmieUxPreview());
}

class GemmieUxPreview extends StatelessWidget {
  const GemmieUxPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gemmie UX Preview',
      debugShowCheckedModeBanner: false,
      theme: GemmieTheme.light(),
      darkTheme: GemmieTheme.dark(),
      themeMode: ThemeMode.system,
      home: const AppShell(),
    );
  }
}
