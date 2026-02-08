# Development Approach

> Architecture decisions, patterns, and strategy for the Prism app build.

---

## Current Architecture: ux_preview

### Layer Structure
```
lib/
├── main.dart              # App entry, theme, shell with bottom nav
├── data/                  # Mock data service + models
│   ├── mock_data_service.dart
│   └── models/            # Data classes
├── theme/                 # Theme provider + palettes
│   ├── theme_provider.dart
│   └── palettes.dart
├── screens/               # Feature screens
│   ├── splash_screen.dart
│   ├── home_screen.dart   # Soul orb daily digest
│   ├── chat_screen.dart
│   ├── brain_screen.dart
│   ├── apps_hub_screen.dart
│   ├── settings_screen.dart
│   └── sub_screens/       # Apps Hub children
│       ├── tasks_screen.dart
│       ├── finance_screen.dart
│       ├── files_screen.dart
│       ├── tools_screen.dart
│       └── gateway_screen.dart
└── widgets/               # Reusable widgets
    ├── soul_orb.dart      # Animated floating orb
    ├── daily_card.dart    # Summary card for home
    └── section_header.dart
```

### Mock Data Strategy
- `MockDataService` singleton loads all JSON on first access
- Returns typed `Future<List<T>>` via model classes
- Easy to swap for real backend later (same interface)
- Additional daily summary data: weather, events, quick stats

### Navigation Flow
```
Splash → Home (Soul Orb)
           ↓ tap orb / voice
         Chat ← Brain ← Apps Hub ← Settings
                            ↓
                    Tasks | Finance | Files | Tools | Gateway
```

### Theme System
- `ThemeProvider` (ChangeNotifier) managing:
  - ThemeMode (light / dark / system / amoled)
  - Accent color (piccolo override)
  - Compact mode toggle
  - Animation toggle
- Persisted via SharedPreferences
- Exposed via InheritedWidget or passed through `MaterialApp`

### Voice-First Design
- Home screen defaults to voice input mode
- Microphone button is primary CTA
- Text input available as secondary option
- Future: AI processes voice → understands intent → routes to feature

---

## File Size Rule
Every `.dart` file stays under 600 lines. When approaching:
1. Extract widget methods into separate widget files
2. Move data/logic into service files
3. Split screen into sub-components

---

## Phase Strategy
1. **ux_preview** — UI/UX demo with mock data (current)
2. **initial_version** — Real functionality (Ollama, tools, persistence)
3. **production** — Full app with all providers, encryption, sync
