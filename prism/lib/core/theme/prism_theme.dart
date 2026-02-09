import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moon_design/moon_design.dart';

/// Available accent color presets.
enum AccentPreset {
  indigo('Indigo', Color(0xFF818CF8)),
  emerald('Emerald', Color(0xFF34D399)),
  rose('Rose', Color(0xFFF43F5E)),
  amber('Amber', Color(0xFFF59E0B)),
  cyan('Cyan', Color(0xFF06B6D4)),
  violet('Violet', Color(0xFFA78BFA)),
  blue('Blue', Color(0xFF3B82F6));

  const AccentPreset(this.label, this.color);
  final String label;
  final Color color;
}

/// Immutable theme configuration.
class PrismThemeState {
  final AccentPreset preset;
  final ThemeMode mode;
  final bool amoled;

  const PrismThemeState({
    this.preset = AccentPreset.indigo,
    this.mode = ThemeMode.dark,
    this.amoled = false,
  });

  Color get accent => preset.color;

  // ── Dark palette ────────────────────────────────
  Color get bgDeep => amoled ? Colors.black : const Color(0xFF060610);
  Color get bgBase => amoled ? const Color(0xFF050505) : const Color(0xFF0C0C16);
  Color get surface => amoled ? const Color(0xFF0A0A0A) : const Color(0xFF16162A);
  Color get border => amoled ? const Color(0xFF1A1A1A) : const Color(0xFF252540);

  static const textPrimary = Color(0xFFE2E2EC);
  static const textSecondary = Color(0xFF7A7A90);

  // ── Themed ThemeData ────────────────────────────
  ThemeData get darkTheme {
    final darkTokens = MoonTokens.dark.copyWith(
      colors: MoonColors.dark.copyWith(
        piccolo: accent,
        hit: const Color(0xFF34D399),
        goku: bgDeep,
        gohan: bgBase,
        goten: surface,
        beerus: border,
        bulma: textPrimary,
        trunks: textSecondary,
        popo: textPrimary,
        jiren: accent.withValues(alpha: 0.12),
        heles: const Color(0x0AFFFFFF),
        textPrimary: textPrimary,
        textSecondary: textSecondary,
        iconPrimary: textPrimary,
        iconSecondary: textSecondary,
      ),
    );

    final scheme = ColorScheme.dark(
      primary: accent,
      onPrimary: Colors.white,
      surface: surface,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      outline: border,
      outlineVariant: border,
    );

    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: bgBase,
      colorScheme: scheme,
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
          return const TextStyle(color: textSecondary, fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return IconThemeData(color: accent);
          return const IconThemeData(color: textSecondary);
        }),
      ),
      extensions: <ThemeExtension>[MoonTheme(tokens: darkTokens)],
    );
  }

  ThemeData get lightTheme {
    final lightTokens = MoonTokens.light.copyWith(
      colors: MoonColors.light.copyWith(piccolo: accent),
    );
    return ThemeData.light().copyWith(
      extensions: <ThemeExtension>[MoonTheme(tokens: lightTokens)],
    );
  }

  PrismThemeState copyWith({AccentPreset? preset, ThemeMode? mode, bool? amoled}) {
    return PrismThemeState(
      preset: preset ?? this.preset,
      mode: mode ?? this.mode,
      amoled: amoled ?? this.amoled,
    );
  }
}

/// Riverpod provider for theme state.
class PrismThemeNotifier extends Notifier<PrismThemeState> {
  @override
  PrismThemeState build() => const PrismThemeState();

  void setPreset(AccentPreset preset) => state = state.copyWith(preset: preset);
  void setMode(ThemeMode mode) => state = state.copyWith(mode: mode);
  void toggleAmoled() => state = state.copyWith(amoled: !state.amoled);
}

final prismThemeProvider = NotifierProvider<PrismThemeNotifier, PrismThemeState>(
  PrismThemeNotifier.new,
);
