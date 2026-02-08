# Scratchpad

> Quick notes, code snippets, experiments, and scratch work.

---

## Soul Orb Animation Concept

The orb is an animated floating circle with:
- Irregular edges (noise-based displacement on a circle)
- Gentle pulsing animation (scale 0.95 ↔ 1.05)
- Subtle rotation
- Glow effect (blur + opacity)
- Accent color (piccolo) with gradient
- Like how souls/spirits are depicted in art — not a perfect circle

### CustomPainter approach:
```dart
// Use sin/cos with slight offsets per angle to create organic shape
// Add Perlin-like noise displacement
// Animate phase offset for living breathing effect
```

## Daily Digest Sections (around the orb)
- 🌤 Weather (temperature, condition)
- ✅ Tasks (X done, Y pending)
- 💬 Chats (unread count)
- 💰 Finance (daily spend summary)
- 📅 Events (next upcoming)
- 🧠 Brain (recent note)

## Theme Presets
```
1. Midnight (current dark) — piccolo: #818CF8
2. Ocean — piccolo: #06B6D4 (cyan-500)
3. Forest — piccolo: #22C55E (green-500)
4. Sunset — piccolo: #F97316 (orange-500)
5. Rose — piccolo: #F43F5E (rose-500)
6. Pure Dark (AMOLED) — gohan: #000000, goten: #0A0A0A
7. Light — standard light theme
```
