import 'package:flutter/material.dart';

/// Theme presets with accent colors and palette overrides.
class ThemePreset {
  final String id;
  final String name;
  final String description;
  final Color accent;

  const ThemePreset({
    required this.id,
    required this.name,
    required this.description,
    required this.accent,
  });
}

/// All available theme presets.
const kThemePresets = <ThemePreset>[
  ThemePreset(id: 'midnight', name: 'Midnight', description: 'Cool indigo vibes', accent: Color(0xFF818CF8)),
  ThemePreset(id: 'ocean', name: 'Ocean', description: 'Deep cyan waters', accent: Color(0xFF06B6D4)),
  ThemePreset(id: 'forest', name: 'Forest', description: 'Natural green tones', accent: Color(0xFF22C55E)),
  ThemePreset(id: 'sunset', name: 'Sunset', description: 'Warm orange glow', accent: Color(0xFFF97316)),
  ThemePreset(id: 'rose', name: 'Rose', description: 'Soft pink elegance', accent: Color(0xFFF43F5E)),
  ThemePreset(id: 'lavender', name: 'Lavender', description: 'Gentle purple haze', accent: Color(0xFFA78BFA)),
  ThemePreset(id: 'amber', name: 'Amber', description: 'Golden warmth', accent: Color(0xFFF59E0B)),
];

/// Manages theme state: mode, accent, AMOLED, font scale, etc.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.dark;
  String _presetId = 'midnight';
  bool _amoled = false;
  bool _animations = true;
  bool _compactMode = false;
  double _fontScale = 1.0;

  ThemeMode get mode => _mode;
  String get presetId => _presetId;
  bool get amoled => _amoled;
  bool get animations => _animations;
  bool get compactMode => _compactMode;
  double get fontScale => _fontScale;

  ThemePreset get preset =>
      kThemePresets.firstWhere((p) => p.id == _presetId, orElse: () => kThemePresets.first);

  Color get accent => preset.accent;

  // ── Dark palette (computed from accent + amoled) ─────────────
  Color get bgDeep => _amoled ? const Color(0xFF000000) : const Color(0xFF060610);
  Color get bgBase => _amoled ? const Color(0xFF050505) : const Color(0xFF0C0C16);
  Color get surface => _amoled ? const Color(0xFF0A0A0A) : const Color(0xFF16162A);
  Color get border => _amoled ? const Color(0xFF1A1A1A) : const Color(0xFF252540);

  static const textPrimary = Color(0xFFE2E2EC);
  static const textSecondary = Color(0xFF7A7A90);

  void setMode(ThemeMode mode) {
    _mode = mode;
    notifyListeners();
  }

  void setPreset(String id) {
    _presetId = id;
    notifyListeners();
  }

  void setAmoled(bool v) {
    _amoled = v;
    notifyListeners();
  }

  void setAnimations(bool v) {
    _animations = v;
    notifyListeners();
  }

  void setCompactMode(bool v) {
    _compactMode = v;
    notifyListeners();
  }

  void setFontScale(double v) {
    _fontScale = v;
    notifyListeners();
  }
}
